import 'package:flutter/foundation.dart';
import 'files_service.dart';
import '../../data/models/file_models.dart';
import '../../core/config/api_config.dart';
import '../../core/network/api_client_manager.dart';

class FilesData {
  final List<FileInfo> files;
  final String currentPath;
  final List<String> pathHistory;
  final bool isLoading;
  final String? error;
  final Set<String> selectedFiles;
  final String? sortBy;
  final String? sortOrder;
  final String? searchQuery;
  final ApiConfig? currentServer;
  final List<FileMountInfo>? mountInfo;
  final FileRecycleStatus? recycleBinStatus;

  const FilesData({
    this.files = const [],
    this.currentPath = '/',
    this.pathHistory = const ['/'],
    this.isLoading = false,
    this.error,
    this.selectedFiles = const {},
    this.sortBy,
    this.sortOrder,
    this.searchQuery,
    this.currentServer,
    this.mountInfo,
    this.recycleBinStatus,
  });

  FilesData copyWith({
    List<FileInfo>? files,
    String? currentPath,
    List<String>? pathHistory,
    bool? isLoading,
    String? error,
    Set<String>? selectedFiles,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
    ApiConfig? currentServer,
    List<FileMountInfo>? mountInfo,
    FileRecycleStatus? recycleBinStatus,
  }) {
    return FilesData(
      files: files ?? this.files,
      currentPath: currentPath ?? this.currentPath,
      pathHistory: pathHistory ?? this.pathHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
      currentServer: currentServer ?? this.currentServer,
      mountInfo: mountInfo ?? this.mountInfo,
      recycleBinStatus: recycleBinStatus ?? this.recycleBinStatus,
    );
  }

  bool get hasSelection => selectedFiles.isNotEmpty;
  int get selectionCount => selectedFiles.length;
  bool isSelected(String path) => selectedFiles.contains(path);
  bool get isSearching => searchQuery != null && searchQuery!.isNotEmpty;
  bool get hasServer => currentServer != null;
}

class FilesProvider extends ChangeNotifier {
  final FilesService _service = FilesService();
  FilesData _data = const FilesData();

  FilesData get data => _data;

  List<String> _pathSegments(String path) {
    return path.split('/').where((segment) => segment.isNotEmpty).toList();
  }

  String _normalizePath(String path) {
    final segments = _pathSegments(path);
    if (segments.isEmpty) return '/';
    return '/${segments.join('/')}';
  }

  Future<void> loadServer() async {
    final server = await _service.getCurrentServer();
    _data = _data.copyWith(currentServer: server);
    notifyListeners();
  }

