import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/features/settings/settings_provider.dart';

class SnapshotPage extends StatefulWidget {
  const SnapshotPage({super.key});

  @override
  State<SnapshotPage> createState() => _SnapshotPageState();
}

class _SnapshotPageState extends State<SnapshotPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSnapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final provider = context.watch<SettingsProvider>();
    final snapshots = provider.data.snapshots;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.snapshotTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            onPressed: () => context.read<SettingsProvider>().loadSnapshots(),
            tooltip: l10n.systemSettingsRefresh,
          ),
        ],
      ),
      body: snapshots == null || snapshots.isEmpty
          ? _buildEmptyState(context, l10n)
          : _buildSnapshotList(context, theme, snapshots, l10n),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSnapshotDialog(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.snapshotCreate),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.snapshotEmpty),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _showCreateSnapshotDialog(context, l10n),
            icon: const Icon(Icons.add),
            label: Text(l10n.snapshotCreate),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotList(BuildContext context, ThemeData theme, List<dynamic> snapshots, AppLocalizations l10n) {
    return ListView.builder(
      padding: AppDesignTokens.pagePadding,
      itemCount: snapshots.length,
      itemBuilder: (context, index) {
        final snapshot = snapshots[index] as Map<String, dynamic>;
        return _buildSnapshotCard(context, theme, snapshot, l10n);
      },
    );
  }

  Widget _buildSnapshotCard(BuildContext context, ThemeData theme, Map<String, dynamic> snapshot, AppLocalizations l10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppDesignTokens.spacingSm),
      child: ListTile(
        leading: const Icon(Icons.photo_library_outlined),
        title: Text(snapshot['name'] ?? 'Snapshot ${snapshot['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${l10n.snapshotCreatedAt}: ${snapshot['createdAt'] ?? '-'}'),
            Text('${l10n.snapshotDescription}: ${snapshot['description'] ?? '-'}'),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleSnapshotAction(context, value, snapshot, l10n),
          itemBuilder: (context) => [
            PopupMenuItem(value: 'recover', child: Text(l10n.snapshotRecover)),
            PopupMenuItem(value: 'download', child: Text(l10n.snapshotDownload)),
            PopupMenuItem(value: 'delete', child: Text(l10n.snapshotDelete)),
          ],
        ),
      ),
    );
  }

  void _showCreateSnapshotDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.snapshotCreate),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.snapshotEnterDesc),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.snapshotDescLabel,
                hintText: l10n.snapshotDescHint,
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<SettingsProvider>().createSnapshot(
                description: controller.text.isEmpty ? null : controller.text,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.snapshotCreateSuccess : l10n.snapshotCreateFailed)),
                );
              }
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  void _handleSnapshotAction(BuildContext context, String action, Map<String, dynamic> snapshot, AppLocalizations l10n) {
    final id = snapshot['id'] as int;
    switch (action) {
      case 'recover':
        _showRecoverConfirmDialog(context, id, l10n);
        break;
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.snapshotDownloadDev)),
        );
        break;
      case 'delete':
        _showDeleteConfirmDialog(context, [id], l10n);
        break;
    }
  }

  void _showRecoverConfirmDialog(BuildContext context, int id, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.snapshotRecoverTitle),
        content: Text(l10n.snapshotRecoverConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<SettingsProvider>().recoverSnapshot(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.snapshotRecoverSuccess : l10n.snapshotRecoverFailed)),
                );
              }
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, List<int> ids, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.snapshotDeleteTitle),
        content: Text(l10n.snapshotDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<SettingsProvider>().deleteSnapshot(ids);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.snapshotDeleteSuccess : l10n.snapshotDeleteFailed)),
                );
              }
            },
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
  }
}
