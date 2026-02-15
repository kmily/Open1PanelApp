import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/monitor_repository.dart';
import 'monitoring_service.dart';

/// 监控数据状态
class MonitoringData {
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final MonitorMetricsSnapshot? currentMetrics;
  final MonitorTimeSeries? cpuTimeSeries;
  final MonitorTimeSeries? memoryTimeSeries;
  final MonitorTimeSeries? loadTimeSeries;
  final MonitorTimeSeries? ioTimeSeries;
  final MonitorTimeSeries? networkTimeSeries;
  final DateTime? lastUpdated;

  const MonitoringData({
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
    this.currentMetrics,
    this.cpuTimeSeries,
    this.memoryTimeSeries,
    this.loadTimeSeries,
    this.ioTimeSeries,
    this.networkTimeSeries,
    this.lastUpdated,
  });

  MonitoringData copyWith({
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    MonitorMetricsSnapshot? currentMetrics,
    MonitorTimeSeries? cpuTimeSeries,
    MonitorTimeSeries? memoryTimeSeries,
    MonitorTimeSeries? loadTimeSeries,
    MonitorTimeSeries? ioTimeSeries,
    MonitorTimeSeries? networkTimeSeries,
    DateTime? lastUpdated,
  }) {
    return MonitoringData(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
      currentMetrics: currentMetrics ?? this.currentMetrics,
      cpuTimeSeries: cpuTimeSeries ?? this.cpuTimeSeries,
      memoryTimeSeries: memoryTimeSeries ?? this.memoryTimeSeries,
      loadTimeSeries: loadTimeSeries ?? this.loadTimeSeries,
      ioTimeSeries: ioTimeSeries ?? this.ioTimeSeries,
      networkTimeSeries: networkTimeSeries ?? this.networkTimeSeries,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 监控数据Provider
/// 
/// 用于MonitoringPage的状态管理
class MonitoringProvider extends ChangeNotifier {
  MonitoringProvider({MonitoringService? service}) : _service = service;

  MonitoringService? _service;
  Timer? _refreshTimer;

  MonitoringData _data = const MonitoringData();
  
  // 自动刷新设置
  Duration _refreshInterval = const Duration(seconds: 5);
  bool _autoRefreshEnabled = false;
  int _maxDataPoints = 6;

  MonitoringData get data => _data;
  Duration get refreshInterval => _refreshInterval;
  bool get autoRefreshEnabled => _autoRefreshEnabled;
  int get maxDataPoints => _maxDataPoints;

  Future<void> _ensureService() async {
    _service ??= MonitoringService();
  }

  /// 设置刷新间隔
  void setRefreshInterval(Duration interval) {
    _refreshInterval = interval;
    if (_autoRefreshEnabled) {
      _stopAutoRefresh();
      _startAutoRefresh();
    }
    notifyListeners();
  }

  /// 设置最大数据点数量
  void setMaxDataPoints(int count) {
    _maxDataPoints = count;
    // 重新加载数据以应用新的限制
    load(silent: true);
    notifyListeners();
  }

  /// 启用/禁用自动刷新
  void toggleAutoRefresh(bool enabled) {
    _autoRefreshEnabled = enabled;
    if (enabled) {
      _startAutoRefresh();
    } else {
      _stopAutoRefresh();
    }
    notifyListeners();
  }

  void _startAutoRefresh() {
    _stopAutoRefresh();
    debugPrint('[MonitoringProvider] 开始自动刷新，间隔: ${_refreshInterval.inSeconds}秒');
    _refreshTimer = Timer.periodic(_refreshInterval, (_) {
      debugPrint('[MonitoringProvider] 自动刷新触发...');
      load(silent: true);
    });
  }

  void _stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void dispose() {
    _stopAutoRefresh();
    super.dispose();
  }

  /// 加载所有监控数据
  Future<void> load({bool silent = false}) async {
    if (!silent) {
      _data = _data.copyWith(isLoading: true, error: null);
    } else {
      _data = _data.copyWith(isRefreshing: true, error: null);
    }
    notifyListeners();
    
    try {
      await _ensureService();
      
      debugPrint('[MonitoringProvider] Loading current metrics...');
      final currentMetrics = await _service!.getCurrentMetrics();
      debugPrint('[MonitoringProvider] currentMetrics: $currentMetrics');
      
      debugPrint('[MonitoringProvider] Loading CPU time series...');
      final cpuTimeSeries = await _service!.getCPUTimeSeries();
      debugPrint('[MonitoringProvider] cpuTimeSeries: ${cpuTimeSeries.data.length} points');
      
      final memoryTimeSeries = await _service!.getMemoryTimeSeries();
      final loadTimeSeries = await _service!.getLoadTimeSeries();
      final ioTimeSeries = await _service!.getIOTimeSeries();
      final networkTimeSeries = await _service!.getNetworkTimeSeries();
      
      // 只保留最近N个数据点，实现滑动窗口效果
      final maxPoints = _maxDataPoints;
      
      final limitedCpu = _limitTimeSeries(cpuTimeSeries, maxPoints);
      final limitedMemory = _limitTimeSeries(memoryTimeSeries, maxPoints);
      final limitedLoad = _limitTimeSeries(loadTimeSeries, maxPoints);
      
      debugPrint('[MonitoringProvider] CPU数据点: ${limitedCpu.data.length}, 值: ${limitedCpu.data.map((e) => e.value.toStringAsFixed(1)).join(", ")}');
      debugPrint('[MonitoringProvider] 内存数据点: ${limitedMemory.data.length}, 值: ${limitedMemory.data.map((e) => e.value.toStringAsFixed(1)).join(", ")}');
      
      _data = _data.copyWith(
        currentMetrics: currentMetrics,
        cpuTimeSeries: limitedCpu,
        memoryTimeSeries: limitedMemory,
        loadTimeSeries: limitedLoad,
        ioTimeSeries: _limitTimeSeries(ioTimeSeries, maxPoints),
        networkTimeSeries: _limitTimeSeries(networkTimeSeries, maxPoints),
        isLoading: false,
        isRefreshing: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e, stack) {
      debugPrint('[MonitoringProvider] Error: $e');
      debugPrint('[MonitoringProvider] Stack: $stack');
      _data = _data.copyWith(
        isLoading: false,
        isRefreshing: false,
        error: e.toString(),
      );
    }
    
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await load(silent: true);
  }

  /// 清除错误
  void clearError() {
    _data = _data.copyWith(error: null);
    notifyListeners();
  }

  /// 限制时间序列数据点数量，实现滑动窗口效果
  MonitorTimeSeries _limitTimeSeries(MonitorTimeSeries series, int maxPoints) {
    if (series.data.length <= maxPoints) return series;
    
    final limitedData = series.data.sublist(series.data.length - maxPoints);
    final values = limitedData.map((e) => e.value).toList();
    
    double? min;
    double? max;
    double sum = 0;
    
    for (final value in values) {
      if (min == null || value < min) min = value;
      if (max == null || value > max) max = value;
      sum += value;
    }
    
    return MonitorTimeSeries(
      name: series.name,
      data: limitedData,
      min: min,
      max: max,
      avg: values.isNotEmpty ? sum / values.length : null,
    );
  }
}
