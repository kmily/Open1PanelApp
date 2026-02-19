# 应用架构分析报告

## 一、应用Tab结构

### 四个主Tab (AppShellPage)

| Tab | 页面 | 用途 |
|-----|------|------|
| 0 | ServerListPage | 服务器列表管理 |
| 1 | FilesPage | 文件管理 |
| 2 | SecurityVerificationPage | 安全验证 |
| 3 | SettingsPage | 设置 |

### 页面导航关系

```
SplashPage
    ├── OnboardingPage (首次使用)
    ├── ServerFormPage (添加服务器)
    └── AppShellPage (主页面)
            ├── ServerListPage (Tab 0)
            │       └── ServerDetailPage (点击服务器卡片)
            │               ├── Apps (应用)
            │               ├── Containers (容器)
            │               ├── Websites (网站)
            │               ├── Databases (数据库)
            │               ├── Firewall (防火墙)
            │               ├── Terminal (终端)
            │               ├── Monitoring (监控) ← MonitoringPage
            │               └── Files (文件)
            ├── FilesPage (Tab 1)
            ├── SecurityVerificationPage (Tab 2)
            └── SettingsPage (Tab 3)
```

## 二、模块职责分析

### Server模块
| 文件 | 职责 |
|------|------|
| `server_list_page.dart` | 服务器列表UI |
| `server_detail_page.dart` | 服务器详情页，包含模块入口 |
| `server_provider.dart` | 状态管理 |
| `server_repository.dart` | 数据获取，调用 `/hosts/monitor/search` |

### Dashboard模块
| 文件 | 职责 |
|------|------|
| `dashboard_page.dart` | 仪表盘UI (**不在Tab中**) |
| `dashboard_provider.dart` | 状态管理 |
| `dashboard_v2.dart` | API客户端，调用 `/dashboard/*` |

### Monitoring模块
| 文件 | 职责 |
|------|------|
| `monitoring_page.dart` | 监控详情UI (**从ServerDetailPage进入**) |
| `monitoring_provider.dart` | 状态管理 |
| `monitoring_service.dart` | 数据获取，调用 `/hosts/monitor/search` |

## 三、发现的问题

### 问题1: MonitoringProvider调用已删除的方法 ❌

**错误代码** (`monitoring_provider.dart`):
```dart
final cpu = await _service!.getSystemMetrics(metricType: MetricType.cpu);
final memory = await _service!.getSystemMetrics(metricType: MetricType.memory);
final disk = await _service!.getSystemMetrics(metricType: MetricType.disk);
```

**问题**: `getSystemMetrics` 和 `MetricType` 已被删除，替换为 `getCurrentMetrics()`

### 问题2: 代码重复 ⚠️

| 模块 | API端点 | 功能 |
|------|---------|------|
| ServerRepository | `/hosts/monitor/search` | 获取监控数据 |
| MonitoringService | `/hosts/monitor/search` | 获取监控数据 |

**结论**: 两个服务调用相同API，存在代码重复

### 问题3: DashboardPage未使用 ⚠️

- `DashboardPage` 已实现但未在Tab中使用
- `DashboardProvider` 已注册但页面未显示

## 四、模块对比

| 维度 | ServerRepository | MonitoringService | DashboardProvider |
|------|------------------|-------------------|-------------------|
| **API** | `/hosts/monitor/search` | `/hosts/monitor/search` | `/dashboard/*` |
| **用途** | 服务器卡片监控数据 | 监控详情页数据 | 仪表盘数据 |
| **数据粒度** | 当前值 | 时间序列 | 当前值+系统信息 |
| **是否重复** | ⚠️ 与MonitoringService重复 | ⚠️ 与ServerRepository重复 | ✅ 独立 |

## 五、已修复的问题

### 1. MonitoringProvider调用错误 ✅ 已修复

**修复内容**:
- 更新 `monitoring_provider.dart` 使用新的API方法
- 更新 `monitoring_page.dart` 使用新的数据结构
- 添加时间序列图表显示

### 2. API请求格式错误 ✅ 已修复

**修复内容**:
- 更新 `monitor_v2.dart` 使用正确的请求参数
- 更新 `monitoring_service.dart` 正确解析API响应

## 六、建议

### 1. 统一监控数据获取

建议创建统一的 `MonitorRepository` 或让 `MonitoringService` 复用 `ServerRepository` 的逻辑

### 2. 明确Dashboard定位

- 如果Dashboard是首页概览，应该替换ServerListPage
- 如果Dashboard是独立功能，应该从某处进入

---

**分析日期**: 2026-02-15
**状态**: 已修复
