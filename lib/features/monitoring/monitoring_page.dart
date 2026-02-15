import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/shared/widgets/app_card.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/monitor_repository.dart';
import 'monitoring_provider.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<MonitoringProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serverModuleMonitoring),
        actions: [
          Consumer<MonitoringProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: provider.data.isLoading ? null : provider.refresh,
              tooltip: l10n.commonRefresh,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: AppDesignTokens.pagePadding,
        child: Consumer<MonitoringProvider>(
          builder: (context, provider, _) {
            return _buildBody(context, provider.data, provider.refresh);
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MonitoringData data,
    Future<void> Function() onRefresh,
  ) {
    final l10n = context.l10n;
    final hasData = data.currentMetrics != null || 
        data.cpuTimeSeries != null || 
        data.memoryTimeSeries != null;

    if (data.error != null && !hasData) {
      return _ErrorView(
        title: l10n.commonLoadFailedTitle,
        error: data.error!,
        onRetry: onRefresh,
      );
    }

    if (data.isLoading && !hasData) {
      return const _LoadingView();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          _buildCurrentMetrics(context, data.currentMetrics),
          const SizedBox(height: AppDesignTokens.spacingMd),
          _buildTimeSeriesCard(
            context, 
            l10n.serverCpuLabel, 
            data.cpuTimeSeries,
            '%',
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          _buildTimeSeriesCard(
            context, 
            l10n.serverMemoryLabel, 
            data.memoryTimeSeries,
            '%',
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          _buildTimeSeriesCard(
            context, 
            'Load', 
            data.loadTimeSeries,
            '',
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          _buildTimeSeriesCard(
            context, 
            l10n.serverDiskLabel, 
            data.ioTimeSeries,
            '%',
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          _buildTimeSeriesCard(
            context, 
            l10n.monitorNetworkLabel, 
            data.networkTimeSeries,
            'KB/s',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMetrics(BuildContext context, MonitorMetricsSnapshot? metrics) {
    final l10n = context.l10n;
    if (metrics == null) return const SizedBox.shrink();

    return AppCard(
      title: l10n.monitorMetricCurrent,
      child: Wrap(
        spacing: AppDesignTokens.spacingMd,
        runSpacing: AppDesignTokens.spacingSm,
        children: [
          _MetricChip(
            label: l10n.serverCpuLabel,
            value: metrics.cpuPercent != null 
                ? '${metrics.cpuPercent!.toStringAsFixed(1)}%' 
                : '--',
            icon: Icons.memory_outlined,
          ),
          _MetricChip(
            label: l10n.serverMemoryLabel,
            value: metrics.memoryPercent != null 
                ? '${metrics.memoryPercent!.toStringAsFixed(1)}%' 
                : '--',
            icon: Icons.storage_outlined,
          ),
          _MetricChip(
            label: l10n.serverDiskLabel,
            value: metrics.diskPercent != null 
                ? '${metrics.diskPercent!.toStringAsFixed(1)}%' 
                : '--',
            icon: Icons.folder_outlined,
          ),
          _MetricChip(
            label: 'Load',
            value: metrics.load1 != null 
                ? metrics.load1!.toStringAsFixed(2) 
                : '--',
            icon: Icons.speed_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeriesCard(
    BuildContext context,
    String title,
    MonitorTimeSeries? timeSeries,
    String unit,
  ) {
    final l10n = context.l10n;
    
    return AppCard(
      title: title,
      subtitle: timeSeries != null && timeSeries.data.isNotEmpty
          ? Text('Points: ${timeSeries.data.length}')
          : null,
      child: timeSeries == null || timeSeries.data.isEmpty
          ? _EmptyView(title: l10n.commonEmpty)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsRow(context, timeSeries, unit),
                const SizedBox(height: AppDesignTokens.spacingSm),
                _buildSimpleChart(context, timeSeries, unit),
              ],
            ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    MonitorTimeSeries timeSeries,
    String unit,
  ) {
    final l10n = context.l10n;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          label: l10n.monitorMetricMin,
          value: timeSeries.min != null 
              ? '${timeSeries.min!.toStringAsFixed(1)}$unit' 
              : '--',
        ),
        _StatItem(
          label: l10n.monitorMetricAvg,
          value: timeSeries.avg != null 
              ? '${timeSeries.avg!.toStringAsFixed(1)}$unit' 
              : '--',
        ),
        _StatItem(
          label: l10n.monitorMetricMax,
          value: timeSeries.max != null 
              ? '${timeSeries.max!.toStringAsFixed(1)}$unit' 
              : '--',
        ),
      ],
    );
  }

  Widget _buildSimpleChart(
    BuildContext context,
    MonitorTimeSeries timeSeries,
    String unit,
  ) {
    if (timeSeries.data.isEmpty) return const SizedBox.shrink();

    final values = timeSeries.data.map((e) => e.value).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    final safeRange = range == 0 ? 1.0 : range;

    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _SimpleChartPainter(
          values: values,
          minVal: minVal,
          range: safeRange,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label: $value'),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  final List<double> values;
  final double minVal;
  final double range;
  final Color color;

  _SimpleChartPainter({
    required this.values,
    required this.minVal,
    required this.range,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final x = i * stepX;
      final y = size.height - ((values[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.minVal != minVal ||
        oldDelegate.range != range ||
        oldDelegate.color != color;
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppDesignTokens.spacingMd),
          Text(l10n.commonLoading),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
        child: Text(title),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDesignTokens.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: AppDesignTokens.spacingMd),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDesignTokens.spacingSm),
            Text(
              error,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDesignTokens.spacingLg),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}
