/// Dashboard状态管理
///
/// 管理仪表盘数据，包括系统信息、资源使用情况、最近活动等

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../api/v2/dashboard_v2.dart';
import '../../api/v2/host_v2.dart';
import '../../core/network/api_client_manager.dart';
import '../../data/models/host_models.dart';

/// 仪表盘数据模型
class DashboardData {
  final HostBaseInfo? baseInfo;
  final HostCurrentInfo? currentInfo;
  final List<DashboardActivity> activities;
  final DateTime? lastUpdated;
  final bool isLoading;
  final String? error;

  const DashboardData({
    this.baseInfo,
    this.currentInfo,
    this.activities = const [],
    this.lastUpdated,
    this.isLoading = false,
    this.error,
  });

  DashboardData copyWith({
    HostBaseInfo? baseInfo,
    HostCurrentInfo? currentInfo,
    List<DashboardActivity>? activities,
    DateTime? lastUpdated,
    bool? isLoading,
    String? error,
  }) {
    return DashboardData(
      baseInfo: baseInfo ?? this.baseInfo,
      currentInfo: currentInfo ?? this.currentInfo,
      activities: activities ?? this.activities,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// 获取CPU使用率
  double? get cpuPercent => currentInfo?.cpu?.percent;

  /// 获取内存使用率
  double? get memoryPercent {
    if (currentInfo?.mem == null) return null;
    final mem = currentInfo!.mem!;
    if (mem.total == null || mem.total == 0) return null;
    return ((mem.used ?? 0) / mem.total!) * 100;
  }

  /// 获取内存使用信息
  String get memoryUsage {
    if (currentInfo?.mem == null) return '--';
    final mem = currentInfo!.mem!;
    final used = _formatBytes(mem.used ?? 0);
    final total = _formatBytes(mem.total ?? 0);
    return '$used / $total';
  }

  /// 获取磁盘使用率
  double? get diskPercent {
    if (currentInfo?.disk == null || currentInfo!.disk!.isEmpty) return null;
    final disk = currentInfo!.disk!.first;
    if (disk.total == null || disk.total == 0) return null;
    return ((disk.used ?? 0) / disk.total!) * 100;
  }

  /// 获取磁盘使用信息
  String get diskUsage {
    if (currentInfo?.disk == null || currentInfo!.disk!.isEmpty) return '--';
    final disk = currentInfo!.disk!.first;
    final used = _formatBytes(disk.used ?? 0);
    final total = _formatBytes(disk.total ?? 0);
    return '$used / $total';
  }

  /// 获取运行时间
  String get uptime {
    if (currentInfo?.uptime == null) return '--';
    final uptimeSeconds = currentInfo!.uptime!;
    final days = uptimeSeconds ~/ 86400;
    final hours = (uptimeSeconds % 86400) ~/ 3600;
    if (days > 0) {
      return '$days天 ${hours}小时';
    }
    return '$hours小时';
  }

  /// 格式化字节数
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// 仪表盘活动项
class DashboardActivity {
  final String title;
  final String description;
  final DateTime time;
  final ActivityType type;

  const DashboardActivity({
    required this.title,
    required this.description,
    required this.time,
    this.type = ActivityType.info,
  });
}

enum ActivityType { info, success, warning, error }

/// Dashboard状态管理器
class DashboardProvider extends ChangeNotifier {
  DashboardProvider({
    DashboardV2Api? dashboardApi,
    HostV2Api? hostApi,
  })  : _dashboardApi = dashboardApi,
        _hostApi = hostApi;

  DashboardV2Api? _dashboardApi;
  HostV2Api? _hostApi;
  Timer? _refreshTimer;

  DashboardData _data = const DashboardData();

  DashboardData get data => _data;

  /// 获取API客户端
  Future<void> _ensureApiClients() async {
    if (_dashboardApi == null || _hostApi == null) {
      final manager = ApiClientManager.instance;
      _dashboardApi = await manager.getDashboardApi();
      _hostApi = await manager.getHostApi();
    }
  }

  /// 加载仪表盘数据
  Future<void> loadData() async {
    _data = _data.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      await _ensureApiClients();

      // 并行获取基础信息和当前信息
      final results = await Future.wait([
        _hostApi!.getBaseInfo(),
        _hostApi!.getCurrentInfo(),
      ]);

      final baseInfo = results[0] as HostBaseInfo?;
      final currentInfo = results[1] as HostCurrentInfo?;

      // 生成模拟活动数据（后续可以替换为真实日志API）
      final activities = _generateActivities();

      _data = _data.copyWith(
        baseInfo: baseInfo,
        currentInfo: currentInfo,
        activities: activities,
        lastUpdated: DateTime.now(),
        isLoading: false,
      );
    } catch (e) {
      _data = _data.copyWith(
        isLoading: false,
        error: '加载数据失败: $e',
      );
    }
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh() async {
    await loadData();
  }

  /// 开始自动刷新
  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      loadData();
    });
  }

  /// 停止自动刷新
  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  /// 生成活动数据（临时，后续替换为真实日志API）
  List<DashboardActivity> _generateActivities() {
    final now = DateTime.now();
    return [
      DashboardActivity(
        title: '系统运行正常',
        description: '所有服务运行正常',
        time: now.subtract(const Duration(minutes: 5)),
        type: ActivityType.success,
      ),
      DashboardActivity(
        title: '数据已同步',
        description: '服务器数据已更新',
        time: now.subtract(const Duration(hours: 1)),
        type: ActivityType.info,
      ),
    ];
  }

  /// 清除错误
  void clearError() {
    _data = _data.copyWith(error: null);
    notifyListeners();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
