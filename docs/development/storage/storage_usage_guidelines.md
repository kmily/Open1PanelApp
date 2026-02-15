# 存储使用规范

## 1. 目的

为确保项目数据存储的规范性、安全性及高性能，特制定本规范。所有涉及本地存储的开发工作必须严格遵守本规范。

## 2. 核心原则

1.  **统一接口**: 必须通过 `StorageService` 接口操作存储，严禁直接使用 `Hive.openBox` 或 `SharedPreferences.getInstance`。
2.  **数据隔离**: 不同业务模块必须使用独立的 Box 或存储命名空间。
3.  **加密存储**: 敏感数据（用户 Token、密码、监控历史数据）必须使用 AES-256 加密存储。
4.  **异步操作**: 所有存储操作必须是异步的，禁止在主线程进行同步 I/O。
5.  **版本控制**: 数据模型变更时必须进行版本迁移处理。

## 3. 命名规范

### 3.1 Box 命名
Box 名称应具有描述性，格式为 `module_data` 或 `module_feature_data`。

- **示例**: `monitor_data`, `auth_session`, `user_settings`
- **禁止**: `temp`, `data`, `box1`

### 3.2 Key 命名
Key 必须具有唯一性，建议使用分层命名法 `category_id_timestamp`。

- **监控数据**: `metric_yyyyMMddHH` (e.g., `cpu_2023102710`)
- **配置项**: `setting_key` (e.g., `theme_mode`)
- **缓存**: `cache_url_hash`

## 4. 数据迁移策略

### 4.1 模型变更
当数据模型发生变更（如新增字段）时：
1.  **兼容读取**: 新字段应设为 nullable，读取旧数据时给予默认值。
2.  **版本号**: 在存储的数据结构中包含 `version` 字段。
3.  **迁移脚本**: 在 `init()` 方法中检查版本号，执行必要的迁移逻辑。

```dart
class UserData {
  final int version;
  final String name;
  final String? email; // 新增字段

  UserData({this.version = 2, required this.name, this.email});

  factory UserData.fromJson(Map<String, dynamic> json) {
    if (json['version'] == 1) {
      // 迁移逻辑: v1 -> v2
      return UserData(name: json['name'], email: '');
    }
    return UserData(
      version: json['version'],
      name: json['name'],
      email: json['email'],
    );
  }
}
```

## 5. 清理机制

### 5.1 过期清理
- **自动清理**: 周期性检查数据的创建时间，自动删除超过保留期限的数据。
- **保留策略**:
  - 监控原始数据: 24小时
  - 降采样数据 (1小时粒度): 30天
  - 降采样数据 (1天粒度): 90天

### 5.2 空间限制
- **LRU 淘汰**: 当存储空间不足或 Box 大小超过阈值（如 50MB）时，优先淘汰最久未访问的数据。

## 6. 代码审查清单 (Compliance Checklist)

- [ ] 是否使用了 `StorageService` 接口？
- [ ] 敏感数据是否开启了加密选项？
- [ ] 是否处理了可能的存储异常（如磁盘满、文件损坏）？
- [ ] 数据模型是否包含版本号或兼容性处理？
- [ ] 是否避免了在主线程进行大量数据的序列化/反序列化？
- [ ] 存储 Key 是否符合命名规范？
- [ ] 是否实现了相应的数据清理逻辑？

## 7. 异常处理

- **初始化失败**: 若存储初始化失败（如密钥损坏），应尝试重建存储或提示用户重新登录。
- **读写失败**: 捕获异常并记录日志，必要时降级服务（如暂时禁用缓存）。
