# 监控数据服务整合方案

## 一、API端点分析

### Dashboard API (`/dashboard/*`)
| 端点 | 用途 | 数据类型 |
|------|------|----------|
| `/dashboard/base/:ioOption/:netOption` | 基础信息 | 当前快照 |
| `/dashboard/current/:ioOption/:netOption` | 当前信息 | 当前快照 |
| `/dashboard/current/top/cpu` | CPU进程 | 当前快照 |
| `/dashboard/current/top/mem` | 内存进程 | 当前快照 |
| `/dashboard/base/os` | 操作系统信息 | 静态信息 |

### Monitor API (`/hosts/monitor/*`)
| 端点 | 用途 | 数据类型 |
|------|------|----------|
| `/hosts/monitor/search` | 监控数据搜索 | 时间序列 |
| `/hosts/monitor/gpu/search` | GPU监控 | 时间序列 |
| `/hosts/monitor/setting` | 监控设置 | 配置 |
| `/hosts/monitor/clean` | 清理数据 | 操作 |

## 二、重复代码分析

### 当前重复

| 模块 | 调用API | 功能 |
|------|---------|------|
| `ServerRepository` | `/hosts/monitor/search` | 获取服务器卡片监控数据 |
| `MonitoringService` | `/hosts/monitor/search` | 获取监控详情页数据 |

**问题**: 两个服务调用相同API，代码重复

## 三、整合方案

### 架构设计

```
┌─────────────────────────────────────────────────────────────┐
│                      UI Layer                                │
├─────────────────┬─────────────────┬─────────────────────────┤
│ ServerListPage  │ MonitoringPage  │ DashboardPage           │
│ (服务器卡片)     │ (监控详情)       │ (仪表盘)                │
└────────┬────────┴────────┬────────┴───────────┬─────────────┘
         │                 │                    │
         ▼                 ▼                    ▼
┌─────────────────┬─────────────────┬─────────────────────────┐
│ServerRepository │MonitoringService│ DashboardProvider       │
│ (服务器管理)     │ (监控服务)       │ (仪表盘)                │
└────────┬────────┴────────┬────────┴───────────┬─────────────┘
         │                 │                    │
         ▼                 ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                   MonitorRepository                          │
│              (统一监控数据获取服务)                            │
├─────────────────────────────────────────────────────────────┤
│ - getCurrentMetrics()    获取当前指标                         │
│ - getTimeSeries()        获取时间序列                         │
│ - getGPUInfo()           获取GPU信息                          │
│ - getSetting()           获取监控设置                         │
└─────────────────────────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│                   MonitorV2Api                               │
│              (API客户端)                                      │
├─────────────────────────────────────────────────────────────┤
│ - search()               POST /hosts/monitor/search          │
│ - searchGPU()            POST /hosts/monitor/gpu/search      │
│ - getSetting()           GET /hosts/monitor/setting          │
│ - updateSetting()        POST /hosts/monitor/setting/update  │
│ - clean()                POST /hosts/monitor/clean           │
└─────────────────────────────────────────────────────────────┘
```

### 文件结构

```
lib/
├── api/v2/
│   └── monitor_v2.dart          # API客户端 (已修复)
├── data/
│   └── repositories/
│       └── monitor_repository.dart  # 统一监控数据仓库 (新建)
├── features/
│   ├── server/
│   │   └── server_repository.dart   # 使用 MonitorRepository
│   ├── monitoring/
│   │   ├── monitoring_service.dart  # 使用 MonitorRepository
│   │   ├── monitoring_provider.dart
│   │   └── monitoring_page.dart
│   └── dashboard/
│       ├── dashboard_provider.dart  # 使用 Dashboard API
│       └── dashboard_page.dart
```

## 四、实施步骤

1. **创建 MonitorRepository** - 统一监控数据获取
2. **更新 ServerRepository** - 使用 MonitorRepository
3. **更新 MonitoringService** - 使用 MonitorRepository
4. **保持 DashboardProvider** - 使用独立的 Dashboard API

## 五、API使用规范

| 场景 | 使用API | 原因 |
|------|---------|------|
| 服务器卡片监控 | `/hosts/monitor/search` | 需要最新值 |
| 监控详情页 | `/hosts/monitor/search` | 需要时间序列 |
| 仪表盘 | `/dashboard/current/*` | 需要当前快照+进程信息 |

## 五、实施结果

### 已完成

| 任务 | 文件 | 状态 |
|------|------|------|
| 创建 MonitorRepository | `lib/data/repositories/monitor_repository.dart` | ✅ |
| 更新 ServerRepository | `lib/features/server/server_repository.dart` | ✅ |
| 更新 MonitoringService | `lib/features/monitoring/monitoring_service.dart` | ✅ |
| 更新 MonitoringProvider | `lib/features/monitoring/monitoring_provider.dart` | ✅ |
| 更新 MonitoringPage | `lib/features/monitoring/monitoring_page.dart` | ✅ |

### 测试结果

```
flutter analyze lib/data/repositories/monitor_repository.dart lib/features/server/server_repository.dart lib/features/monitoring/
Analyzing 3 items...
No issues found! (ran in 1.5s)
```

### 架构优化效果

| 优化项 | 效果 |
|--------|------|
| 消除代码重复 | API调用逻辑集中在 MonitorRepository |
| 统一数据模型 | MonitorMetricsSnapshot, MonitorTimeSeries |
| 职责分离 | ServerRepository 管理服务器，MonitorRepository 管理监控数据 |

---

**创建日期**: 2026-02-15
**状态**: 已完成
