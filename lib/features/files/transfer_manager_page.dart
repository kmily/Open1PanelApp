import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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
  List<DownloadTask>? _downloadTasks;
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTasks();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }
  
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadTasks();
    });
  }
  
  Future<void> _loadTasks() async {
    final tasks = await TransferManager().getDownloaderTasks();
    if (mounted) {
      setState(() {
        _downloadTasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transferManagerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: l10n.commonRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearDialog(context),
            tooltip: l10n.transferClearCompleted,
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDownloadTaskList(context, _getActiveDownloads(), l10n, theme),
                Consumer<TransferManager>(
                  builder: (context, manager, _) {
                    return _buildUploadTaskList(context, manager.pendingTasks, l10n, theme);
                  },
                ),
                _buildDownloadTaskList(context, _getCompletedDownloads(), l10n, theme),
              ],
            ),
    );
  }
  
  List<DownloadTask> _getActiveDownloads() {
    if (_downloadTasks == null) return [];
    return _downloadTasks!
        .where(
          (t) =>
              t.status == DownloadTaskStatus.running ||
              t.status == DownloadTaskStatus.paused ||
              t.status == DownloadTaskStatus.enqueued ||
              (t.status == DownloadTaskStatus.failed && t.progress != 100),
        )
        .toList();
  }
  
  List<DownloadTask> _getCompletedDownloads() {
    if (_downloadTasks == null) return [];
    return _downloadTasks!
        .where(
          (t) =>
              t.status == DownloadTaskStatus.complete ||
              t.status == DownloadTaskStatus.canceled ||
              (t.status == DownloadTaskStatus.failed && t.progress == 100),
        )
        .toList();
  }

  Widget _buildDownloadTaskList(
    BuildContext context,
    List<DownloadTask> tasks,
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
        return _DownloadTaskTile(
          task: task,
          onRefresh: _loadTasks,
        );
      },
    );
  }
  
  Widget _buildUploadTaskList(
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
        return _UploadTaskTile(task: task);
      },
    );
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
            onPressed: () async {
              await TransferManager().clearCompleted();
              if (context.mounted) Navigator.pop(context);
              _loadTasks();
            },
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
  }
}

class _DownloadTaskTile extends StatelessWidget {
  final DownloadTask task;
  final VoidCallback onRefresh;

