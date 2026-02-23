import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../api/v2/file_v2.dart';
import '../../data/models/file_models.dart';
import '../../core/network/api_client_manager.dart';
import '../../core/config/api_config.dart';
import '../../core/config/api_constants.dart';
import '../../core/services/logger/logger_service.dart';

class FilesService {
  FileV2Api? _api;
  String? _currentServerId;
  String? _currentApiKey;

  Future<FileV2Api> _getApi() async {
    appLogger.dWithPackage('files', '_getApi: 开始获取API客户端');
    final config = await ApiConfigManager.getCurrentConfig();
    if (config == null) {
      appLogger.eWithPackage('files', '_getApi: 没有配置服务器');
      throw StateError('No server configured');
    }
    
    if (_api == null || _currentServerId != config.id || _currentApiKey != config.apiKey) {
      appLogger.dWithPackage('files', '_getApi: 创建新的API客户端, serverId=${config.id}');
      final client = await ApiClientManager.instance.getCurrentClient();
      _api = FileV2Api(client);
      _currentServerId = config.id;
      _currentApiKey = config.apiKey;
    }
    return _api!;
  }

  void clearCache() {
    appLogger.dWithPackage('files', 'clearCache: 清除API缓存');
    _api = null;
    _currentServerId = null;
    _currentApiKey = null;
  }

  Future<ApiConfig?> getCurrentServer() async {
    return await ApiConfigManager.getCurrentConfig();
  }

  Future<FileSearchResponse> searchFiles({
    required String path,
    String? search,
    int page = 1,
    int pageSize = 100,
    bool? expand,
    String? sortBy,
    String? sortOrder,
  }) async {
    appLogger.dWithPackage('files', 'searchFiles: path=$path, search=$search, page=$page');
    final api = await _getApi();
    final response = await api.searchFiles(FileSearch(
      path: path,
      search: search,
      page: page,
      pageSize: pageSize,
      expand: expand,
      sortBy: sortBy,
      sortOrder: sortOrder,
    ));
    appLogger.iWithPackage('files', 'searchFiles: 成功, 文件数=${response.data?.items.length ?? 0}');
    return response.data!;
  }

  Future<List<FileInfo>> getFiles({
    required String path,
    String? search,
    int page = 1,
    int pageSize = 100,
    bool expand = true,
    String? sortBy,
    String? sortOrder,
    bool? showHidden,
  }) async {
    appLogger.dWithPackage('files', 'getFiles: path=$path, search=$search, page=$page, pageSize=$pageSize');
    final api = await _getApi();
    final response = await api.getFiles(FileSearch(
      path: path,
      search: search,
      page: page,
      pageSize: pageSize,
      expand: expand,
      sortBy: sortBy,
      sortOrder: sortOrder,
      showHidden: showHidden,
    ));
    final files = response.data ?? [];
    appLogger.iWithPackage('files', 'getFiles: 成功, 返回${files.length}个文件');
    return files;
  }

  Future<void> createDirectory(String path) async {
    appLogger.dWithPackage('files', 'createDirectory: path=$path');
    final api = await _getApi();
    await api.createDirectory(FileCreate(path: path, isDir: true));
    appLogger.iWithPackage('files', 'createDirectory: 成功创建文件夹 $path');
  }

  Future<void> createFile(String path, {String? content}) async {
    appLogger.dWithPackage('files', 'createFile: path=$path, hasContent=${content != null}');
    final api = await _getApi();
    await api.createFile(FileCreate(path: path, content: content, isDir: false));
    appLogger.iWithPackage('files', 'createFile: 成功创建文件 $path');
  }

  Future<void> deleteFiles(List<String> paths, {bool? force, bool? isDir}) async {
    appLogger.dWithPackage('files', 'deleteFiles: paths=$paths, force=$force, isDir=$isDir');
    final api = await _getApi();
    if (paths.length == 1) {
      await api.deleteFile(FileDelete(path: paths.first, isDir: isDir, forceDelete: force));
    } else {
      await api.deleteFiles(FileBatchDelete(paths: paths, isDir: isDir));
    }
    appLogger.iWithPackage('files', 'deleteFiles: 成功删除 ${paths.length} 个文件');
  }

