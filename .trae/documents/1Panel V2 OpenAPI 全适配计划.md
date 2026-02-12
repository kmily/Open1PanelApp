# 1Panel V2 OpenAPI 全适配计划

## 一、项目现状分析

### 1.1 当前实现状态
- **已有 API 文件**: 26 个 V2 API 模块文件
- **已有数据模型**: 31 个模型文件
- **主要问题**:
  - 大量模型类缺失（如 `OperateByID`, `BatchDelete`, `SearchWithPage` 等）
  - API 实现中存在未定义的类引用
  - 部分导入路径错误（如 `package:dio/dio/dio.dart`）
  - 代码生成文件（`.g.dart`）与当前依赖版本不兼容

### 1.2 OpenAPI 文档结构
根据 `1PanelV2OpenAPI.json`，API 按功能模块划分为：
- System Group（系统组管理）
- AI（AI/Ollama 管理）
- Container（容器管理）
- Database（数据库管理）
- Website（网站管理）
- File（文件管理）
- Backup（备份管理）
- 等 20+ 个模块

## 二、适配目标

实现完整的 1Panel V2 API 适配，包括：
1. **425+ API 端点** 完整封装
2. **所有数据模型** 完整定义
3. **类型安全** 的 API 调用
4. **统一错误处理** 机制
5. **代码生成** 自动化支持

## 三、实施计划

### 阶段一：基础设施修复（第 1-2 天）

#### 1.1 修复导入错误
- 修复 `database_v2.dart` 中的错误导入 `package:dio/dio/dio.dart` → `package:dio/dio.dart`
- 检查并修复其他 API 文件中的导入问题

#### 1.2 完善通用模型
创建/完善 `lib/data/models/common_models.dart`：
```dart
// 需要添加的模型：
- OperateByID
- OperateByType  
- PageRequest / PageResult
- BatchDelete
- SearchWithPage
- OperationWithName
- RecordSearch
- GroupCreate / GroupUpdate / GroupSearch
- ForceDelete
- CommonBackup / CommonRecover
```

#### 1.3 修复代码生成配置
- 检查 `build_runner` 配置
- 重新生成 `.g.dart` 文件

### 阶段二：核心模块模型完善（第 3-5 天）

#### 2.1 Container 模块
完善 `lib/data/models/container_models.dart`：
- ContainerOperate
- ContainerOperation
- ContainerListStats
- ContainerInfo
- 等 15+ 个模型

#### 2.2 Database 模块
完善 `lib/data/models/database_models.dart`：
- DatabaseCreate / DatabaseUpdate
- DatabaseInfo
- DatabaseSearch
- DatabaseBackup
- 等 10+ 个模型

#### 2.3 Backup 模块
完善 `lib/data/models/backup_models.dart`：
- BackupOperate
- BackupOption
- CommonBackup / CommonRecover
- 等 8+ 个模型

### 阶段三：API 实现完善（第 6-10 天）

#### 3.1 容器管理 API
完善 `lib/api/v2/container_v2.dart`：
- 创建/删除/更新容器
- 启动/停止/重启容器
- 容器日志/终端
- 容器统计信息
- 等 20+ 个端点

#### 3.2 数据库管理 API
完善 `lib/api/v2/database_v2.dart`：
- 创建/删除数据库
- 数据库备份/恢复
- 数据库用户管理
- 等 15+ 个端点

#### 3.3 其他核心模块
- WebsiteV2Api（网站管理）
- FileV2Api（文件管理）
- BackupAccountV2Api（备份账户）
- ContainerComposeV2Api（Compose管理）

### 阶段四：高级功能模块（第 11-15 天）

#### 4.1 AI 模块
完善 `lib/api/v2/ai_v2.dart` 和模型：
- Ollama 模型管理
- GPU 信息获取
- 域名绑定

#### 4.2 系统管理模块
- DashboardV2Api（仪表盘）
- HostV2Api（主机管理）
- MonitorV2Api（监控）
- SettingV2Api（设置）

#### 4.3 网络与安全模块
- FirewallV2Api（防火墙）
- SSLV2Api（SSL证书）
- OpenrestyV2Api（OpenResty）

### 阶段五：测试与验证（第 16-18 天）

#### 5.1 代码生成
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 5.2 静态分析
```bash
flutter analyze
```

#### 5.3 单元测试
- 编写模型序列化/反序列化测试
- 编写 API 调用测试（使用 mock）

## 四、技术规范

### 4.1 API 文件模板
```dart
/// 1Panel V2 API - {Module} 相关接口
///
/// 此文件包含与{功能}相关的所有API接口

import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/{module}_models.dart';
import '../../data/models/common_models.dart';

class {Module}V2Api {
  final DioClient _client;
  {Module}V2Api(this._client);
  
  // API 方法...
}
```

### 4.2 模型文件模板
```dart
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part '{module}_models.g.dart';

@JsonSerializable()
class {ModelName} extends Equatable {
  final String field;
  
  const {ModelName}({required this.field});
  
  factory {ModelName}.fromJson(Map<String, dynamic> json) => 
      _${ModelName}FromJson(json);
  
  Map<String, dynamic> toJson() => _${ModelName}ToJson(this);
  
  @override
  List<Object?> get props => [field];
}
```

### 4.3 命名规范
- API 类名：`{Module}V2Api`
- 模型类名：PascalCase
- 文件名：snake_case
- 方法名：camelCase，动词开头（get/create/update/delete/search）

## 五、优先级排序

| 优先级 | 模块 | 原因 |
|--------|------|------|
| P0 | common_models | 基础依赖 |
| P0 | container_v2 | 核心功能 |
| P0 | database_v2 | 核心功能 |
| P1 | backup_account_v2 | 重要功能 |
| P1 | website_v2 | 重要功能 |
| P1 | file_v2 | 重要功能 |
| P2 | ai_v2 | 特色功能 |
| P2 | dashboard_v2 | 辅助功能 |
| P3 | 其他模块 | 扩展功能 |

## 六、预期成果

1. **完整的 API 覆盖**：425+ 端点全部实现
2. **类型安全**：所有 API 调用都有完整的类型定义
3. **代码生成支持**：支持 `build_runner` 自动生成代码
4. **文档完善**：每个 API 和模型都有详细文档注释
5. **零警告**：`flutter analyze` 无错误和警告

## 七、风险与缓解

| 风险 | 缓解措施 |
|------|----------|
| API 文档与实现不一致 | 以实际 OpenAPI JSON 为准，必要时进行测试验证 |
| 模型字段类型不确定 | 使用 `dynamic` 或 `Object?` 作为备选，逐步完善 |
| 代码生成失败 | 检查依赖版本，必要时手动编写序列化代码 |
| 工作量超出预期 | 按优先级分阶段交付，确保核心功能先完成 |

---

请确认此计划后，我将开始执行具体的适配工作。