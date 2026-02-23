import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/data/models/file_models.dart';
import 'package:onepanelapp_app/core/services/logger/logger_service.dart';
import 'package:onepanelapp_app/features/files/files_provider.dart';

class FilePropertiesDialog extends StatefulWidget {
  final FilesProvider provider;
  final FileInfo file;

  const FilePropertiesDialog({
    super.key,
    required this.provider,
    required this.file,
  });

  @override
  State<FilePropertiesDialog> createState() => _FilePropertiesDialogState();
}

class _FilePropertiesDialogState extends State<FilePropertiesDialog> {
  FileProperties? _properties;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    try {
      final properties = await widget.provider.getFileProperties(widget.file.path);
      if (mounted) {
        setState(() {
          _properties = properties;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      appLogger.eWithPackage('file_properties', '加载属性失败', error: e, stackTrace: stackTrace);
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

    return AlertDialog(
      title: Text(l10n.filesPropertiesTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: _buildContent(context, l10n, theme),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, dynamic l10n, ThemeData theme) {
    if (_isLoading) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading...'),
        ],
      );
    }

    if (_error != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 48),
          const SizedBox(height: 16),
          Text(_error!),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadProperties();
            },
            icon: const Icon(Icons.refresh),
            label: Text(l10n.commonRetry),
          ),
        ],
      );
    }

    if (_properties == null) {
      return const SizedBox();
    }

    final props = _properties!;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPropertyItem(context, l10n.filesNameLabel, props.name, copyable: true),
          _buildPropertyItem(context, l10n.filesPathLabel, props.path, copyable: true),
          _buildPropertyItem(context, l10n.filesTypeLabel, props.type),
          _buildPropertyItem(context, l10n.filesSizeLabel, _formatSize(props.size)),
          if (props.mimeType != null)
            _buildPropertyItem(context, 'MIME Type', props.mimeType!),
          const Divider(),
          _buildPropertyItem(context, l10n.filesPermissionTitle, '${props.permission} (${props.owner}:${props.group})'),
          if (props.createdAt != null)
            _buildPropertyItem(context, l10n.filesCreatedLabel, dateFormat.format(props.createdAt!)),
          if (props.modifiedAt != null)
            _buildPropertyItem(context, l10n.filesModifiedLabel, dateFormat.format(props.modifiedAt!)),
          if (props.accessedAt != null)
            _buildPropertyItem(context, l10n.filesAccessedLabel, dateFormat.format(props.accessedAt!)),
          if (props.checksum != null) ...[
            const Divider(),
            _buildPropertyItem(context, 'Checksum', props.checksum!, copyable: true),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyItem(
    BuildContext context,
    String label,
    String value, {
    bool copyable = false,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (copyable)
                IconButton(
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(context.l10n.commonCopySuccess)),
                    );
                  },
                  tooltip: context.l10n.commonCopy,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

void showFilePropertiesDialog(BuildContext context, FilesProvider provider, FileInfo file) {
  showDialog(
    context: context,
    builder: (context) => FilePropertiesDialog(
      provider: provider,
      file: file,
    ),
  );
}