  Future<void> renameFile(String oldPath, String newPath) async {
    appLogger.dWithPackage('files', 'renameFile: oldPath=$oldPath, newPath=$newPath');
    final api = await _getApi();
    await api.renameFile(FileRename(oldPath: oldPath, newPath: newPath));
    appLogger.iWithPackage('files', 'renameFile: 成功重命名 $oldPath -> $newPath');
  }

  Future<void> moveFiles(List<String> paths, String targetPath) async {
    appLogger.dWithPackage('files', 'moveFiles: paths=$paths, targetPath=$targetPath');
    final api = await _getApi();
    await api.moveFiles(FileMove(paths: paths, targetPath: targetPath, type: 'cut'));
    appLogger.iWithPackage('files', 'moveFiles: 成功移动 ${paths.length} 个文件到 $targetPath');
  }

  Future<void> copyFiles(List<String> paths, String targetPath, {String? newName}) async {
    appLogger.dWithPackage('files', 'copyFiles: paths=$paths, targetPath=$targetPath, newName=$newName');
    final api = await _getApi();
    
    for (final sourcePath in paths) {
      final sourceDir = sourcePath.substring(0, sourcePath.lastIndexOf('/'));
      final sourceName = sourcePath.substring(sourcePath.lastIndexOf('/') + 1);
      
      String? name = newName;
      
      if (sourceDir == targetPath && name == null) {
        name = _generateCopyName(sourceName);
        appLogger.iWithPackage('files', 'copyFiles: 源目录与目标目录相同，自动重命名为 $name');
      }
      
      await api.moveFiles(FileMove(
        paths: [sourcePath],
        targetPath: targetPath,
        type: 'copy',
        name: name,
      ));
    }
    
    appLogger.iWithPackage('files', 'copyFiles: 成功复制 ${paths.length} 个文件到 $targetPath');
  }

  String _generateCopyName(String originalName) {
    final lastDot = originalName.lastIndexOf('.');
    String baseName;
    String extension = '';
    
    if (lastDot > 0) {
      baseName = originalName.substring(0, lastDot);
      extension = originalName.substring(lastDot);
    } else {
      baseName = originalName;
    }
    
    int counter = 1;
    while (true) {
      final newName = '$baseName ($counter)$extension';
      return newName;
    }
  }

  Future<String> getFileContent(String path) async {
    appLogger.dWithPackage('files', 'getFileContent: path=$path');
    final api = await _getApi();
    final response = await api.getFileContent(path);
    appLogger.iWithPackage('files', 'getFileContent: 成功获取文件内容, 长度=${response.data?.length ?? 0}');
    return response.data ?? '';
  }

  Future<void> updateFileContent(String path, String content) async {
    appLogger.dWithPackage('files', 'updateFileContent: path=$path, contentLength=${content.length}');
    final api = await _getApi();
    await api.updateFileContent(FileContent(path: path, content: content));
    appLogger.iWithPackage('files', 'updateFileContent: 成功更新文件内容');
  }

  Future<void> compressFiles({
    required List<String> files,
    required String dst,
    required String name,
    required String type,
    String? secret,
  }) async {
    appLogger.dWithPackage('files', 'compressFiles: files=$files, dst=$dst, name=$name, type=$type, hasSecret=${secret != null}');
    final api = await _getApi();
    await api.compressFiles(FileCompress(
      files: files,
      dst: dst,
      name: name,
      type: type,
      secret: secret,
    ));
    appLogger.iWithPackage('files', 'compressFiles: 成功压缩到 $dst/$name');
  }

  Future<void> extractFile({
    required String path,
    required String dst,
    required String type,
    String? secret,
  }) async {
    appLogger.dWithPackage('files', 'extractFile: path=$path, dst=$dst, type=$type, hasSecret=${secret != null}');
    final api = await _getApi();
    await api.extractFile(FileExtract(
      path: path,
      dst: dst,
      type: type,
      secret: secret,
    ));
    appLogger.iWithPackage('files', 'extractFile: 成功解压到 $dst');
  }

