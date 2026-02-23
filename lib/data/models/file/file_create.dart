import 'package:equatable/equatable.dart';

enum FileType {
  file('file', '文件'),
  directory('directory', '目录'),
  symlink('symlink', '符号链接');

  const FileType(this.value, this.displayName);

  final String value;
  final String displayName;

  static FileType fromString(String value) {
    return FileType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => FileType.file,
    );
  }
}

class FileCreate extends Equatable {
  final String path;
  final String? content;
  final bool? isDir;
  final String? permission;
  final bool? isLink;
  final String? linkPath;
  final bool? isSymlink;
  final bool? sub;
  final int? mode;

  const FileCreate({
    required this.path,
    this.content,
    this.isDir,
    this.permission,
    this.isLink,
    this.linkPath,
    this.isSymlink,
    this.sub,
    this.mode,
  });

  factory FileCreate.fromJson(Map<String, dynamic> json) {
    return FileCreate(
      path: json['path'] as String,
      content: json['content'] as String?,
      isDir: json['isDir'] as bool?,
      permission: json['permission'] as String?,
      isLink: json['isLink'] as bool?,
      linkPath: json['linkPath'] as String?,
      isSymlink: json['isSymlink'] as bool?,
      sub: json['sub'] as bool?,
      mode: json['mode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'content': content,
      'isDir': isDir,
      'permission': permission,
      'isLink': isLink,
      'linkPath': linkPath,
      'isSymlink': isSymlink,
      'sub': sub,
      'mode': mode,
    };
  }

  @override
  List<Object?> get props => [
        path,
        content,
        isDir,
        permission,
        isLink,
        linkPath,
        isSymlink,
        sub,
        mode,
      ];
}

class FileRead extends Equatable {
  final String path;
  final int? offset;
  final int? length;
  final String? encoding;

  const FileRead({
    required this.path,
    this.offset,
    this.length,
    this.encoding,
  });

  factory FileRead.fromJson(Map<String, dynamic> json) {
    return FileRead(
      path: json['path'] as String,
      offset: json['offset'] as int?,
      length: json['length'] as int?,
      encoding: json['encoding'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'offset': offset,
      'length': length,
      'encoding': encoding,
    };
  }

  @override
  List<Object?> get props => [path, offset, length, encoding];
}

class FileSave extends Equatable {
  final String path;
  final String content;
  final String? encoding;
  final bool? createDir;

  const FileSave({
    required this.path,
    required this.content,
    this.encoding,
    this.createDir,
  });

  factory FileSave.fromJson(Map<String, dynamic> json) {
    return FileSave(
      path: json['path'] as String,
      content: json['content'] as String,
      encoding: json['encoding'] as String?,
      createDir: json['createDir'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'content': content,
      'encoding': encoding,
      'createDir': createDir,
    };
  }

  @override
  List<Object?> get props => [path, content, encoding, createDir];
}

class FileLinkCreate extends Equatable {
  final String sourcePath;
  final String linkPath;
  final String linkType;
  final bool? overwrite;

  const FileLinkCreate({
    required this.sourcePath,
    required this.linkPath,
    required this.linkType,
    this.overwrite,
  });

  factory FileLinkCreate.fromJson(Map<String, dynamic> json) {
    return FileLinkCreate(
      sourcePath: json['sourcePath'] as String,
      linkPath: json['linkPath'] as String,
      linkType: json['linkType'] as String,
      overwrite: json['overwrite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourcePath': sourcePath,
      'linkPath': linkPath,
      'linkType': linkType,
      'overwrite': overwrite,
    };
  }

  @override
  List<Object?> get props => [sourcePath, linkPath, linkType, overwrite];
}

class FileLinkResult extends Equatable {
  final bool success;
  final String? linkPath;
  final String? error;

  const FileLinkResult({
    required this.success,
    this.linkPath,
    this.error,
  });

  factory FileLinkResult.fromJson(Map<String, dynamic> json) {
    return FileLinkResult(
      success: json['success'] as bool? ?? false,
      linkPath: json['linkPath'] as String?,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'linkPath': linkPath,
      'error': error,
    };
  }

  @override
  List<Object?> get props => [success, linkPath, error];
}
