import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/data/models/file_models.dart';
import 'package:onepanelapp_app/features/files/files_provider.dart';
import 'package:onepanelapp_app/core/utils/debug_error_dialog.dart';
import 'package:onepanelapp_app/core/services/logger/logger_service.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: context.read<FilesProvider>(),
      child: const FavoritesView(),
    );
  }
}

class FavoritesView extends StatefulWidget {
  const FavoritesView({super.key});

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FilesProvider>().loadFavorites();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.filesFavorites),
      ),
      body: Consumer<FilesProvider>(
        builder: (context, provider, _) {
          if (provider.data.favorites.isEmpty) {
            return _buildEmptyState(context, l10n, theme);
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadFavorites(),
            child: ListView.builder(
              padding: AppDesignTokens.pagePadding,
              itemCount: provider.data.favorites.length,
              itemBuilder: (context, index) {
                final file = provider.data.favorites[index];
                return _buildFavoriteItem(context, provider, file, theme, l10n);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.filesFavoritesEmpty,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.filesFavoritesEmptyDesc,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context,
    FilesProvider provider,
    FileInfo file,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final isDir = file.isDir;
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.spacingXs),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(
          isDir ? Icons.folder_outlined : _getFileIcon(file.name),
          color: isDir ? colorScheme.primary : _getFileIconColor(file.name, colorScheme),
          size: 32,
        ),
        title: Text(file.name),
        subtitle: Text(
          file.path,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleAction(context, provider, file, value, l10n),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'navigate',
              child: ListTile(
                leading: const Icon(Icons.folder_open),
                title: Text(l10n.filesNavigateToFolder),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.star_outline, color: colorScheme.error),
                title: Text(
                  l10n.filesRemoveFromFavorites,
                  style: TextStyle(color: colorScheme.error),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _navigateToFolder(context, file),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image_outlined;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return Icons.video_file_outlined;
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icons.audio_file_outlined;
      case 'zip':
      case 'tar':
      case 'gz':
      case '7z':
      case 'rar':
        return Icons.folder_zip_outlined;
      case 'dart':
      case 'js':
      case 'ts':
      case 'py':
      case 'java':
      case 'swift':
      case 'kt':
        return Icons.code_outlined;
      case 'json':
      case 'yaml':
      case 'yml':
      case 'xml':
        return Icons.data_object_outlined;
      case 'md':
      case 'txt':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _getFileIconColor(String fileName, ColorScheme colorScheme) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return colorScheme.error;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return colorScheme.primary;
      case 'mp4':
      case 'avi':
      case 'mkv':
      case 'mov':
        return colorScheme.tertiary;
      case 'mp3':
      case 'wav':
      case 'flac':
        return colorScheme.secondary;
      case 'zip':
      case 'tar':
      case 'gz':
      case '7z':
      case 'rar':
        return colorScheme.tertiaryContainer;
      case 'dart':
        return colorScheme.primary;
      case 'js':
      case 'ts':
        return colorScheme.secondary;
      case 'py':
        return colorScheme.tertiary;
      case 'json':
      case 'yaml':
      case 'yml':
        return colorScheme.secondaryContainer;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  void _handleAction(
    BuildContext context,
    FilesProvider provider,
    FileInfo file,
    String action,
    AppLocalizations l10n,
  ) {
    switch (action) {
      case 'navigate':
        _navigateToFolder(context, file);
        break;
      case 'remove':
        _removeFavorite(context, provider, file, l10n);
        break;
    }
  }

  void _navigateToFolder(BuildContext context, FileInfo file) {
    appLogger.dWithPackage('favorites_page', '_navigateToFolder: path=${file.path}');
    final parentPath = file.path.substring(0, file.path.lastIndexOf('/'));
    final targetPath = parentPath.isEmpty ? '/' : parentPath;

    Navigator.of(context).pop(targetPath);
  }

  Future<void> _removeFavorite(
    BuildContext context,
    FilesProvider provider,
    FileInfo file,
    AppLocalizations l10n,
  ) async {
    appLogger.dWithPackage('favorites_page', '_removeFavorite: path=${file.path}');
    try {
      await provider.removeFromFavorites(file.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.filesFavoritesRemoved)),
        );
      }
    } catch (e, stackTrace) {
      appLogger.eWithPackage('favorites_page', '_removeFavorite: 失败', error: e, stackTrace: stackTrace);
      if (context.mounted) {
        DebugErrorDialog.show(context, l10n.filesFavoritesLoadFailed, e, stackTrace: stackTrace);
      }
    }
  }
}
