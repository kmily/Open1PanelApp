import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:onepanelapp_app/core/services/logger/logger_service.dart';
import 'package:onepanelapp_app/core/services/transfer/transfer_task.dart';
import 'package:onepanelapp_app/core/services/file_save_service.dart';
import 'package:onepanelapp_app/api/v2/file_v2.dart';
import 'package:onepanelapp_app/data/models/file/file_transfer.dart';

class TransferManager extends ChangeNotifier {
  static final TransferManager _instance = TransferManager._internal();
  factory TransferManager() => _instance;
  
  TransferManager._internal();
  
  final Queue<TransferTask> _pendingQueue = Queue();
  final Map<String, TransferTask> _activeTasks = {};
  final Map<String, TransferTask> _completedTasks = {};
  
  static const int _maxConcurrent = 3;
  static const int _defaultChunkSize = 1024 * 1024;
  static const String _tasksBoxName = 'transfer_tasks';
  
  FileV2Api? _api;
  Box? _tasksBox;
  final FileSaveService _fileSaveService = FileSaveService();
  
  Function(TransferTask task)? onTaskCompleted;
  Function(TransferTask task)? onTaskFailed;
  
  List<TransferTask> get pendingTasks => _pendingQueue.toList();
  List<TransferTask> get activeTasks => _activeTasks.values.toList();
  List<TransferTask> get completedTasks => _completedTasks.values.toList();
  List<TransferTask> get allTasks => [...activeTasks, ...pendingTasks, ...completedTasks];
  
  int get activeCount => _activeTasks.length;
  int get pendingCount => _pendingQueue.length;
  int get completedCount => _completedTasks.length;
  
  void setApi(FileV2Api api) {
    _api = api;
  }
  
  Future<void> init() async {
    if (Hive.isBoxOpen(_tasksBoxName)) {
      _tasksBox = Hive.box(_tasksBoxName);
    } else {
      _tasksBox = await Hive.openBox(_tasksBoxName);
    }
  }
  
  Future<void> _saveTask(TransferTask task) async {
    try {
      if (_tasksBox != null) {
        await _tasksBox!.put(task.id, task.toJson());
      }
    } catch (e) {
      appLogger.wWithPackage('transfer', '_saveTask: 保存任务失败: $e');
    }
  }
  
  Future<void> _deleteTask(String taskId) async {
    try {
      if (_tasksBox != null) {
        await _tasksBox!.delete(taskId);
      }
    } catch (e) {
      appLogger.wWithPackage('transfer', '_deleteTask: 删除任务失败: $e');
    }
  }
  
  Future<void> restoreTasks() async {
    try {
      if (_tasksBox == null) {
        await init();
      }
      
      if (_tasksBox == null || _tasksBox!.isEmpty) return;
      
      final restorableStatuses = [
        TransferStatus.pending,
        TransferStatus.running,
        TransferStatus.paused,
      ];
      
      for (final key in _tasksBox!.keys) {
        final data = _tasksBox!.get(key);
        if (data == null) continue;
        
        try {
          final task = TransferTask.fromJson(Map<String, dynamic>.from(data));
          
          if (restorableStatuses.contains(task.status)) {
            final restoredTask = task.copyWith(status: TransferStatus.pending);
            _pendingQueue.add(restoredTask);
            appLogger.iWithPackage('transfer', 'restoreTasks: 恢复任务 ${task.id} 到待处理队列');
          }
        } catch (e) {
          appLogger.wWithPackage('transfer', 'restoreTasks: 解析任务失败: $e');
        }
      }
      
      notifyListeners();
      _processQueue();
    } catch (e, stackTrace) {
      appLogger.eWithPackage('transfer', 'restoreTasks: 恢复任务失败', error: e, stackTrace: stackTrace);
    }
  }
  
