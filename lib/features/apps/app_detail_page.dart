import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/i18n/l10n_x.dart';
import '../../../data/models/app_models.dart';
import '../../../core/config/api_constants.dart';
import 'app_service.dart';
import 'widgets/app_install_dialog.dart';

class AppDetailPage extends StatefulWidget {
  final AppItem app;

  const AppDetailPage({super.key, required this.app});

  @override
  State<AppDetailPage> createState() => _AppDetailPageState();
}

class _AppDetailPageState extends State<AppDetailPage> {
  late AppItem _app;
  bool _isLoading = true;
  String? _error;
  String? _readme;

  @override
  void initState() {
    super.initState();
    _app = widget.app;
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final appService = context.read<AppService>();
      final version = _app.versions?.first ?? 'latest';
      final type = _app.type ?? 'unknown';
      
      final detail = await appService.getAppDetail(
        _app.id.toString(),
        version,
        type,
      );

      if (mounted) {
        setState(() {
          _app = detail;
          _readme = detail.readMe;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _showInstallDialog() {
    showDialog(
      context: context,
      builder: (context) => AppInstallDialog(app: _app),
    );
  }

  String get _iconUrl {
    if (_app.icon != null && _app.icon!.startsWith('http')) {
      return _app.icon!;
    }
    // Construct icon URL if it's not a full URL
    // Assuming the icon can be fetched via /apps/icon/:key
    // or we might need to use the base URL from ApiConstants
    if (_app.key != null) {
      return ApiConstants.buildApiPath('/apps/icon/${_app.key}');
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(_app.name ?? l10n.appStoreTitle),
      ),
      body: _buildBody(context, theme),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FilledButton(
            onPressed: _showInstallDialog,
            child: Text(l10n.appStoreInstall),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(context.l10n.commonLoadFailedTitle),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadDetail();
              },
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, theme),
          const SizedBox(height: 24),
          Text(
            'Description', // TODO: Use l10n
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_readme != null && _readme!.isNotEmpty)
            MarkdownBody(
              data: _readme!,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium,
              ),
            )
          else
            Text(
              _app.description ?? context.l10n.commonEmpty,
              style: theme.textTheme.bodyMedium,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_iconUrl.isNotEmpty)
          CachedNetworkImage(
            imageUrl: _iconUrl,
            width: 80,
            height: 80,
            placeholder: (context, url) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image),
            ),
            errorWidget: (context, url, error) => Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.broken_image),
            ),
          )
        else
          Container(
            width: 80,
            height: 80,
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.apps, size: 40),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _app.name ?? '',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (_app.versions != null && _app.versions!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _app.versions!.first,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                _app.description ?? '',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
