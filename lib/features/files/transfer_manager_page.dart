import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/services/transfer/transfer_task.dart';
import 'package:onepanelapp_app/core/services/transfer/transfer_manager.dart';
import 'package:onepanelapp_app/core/services/file_save_service.dart';

enum TransferFilter { all, uploading, downloading }
enum TransferSort { newest, oldest, name, size }

class TransferManagerPage extends StatefulWidget {
  const TransferManagerPage({super.key});

  @override
  State<TransferManagerPage> createState() => _TransferManagerPageState();
}

class _TransferManagerPageState extends State<TransferManagerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TransferFilter _filter = TransferFilter.all;
  TransferSort _sort = TransferSort.newest;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TransferTask> _getFilteredAndSortedTasks(TransferManager manager) {
    var tasks = manager.allTasks;

    switch (_filter) {
      case TransferFilter.uploading:
        tasks = tasks.where((t) => t.type == TransferType.upload).toList();
        break;
      case TransferFilter.downloading:
        tasks = tasks.where((t) => t.type == TransferType.download).toList();
        break;
      case TransferFilter.all:
        break;
    }

    switch (_sort) {
      case TransferSort.newest:
        tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TransferSort.oldest:
        tasks.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case TransferSort.name:
        tasks.sort((a, b) => (a.fileName ?? '').compareTo(b.fileName ?? ''));
        break;
      case TransferSort.size:
        tasks.sort((a, b) => b.totalSize.compareTo(a.totalSize));
        break;
    }

    return tasks;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transferManagerTitle),
        actions: [
          PopupMenuButton<TransferFilter>(
            icon: const Icon(Icons.filter_list),
            initialValue: _filter,
            onSelected: (filter) {
              setState(() => _filter = filter);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TransferFilter.all,
                child: Text(l10n.transferFilterAll),
              ),
              PopupMenuItem(
                value: TransferFilter.uploading,
                child: Text(l10n.transferFilterUploading),
              ),
              PopupMenuItem(
                value: TransferFilter.downloading,
                child: Text(l10n.transferFilterDownloading),
              ),
            ],
          ),
          PopupMenuButton<TransferSort>(
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (sort) {
              setState(() => _sort = sort);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TransferSort.newest,
                child: Text(l10n.transferSortNewest),
              ),
              PopupMenuItem(
                value: TransferSort.oldest,
                child: Text(l10n.transferSortOldest),
              ),
              PopupMenuItem(
                value: TransferSort.name,
                child: Text(l10n.transferSortName),
              ),
              PopupMenuItem(
                value: TransferSort.size,
                child: Text(l10n.transferSortSize),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearDialog(context),
            tooltip: l10n.transferClearCompleted,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsDialog(context),
            tooltip: l10n.transferSettingsTitle,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.transferTabActive),
            Tab(text: l10n.transferTabPending),
            Tab(text: l10n.transferTabCompleted),
          ],
        ),
      ),
      body: Consumer<TransferManager>(
        builder: (context, manager, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildTaskList(context, manager.activeTasks, l10n, theme),
              _buildTaskList(context, manager.pendingTasks, l10n, theme),
              _buildTaskList(context, manager.completedTasks, l10n, theme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskList(
    BuildContext context,
    List<TransferTask> tasks,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.transferEmpty,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _TransferTaskTile(
          task: task,
          onOpenFile: task.localPath != null
              ? () => _openFile(context, task.localPath!)
              : null,
        );
      },
    );
  }

  Future<void> _openFile(BuildContext context, String filePath) async {
    final l10n = context.l10n;
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.transferFileNotFound)),
          );
        }
        return;
      }

      final fileSaveService = FileSaveService();
      await fileSaveService.openFileLocation(filePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transferFileLocationOpened)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.transferOpenFileError}: $e')),
        );
      }
    }
  }

  void _showClearDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.transferClearTitle),
        content: Text(l10n.transferClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () {
              context.read<TransferManager>().clearCompleted();
              Navigator.pop(context);
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    final l10n = context.l10n;
    final manager = context.read<TransferManager>();
    final currentDays = manager.historyRetentionDays;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          int selectedDays = currentDays;
          return AlertDialog(
            title: Text(l10n.transferSettingsTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.transferHistoryRetentionHint),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [7, 14, 30, 60, 90].map((days) {
                    final isSelected = selectedDays == days;
                    return ChoiceChip(
                      label: Text(l10n.transferHistoryDays(days)),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => selectedDays = days);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () {
                  manager.setHistoryRetentionDays(selectedDays);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.transferHistorySaved)),
                  );
                },
                child: Text(l10n.commonSave),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TransferTaskTile extends StatelessWidget {
  final TransferTask task;
  final VoidCallback? onOpenFile;

  const _TransferTaskTile({
    required this.task,
    this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  task.type == TransferType.upload
                      ? Icons.upload_file
                      : Icons.download,
                  color: _getStatusColor(task.status, theme),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.fileName ?? task.path.split('/').last,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatSize(task.totalSize),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context, theme),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: task.progress,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  _getStatusColor(task.status, theme),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  task.progressPercent,
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  _getStatusText(task.status, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(task.status, theme),
                  ),
                ),
              ],
            ),
            if (task.error != null) ...[
              const SizedBox(height: 8),
              Text(
                task.error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(task.status, theme).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(task.status, context.l10n),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(task.status, theme),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(BuildContext context) {
    final manager = context.read<TransferManager>();
    final l10n = context.l10n;
    final buttons = <Widget>[];

    switch (task.status) {
      case TransferStatus.running:
        buttons.addAll([
          TextButton.icon(
            icon: const Icon(Icons.pause),
            label: Text(l10n.transferPause),
            onPressed: () => manager.pauseTask(task.id),
          ),
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: Text(l10n.transferCancel),
            onPressed: () => manager.cancelTask(task.id),
          ),
        ]);
        break;
      case TransferStatus.paused:
      case TransferStatus.failed:
        buttons.addAll([
          TextButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.transferResume),
            onPressed: () => manager.resumeTask(task.id),
          ),
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: Text(l10n.transferCancel),
            onPressed: () => manager.cancelTask(task.id),
          ),
        ]);
        break;
      case TransferStatus.pending:
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: Text(l10n.transferCancel),
            onPressed: () => manager.cancelTask(task.id),
          ),
        );
        break;
      case TransferStatus.completed:
        if (onOpenFile != null) {
          buttons.add(
            TextButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text(l10n.transferOpenLocation),
              onPressed: onOpenFile,
            ),
          );
        }
        break;
      case TransferStatus.cancelled:
        break;
    }

    return buttons;
  }

  Color _getStatusColor(TransferStatus status, ThemeData theme) {
    switch (status) {
      case TransferStatus.running:
        return theme.colorScheme.primary;
      case TransferStatus.paused:
        return theme.colorScheme.tertiary;
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.failed:
        return theme.colorScheme.error;
      case TransferStatus.cancelled:
        return theme.colorScheme.outline;
      case TransferStatus.pending:
        return theme.colorScheme.secondary;
    }
  }

  String _getStatusText(TransferStatus status, AppLocalizations l10n) {
    switch (status) {
      case TransferStatus.running:
        return l10n.transferStatusRunning;
      case TransferStatus.paused:
        return l10n.transferStatusPaused;
      case TransferStatus.completed:
        return l10n.transferStatusCompleted;
      case TransferStatus.failed:
        return l10n.transferStatusFailed;
      case TransferStatus.cancelled:
        return l10n.transferStatusCancelled;
      case TransferStatus.pending:
        return l10n.transferStatusPending;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }
}
