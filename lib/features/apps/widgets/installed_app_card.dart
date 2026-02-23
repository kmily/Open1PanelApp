import 'package:flutter/material.dart';
import '../../../data/models/app_models.dart';
import '../../../shared/widgets/app_card.dart';

/// 已安装应用卡片
class InstalledAppCard extends StatelessWidget {
  final AppInstallInfo app;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRestart;
  final VoidCallback onUninstall;

  const InstalledAppCard({
    super.key,
    required this.app,
    required this.onStart,
    required this.onStop,
    required this.onRestart,
    required this.onUninstall,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = app.status?.toLowerCase() == 'running';
    final statusColor = isRunning ? Colors.green : Colors.orange;

    return AppCard(
      title: app.appName ?? app.name ?? '未命名应用',
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (app.name != null && app.name != app.appName)
            Text(
              app.name!,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          Text(app.version ?? '未知版本'),
        ],
      ),
      trailing: _StatusChip(
        status: isRunning ? '运行中' : '已停止',
        color: statusColor,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/app-detail',
          arguments: {'appId': app.id?.toString()},
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (app.version != null)
            Text(
              '版本: ${app.version}',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isRunning) ...[
                _ActionButton(
                  icon: Icons.stop,
                  label: '停止',
                  color: Colors.orange,
                  onTap: onStop,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.restart_alt,
                  label: '重启',
                  color: colorScheme.primary,
                  onTap: onRestart,
                ),
              ] else ...[
                _ActionButton(
                  icon: Icons.play_arrow,
                  label: '启动',
                  color: Colors.green,
                  onTap: onStart,
                ),
              ],
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.delete_outline,
                label: '卸载',
                color: Colors.red,
                onTap: onUninstall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 状态标签
class _StatusChip extends StatelessWidget {
  final String status;
  final Color color;

  const _StatusChip({
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 操作按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
