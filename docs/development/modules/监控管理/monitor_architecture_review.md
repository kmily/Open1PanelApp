# 监控管理模块架构改造报告

## 一、模块对比分析结论

### 仪表盘模块 vs 监控管理模块

| 维度 | 仪表盘模块 | 监控管理模块 |
|------|-----------|-------------|
| **API端点** | `/dashboard/*` | `/hosts/monitor/*` |
| **用途** | 首页概览、快速状态查看 | 详细监控、历史数据分析 |
| **数据粒度** | 当前快照 | 时间序列数据 |
| **功能定位** | P0核心模块，用户首页 | 专业监控模块，深度分析 |

**结论**: 两个模块**不重复**，各有不同的API端点和功能定位。

## 二、发现的问题

### 问题1: API请求格式严重错误 ✅ 已修复

**错误实现**:
```dart
class MonitorSearch {
  final String? timeRange;  // ❌ 错误
  final String? metricType; // ❌ 错误
}
```

**正确格式**:
```dart
class MonitorSearch {
  final String param;       // ✅ 必需参数
  final String? startTime;  // ✅ UTC时间
  final String? endTime;    // ✅ UTC时间
}
```

### 问题2: 数据模型与API响应不匹配 ✅ 已修复

**新增模型**:
- `MonitorSearchResponse`: 包含 `code`, `message`, `data` 字段
- `MonitorDataItem`: 包含 `param`, `date`, `value` 字段
- `MonitorMetrics`: 提取的监控指标数据
- `MonitorTimeSeries`: 时间序列数据

### 问题3: 服务层API调用错误 ✅ 已修复

**修复内容**:
- 使用正确的 `getCurrentClient()` 方法
- 正确解析1Panel API响应格式 `{code: 200, data: [...]}`
- 添加便捷方法获取各类监控数据

## 三、改造内容

### 1. API客户端 (monitor_v2.dart)

| 方法 | 端点 | 说明 |
|------|------|------|
| `search()` | POST /hosts/monitor/search | 搜索监控数据 |
| `searchGPU()` | POST /hosts/monitor/gpu/search | GPU监控数据 |
| `clean()` | POST /hosts/monitor/clean | 清理监控数据 |
| `getSetting()` | GET /hosts/monitor/setting | 获取监控设置 |
| `updateSetting()` | POST /hosts/monitor/setting/update | 更新监控设置 |
| `getAllMetrics()` | - | 便捷方法：获取所有监控 |
| `getBaseMetrics()` | - | 便捷方法：获取基础监控 |
| `getIOMetrics()` | - | 便捷方法：获取IO监控 |
| `getNetworkMetrics()` | - | 便捷方法：获取网络监控 |

### 2. 服务层 (monitoring_service.dart)

| 方法 | 返回类型 | 说明 |
|------|----------|------|
| `getCurrentMetrics()` | `MonitorMetrics` | 获取当前监控指标 |
| `getCPUTimeSeries()` | `MonitorTimeSeries` | CPU时间序列 |
| `getMemoryTimeSeries()` | `MonitorTimeSeries` | 内存时间序列 |
| `getLoadTimeSeries()` | `MonitorTimeSeries` | 负载时间序列 |
| `getIOTimeSeries()` | `MonitorTimeSeries` | IO时间序列 |
| `getNetworkTimeSeries()` | `MonitorTimeSeries` | 网络时间序列 |
| `getSetting()` | `MonitorSetting` | 获取监控设置 |
| `updateSetting()` | `bool` | 更新监控设置 |
| `cleanData()` | `bool` | 清理监控数据 |
| `getGPUInfo()` | `List<GPUInfo>` | GPU监控数据 |

## 四、API响应格式

### 请求格式
```json
{
  "param": "all",
  "startTime": "2026-02-15T13:05:02.340098Z",
  "endTime": "2026-02-15T14:05:02.340098Z"
}
```

### 响应格式
```json
{
  "code": 200,
  "message": "",
  "data": [
    {
      "param": "base",
      "date": ["2026-02-15T13:11:02.055103768+08:00", ...],
      "value": [
        {
          "cpu": 0.92,
          "memory": 37.17,
          "cpuLoad1": 0.12,
          "cpuLoad5": 0.15,
          "cpuLoad15": 0.18
        }
      ]
    },
    {
      "param": "io",
      "date": null,
      "value": null
    }
  ]
}
```

## 五、测试结果

```
flutter analyze lib/api/v2/monitor_v2.dart lib/features/monitoring/monitoring_service.dart
Analyzing 2 items...
No issues found! (ran in 0.8s)
```

## 六、规范遵循情况

| 规范项 | 状态 |
|--------|------|
| Material Design 3 | ✅ 遵循 |
| API请求格式正确 | ✅ 已修复 |
| 数据模型匹配 | ✅ 已修复 |
| 错误处理 | ✅ 已添加 |
| 代码注释 | ✅ 已添加 |

---

**改造日期**: 2026-02-15
**改造人**: 自动分析
**状态**: 已完成
