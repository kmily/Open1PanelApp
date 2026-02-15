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
      final provider = context.read<MonitoringProvider>();
      provider.load();
      // 默认启用自动刷新
      provider.toggleAutoRefresh(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.serverModuleMonitoring),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.show_chart),
            tooltip: l10n.monitorDataPoints,
            onSelected: (count) {
              context.read<MonitoringProvider>().setMaxDataPoints(count);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 6,
                child: Text(l10n.monitorDataPointsCount(6, l10n.monitorTimeMinutes(30))),
              ),
              PopupMenuItem(
                value: 12,
                child: Text(l10n.monitorDataPointsCount(12, l10n.monitorTimeHours(1))),
              ),
            ],
          ),
          PopupMenuButton<Duration>(
            icon: const Icon(Icons.timer),
            tooltip: l10n.monitorRefreshInterval,
            onSelected: (duration) {
              context.read<MonitoringProvider>().setRefreshInterval(duration);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: const Duration(seconds: 3),
                child: Text(l10n.monitorSeconds(3)),
              ),
              PopupMenuItem(
                value: const Duration(seconds: 5),
                child: Text(l10n.monitorSecondsDefault(5)),
              ),
              PopupMenuItem(
                value: const Duration(seconds: 10),
                child: Text(l10n.monitorSeconds(10)),
              ),
              PopupMenuItem(
                value: const Duration(seconds: 30),
                child: Text(l10n.monitorSeconds(30)),
              ),
              PopupMenuItem(
                value: const Duration(minutes: 1),
                child: Text(l10n.monitorMinute(1)),
              ),
            ],
          ),
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
            l10n.serverLoadLabel,
            data.loadTimeSeries,
            '',
          ),
          const SizedBox(height: AppDesignTokens.spacingSm),
          _buildTimeSeriesCard(
            context,
            '${l10n.serverDiskLabel} IO',
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
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: AppDesignTokens.spacingSm,
        crossAxisSpacing: AppDesignTokens.spacingSm,
        childAspectRatio: 3.5,
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
            label: l10n.serverLoadLabel,
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
    return _ExpandableChartCard(
      title: title,
      timeSeries: timeSeries,
      unit: unit,
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
  final List<DateTime> times;
  final double minVal;
  final double range;
  final Color color;
  final String unit;

  _SimpleChartPainter({
    required this.values,
    required this.times,
    required this.minVal,
    required this.range,
    required this.color,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final leftPadding = 40.0; // Y轴标签空间
    final rightPadding = 16.0; // 右边距
    final bottomPadding = 24.0; // X轴标签空间
    final topPadding = 8.0; // 上边距
    
    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - bottomPadding - topPadding;

    // 绘制背景网格线
    _drawGrid(canvas, size, leftPadding, rightPadding, topPadding, bottomPadding, chartWidth, chartHeight);

    // 绘制坐标轴
    _drawAxes(canvas, size, leftPadding, rightPadding, topPadding, bottomPadding, chartWidth, chartHeight);

    // 绘制数据线
    _drawLine(canvas, leftPadding, rightPadding, topPadding, bottomPadding, chartWidth, chartHeight);

    // 绘制坐标轴标签
    _drawLabels(canvas, size, leftPadding, rightPadding, topPadding, bottomPadding, chartWidth, chartHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double leftPadding, double rightPadding, double topPadding, double bottomPadding, double chartWidth, double chartHeight) {
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    // 水平网格线 (5条，包括0%和100%)
    for (var i = 0; i <= 4; i++) {
      final y = topPadding + (chartHeight / 4) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    // 垂直网格线
    final stepX = chartWidth / (values.length - 1);
    final gridStep = (values.length ~/ 4).clamp(1, values.length);
    for (var i = 0; i < values.length; i += gridStep) {
      final x = leftPadding + i * stepX;
      canvas.drawLine(
        Offset(x, topPadding),
        Offset(x, topPadding + chartHeight),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, double leftPadding, double rightPadding, double topPadding, double bottomPadding, double chartWidth, double chartHeight) {
    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    // Y轴
    canvas.drawLine(
      Offset(leftPadding, topPadding),
      Offset(leftPadding, topPadding + chartHeight),
      axisPaint,
    );

    // X轴
    canvas.drawLine(
      Offset(leftPadding, topPadding + chartHeight),
      Offset(size.width - rightPadding, topPadding + chartHeight),
      axisPaint,
    );
  }

  void _drawLine(Canvas canvas, double leftPadding, double rightPadding, double topPadding, double bottomPadding, double chartWidth, double chartHeight) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = chartWidth / (values.length - 1);

    for (var i = 0; i < values.length; i++) {
      final x = leftPadding + i * stepX;
      final normalizedY = range == 0 ? 0.5 : (values[i] - minVal) / range;
      final y = topPadding + chartHeight - (normalizedY * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, topPadding + chartHeight);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(leftPadding + chartWidth, topPadding + chartHeight);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // 绘制数据点
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final maxValue = values.reduce((a, b) => a > b ? a : b);

    for (var i = 0; i < values.length; i++) {
      final x = leftPadding + i * stepX;
      final normalizedY = range == 0 ? 0.5 : (values[i] - minVal) / range;
      final y = topPadding + chartHeight - (normalizedY * chartHeight);

      // 只绘制第一个、最后一个和极值点
      if (i == 0 || i == values.length - 1 || values[i] == minVal || values[i] == maxValue) {
        canvas.drawCircle(Offset(x, y), 3, pointPaint);
        canvas.drawCircle(Offset(x, y), 5, paint..color = color.withValues(alpha: 0.3));
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size, double leftPadding, double rightPadding, double topPadding, double bottomPadding, double chartWidth, double chartHeight) {
    final labelStyle = TextStyle(
      color: Colors.grey.withValues(alpha: 0.8),
      fontSize: 10,
    );
    final labelPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Y轴标签 (5个)
    for (var i = 0; i <= 4; i++) {
      final value = minVal + (range * (4 - i) / 4);
      final label = '${value.toStringAsFixed(0)}$unit';
      
      labelPainter.text = TextSpan(text: label, style: labelStyle);
      labelPainter.layout();
      
      final y = topPadding + (chartHeight / 4) * i;
      labelPainter.paint(
        canvas,
        Offset(leftPadding - labelPainter.width - 4, y - labelPainter.height / 2),
      );
    }

    // X轴标签 (时间)
    if (times.isNotEmpty) {
      final timeStep = (values.length ~/ 4).clamp(1, values.length);
      for (var i = 0; i < values.length && i < times.length; i += timeStep) {
        final time = times[i].toLocal(); // 转换为本地时间
        final label = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
        
        labelPainter.text = TextSpan(text: label, style: labelStyle);
        labelPainter.layout();
        
        final stepX = chartWidth / (values.length - 1);
        final x = leftPadding + i * stepX;
        
        labelPainter.paint(
          canvas,
          Offset(x - labelPainter.width / 2, topPadding + chartHeight + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.times != times ||
        oldDelegate.minVal != minVal ||
        oldDelegate.range != range ||
        oldDelegate.color != color ||
        oldDelegate.unit != unit;
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

class _ExpandableChartCard extends StatefulWidget {
  final String title;
  final MonitorTimeSeries? timeSeries;
  final String unit;

  const _ExpandableChartCard({
    required this.title,
    required this.timeSeries,
    required this.unit,
  });

  @override
  State<_ExpandableChartCard> createState() => _ExpandableChartCardState();
}

class _ExpandableChartCardState extends State<_ExpandableChartCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final timeSeries = widget.timeSeries;

    return Card(
      child: Column(
        children: [
          // 标题栏（可点击折叠）
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (timeSeries != null && timeSeries.data.isNotEmpty)
                          Text(
                            l10n.monitorDataPointsLabel(timeSeries.data.length),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  // 当前值
                  if (timeSeries != null && timeSeries.data.isNotEmpty)
                    Text(
                      '${timeSeries.data.last.value.toStringAsFixed(1)}${widget.unit}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  const SizedBox(width: AppDesignTokens.spacingSm),
                  // 折叠图标
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                ],
              ),
            ),
          ),
          // 展开内容
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: timeSeries == null || timeSeries.data.isEmpty
                ? _EmptyView(title: l10n.commonEmpty)
                : Padding(
                    padding: const EdgeInsets.all(AppDesignTokens.spacingMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(context, timeSeries, widget.unit),
                        const SizedBox(height: AppDesignTokens.spacingSm),
                        _buildSimpleChart(context, timeSeries, widget.unit),
                      ],
                    ),
                  ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
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
    final times = timeSeries.data.map((e) => e.time).toList();
    final maxVal = values.reduce((a, b) => a > b ? a : b);
    final minVal = values.reduce((a, b) => a < b ? a : b);
    final range = maxVal - minVal;
    final safeRange = range == 0 ? 1.0 : range;

    return SizedBox(
      height: 140,
      child: CustomPaint(
        painter: _SimpleChartPainter(
          values: values,
          times: times,
          minVal: minVal,
          range: safeRange,
          color: Theme.of(context).colorScheme.primary,
          unit: unit,
        ),
        size: Size.infinite,
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
