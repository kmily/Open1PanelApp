import 'package:flutter/foundation.dart';
import '../../data/repositories/monitor_repository.dart';
import 'monitoring_service.dart';

/// 监控数据状态
class MonitoringData {
  final bool isLoading;
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

  MonitoringData _data = const MonitoringData();

  MonitoringData get data => _data;

  Future<void> _ensureService() async {
    _service ??= MonitoringService();
  }

  /// 加载所有监控数据
  Future<void> load() async {
    _data = _data.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      await _ensureService();
      
      final currentMetrics = await _service!.getCurrentMetrics();
      final cpuTimeSeries = await _service!.getCPUTimeSeries();
      final memoryTimeSeries = await _service!.getMemoryTimeSeries();
      final loadTimeSeries = await _service!.getLoadTimeSeries();
      final ioTimeSeries = await _service!.getIOTimeSeries();
      final networkTimeSeries = await _service!.getNetworkTimeSeries();
      
      _data = _data.copyWith(
        currentMetrics: currentMetrics,
        cpuTimeSeries: cpuTimeSeries,
        memoryTimeSeries: memoryTimeSeries,
        loadTimeSeries: loadTimeSeries,
        ioTimeSeries: ioTimeSeries,
        networkTimeSeries: networkTimeSeries,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      _data = _data.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await load();
  }

  /// 清除错误
  void clearError() {
    _data = _data.copyWith(error: null);
    notifyListeners();
  }
}
