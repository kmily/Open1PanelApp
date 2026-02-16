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
  List<Map<String, dynamic>>? _backupAccounts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = context.read<SettingsProvider>();
    await provider.loadSnapshots();
    final accounts = await provider.loadBackupAccountOptions();
    debugPrint('[SnapshotPage] loadBackupAccountOptions: $accounts');
    if (mounted) {
      setState(() {
        _backupAccounts = accounts;
      });
    }
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
          TextButton.icon(
            onPressed: () => _showImportSnapshotDialog(context, l10n),
            icon: const Icon(Icons.file_upload_outlined),
            label: Text(l10n.snapshotImport),
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
            PopupMenuItem(value: 'rollback', child: Text(l10n.snapshotRollback)),
            PopupMenuItem(value: 'editDesc', child: Text(l10n.snapshotEditDesc)),
            const PopupMenuDivider(),
            PopupMenuItem(value: 'delete', child: Text(l10n.snapshotDelete, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  void _showCreateSnapshotDialog(BuildContext context, AppLocalizations l10n) {
    final descController = TextEditingController();
    final provider = context.read<SettingsProvider>();
    int? selectedAccountId;

    if (_backupAccounts != null && _backupAccounts!.isNotEmpty) {
      selectedAccountId = _backupAccounts!.first['id'] as int;
    }

    debugPrint('[SnapshotPage] _showCreateSnapshotDialog: _backupAccounts=$_backupAccounts, initial selectedAccountId=$selectedAccountId');

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setDialogState) {
          return AlertDialog(
            title: Text(l10n.snapshotCreate),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_backupAccounts == null || _backupAccounts!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('没有可用的备份账户，请先在备份账户管理中添加备份账户'),
                  )
                else ...[
                  Text(l10n.snapshotEnterDesc),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      labelText: l10n.snapshotDescLabel,
                      hintText: l10n.snapshotDescHint,
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedAccountId,
                    decoration: const InputDecoration(
                      labelText: '备份账户',
                      prefixIcon: Icon(Icons.cloud_outlined),
                    ),
                    items: _backupAccounts!.map((account) {
                      return DropdownMenuItem<int>(
                        value: account['id'] as int,
                        child: Text('${account['name']} (${account['type']})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      debugPrint('[SnapshotPage] Dropdown changed to: $value');
                      setDialogState(() {
                        selectedAccountId = value;
                      });
                    },
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: _backupAccounts == null || _backupAccounts!.isEmpty || selectedAccountId == null
                    ? null
                    : () async {
                        Navigator.pop(dialogContext);
                        debugPrint('[SnapshotPage] Creating snapshot with account: $selectedAccountId');
                        final success = await provider.createSnapshot(
                          description: descController.text.isEmpty ? null : descController.text,
                          sourceAccountIDs: selectedAccountId.toString(),
                          downloadAccountID: selectedAccountId!,
                        );
                        debugPrint('[SnapshotPage] Create snapshot result: $success');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? l10n.snapshotCreateSuccess : l10n.snapshotCreateFailed)),
                          );
                        }
                      },
                child: Text(l10n.commonConfirm),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showImportSnapshotDialog(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.snapshotImportTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.snapshotImportPath,
            hintText: l10n.snapshotImportPathHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              if (controller.text.isEmpty) return;
              final success = await context.read<SettingsProvider>().importSnapshot(controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.snapshotImportSuccess : l10n.snapshotImportFailed)),
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
      case 'rollback':
        _showRollbackConfirmDialog(context, id, l10n);
        break;
      case 'editDesc':
        _showEditDescDialog(context, id, snapshot['description'] as String?, l10n);
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

  void _showRollbackConfirmDialog(BuildContext context, int id, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.snapshotRollbackTitle),
        content: Text(l10n.snapshotRollbackConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<SettingsProvider>().rollbackSnapshot(id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.snapshotRollbackSuccess : l10n.snapshotRollbackFailed)),
                );
              }
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  void _showEditDescDialog(BuildContext context, int id, String? currentDesc, AppLocalizations l10n) {
    final controller = TextEditingController(text: currentDesc ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.snapshotEditDescTitle),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.snapshotDescLabel,
            hintText: l10n.snapshotDescHint,
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<SettingsProvider>().updateSnapshotDescription(id, controller.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.snapshotEditDescSuccess : l10n.snapshotEditDescFailed)),
                );
              }
            },
            child: Text(l10n.commonSave),
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
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
