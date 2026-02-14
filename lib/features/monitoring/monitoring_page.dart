import 'package:flutter/material.dart';
import 'package:onepanelapp_app/core/i18n/l10n_x.dart';
import 'package:onepanelapp_app/core/network/api_client_manager.dart';
import 'package:onepanelapp_app/core/theme/app_design_tokens.dart';
import 'package:onepanelapp_app/data/models/monitoring_models.dart';
import 'package:onepanelapp_app/shared/widgets/app_card.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  bool _loading = false;
  String? _error;
  SystemMetrics? _cpuMetrics;
  SystemMetrics? _memoryMetrics;
  SystemMetrics? _diskMetrics;
  List<NetworkMetrics> _networkMetrics = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = await ApiClientManager.instance.getMonitorApi();
      final cpuResponse = await api.getSystemMetrics(metricType: MetricType.cpu);
      final memoryResponse = await api.getSystemMetrics(metricType: MetricType.memory);
      final diskResponse = await api.getSystemMetrics(metricType: MetricType.disk);
      final networkResponse = await api.getNetworkMetrics();

      setState(() {
        _cpuMetrics = cpuResponse.data;
        _memoryMetrics = memoryResponse.data;
        _diskMetrics = diskResponse.data;
        _networkMetrics = networkResponse.data ?? [];
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serverModuleMonitoring),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loading ? null : _load,
            tooltip: l10n.commonRefresh,
          ),
        ],
      ),
      body: Padding(
        padding: AppDesignTokens.pagePadding,
        child: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = context.l10n;

    if (_error != null && _cpuMetrics == null && _memoryMetrics == null && _diskMetrics == null && _networkMetrics.isEmpty) {
      return _ErrorView(
        title: l10n.commonLoadFailedTitle,
        error: _error!,
        onRetry: _load,
      );
    }

    if (_loading && _cpuMetrics == null && _memoryMetrics == null && _diskMetrics == null && _networkMetrics.isEmpty) {
      return const _LoadingView();
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        children: [
          _MetricCard(
            title: l10n.serverCpuLabel,
            metrics: _cpuMetrics,
            currentLabel: l10n.monitorMetricCurrent,
            minLabel: l10n.monitorMetricMin,
            avgLabel: l10n.monitorMetricAvg,
            maxLabel: l10n.monitorMetricMax,
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          _MetricCard(
            title: l10n.serverMemoryLabel,
            metrics: _memoryMetrics,
            currentLabel: l10n.monitorMetricCurrent,
            minLabel: l10n.monitorMetricMin,
            avgLabel: l10n.monitorMetricAvg,
            maxLabel: l10n.monitorMetricMax,
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          _MetricCard(
            title: l10n.serverDiskLabel,
            metrics: _diskMetrics,
            currentLabel: l10n.monitorMetricCurrent,
            minLabel: l10n.monitorMetricMin,
            avgLabel: l10n.monitorMetricAvg,
            maxLabel: l10n.monitorMetricMax,
          ),
          const SizedBox(height: AppDesignTokens.spacingMd),
          if (_networkMetrics.isEmpty)
            _EmptyView(title: l10n.commonEmpty)
          else
            ..._networkMetrics.map(
              (metric) => Padding(
                padding: const EdgeInsets.only(bottom: AppDesignTokens.spacingSm),
                child: AppCard(
                  title: metric.interface ?? '',
                  subtitle: _buildNetworkSubtitle(context, metric),
                  child: _buildNetworkDetail(context, metric),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget? _buildNetworkSubtitle(BuildContext context, NetworkMetrics metric) {
    final l10n = context.l10n;
    final parts = <String>[];
    if (metric.receiveSpeed != null) {
      parts.add('↓ ${metric.receiveSpeed!.toStringAsFixed(2)}');
    }
    if (metric.transmitSpeed != null) {
      parts.add('↑ ${metric.transmitSpeed!.toStringAsFixed(2)}');
    }
    if (parts.isEmpty) {
      return null;
    }
    return Text('${l10n.monitorNetworkLabel} · ${parts.join(' · ')}');
  }

  Widget _buildNetworkDetail(BuildContext context, NetworkMetrics metric) {
    return Wrap(
      spacing: AppDesignTokens.spacingSm,
      runSpacing: AppDesignTokens.spacingSm,
      children: [
        _MetricIconValue(
          icon: Icons.download_outlined,
          value: _formatBytes(metric.bytesReceived),
        ),
        _MetricIconValue(
          icon: Icons.upload_outlined,
          value: _formatBytes(metric.bytesSent),
        ),
      ],
    );
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) {
      return '--';
    }
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = bytes.toDouble();
    int index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(1)} ${units[index]}';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.metrics,
    required this.currentLabel,
    required this.minLabel,
    required this.avgLabel,
    required this.maxLabel,
  });

  final String title;
  final SystemMetrics? metrics;
  final String currentLabel;
  final String minLabel;
  final String avgLabel;
  final String maxLabel;

  @override
  Widget build(BuildContext context) {
    final unit = metrics?.unit;
    final current = _formatMetricValue(metrics?.current, unit);
    final minValue = _formatMetricValue(metrics?.min, unit);
    final avgValue = _formatMetricValue(metrics?.avg, unit);
    final maxValue = _formatMetricValue(metrics?.max, unit);
    final values = metrics?.dataPoints
            ?.map((point) => point.value)
            .whereType<double>()
            .toList() ??
        const [];
    return AppCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            current,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          if (values.length > 1) ...[
            SizedBox(
              height: 64,
              child: CustomPaint(
                painter: _MetricSparklinePainter(
                  values: values,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppDesignTokens.spacingSm),
          ],
          Wrap(
            spacing: AppDesignTokens.spacingSm,
            runSpacing: AppDesignTokens.spacingSm,
            children: [
              _MetricStatChip(label: currentLabel, value: current),
              _MetricStatChip(label: minLabel, value: minValue),
              _MetricStatChip(label: avgLabel, value: avgValue),
              _MetricStatChip(label: maxLabel, value: maxValue),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMetricValue(double? value, String? unit) {
    if (value == null) {
      return '--';
    }
    final fixed = value.toStringAsFixed(2);
    if (unit == null || unit.isEmpty) {
      return fixed;
    }
    return '$fixed $unit';
  }
}

class _MetricStatChip extends StatelessWidget {
  const _MetricStatChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
    );
  }
}

class _MetricIconValue extends StatelessWidget {
  const _MetricIconValue({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(value),
    );
  }
}

class _MetricSparklinePainter extends CustomPainter {
  _MetricSparklinePainter({
    required this.values,
    required this.color,
  });

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = maxValue - minValue == 0 ? 1 : maxValue - minValue;
    final points = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final dx = size.width * i / (values.length - 1);
      final normalized = (values[i] - minValue) / span;
      final dy = size.height - normalized * size.height;
      points.add(Offset(dx, dy));
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MetricSparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48),
          const SizedBox(height: AppDesignTokens.spacingMd),
          Text(title),
        ],
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
