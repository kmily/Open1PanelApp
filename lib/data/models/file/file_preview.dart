import 'package:equatable/equatable.dart';

class FilePreviewRequest extends Equatable {
  final String path;
  final int? line;
  final int? limit;

  const FilePreviewRequest({
    required this.path,
    this.line,
    this.limit,
  });

  factory FilePreviewRequest.fromJson(Map<String, dynamic> json) {
    return FilePreviewRequest(
      path: json['path'] as String,
      line: json['line'] as int?,
      limit: json['limit'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'path': path};
    if (line != null) json['line'] = line;
    if (limit != null) json['limit'] = limit;
    return json;
  }

  @override
  List<Object?> get props => [path, line, limit];
}