  Future<String> _generateTaskId(String path, TransferType type) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = md5.convert(utf8.encode('$path$type$timestamp')).toString();
    return hash.substring(0, 8);
  }
  
  Future<TransferTask> createUploadTask({
    required String path,
    required File file,
    String? fileName,
  }) async {
    final stat = await file.stat();
    final totalSize = stat.size;
    final totalChunks = (totalSize / _defaultChunkSize).ceil();
    
    final task = TransferTask(
      id: await _generateTaskId(path, TransferType.upload),
      path: path,
      fileName: fileName ?? file.path.split('/').last,
      totalSize: totalSize,
      type: TransferType.upload,
      totalChunks: totalChunks,
      createdAt: DateTime.now(),
    );
    
    await _loadProgress(task);
    
    _pendingQueue.add(task);
    await _saveTask(task);
    notifyListeners();
    _processQueue();
    
    return task;
  }
  
  Future<TransferTask> createDownloadTask({
    required String path,
    required int totalSize,
    String? fileName,
  }) async {
    final totalChunks = (totalSize / _defaultChunkSize).ceil();
    
    final task = TransferTask(
      id: await _generateTaskId(path, TransferType.download),
      path: path,
      fileName: fileName ?? path.split('/').last,
      totalSize: totalSize,
      type: TransferType.download,
      totalChunks: totalChunks,
      createdAt: DateTime.now(),
    );
    
    await _loadProgress(task);
    
    _pendingQueue.add(task);
    await _saveTask(task);
    notifyListeners();
    _processQueue();
    
    return task;
  }
  
  Future<void> _loadProgress(TransferTask task) async {
    try {
      final progressFile = await _getProgressFile(task.id);
      if (await progressFile.exists()) {
        final content = await progressFile.readAsString();
        final data = jsonDecode(content) as Map<String, dynamic>;
        final uploadedChunks = Set<int>.from(data['uploadedChunks'] as List);
        
        task = task.copyWith(
          uploadedChunks: uploadedChunks,
          completedChunks: uploadedChunks.length,
          transferredSize: uploadedChunks.length * _defaultChunkSize,
        );
      }
    } catch (e) {
      appLogger.wWithPackage('transfer', '_loadProgress: 加载进度失败: $e');
    }
  }
  
  Future<File> _getProgressFile(String taskId) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/transfer_progress_$taskId.json');
  }
  
  Future<void> _saveProgress(TransferTask task) async {
    try {
      final progressFile = await _getProgressFile(task.id);
      final data = {
        'id': task.id,
        'path': task.path,
        'uploadedChunks': task.uploadedChunks.toList(),
        'completedChunks': task.completedChunks,
        'transferredSize': task.transferredSize,
      };
      await progressFile.writeAsString(jsonEncode(data));
    } catch (e) {
      appLogger.wWithPackage('transfer', '_saveProgress: 保存进度失败: $e');
    }
  }
  
  void _processQueue() {
    while (_activeTasks.length < _maxConcurrent && _pendingQueue.isNotEmpty) {
      final task = _pendingQueue.removeFirst();
      _startTask(task);
    }
  }
  
  Future<void> _startTask(TransferTask task) async {
    task = task.copyWith(
      status: TransferStatus.running,
      startedAt: DateTime.now(),
    );
    _activeTasks[task.id] = task;
    await _saveTask(task);
    notifyListeners();
    
    try {
      if (task.type == TransferType.upload) {
        await _executeUpload(task);
      } else {
        await _executeDownload(task);
      }
      
      task = task.copyWith(
        status: TransferStatus.completed,
        completedAt: DateTime.now(),
      );
      _activeTasks.remove(task.id);
      _completedTasks[task.id] = task;
      
      final progressFile = await _getProgressFile(task.id);
      if (await progressFile.exists()) {
        await progressFile.delete();
      }
      
      await _deleteTask(task.id);
      
      onTaskCompleted?.call(task);
    } catch (e, stackTrace) {
      appLogger.eWithPackage('transfer', '_startTask: 传输失败', error: e, stackTrace: stackTrace);
      task = task.copyWith(
        status: TransferStatus.failed,
        error: e.toString(),
      );
      _activeTasks.remove(task.id);
      _completedTasks[task.id] = task;
      await _saveTask(task);
      onTaskFailed?.call(task);
    }
    
    notifyListeners();
    _processQueue();
  }
  
  Future<void> _executeUpload(TransferTask task) async {
    if (_api == null) throw Exception('API not initialized');
    
    final file = File(task.path);
    if (!await file.exists()) throw Exception('File not found: ${task.path}');
    
    final totalChunks = task.totalChunks;
    final uploadedChunks = Set<int>.from(task.uploadedChunks);
    
    for (var i = 0; i < totalChunks; i++) {
      if (uploadedChunks.contains(i)) continue;
      
      final activeTask = _activeTasks[task.id];
      if (activeTask?.status == TransferStatus.paused ||
          activeTask?.status == TransferStatus.cancelled) {
        throw Exception('Transfer ${activeTask?.status}');
      }
      
      final start = i * _defaultChunkSize;
      final end = (start + _defaultChunkSize > task.totalSize)
          ? task.totalSize
          : start + _defaultChunkSize;
      
      final randomAccessFile = await file.open();
      await randomAccessFile.setPosition(start);
      final bytes = await randomAccessFile.read(end - start);
      await randomAccessFile.close();
      
      final base64Data = base64Encode(bytes);
      final isLastChunk = i == totalChunks - 1;
      
      final response = await _api!.chunkUpload(FileChunkUpload(
        path: task.path,
        data: base64Data,
        chunkNumber: i + 1,
        isLastChunk: isLastChunk,
      ));
      
      if (response.data?.success == true) {
        uploadedChunks.add(i);
        final transferredSize = uploadedChunks.length * _defaultChunkSize;
        
        task = task.copyWith(
          uploadedChunks: uploadedChunks,
          completedChunks: uploadedChunks.length,
          transferredSize: transferredSize > task.totalSize
              ? task.totalSize
              : transferredSize,
        );
        _activeTasks[task.id] = task;
        await _saveProgress(task);
        notifyListeners();
      }
    }
  }
  
  Future<void> _executeDownload(TransferTask task) async {
    if (_api == null) throw Exception('API not initialized');
    
    final totalChunks = task.totalChunks;
    final downloadedChunks = Set<int>.from(task.uploadedChunks);
    final chunks = <int, Uint8List>{};
    
    for (var i = 0; i < totalChunks; i++) {
      if (downloadedChunks.contains(i)) continue;
      
      final activeTask = _activeTasks[task.id];
      if (activeTask?.status == TransferStatus.paused ||
          activeTask?.status == TransferStatus.cancelled) {
        throw Exception('Transfer ${activeTask?.status}');
      }
      
      final response = await _api!.chunkDownload(FileChunkDownload(
        path: task.path,
        chunkSize: _defaultChunkSize,
        chunkNumber: i + 1,
      ));
      
      if (response.data?.data != null) {
        final bytes = base64Decode(response.data!.data!);
        chunks[i] = bytes;
        downloadedChunks.add(i);
        
        final transferredSize = downloadedChunks.length * _defaultChunkSize;
        
        task = task.copyWith(
          uploadedChunks: downloadedChunks,
          completedChunks: downloadedChunks.length,
          transferredSize: transferredSize > task.totalSize
              ? task.totalSize
              : transferredSize,
        );
        _activeTasks[task.id] = task;
        await _saveProgress(task);
        await _saveTask(task);
        notifyListeners();
      }
      
      if (response.data?.isLastChunk == true) break;
    }
    
    final bytesBuilder = BytesBuilder();
    for (var i = 0; i < totalChunks; i++) {
      if (chunks.containsKey(i)) {
        bytesBuilder.add(chunks[i]!);
      }
    }
    final fileBytes = bytesBuilder.takeBytes();
    
    final saveResult = await _fileSaveService.saveFile(
      fileName: task.fileName ?? 'download_file',
      bytes: fileBytes,
    );
    
    if (saveResult.success && saveResult.filePath != null) {
      task = task.copyWith(localPath: saveResult.filePath);
      _activeTasks[task.id] = task;
      appLogger.iWithPackage('transfer', '_executeDownload: 文件已保存到 ${saveResult.filePath}');
    } else {
      appLogger.wWithPackage('transfer', '_executeDownload: 保存文件失败: ${saveResult.errorMessage}');
    }
  }
  
  void pauseTask(String taskId) {
    final task = _activeTasks[taskId];
    if (task != null) {
      final pausedTask = task.copyWith(status: TransferStatus.paused);
      _activeTasks[taskId] = pausedTask;
      _saveTask(pausedTask);
      notifyListeners();
    }
  }
  
  void resumeTask(String taskId) {
    TransferTask? task = _activeTasks[taskId] ?? _completedTasks[taskId];
    if (task != null && task.isResumable) {
      _activeTasks.remove(taskId);
      _completedTasks.remove(taskId);
      
      final resumedTask = task.copyWith(status: TransferStatus.pending);
      _pendingQueue.add(resumedTask);
      _saveTask(resumedTask);
      notifyListeners();
      _processQueue();
    }
  }
  
  void cancelTask(String taskId) {
    TransferTask? task = _activeTasks[taskId];
    task ??= _pendingQueue.firstWhere(
      (t) => t.id == taskId,
      orElse: () => throw Exception('Task not found'),
    );
    
    _activeTasks.remove(taskId);
    _pendingQueue.removeWhere((t) => t.id == taskId);
    
    final cancelledTask = task.copyWith(
      status: TransferStatus.cancelled,
      completedAt: DateTime.now(),
    );
    _completedTasks[taskId] = cancelledTask;
    _deleteTask(taskId);
    notifyListeners();
    _processQueue();
  }
  
  void clearCompleted() {
    _completedTasks.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _pendingQueue.clear();
    _activeTasks.clear();
    _completedTasks.clear();
    super.dispose();
  }
}
