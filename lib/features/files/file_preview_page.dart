import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:photo_view/photo_view.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/services/logger/logger_service.dart';
import 'package:onepanelapp_app/features/files/files_provider.dart';
import 'package:onepanelapp_app/features/files/file_editor_page.dart';
import 'package:provider/provider.dart';

class FilePreviewPage extends StatefulWidget {
  final String filePath;
  final String fileName;

  const FilePreviewPage({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  State<FilePreviewPage> createState() => _FilePreviewPageState();
}

class _FilePreviewPageState extends State<FilePreviewPage> {
  String? _content;
  bool _isLoading = true;
  String? _error;
  late FileType _fileType;

  static const Set<String> _imageExtensions = {
    'jpg', 'jpeg', 'png', 'gif', 'webp', 'svg', 'bmp', 'ico'
  };

  static const Set<String> _textExtensions = {
    'txt', 'md', 'json', 'xml', 'yaml', 'yml', 'html', 'css', 'js', 'ts',
    'dart', 'py', 'java', 'c', 'cpp', 'h', 'hpp', 'sh', 'bash', 'sql',
    'log', 'conf', 'ini', 'env', 'gitignore', 'dockerfile', 'makefile',
    'toml', 'gradle', 'properties', 'vue', 'jsx', 'tsx', 'scss', 'sass',
    'less', 'go', 'rs', 'swift', 'kt', 'scala', 'rb', 'php', 'pl', 'lua'
  };

  @override
  void initState() {
    super.initState();
    _fileType = _getFileType(widget.fileName);
    if (_fileType != FileType.image) {
      _loadContent();
    } else {
      _isLoading = false;
    }
  }

  FileType _getFileType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    if (_imageExtensions.contains(ext)) {
      return FileType.image;
    }
    if (_textExtensions.contains(ext) || _isTextFileName(fileName)) {
      return FileType.text;
    }
    return FileType.unknown;
  }

  bool _isTextFileName(String fileName) {
    final name = fileName.toLowerCase();
    const textNames = ['dockerfile', 'makefile', '.gitignore', '.env', 'license', 'readme'];
    for (final textName in textNames) {
      if (name == textName || name.startsWith(textName)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _loadContent() async {
    appLogger.dWithPackage('file_preview', '_loadContent: path=${widget.filePath}');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<FilesProvider>();
      final content = await provider.getFileContent(widget.filePath);
      appLogger.iWithPackage('file_preview', '_loadContent: 成功加载, 长度=${content.length}');
      if (mounted) {
        setState(() {
          _content = content;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      appLogger.eWithPackage('file_preview', '_loadContent: 加载失败', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_fileType == FileType.text)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _openEditor(context),
              tooltip: l10n.filesEditFile,
            ),
        ],
      ),
      body: _buildBody(context, l10n, theme),
    );
  }

  Widget _buildBody(BuildContext context, dynamic l10n, ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(l10n.filesPreviewError, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_error!, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loadContent,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    switch (_fileType) {
      case FileType.image:
        return _buildImagePreview(context, theme);
      case FileType.text:
        return _buildTextPreview(context, theme);
      case FileType.unknown:
        return _buildUnsupportedPreview(context, l10n, theme);
    }
  }

  Widget _buildImagePreview(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final isSvg = widget.fileName.toLowerCase().endsWith('.svg');

    final imageUrl = _getImageUrl(context);

    if (isSvg) {
      return Center(
        child: SvgPicture.network(
          imageUrl,
          placeholderBuilder: (context) => const CircularProgressIndicator(),
          errorBuilder: (context, error, stackTrace) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(error.toString()),
              ],
            );
          },
        ),
      );
    }

    return PhotoView(
      imageProvider: NetworkImage(imageUrl),
      loadingBuilder: (context, event) => Center(
        child: CircularProgressIndicator(
          value: event?.expectedTotalBytes != null
              ? event!.cumulativeBytesLoaded / event.expectedTotalBytes!
              : null,
        ),
      ),
      errorBuilder: (context, error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(error.toString()),
          ],
        ),
      ),
      backgroundDecoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.grey[200],
      ),
      minScale: PhotoViewComputedScale.contained,
      maxScale: PhotoViewComputedScale.covered * 3,
    );
  }

  String _getImageUrl(BuildContext context) {
    final provider = context.read<FilesProvider>();
    final server = provider.data.currentServer;
    if (server == null) {
      return '';
    }
    final baseUrl = server.url.endsWith('/') ? server.url : '${server.url}/';
    final apiKey = server.apiKey;
    final path = widget.filePath.startsWith('/') ? widget.filePath.substring(1) : widget.filePath;
    return '${baseUrl}api/v2/files/download?path=/$path&apiKey=$apiKey';
  }

  Widget _buildTextPreview(BuildContext context, ThemeData theme) {
    if (_content == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final language = _getLanguage(widget.fileName);

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: language != null
            ? HighlightView(
                _content!,
                language: language,
                theme: githubTheme,
                padding: const EdgeInsets.all(16),
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              )
            : SelectableText(
                _content!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  String? _getLanguage(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    final name = fileName.toLowerCase();

    if (name == 'dockerfile' || name.startsWith('dockerfile.')) return 'dockerfile';
    if (name == 'makefile') return 'makefile';
    if (name == '.gitignore') return 'gitignore';
    if (name.startsWith('.env')) return 'bash';

    const extToLanguage = {
      'dart': 'dart',
      'js': 'javascript',
      'ts': 'typescript',
      'jsx': 'javascript',
      'tsx': 'typescript',
      'json': 'json',
      'yaml': 'yaml',
      'yml': 'yaml',
      'xml': 'xml',
      'html': 'html',
      'htm': 'html',
      'css': 'css',
      'scss': 'scss',
      'sass': 'sass',
      'less': 'less',
      'md': 'markdown',
      'py': 'python',
      'java': 'java',
      'c': 'c',
      'cpp': 'cpp',
      'h': 'c',
      'hpp': 'cpp',
      'sh': 'bash',
      'bash': 'bash',
      'sql': 'sql',
      'go': 'go',
      'rs': 'rust',
      'swift': 'swift',
      'kt': 'kotlin',
      'scala': 'scala',
      'rb': 'ruby',
      'php': 'php',
      'pl': 'perl',
      'lua': 'lua',
      'vue': 'vue',
      'toml': 'toml',
      'gradle': 'gradle',
      'properties': 'properties',
      'conf': 'nginx',
      'ini': 'ini',
    };

    return extToLanguage[ext];
  }

  Widget _buildUnsupportedPreview(BuildContext context, dynamic l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.insert_drive_file_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.filesPreviewUnsupported,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            widget.fileName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => FileEditorPage(
          filePath: widget.filePath,
          fileName: widget.fileName,
          initialContent: _content,
        ),
      ),
    );
  }
}

enum FileType {
  image,
  text,
  unknown,
}
