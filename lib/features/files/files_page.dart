import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.filesPageTitle)),
      body: ListView(
        padding: AppDesignTokens.pagePadding,
        children: [
          Card(
            child: Padding(
              padding: AppDesignTokens.pagePadding,
              child: Row(
                children: [
                  const Icon(Icons.folder_open_outlined),
                  const SizedBox(width: AppDesignTokens.spacingSm),
                  Expanded(
                    child: Text('${l10n.filesPath}: /${l10n.filesRoot}'),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDesignTokens.spacingLg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(l10n.filesActionUpload),
                ),
              ),
              const SizedBox(width: AppDesignTokens.spacingSm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.note_add_outlined),
                  label: Text(l10n.filesActionNewFile),
                ),
              ),
              const SizedBox(width: AppDesignTokens.spacingSm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: Text(l10n.filesActionNewFolder),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignTokens.spacingLg),
          Card(
            child: Padding(
              padding: AppDesignTokens.pagePadding,
              child: Column(
                children: [
                  const Icon(Icons.folder_copy_outlined, size: 56),
                  const SizedBox(height: AppDesignTokens.spacingMd),
                  Text(l10n.filesEmptyTitle,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppDesignTokens.spacingSm),
                  Text(l10n.filesEmptyDesc, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