  Future<void> changeFileMode(String path, int mode, {bool? sub}) async {
    appLogger.dWithPackage('files', 'changeFileMode: path=$path, mode=$mode, sub=$sub');
    final api = await _getApi();
    await api.updateFileMode(FileModeChange(
      path: path,
      mode: mode,
      sub: sub,
    ));
  }

  Future<void> changeFileOwner(String path, String user, String group, {bool? sub}) async {
    appLogger.dWithPackage('files', 'changeFileOwner: path=$path, user=$user, group=$group, sub=$sub');
    final api = await _getApi();
    await api.updateFileOwner(FileOwnerChange(
      path: path,
      user: user,
      group: group,
      sub: sub,
    ));
  }

  Future<void> batchChangeFileRole({
    required List<String> paths,
    int? mode,
    String? user,
    String? group,
    bool? sub,
  }) async {
    appLogger.dWithPackage('files', 'batchChangeFileRole: paths=$paths, mode=$mode, user=$user, group=$group');
    final api = await _getApi();
    await api.batchChangeFileRole(FileBatchRoleRequest(
      paths: paths,
      mode: mode,
      user: user,
      group: group,
      sub: sub,
    ));
    appLogger.iWithPackage('files', 'batchChangeFileRole: 成功修改角色');
  }

  Future<FileCheckResult> checkFile(String path) async {
    appLogger.dWithPackage('files', 'checkFile: path=$path');
    final api = await _getApi();
    final response = await api.checkFile(FileCheck(path: path));
    return response.data!;
  }

  Future<FileTree> getFileTree({
    required String path,
    int? maxDepth,
    bool? includeFiles,
    bool? includeHidden,
  }) async {
    appLogger.dWithPackage('files', 'getFileTree: path=$path, maxDepth=$maxDepth');
    final api = await _getApi();
    final response = await api.getFileTree(FileTreeRequest(
      path: path,
      maxDepth: maxDepth,
      includeFiles: includeFiles,
      includeHidden: includeHidden,
    ));
    return response.data!;
  }

  Future<FileSizeInfo> getFileSize(String path, {bool? recursive}) async {
    appLogger.dWithPackage('files', 'getFileSize: path=$path, recursive=$recursive');
    final api = await _getApi();
    final response = await api.getFileSize(FileSizeRequest(
      path: path,
      recursive: recursive,
    ));
    return response.data!;
  }

  Future<void> favoriteFile(String path, {String? name, String? description}) async {
    appLogger.dWithPackage('files', 'favoriteFile: path=$path');
    final api = await _getApi();
    await api.favoriteFile(FileFavorite(path: path, name: name, description: description));
  }

  Future<void> unfavoriteFile(String path) async {
    appLogger.dWithPackage('files', 'unfavoriteFile: path=$path');
    final api = await _getApi();
    await api.unfavoriteFile(FileUnfavorite(path: path));
  }

  Future<List<FileInfo>> searchFavoriteFiles({
    required String path,
    int page = 1,
    int pageSize = 100,
  }) async {
    appLogger.dWithPackage('files', 'searchFavoriteFiles: path=$path');
    final api = await _getApi();
    final response = await api.searchFavoriteFiles(FileSearch(
      path: path,
      page: page,
      pageSize: pageSize,
    ));
    return response.data!;
  }

  Future<String> getRecycleBinStatus() async {
    appLogger.dWithPackage('files', 'getRecycleBinStatus');
    final api = await _getApi();
    final response = await api.getRecycleBinStatus();
    return response.data!.fileCount.toString();
  }

  Future<List<FileInfo>> searchRecycleBin({
    required String path,
    int page = 1,
    int pageSize = 100,
  }) async {
    appLogger.dWithPackage('files', 'searchRecycleBin: path=$path');
    final api = await _getApi();
    final response = await api.searchRecycleBin(FileSearch(
      path: path,
      page: page,
      pageSize: pageSize,
    ));
    return response.data!;
  }

  Future<void> clearRecycleBin() async {
    appLogger.dWithPackage('files', 'clearRecycleBin');
    final api = await _getApi();
    await api.clearRecycleBin();
  }

