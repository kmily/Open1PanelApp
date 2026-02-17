import '../../api/v2/file_v2.dart';
import '../../data/models/file_models.dart';
import '../../core/network/api_client_manager.dart';
import '../../core/config/api_config.dart';

class FilesService {
  FileV2Api? _api;
  String? _currentServerId;

  Future<FileV2Api> _getApi() async {
    final config = await ApiConfigManager.getCurrentConfig();
    if (config == null) {
      throw StateError('No server configured');
    }
    
    if (_api == null || _currentServerId != config.id) {
      final client = await ApiClientManager.instance.getCurrentClient();
      _api = FileV2Api(client);
      _currentServerId = config.id;
    }
    return _api!;
  }

  void clearCache() {
    _api = null;
    _currentServerId = null;
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
    return response.data ?? [];
  }

  Future<void> createDirectory(String path) async {
    final api = await _getApi();
    await api.createDirectory(FileCreate(path: path, isDir: true));
  }

  Future<void> createFile(String path, {String? content}) async {
    final api = await _getApi();
    await api.createDirectory(FileCreate(path: path, content: content, isDir: false));
  }

  Future<void> deleteFiles(List<String> paths, {bool? force}) async {
    final api = await _getApi();
    await api.deleteFiles(FileOperate(paths: paths, force: force));
  }

  Future<void> renameFile(String oldPath, String newPath) async {
    final api = await _getApi();
    await api.renameFile(FileRename(oldPath: oldPath, newPath: newPath));
  }

  Future<void> moveFiles(List<String> paths, String targetPath) async {
    final api = await _getApi();
    await api.moveFiles(FileMove(paths: paths, targetPath: targetPath));
  }

  Future<String> getFileContent(String path) async {
    final api = await _getApi();
    final response = await api.getFileContent(path);
    return response.data ?? '';
  }

  Future<void> updateFileContent(String path, String content) async {
    final api = await _getApi();
    await api.updateFileContent(FileContent(path: path, content: content));
  }

  Future<void> compressFiles({
    required List<String> paths,
    required String targetPath,
    required String type,
    String? password,
  }) async {
    final api = await _getApi();
    await api.compressFiles(FileCompress(
      paths: paths,
      targetPath: targetPath,
      type: type,
      password: password,
    ));
  }

  Future<void> extractFile({
    required String path,
    required String targetPath,
    String? password,
  }) async {
    final api = await _getApi();
    await api.extractFile(FileExtract(
      path: path,
      targetPath: targetPath,
      password: password,
    ));
  }

  Future<FilePermission> getFilePermission(String path) async {
    final api = await _getApi();
    final response = await api.getFilePermission(path);
    return response.data!;
  }

  Future<void> updateFilePermission(FilePermission permission) async {
    final api = await _getApi();
    await api.updateFilePermission(permission);
  }

  Future<FileCheckResult> checkFile(String path) async {
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
    final api = await _getApi();
    final response = await api.getFileSize(FileSizeRequest(
      path: path,
      recursive: recursive,
    ));
    return response.data!;
  }

  Future<void> favoriteFile(String path, {String? name, String? description}) async {
    final api = await _getApi();
    await api.favoriteFile(FileFavorite(path: path, name: name, description: description));
  }

  Future<void> unfavoriteFile(String path) async {
    final api = await _getApi();
    await api.unfavoriteFile(FileUnfavorite(path: path));
  }

  Future<List<FileInfo>> searchFavoriteFiles({
    required String path,
    int page = 1,
    int pageSize = 100,
  }) async {
    final api = await _getApi();
    final response = await api.searchFavoriteFiles(FileSearch(
      path: path,
      page: page,
      pageSize: pageSize,
    ));
    return response.data!;
  }

  Future<String> getRecycleBinStatus() async {
    final api = await _getApi();
    final response = await api.getRecycleBinStatus();
    return response.data!.fileCount.toString();
  }

  Future<List<FileInfo>> searchRecycleBin({
    required String path,
    int page = 1,
    int pageSize = 100,
  }) async {
    final api = await _getApi();
    final response = await api.searchRecycleBin(FileSearch(
      path: path,
      page: page,
      pageSize: pageSize,
    ));
    return response.data!;
  }

  Future<void> clearRecycleBin() async {
    final api = await _getApi();
    await api.clearRecycleBin();
  }

  Future<FileWgetResult> wgetDownload({
    required String url,
    required String path,
    String? filename,
    bool? overwrite,
  }) async {
    final api = await _getApi();
    final response = await api.wgetDownload(FileWgetRequest(
      url: url,
      path: path,
      filename: filename,
      overwrite: overwrite,
    ));
    return response.data!;
  }

  Future<void> convertFile({
    required String path,
    required String fromEncoding,
    required String toEncoding,
  }) async {
    final api = await _getApi();
    await api.convertFile(FileConvertRequest(
      path: path,
      fromEncoding: fromEncoding,
      toEncoding: toEncoding,
    ));
  }

  Future<String> convertFileLog(String path) async {
    final api = await _getApi();
    final response = await api.convertFileLog(FileConvertLogRequest(path: path));
    return response.data ?? '';
  }

  Future<FileDepthSizeInfo> getDepthSize(List<String> paths) async {
    final api = await _getApi();
    final response = await api.getDepthSize(FileDepthSizeRequest(paths: paths));
    return response.data!;
  }

  Future<List<FileMountInfo>> getMountInfo() async {
    final api = await _getApi();
    final response = await api.getMountInfo();
    return response.data!;
  }

  Future<String> previewFile(String path, {int? line, int? limit}) async {
    final api = await _getApi();
    final response = await api.previewFile(FilePreviewRequest(
      path: path,
      line: line,
      limit: limit,
    ));
    return response.data ?? '';
  }

  Future<FileUserGroupResponse> getUserGroup() async {
    final api = await _getApi();
    final response = await api.getUserGroup();
    return response.data!;
  }

  Future<FileBatchCheckResult> batchCheckFiles(List<String> paths) async {
    final api = await _getApi();
    final response = await api.batchCheckFiles(FileBatchCheckRequest(paths: paths));
    return response.data!;
  }

  Future<void> changeFileMode(String path, String mode, {bool? recursive}) async {
    final api = await _getApi();
    await api.changeFileMode(FileModeChange(
      path: path,
      mode: mode,
      recursive: recursive,
    ));
  }

  Future<void> changeFileOwner(String path, {String? user, String? group, bool? recursive}) async {
    final api = await _getApi();
    await api.changeFileOwner(FileOwnerChange(
      path: path,
      user: user,
      group: group,
      recursive: recursive,
    ));
  }

  Future<void> saveFile(String path, String content, {String? encoding, bool? createDir}) async {
    final api = await _getApi();
    await api.saveFile(FileSave(
      path: path,
      content: content,
      encoding: encoding,
      createDir: createDir,
    ));
  }

  Future<String> readFile(String path, {int? offset, int? length, String? encoding}) async {
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
    final api = await _getApi();
    await api.downloadFile(path);
  }

  Future<void> uploadFile(String path, dynamic file) async {
    final api = await _getApi();
    await api.uploadFile(path, file);
  }

  Future<void> batchChangeRole(List<String> paths, String operation, {bool? force}) async {
    final api = await _getApi();
    await api.batchChangeFileRole(FileBatchOperate(
      paths: paths,
      operation: operation,
      force: force,
    ));
  }
}
