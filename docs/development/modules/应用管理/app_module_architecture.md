# 应用管理模块架构设计

## 模块目标

- 适配 Open1PanelApp 作为 1Panel Linux 运维面板社区版的定位
- 提供完整的应用商店浏览、安装、配置、管理能力
- 支持应用生命周期管理（安装、启动、停止、重启、卸载、更新）
- 提供应用详情查看、日志查看、配置编辑功能
- 统一应用状态管理与错误反馈

## 功能完整性清单

基于 `app_api_analysis.md` 解析的 App 标签及相关端点 (共 33 个):

### 应用商店 (App Store)
1. POST /apps/search - 获取应用列表 (List apps)
2. GET /apps/detail/:appId/:version/:type - 获取应用详情 (Search app detail by appid)
3. GET /apps/details/:id - 获取应用详情 (Get app detail by id)
4. GET /apps/icon/:appId - 获取应用图标 (Get app icon by app_id)
5. GET /apps/:key - 根据 Key 搜索应用 (Search app by key)
6. POST /apps/sync/local - 同步本地应用列表 (Sync local app list)
7. POST /apps/sync/remote - 同步远程应用列表 (Sync remote app list)
8. GET /apps/checkupdate - 获取应用列表更新 (Get app list update)

### 应用安装 (App Installation)
9. POST /apps/install - 安装应用 (Install app)

### 已安装应用管理 (Installed Apps Management)
10. GET /apps/installed/list - 获取已安装应用列表 (List app installed)
11. POST /apps/installed/search - 分页搜索已安装应用 (Page app installed)
12. GET /apps/installed/info/:appInstallId - 获取安装信息 (Get app install info)
13. POST /apps/installed/sync - 同步已安装应用 (Sync app installed)
14. POST /apps/installed/check - 检查已安装应用 (Check app installed)
15. GET /apps/installed/delete/check/:appInstallId - 删除前检查 (Check before delete)

### 应用操作 (App Operations)
16. POST /apps/installed/op - 操作已安装应用 (Operate installed app)

### 应用配置与参数 (App Configuration & Params)
17. POST /apps/installed/conf - 获取默认配置 (Search default config by key)
18. POST /apps/installed/config/update - 更新应用配置 (Update app config)
19. GET /apps/installed/params/:appInstallId - 获取应用参数 (Search params by appInstallId)
20. POST /apps/installed/params/update - 更新应用参数 (Change app params)
21. POST /apps/installed/conninfo - 获取应用连接信息 (Search app password by key)
22. POST /apps/installed/loadport - 获取应用端口 (Search app port by key)
23. POST /apps/installed/port/change - 修改应用端口 (Change app port)
24. GET /apps/services/:key - 获取应用服务 (Search app service by key)

### 应用更新与忽略 (App Updates & Ignore)
25. POST /apps/installed/update/versions - 获取更新版本 (Search app update version by install id)
26. POST /apps/installed/ignore - 忽略更新 (Ignore Upgrade App)
27. POST /apps/ignored/cancel - 取消忽略更新 (Cancel Ignore Upgrade App)
28. GET /apps/ignored/detail - 获取忽略更新列表 (List Upgrade Ignored App)

### 设置 (Settings)
29. GET /core/settings/apps/store/config - 获取应用商店配置 (Get appstore config)
30. POST /core/settings/apps/store/update - 更新应用商店配置 (Update appstore config)

### 仪表盘 (Dashboard)
31. GET /dashboard/app/launcher - 加载应用启动器 (Load app launcher)
32. POST /dashboard/app/launcher/option - 加载应用启动器选项 (Load app launcher options)
33. POST /dashboard/app/launcher/show - 更新应用启动器 (Update app Launcher)

## 业务流程与交互验证

### 应用商店浏览流程
- 进入应用商店页面
- 显示应用分类和推荐应用
- 支持按分类筛选应用
- 支持搜索应用名称
- 点击应用查看详情

### 应用安装流程
- 在应用详情页点击安装
- 显示安装参数配置页面
- 用户配置安装参数
- 检查安装条件
- 开始安装并显示进度
- 安装完成后跳转到已安装应用列表

### 应用管理流程
- 进入已安装应用列表
- 显示应用状态（运行中/已停止）
- 点击应用查看详情
- 提供启动/停止/重启/卸载操作
- 操作完成后更新状态

### 应用更新流程
- 检查应用是否有更新
- 显示更新日志
- 用户确认更新
- 执行更新并显示进度
- 更新完成后刷新应用信息

### 应用配置流程
- 进入应用详情页
- 点击配置管理
- 显示当前配置
- 用户编辑配置
- 检查配置有效性
- 保存配置并重启应用

## 关键边界与异常

### 安装失败
- 依赖条件不满足时的提示
- 端口冲突的处理
- 磁盘空间不足的提示
- 网络问题导致的下载失败

### 操作失败
- 应用启动失败的诊断
- 应用停止超时的处理
- 配置错误导致的异常
- 权限不足的提示

### 更新问题
- 版本不兼容的提示
- 更新失败的回滚
- 数据迁移的风险提示

### 卸载风险
- 数据丢失的警告
- 依赖应用的检查
- 卸载失败的清理

## 模块分层与职责

### 前端
- UI页面: 应用商店、已安装应用、应用详情、安装向导、配置管理
- 状态管理: 应用列表缓存、安装状态、操作状态

### 服务层
- API适配: AppV2Api
- 数据模型: App、AppInstall、AppConfig、AppStatus等

## 数据流

1. UI触发 -> Provider/Service -> API客户端请求
2. API响应解析 -> 模型映射 -> 状态更新
3. 状态更新 -> UI刷新 -> 用户反馈
4. 长时间操作 -> 进度轮询 -> 状态更新

## 与现有实现的差距

- 应用商店浏览页面缺失
- 应用安装向导未实现
- 应用详情页面不完整
- 应用配置管理功能缺失
- 应用日志查看功能缺失

## 评审记录

| 日期 | 评审人 | 结论 | 备注 |
| --- | --- | --- | --- |
| 待定 | 评审人A | 待评审 | |
| 待定 | 评审人B | 待评审 | |