  Future<void> restoreFile(RecycleBinReduceRequest request) async {
    appLogger.dWithPackage('files', 'restoreFile: rName=${request.rName}, from=${request.from}');
    final api = await _getApi();
    await api.restoreRecycleBinFile(request);
    appLogger.iWithPackage('files', 'restoreFile: 成功恢复文件 ${request.name}');
  }

  Future<void> restoreFiles(List<RecycleBinReduceRequest> requests) async {
    appLogger.dWithPackage('files', 'restoreFiles: 恢复${requests.length}个文件');
    final api = await _getApi();
    for (final request in requests) {
      await api.restoreRecycleBinFile(request);
    }
    appLogger.iWithPackage('files', 'restoreFiles: 成功恢复${requests.length}个文件');
  }

  Future<void> deleteRecycleBinFiles(List<RecycleBinItem> files) async {
    appLogger.dWithPackage('files', 'deleteRecycleBinFiles: 删除${files.length}个回收站文件');
    final api = await _getApi();
    for (final file in files) {
      final recyclePath = '${file.from}/${file.rName}';
      appLogger.dWithPackage('files', 'deleteRecycleBinFiles: 删除路径=$recyclePath');
      await api.deleteFile(FileDelete(path: recyclePath, forceDelete: true));
    }
    appLogger.iWithPackage('files', 'deleteRecycleBinFiles: 成功永久删除${files.length}个文件');
  }

  Future<FileWgetResult> wgetDownload({
    required String url,
    required String path,
    required String name,
    bool? ignoreCertificate,
  }) async {
    appLogger.dWithPackage('files', 'wgetDownload: url=$url, path=$path, name=$name');
    final api = await _getApi();
    final response = await api.wgetDownload(FileWgetRequest(
      url: url,
      path: path,
      name: name,
      ignoreCertificate: ignoreCertificate,
    ));
    return response.data!;
  }

