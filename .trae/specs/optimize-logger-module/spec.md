# 日志功能优化 Spec

## Why
当前项目已经使用了官方 `logger: ^2.6.2` 包，但存在手搓的冗余代码：
- 自定义 `LogLevel` 枚举与logger包的 `Level` 重复
- 自定义 `BuildMode` 枚举与Flutter的 `kReleaseMode` 等重复
- 自定义 `_CustomLogFilter` 过滤器，logger包已提供 `ProductionFilter` 和 `DevelopmentFilter`
- 大量冗余的包装方法增加了维护成本

需要删除手搓代码，使用官方logger包的标准实现。

## What Changes
- **删除** `lib/core/config/logger_config.dart` 中的自定义 `LogLevel` 枚举
- **删除** `lib/core/config/logger_config.dart` 中的自定义 `BuildMode` 枚举
- **简化** `lib/core/services/logger/logger_service.dart`，使用logger包的标准功能
- **删除** 自定义 `_CustomLogFilter`，使用logger包的 `ProductionFilter` 或 `DevelopmentFilter`
- **保留** 必要的配置常量（如 `lineLength`、`colors` 等）
- **简化** 日志方法，移除冗余的包装

## Impact
- Affected code: 
  - `lib/core/services/logger/logger_service.dart`
  - `lib/core/config/logger_config.dart`
  - 所有使用 `AppLogger` 的文件

## ADDED Requirements

### Requirement: 使用官方Logger标准功能
系统 SHALL 使用logger包提供的标准功能，而非手搓实现。

#### Scenario: 日志级别使用官方Level
- **WHEN** 配置日志级别时
- **THEN** 使用logger包的 `Level.trace`、`Level.debug`、`Level.info`、`Level.warning`、`Level.error`、`Level.fatal`

#### Scenario: 日志过滤器使用官方Filter
- **WHEN** 配置日志过滤器时
- **THEN** 使用logger包的 `DevelopmentFilter` 或 `ProductionFilter`

### Requirement: 简化日志服务类
系统 SHALL 提供简洁的日志服务类，仅包装必要的功能。

#### Scenario: 基本日志方法
- **WHEN** 调用日志方法时
- **THEN** 直接使用logger包的标准方法 `logger.t()`、`logger.d()`、`logger.i()`、`logger.w()`、`logger.e()`、`logger.f()`

#### Scenario: 构建模式检测
- **WHEN** 判断构建模式时
- **THEN** 使用Flutter提供的 `kReleaseMode`、`kProfileMode`、`kDebugMode`

## REMOVED Requirements

### Requirement: 自定义LogLevel枚举
**Reason**: logger包已提供 `Level` 枚举
**Migration**: 使用 `Level.trace`、`Level.debug` 等替代 `LogLevel.trace`、`LogLevel.debug`

### Requirement: 自定义BuildMode枚举
**Reason**: Flutter已提供 `kReleaseMode`、`kProfileMode`、`kDebugMode`
**Migration**: 使用Flutter内置常量

### Requirement: 自定义LogFilter
**Reason**: logger包已提供 `DevelopmentFilter` 和 `ProductionFilter`
**Migration**: 使用logger包的过滤器或直接设置 `Logger.level`
