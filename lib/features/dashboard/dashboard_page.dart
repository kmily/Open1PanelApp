/// 仪表盘页面
/// 
/// 此文件定义仪表盘页面，显示系统概览和实时监控数据。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/app_card.dart';
import '../../widgets/main_layout.dart';
import 'dashboard_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时获取数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('仪表盘'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<DashboardProvider>().refresh();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ],
        ),
        body: Consumer<DashboardProvider>(
          builder: (context, provider, child) {
            final data = provider.data;

            // 显示错误
            if (data.error != null) {
              return _ErrorView(
                error: data.error!,
                onRetry: () => provider.loadData(),
              );
            }

            // 显示加载状态
            if (data.isLoading && data.baseInfo == null) {
              return const _LoadingView();
            }

            return RefreshIndicator(
              onRefresh: () => provider.refresh(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 服务器信息卡片
                    _ServerInfoCard(data: data),
                    const SizedBox(height: 16),
                    
                    // 系统资源卡片
                    _ResourceCard(data: data),
                    const SizedBox(height: 16),
                    
                    // 快速操作卡片
                    const _QuickActionsCard(),
                    const SizedBox(height: 16),
                    
                    // 最近活动卡片
                    _ActivityCard(activities: data.activities),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 加载中视图
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('加载中...'),
        ],
      ),
    );
  }
}

/// 错误视图
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '加载失败',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 服务器信息卡片
class _ServerInfoCard extends StatelessWidget {
  final DashboardData data;

  const _ServerInfoCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final baseInfo = data.baseInfo;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      title: '服务器信息',
      subtitle: Text(
        baseInfo != null ? '运行正常' : '连接中...',
        style: TextStyle(
          color: baseInfo != null ? Colors.green : Colors.orange,
        ),
      ),
      trailing: Icon(
        Icons.computer,
        color: baseInfo != null ? Colors.green : Colors.orange,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            label: '主机名',
            value: baseInfo?.hostName ?? '--',
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: '操作系统',
            value: _formatOsInfo(baseInfo),
          ),
          const SizedBox(height: 8),
          _InfoRow(
            label: '运行时间',
            value: data.uptime,
          ),
          if (data.lastUpdated != null) ...[
            const SizedBox(height: 8),
            Text(
              '更新时间: ${_formatTime(data.lastUpdated!)}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatOsInfo(HostBaseInfo? info) {
    if (info == null) return '--';
    final os = info.os ?? 'Unknown';
    final platform = info.platform ?? '';
    final platformVersion = info.platformVersion ?? '';
    if (platform.isNotEmpty && platformVersion.isNotEmpty) {
      return '$os $platform $platformVersion';
    }
    return os;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

/// 信息行组件
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// 系统资源卡片
class _ResourceCard extends StatelessWidget {
  final DashboardData data;

  const _ResourceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: '系统资源',
      child: Column(
        children: [
          _ResourceItem(
            title: 'CPU使用率',
            value: data.cpuPercent != null
                ? '${data.cpuPercent!.toStringAsFixed(1)}%'
                : '--',
            percent: data.cpuPercent,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _ResourceItem(
            title: '内存使用率',
            value: data.memoryPercent != null
                ? '${data.memoryPercent!.toStringAsFixed(1)}%'
                : '--',
            subtitle: data.memoryUsage,
            percent: data.memoryPercent,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _ResourceItem(
            title: '磁盘使用率',
            value: data.diskPercent != null
                ? '${data.diskPercent!.toStringAsFixed(1)}%'
                : '--',
            subtitle: data.diskUsage,
            percent: data.diskPercent,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}

/// 资源使用项组件
class _ResourceItem extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double? percent;
  final Color color;

  const _ResourceItem({
    required this.title,
    required this.value,
    this.subtitle,
    this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (percent != null) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent! / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ],
    );
  }
}

/// 快速操作卡片
class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: '快速操作',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          _QuickActionItem(
            icon: Icons.restart_alt,
            label: '重启服务器',
            color: Colors.red,
            onTap: () => _showRestartDialog(context),
          ),
          _QuickActionItem(
            icon: Icons.update,
            label: '系统更新',
            color: Colors.blue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('系统更新功能开发中')),
              );
            },
          ),
          _QuickActionItem(
            icon: Icons.backup,
            label: '创建备份',
            color: Colors.green,
            onTap: () {
              Navigator.pushNamed(context, '/backups');
            },
          ),
          _QuickActionItem(
            icon: Icons.security,
            label: '安全检查',
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, '/security');
            },
          ),
        ],
      ),
    );
  }

  void _showRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重启服务器'),
        content: const Text('确定要重启服务器吗？这将导致所有服务暂时不可用。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 调用重启API
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('重启请求已发送')),
              );
            },
            child: const Text('确认重启'),
          ),
        ],
      ),
    );
  }
}

/// 快速操作项组件
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 活动卡片
class _ActivityCard extends StatelessWidget {
  final List<DashboardActivity> activities;

  const _ActivityCard({required this.activities});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: '最近活动',
      child: activities.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无活动记录'),
              ),
            )
          : Column(
              children: activities.map((activity) {
                return _ActivityItem(
                  title: activity.title,
                  description: activity.description,
                  time: _formatTimeAgo(activity.time),
                  type: activity.type,
                );
              }).toList(),
            ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

/// 活动项组件
class _ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final ActivityType type;

  const _ActivityItem({
    required this.title,
    required this.description,
    required this.time,
    this.type = ActivityType.info,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTypeIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIcon() {
    IconData iconData;
    Color color;

    switch (type) {
      case ActivityType.success:
        iconData = Icons.check_circle;
        color = Colors.green;
        break;
      case ActivityType.warning:
        iconData = Icons.warning;
        color = Colors.orange;
        break;
      case ActivityType.error:
        iconData = Icons.error;
        color = Colors.red;
        break;
      case ActivityType.info:
      default:
        iconData = Icons.info;
        color = Colors.blue;
        break;
    }

    return Icon(iconData, color: color, size: 20);
  }
}