  const _DownloadTaskTile({
    required this.task,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final displayStatus = _getDisplayStatus(task);

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
                  Icons.download,
                  color: _getStatusColor(displayStatus, theme),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.filename ?? l10n.systemSettingsUnknown,
                        style: theme.textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.savedDir.split('/').last,
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
                value: task.progress / 100,
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(
                  _getStatusColor(displayStatus, theme),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${task.progress}%',
                  style: theme.textTheme.bodySmall,
                ),
                const Spacer(),
                Text(
                  _getStatusText(displayStatus, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(displayStatus, theme),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _buildActionButtons(context, displayStatus),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, ThemeData theme) {
    final displayStatus = _getDisplayStatus(task);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(displayStatus, theme).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(displayStatus, context.l10n),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(displayStatus, theme),
        ),
      ),
    );
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    DownloadTaskStatus displayStatus,
  ) {
    final manager = TransferManager();
    final l10n = context.l10n;
    final buttons = <Widget>[];

    switch (displayStatus) {
      case DownloadTaskStatus.running:
        buttons.addAll([
          TextButton.icon(
            icon: const Icon(Icons.pause),
            label: Text(l10n.transferPause),
            onPressed: () async {
              await manager.pauseDownloadTask(task.taskId);
              onRefresh();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: Text(l10n.transferCancel),
            onPressed: () async {
              await manager.cancelDownloadTask(task.taskId);
              onRefresh();
            },
          ),
        ]);
        break;
      case DownloadTaskStatus.paused:
        buttons.addAll([
          TextButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.transferResume),
            onPressed: () async {
              await manager.resumeDownloadTask(task.taskId);
              onRefresh();
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: Text(l10n.transferCancel),
            onPressed: () async {
              await manager.cancelDownloadTask(task.taskId);
              onRefresh();
            },
          ),
        ]);
        break;
      case DownloadTaskStatus.failed:
        buttons.addAll([
          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(l10n.commonRetry),
            onPressed: () async {
              final result = await manager.retryDownloadTaskWithNewAuth(task);
              if (!context.mounted) return;
              switch (result) {
                case RetryDownloadTaskWithNewAuthResult.recreated:
                  onRefresh();
                  break;
                case RetryDownloadTaskWithNewAuthResult.fileAlreadyDownloaded:
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.transferFileAlreadyDownloaded)),
                  );
                  onRefresh();
                  break;
                case RetryDownloadTaskWithNewAuthResult.failed:
                  break;
              }
            },
          ),
          TextButton.icon(
            icon: const Icon(Icons.delete),
            label: Text(l10n.commonDelete),
            onPressed: () async {
              await manager.deleteDownloadTask(task.taskId);
              onRefresh();
            },
          ),
        ]);
        break;
      case DownloadTaskStatus.complete:
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.folder_open),
            label: Text(l10n.transferOpenLocation),
            onPressed: () => _openFile(context),
          ),
        );
        break;
      case DownloadTaskStatus.canceled:
      case DownloadTaskStatus.undefined:
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.delete),
            label: Text(l10n.commonDelete),
            onPressed: () async {
              await manager.deleteDownloadTask(task.taskId);
              onRefresh();
            },
          ),
        );
        break;
      case DownloadTaskStatus.enqueued:
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: Text(l10n.transferCancel),
            onPressed: () async {
              await manager.cancelDownloadTask(task.taskId);
              onRefresh();
            },
          ),
        );
        break;
    }

    return buttons;
  }
  
  DownloadTaskStatus _getDisplayStatus(DownloadTask task) {
    if (task.status == DownloadTaskStatus.failed && task.progress == 100) {
      return DownloadTaskStatus.complete;
    }
    return task.status;
  }
  
  Future<void> _openFile(BuildContext context) async {
    final l10n = context.l10n;
    try {
      final filePath = '${task.savedDir}/${task.filename}';
      final file = File(filePath);
      if (!await file.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.transferFileNotFound)),
          );
        }
        return;
      }

      final fileSaveService = FileSaveService();
      await fileSaveService.openFileLocation(filePath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transferFileLocationOpened)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.transferOpenFileError}: $e')),
        );
      }
    }
  }

  Color _getStatusColor(DownloadTaskStatus status, ThemeData theme) {
    switch (status) {
      case DownloadTaskStatus.running:
      case DownloadTaskStatus.enqueued:
        return theme.colorScheme.primary;
      case DownloadTaskStatus.paused:
        return theme.colorScheme.tertiary;
      case DownloadTaskStatus.complete:
        return theme.colorScheme.secondary;
      case DownloadTaskStatus.failed:
        return theme.colorScheme.error;
      case DownloadTaskStatus.canceled:
      case DownloadTaskStatus.undefined:
        return theme.colorScheme.outline;
    }
  }

  String _getStatusText(DownloadTaskStatus status, AppLocalizations l10n) {
    switch (status) {
      case DownloadTaskStatus.running:
        return l10n.transferStatusRunning;
      case DownloadTaskStatus.paused:
        return l10n.transferStatusPaused;
      case DownloadTaskStatus.complete:
        return l10n.transferStatusCompleted;
      case DownloadTaskStatus.failed:
        return l10n.transferStatusFailed;
      case DownloadTaskStatus.canceled:
        return l10n.transferStatusCancelled;
      case DownloadTaskStatus.enqueued:
        return l10n.transferStatusPending;
      case DownloadTaskStatus.undefined:
        return l10n.transferStatusFailed;
    }
  }
}

class _UploadTaskTile extends StatelessWidget {
  final TransferTask task;

  const _UploadTaskTile({
    required this.task,
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
                  Icons.upload_file,
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
        color: _getStatusColor(task.status, theme).withValues(alpha: 0.1),
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
            onPressed: () => manager.cancelUploadTask(task.id),
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
            onPressed: () => manager.cancelUploadTask(task.id),
          ),
        ]);
        break;
      case TransferStatus.pending:
        buttons.add(
          TextButton.icon(
            icon: const Icon(Icons.close),
            label: Text(l10n.transferCancel),
            onPressed: () => manager.cancelUploadTask(task.id),
          ),
        );
        break;
      case TransferStatus.completed:
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
