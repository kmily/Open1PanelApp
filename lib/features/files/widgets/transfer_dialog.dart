import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/services/transfer/transfer_task.dart';
import 'package:onepanelapp_app/core/services/transfer/transfer_manager.dart';

class TransferListPage extends StatelessWidget {
  const TransferListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transferListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () {
              context.read<TransferManager>().clearCompleted();
            },
            tooltip: l10n.transferClearCompleted,
          ),
        ],
      ),
      body: Consumer<TransferManager>(
        builder: (context, manager, _) {
          final allTasks = manager.allTasks;
          
          if (allTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.transferEmpty,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: allTasks.length,
            itemBuilder: (context, index) {
              final task = allTasks[index];
              return _TransferTaskTile(task: task);
            },
          );
        },
      ),
    );
  }
}

class _TransferTaskTile extends StatelessWidget {
  final TransferTask task;
  
  const _TransferTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        task.type == TransferType.upload
            ? Icons.upload_file
            : Icons.download,
        color: _getStatusColor(task.status, theme),
      ),
      title: Text(
        task.fileName ?? task.path.split('/').last,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: task.progress,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(_getStatusColor(task.status, theme)),
          ),
          const SizedBox(height: 4),
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
        ],
      ),
      trailing: _buildTrailingButton(context),
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    final manager = context.read<TransferManager>();
    
    switch (task.status) {
      case TransferStatus.running:
        return IconButton(
          icon: const Icon(Icons.pause),
          onPressed: () => manager.pauseTask(task.id),
        );
      case TransferStatus.paused:
      case TransferStatus.failed:
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: () => manager.resumeTask(task.id),
        );
      case TransferStatus.pending:
        return IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => manager.cancelTask(task.id),
        );
      case TransferStatus.completed:
      case TransferStatus.cancelled:
        return const Icon(Icons.check_circle_outline, color: Colors.green);
    }
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
}

class TransferProgressDialog extends StatelessWidget {
  final TransferTask task;
  
  const TransferProgressDialog({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(
        task.type == TransferType.upload
            ? l10n.transferUploading
            : l10n.transferDownloading,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.fileName ?? task.path.split('/').last,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: task.progress),
          const SizedBox(height: 8),
          Text(
            '${task.progressPercent} (${task.completedChunks}/${task.totalChunks} ${l10n.transferChunks})',
          ),
          if (task.speed != null) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.transferSpeed}: ${_formatSpeed(task.speed!)}',
            ),
          ],
          if (task.eta != null) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.transferEta}: ${_formatEta(task.eta!)}',
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<TransferManager>().cancelTask(task.id);
          },
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }

  String _formatSpeed(double speed) {
    if (speed < 1024) {
      return '${speed.toStringAsFixed(0)} B/s';
    } else if (speed < 1024 * 1024) {
      return '${(speed / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(speed / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  String _formatEta(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m ${secs}s';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }
}