  Future<List<FileInfo>> searchUploadedFiles({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    appLogger.dWithPackage('files', 'searchUploadedFiles: page=$page, size=$pageSize');
    final api = await _getApi();
    final response = await api.searchUploadedFiles(FileSearch(
      path: '',
      page: page,
      pageSize: pageSize,
      search: search,
    ));
    return response.data!;
  }

  Future<FileSearchResult> searchInFiles({
    required String path,
    required String pattern,
    bool? caseSensitive,
    bool? wholeWord,
    bool? regex,
    List<String>? fileTypes,
    int? maxResults,
  }) async {
    appLogger.dWithPackage('files', 'searchInFiles: path=$path, pattern=$pattern');
    final api = await _getApi();
    final response = await api.searchInFiles(FileSearchInRequest(
      path: path,
      pattern: pattern,
      caseSensitive: caseSensitive,
      wholeWord: wholeWord,
      regex: regex,
      fileTypes: fileTypes,
      maxResults: maxResults,
    ));
    return response.data!;
  }

  Future<void> convertFile({
    required String path,
    required String fromEncoding,
    required String toEncoding,
  }) async {
    appLogger.dWithPackage('files', 'convertFile: path=$path, from=$fromEncoding, to=$toEncoding');
    final api = await _getApi();
    await api.convertFile(FileConvertRequest(
      path: path,
      fromEncoding: fromEncoding,
      toEncoding: toEncoding,
    ));
  }

  Future<String> convertFileLog(String path) async {
    appLogger.dWithPackage('files', 'convertFileLog: path=$path');
    final api = await _getApi();
    final response = await api.convertFileLog(FileConvertLogRequest(path: path));
    return response.data ?? '';
  }

  Future<FileEncodingResult> convertFileEncoding({
    required String path,
    required String fromEncoding,
    required String toEncoding,
    bool? backup,
  }) async {
    appLogger.dWithPackage(
      'files',
      'convertFileEncoding: path=$path, from=$fromEncoding, to=$toEncoding, backup=$backup',
    );
    final api = await _getApi();
    final response = await api.convertFileEncoding(
      FileEncodingConvert(
        path: path,
        fromEncoding: fromEncoding,
        toEncoding: toEncoding,
        backup: backup,
      ),
    );
    return response.data!;
  }

  Future<FileDepthSizeInfo> getDepthSize(List<String> paths) async {
    appLogger.dWithPackage('files', 'getDepthSize: paths=$paths');
    final api = await _getApi();
    final response = await api.getDepthSize(FileDepthSizeRequest(paths: paths));
    return response.data!;
  }

  Future<List<FileMountInfo>> getMountInfo() async {
    appLogger.dWithPackage('files', 'getMountInfo');
    final api = await _getApi();
    final response = await api.getMountInfo();
    return response.data!;
  }

  Future<FileProperties> getFileProperties(String path) async {
    appLogger.dWithPackage('files', 'getFileProperties: path=$path');
    final api = await _getApi();
    final response = await api.getFileProperties(FilePropertiesRequest(path: path));
    return response.data!;
  }

  Future<void> createFileLink({
    required String sourcePath,
    required String linkPath,
    required String linkType,
    bool? overwrite,
  }) async {
    appLogger.dWithPackage('files', 'createFileLink: source=$sourcePath, link=$linkPath, type=$linkType');
    final api = await _getApi();
    await api.createFileLink(FileLinkCreate(
      sourcePath: sourcePath,
      linkPath: linkPath,
      linkType: linkType,
      overwrite: overwrite,
    ));
    appLogger.iWithPackage('files', 'createFileLink: 成功创建链接');
  }

  Future<String> previewFile(String path, {int? line, int? limit}) async {
    appLogger.dWithPackage('files', 'previewFile: path=$path, line=$line, limit=$limit');
    final api = await _getApi();
    final response = await api.previewFile(FilePreviewRequest(
      path: path,
      line: line,
      limit: limit,
    ));
    return response.data ?? '';
  }

  Future<FileUserGroupResponse> getUserGroup() async {
    appLogger.dWithPackage('files', 'getUserGroup');
    final api = await _getApi();
    final response = await api.getUserGroup();
    return response.data!;
  }

  Future<FileBatchCheckResult> batchCheckFiles(List<String> paths) async {
    appLogger.dWithPackage('files', 'batchCheckFiles: paths=$paths');
    final api = await _getApi();
    final response = await api.batchCheckFiles(FileBatchCheckRequest(paths: paths));
    return response.data!;
  }

  Future<void> saveFile(String path, String content, {String? encoding, bool? createDir}) async {
    appLogger.dWithPackage('files', 'saveFile: path=$path, contentLength=${content.length}');
    final api = await _getApi();
    await api.saveFile(FileSave(
      path: path,
      content: content,
      encoding: encoding,
      createDir: createDir,
    ));
  }

  Future<String> readFile(String path, {int? offset, int? length, String? encoding}) async {
    appLogger.dWithPackage('files', 'readFile: path=$path, offset=$offset, length=$length');
    final api = await _getApi();
    final response = await api.readFile(FileRead(
      path: path,
      offset: offset,
      length: length,
      encoding: encoding,
    ));
    return response.data ?? '';
  }

  Future<void> downloadFile(String path, String savePath) async {
    appLogger.dWithPackage('files', 'downloadFile: path=$path, savePath=$savePath');
    final api = await _getApi();
    final response = await api.downloadFile(path);
    
    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception('下载文件失败: 响应为空');
    }
    
    final file = await File(savePath).create(recursive: true);
    await file.writeAsBytes(bytes);
    
    appLogger.iWithPackage('files', 'downloadFile: 文件已保存到 $savePath');
  }

  CancelToken? _downloadCancelToken;