  Future<void> loadFiles({String? path}) async {
    final targetPath = _normalizePath(path ?? _data.currentPath);
    _data = _data.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final files = await _service.getFiles(
        path: targetPath,
        search: _data.searchQuery,
      );
      
      _data = _data.copyWith(
        files: files,
        currentPath: targetPath,
        isLoading: false,
        selectedFiles: {},
      );
      
      if (path != null && !_data.pathHistory.contains(targetPath)) {
        _data = _data.copyWith(
          pathHistory: [..._data.pathHistory, targetPath],
        );
      }
    } catch (e) {
      _data = _data.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> loadMountInfo() async {
    try {
      final mounts = await _service.getMountInfo();
      _data = _data.copyWith(mountInfo: mounts);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load mount info: $e');
    }
  }

  Future<void> loadRecycleBinStatus() async {
    try {
      final api = await ApiClientManager.instance.getFileApi();
      final response = await api.getRecycleBinStatus();
      _data = _data.copyWith(recycleBinStatus: response.data);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load recycle bin status: $e');
    }
  }

  void onServerChanged() {
    _service.clearCache();
    _data = const FilesData();
    notifyListeners();
    loadServer().then((_) => loadFiles());
  }

  Future<void> navigateTo(String path) async {
    await loadFiles(path: _normalizePath(path));
  }

  Future<void> navigateUp() async {
    if (_data.currentPath == '/') return;

    final segments = _pathSegments(_data.currentPath);
    if (segments.isEmpty) {
      await loadFiles(path: '/');
      return;
    }
    segments.removeLast();
    final parentPath = segments.isEmpty ? '/' : '/${segments.join('/')}';
    await loadFiles(path: parentPath);
  }

  Future<void> refresh() async {
    await loadFiles();
  }

  void setSearchQuery(String? query) {
    _data = _data.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setSorting(String? sortBy, String? sortOrder) {
    _data = _data.copyWith(sortBy: sortBy, sortOrder: sortOrder);
    notifyListeners();
    loadFiles();
  }

  void toggleSelection(String path) {
    final newSelection = Set<String>.from(_data.selectedFiles);
    if (newSelection.contains(path)) {
      newSelection.remove(path);
    } else {
      newSelection.add(path);
    }
    _data = _data.copyWith(selectedFiles: newSelection);
    notifyListeners();
  }

  void selectAll() {
    final allPaths = _data.files.map((f) => f.path).toSet();
    _data = _data.copyWith(selectedFiles: allPaths);
    notifyListeners();
  }

  void clearSelection() {
    _data = _data.copyWith(selectedFiles: {});
    notifyListeners();
  }

  Future<void> createDirectory(String name) async {
    final newPath = _data.currentPath == '/'
        ? '/$name'
        : '${_data.currentPath}/$name';
    await _service.createDirectory(newPath);
    await refresh();
  }

  Future<void> createFile(String name, {String? content}) async {
    final newPath = _data.currentPath == '/'
        ? '/$name'
        : '${_data.currentPath}/$name';
    await _service.createFile(newPath, content: content);
    await refresh();
  }

  Future<void> deleteSelected() async {
    if (_data.selectedFiles.isEmpty) return;
    await _service.deleteFiles(_data.selectedFiles.toList());
    await refresh();
  }

  Future<void> deleteFile(String path) async {
    await _service.deleteFiles([path]);
    await refresh();
  }

  Future<void> renameFile(String oldPath, String newName) async {
    final parentPath = oldPath.substring(0, oldPath.lastIndexOf('/'));
    final newPath = parentPath.isEmpty ? '/$newName' : '$parentPath/$newName';
    await _service.renameFile(oldPath, newPath);
    await refresh();
  }

  Future<void> moveSelected(String targetPath) async {
    if (_data.selectedFiles.isEmpty) return;
    await _service.moveFiles(_data.selectedFiles.toList(), targetPath);
    clearSelection();
    await refresh();
  }

  Future<void> moveFile(String sourcePath, String targetPath) async {
    await _service.moveFiles([sourcePath], targetPath);
    await refresh();
  }

  Future<String> getFileContent(String path) async {
    return await _service.getFileContent(path);
  }

  Future<void> saveFileContent(String path, String content) async {
    await _service.updateFileContent(path, content);
  }

  Future<void> compressSelected(String targetPath, String type, {String? password}) async {
    if (_data.selectedFiles.isEmpty) return;
    await _service.compressFiles(
      paths: _data.selectedFiles.toList(),
      targetPath: targetPath,
      type: type,
      password: password,
    );
    clearSelection();
    await refresh();
  }

  Future<void> compressFiles(List<String> paths, String targetPath, String type, {String? password}) async {
    await _service.compressFiles(
      paths: paths,
      targetPath: targetPath,
      type: type,
      password: password,
    );
    await refresh();
  }

  Future<void> extractFile(String path, String targetPath, {String? password}) async {
    await _service.extractFile(path: path, targetPath: targetPath, password: password);
    await refresh();
  }

  Future<FileSizeInfo> getFileSize(String path) async {
    return await _service.getFileSize(path, recursive: true);
  }

  Future<void> toggleFavorite(String path) async {
    final isFavorite = _data.files.firstWhere((f) => f.path == path).isDir;
    if (isFavorite) {
      await _service.unfavoriteFile(path);
    } else {
      await _service.favoriteFile(path);
    }
    await refresh();
  }
}
