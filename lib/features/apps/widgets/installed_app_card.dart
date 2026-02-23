import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:onepanelapp_app/config/app_router.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import '../../../data/models/app_models.dart';
import '../../../shared/widgets/app_card.dart';
import 'app_icon.dart';

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
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final isRunning = app.status?.toLowerCase() == 'running';
    final statusColor = isRunning ? Colors.green : Colors.orange;

    final List<String> ports = [];
    if (app.httpPort != null && app.httpPort != 0) ports.add('${app.httpPort} (HTTP)');
    if (app.httpsPort != null && app.httpsPort != 0) ports.add('${app.httpsPort} (HTTPS)');
    final portsString = ports.join(', ');

    return AppCard(
      leading: AppIcon(
        appId: app.appId,
        appKey: app.appKey,
        iconUrl: app.icon,
        size: 48,
      ),
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
        status: isRunning ? l10n.appStatusRunning : l10n.appStatusStopped,
        color: statusColor,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.installedAppDetail,
          arguments: app,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (app.container != null && app.container!.isNotEmpty)
            _InfoRow(
              label: l10n.appInstallContainerName,
              value: app.container!,
              colorScheme: colorScheme,
            ),
          if (portsString.isNotEmpty) ...[
            const SizedBox(height: 4),
            _InfoRow(
              label: l10n.appInstallPorts,
              value: portsString,
              colorScheme: colorScheme,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (app.webUI != null && app.webUI!.isNotEmpty) ...[
                _ActionButton(
                  icon: Icons.web,
                  label: l10n.appActionWeb,
                  color: colorScheme.primary,
                  onTap: () => _openWeb(context, app.webUI!),
                ),
                const SizedBox(width: 8),
              ],
              if (isRunning) ...[
                _ActionButton(
                  icon: Icons.stop,
                  label: l10n.appActionStop,
                  color: Colors.orange,
                  onTap: onStop,
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.restart_alt,
                  label: l10n.appActionRestart,
                  color: colorScheme.primary,
                  onTap: onRestart,
                ),
              ] else ...[
                _ActionButton(
                  icon: Icons.play_arrow,
                  label: l10n.appActionStart,
                  color: Colors.green,
                  onTap: onStart,
                ),
              ],
              const SizedBox(width: 8),
              _ActionButton(
                icon: Icons.delete_outline,
                label: l10n.appActionUninstall,
                color: Colors.red,
                onTap: onUninstall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openWeb(BuildContext context, String urlString) async {
    final Uri? url = Uri.tryParse(urlString);
    if (url != null) {
      try {
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch $url')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to open web: $e')),
          );
        }
      }
    }
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

/// 信息行
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              color: colorScheme.outline,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