  Future<String> downloadFileToDevice(
    String filePath,
    String fileName, {
    Function(int received, int total)? onProgress,
    Function()? onCancel,
  }) async {
    appLogger.dWithPackage('files', 'downloadFileToDevice: filePath=$filePath, fileName=$fileName');

    final savePath = await _getDownloadPath(fileName);
    appLogger.iWithPackage('files', 'downloadFileToDevice: savePath=$savePath');

    _downloadCancelToken = CancelToken();

    try {
      final config = await ApiConfigManager.getCurrentConfig();
      if (config == null) {
        throw StateError('No server configured');
      }

      final downloadUrl = '${config.url}${ApiConstants.buildApiPath('/files/download')}?path=${Uri.encodeComponent(filePath)}';

      // 使用 1Panel API 认证头部
      final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).floor().toString();
      final authToken = _generate1PanelAuthToken(config.apiKey, timestamp);

      final dio = Dio();
      dio.options.headers['1Panel-Token'] = authToken;
      dio.options.headers['1Panel-Timestamp'] = timestamp;

      await dio.download(
        downloadUrl,
        savePath,
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress?.call(received, total);
          }
        },
      );

      appLogger.iWithPackage('files', 'downloadFileToDevice: 下载成功');
      return savePath;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        appLogger.iWithPackage('files', 'downloadFileToDevice: 用户取消下载');
        throw Exception('Download cancelled');
      }
      appLogger.eWithPackage('files', 'downloadFileToDevice: 下载失败', error: e);
      rethrow;
    } finally {
      _downloadCancelToken = null;
    }
  }

  void cancelDownload() {
    if (_downloadCancelToken != null && !_downloadCancelToken!.isCancelled) {
      _downloadCancelToken!.cancel('User cancelled');
      appLogger.iWithPackage('files', 'cancelDownload: 取消下载');
    }
  }

  Future<String> _getDownloadPath(String fileName) async {
    Directory downloadDir;

    if (Platform.isAndroid) {
      final permissionGranted = await _requestStoragePermission();
      if (permissionGranted) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }
    } else if (Platform.isIOS) {
      downloadDir = await getApplicationDocumentsDirectory();
    } else {
      downloadDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    }

    final safeFileName = _sanitizeFileName(fileName);
    final filePath = '${downloadDir.path}/$safeFileName';

    int counter = 1;
    String finalPath = filePath;
    while (await File(finalPath).exists()) {
      final lastDot = filePath.lastIndexOf('.');
      if (lastDot > 0) {
        finalPath = '${filePath.substring(0, lastDot)} ($counter)${filePath.substring(lastDot)}';
      } else {
        finalPath = '$filePath ($counter)';
      }
      counter++;
    }

    return finalPath;
  }

  String _sanitizeFileName(String fileName) {
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  String _generate1PanelAuthToken(String apiKey, String timestamp) {
    final authString = '1panel$apiKey$timestamp';
    final bytes = utf8.encode(authString);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      try {
        if (await Permission.manageExternalStorage.isGranted) {
          return true;
        }
        
        final status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }
        
        if (status.isDenied) {
          final result = await Permission.storage.request();
          if (result.isGranted) {
            return true;
          }
        }
        
        if (status.isPermanentlyDenied) {
          await openAppSettings();
          return false;
        }
        
        final manageResult = await Permission.manageExternalStorage.request();
        return manageResult.isGranted;
      } catch (e) {
        appLogger.wWithPackage('files', '_requestStoragePermission: 权限检查失败，降级处理: $e');
        return true;
      }
    }
    return true;
  }

  Future<bool> checkAndRequestStoragePermission() async {
    if (Platform.isIOS) {
      return true;
    }
    
    if (Platform.isAndroid) {
      try {
        if (await Permission.manageExternalStorage.isGranted) {
          return true;
        }
        
        final status = await Permission.storage.status;
        if (status.isGranted) {
          return true;
        }
        
        if (status.isDenied) {
          final result = await Permission.storage.request();
          return result.isGranted;
        }
        
        if (status.isPermanentlyDenied) {
          return false;
        }
        
        return false;
      } catch (e) {
        appLogger.wWithPackage('files', 'checkAndRequestStoragePermission: 权限检查失败: $e');
        return true;
      }
    }
    
    return true;
  }

  Future<bool> isStoragePermissionPermanentlyDenied() async {
    if (Platform.isAndroid) {
      try {
        final status = await Permission.storage.status;
        return status.isPermanentlyDenied;
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<void> uploadFile(String path, dynamic file) async {
    appLogger.dWithPackage('files', 'uploadFile: path=$path');
    final api = await _getApi();
    await api.uploadFile(path, file);
  }
}
