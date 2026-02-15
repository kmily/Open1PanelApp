# 应用导航架构规划

## 一、现有页面清单

| 页面 | 文件 | 当前入口 | 功能 |
|------|------|----------|------|
| ServerListPage | server_list_page.dart | Tab 0 | 服务器列表 |
| ServerDetailPage | server_detail_page.dart | 点击服务器卡片 | 服务器详情 |
| ServerFormPage | server_form_page.dart | 添加服务器按钮 | 添加/编辑服务器 |
| FilesPage | files_page.dart | Tab 1 | 文件管理 |
| SecurityVerificationPage | security_verification_page.dart | Tab 2 | 安全验证(MFA) |
| SettingsPage | settings_page.dart | Tab 3 | 设置 |
| DashboardPage | dashboard_page.dart | **无入口** | 仪表盘概览 |
| MonitoringPage | monitoring_page.dart | ServerDetailPage | 监控详情 |
| AppsPage | apps_page.dart | ServerDetailPage | 应用管理 |
| ContainersPage | containers_page.dart | ServerDetailPage | 容器管理 |
| WebsitesPage | websites_page.dart | ServerDetailPage | 网站管理 |
| DatabasesPage | databases_page.dart | ServerDetailPage | 数据库管理 |
| FirewallPage | firewall_page.dart | ServerDetailPage | 防火墙 |
| TerminalPage | terminal_page.dart | ServerDetailPage | 终端 |
| AIPage | ai_page.dart | ServerDetailPage | AI助手 |
| LoginPage | login_page.dart | 启动 | 登录 |
| OnboardingPage | onboarding_page.dart | 首次使用 | 引导 |

## 二、模块功能对比

### Dashboard vs Monitoring vs ServerRepository

| 维度 | Dashboard | Monitoring | ServerRepository |
|------|-----------|------------|------------------|
| **API** | `/dashboard/*` | `/hosts/monitor/*` | `/hosts/monitor/*` |
| **数据类型** | 当前快照 | 时间序列 | 当前值 |
| **功能** | 系统概览、进程列表 | 历史趋势、GPU监控 | 服务器卡片数据 |
| **是否重复** | ✅ 独立 | ✅ 独立 | ⚠️ 与Monitoring共用API |

**结论**: 
- Dashboard 和 Monitoring **不重复**，功能互补
- ServerRepository 和 MonitoringService 已整合到 MonitorRepository

### Dashboard 功能列表

| 功能 | API端点 | 说明 |
|------|---------|------|
| 系统信息 | `/dashboard/base/os` | 操作系统、内核版本 |
| 当前指标 | `/dashboard/current` | CPU、内存、磁盘 |
| CPU进程 | `/dashboard/current/top/cpu` | Top CPU进程 |
| 内存进程 | `/dashboard/current/top/mem` | Top内存进程 |
| 应用启动器 | `/dashboard/app_launcher` | 快速启动应用 |
| 快速跳转 | `/dashboard/quick` | 快捷入口 |

### Monitoring 功能列表

| 功能 | API端点 | 说明 |
|------|---------|------|
| 时间序列 | `/hosts/monitor/search` | 历史趋势数据 |
| GPU监控 | `/hosts/monitor/gpu/search` | GPU使用情况 |
| 监控设置 | `/hosts/monitor/setting` | 监控配置 |

## 三、导航架构规划

### 方案：服务器详情页 + 底部导航

```
┌─────────────────────────────────────────────────────────────┐
│                        App Shell                             │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              ServerListPage (服务器列表)              │   │
│   │                                                       │   │
│   │   ┌─────────┐  ┌─────────┐  ┌─────────┐             │   │
│   │   │ Server1 │  │ Server2 │  │ Server3 │             │   │
│   │   │  CPU%   │  │  CPU%   │  │  CPU%   │             │   │
│   │   │  MEM%   │  │  MEM%   │  │  MEM%   │             │   │
│   │   └────┬────┘  └─────────┘  └─────────┘             │   │
│   │        │                                              │   │
│   └────────│──────────────────────────────────────────────┘   │
│            │                                                  │
│            ▼                                                  │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              ServerDetailPage (服务器详情)            │   │
│   │                                                       │   │
│   │   ┌──────────────────────────────────────────────┐  │   │
│   │   │  Dashboard (概览) - 替换原来的Apps Tab        │  │   │
│   │   │  - 系统信息、当前指标、进程列表               │  │   │
│   │   │  - 应用启动器、快速跳转                       │  │   │
│   │   └──────────────────────────────────────────────┘  │   │
│   │                                                       │   │
│   │   [Apps] [Containers] [Websites] [Databases]         │   │
│   │   [Firewall] [Terminal] [Monitoring] [AI]            │   │
│   │                                                       │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│  [服务器]  [文件]  [安全验证]  [设置]                         │
└─────────────────────────────────────────────────────────────┘
```

### Tab结构

| Tab | 名称 | 页面 | 说明 |
|-----|------|------|------|
| 0 | 服务器 | ServerListPage | 服务器列表和管理 |
| 1 | 文件 | FilesPage | 文件管理 |
| 2 | 安全验证 | SecurityVerificationPage | MFA动态验证 |
| 3 | 设置 | SettingsPage | 应用设置 |

### ServerDetailPage 子页面

| 入口 | 页面 | 说明 |
|------|------|------|
| 概览 | DashboardPage | 系统概览（新入口） |
| 应用 | AppsPage | 应用管理 |
| 容器 | ContainersPage | 容器管理 |
| 网站 | WebsitesPage | 网站管理 |
| 数据库 | DatabasesPage | 数据库管理 |
| 防火墙 | FirewallPage | 防火墙管理 |
| 终端 | TerminalPage | Web终端 |
| 监控 | MonitoringPage | 监控详情 |
| AI | AIPage | AI助手 |

## 四、实施步骤

### 1. 修改 ServerDetailPage 添加 Dashboard 入口

在 ServerDetailPage 的模块列表中添加"概览"入口，点击后显示 DashboardPage

### 2. 保持现有 Tab 结构

当前四个 Tab 保持不变：
- Tab 0: 服务器
- Tab 1: 文件
- Tab 2: 安全验证
- Tab 3: 设置

### 3. Dashboard 作为服务器详情的第一个模块

用户点击服务器卡片后，默认显示 Dashboard 概览页

## 四、实施结果

### 已完成

| 任务 | 文件 | 状态 |
|------|------|------|
| 添加 Dashboard 入口 | `server_detail_page.dart` | ✅ |
| 添加 l10n 键 | `app_en.arb`, `app_zh.arb` | ✅ |
| 添加 Dashboard 路由 | `app_router.dart` | ✅ |

### 测试结果

```
flutter analyze lib/config/app_router.dart lib/features/server/server_detail_page.dart lib/l10n/
Analyzing 3 items...
No issues found! (ran in 1.7s)
```

### 导航流程

```
ServerListPage (服务器列表)
    │
    └── 点击服务器卡片
            │
            ▼
    ServerDetailPage (服务器详情)
            │
            ├── 概览 (DashboardPage) ← 新入口
            ├── 应用
            ├── 容器
            ├── 网站
            ├── 数据库
            ├── 防火墙
            ├── 终端
            ├── 监控
            └── AI (AIPage)
```

---

**创建日期**: 2026-02-15
**状态**: 已完成
