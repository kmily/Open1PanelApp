# 存储选型报告 (Storage Selection Report)

## 1. 候选方案对比

| 特性 | **Hive** | **SQLite (sqflite)** | **Shared Preferences** | **Realm** |
|---|---|---|---|---|
| **类型** | NoSQL (Key-Value) | Relational (SQL) | Key-Value (XML/Plist) | NoSQL (Object) |
| **语言** | Pure Dart | C/C++ Bridge | Platform Native | C++ Bridge |
| **读写速度** | ⭐⭐⭐⭐⭐ (极快) | ⭐⭐⭐ (中等) | ⭐⭐ (慢，同步阻塞) | ⭐⭐⭐⭐⭐ (极快) |
| **加密支持** | AES-256 (内置) | SQLCipher (需扩展) | 无 (需配合 EncryptedSharedPreferences) | AES-256 (内置) |
| **复杂查询** | 弱 (仅 Key 查询) | 强 (SQL) | 无 | 强 (对象查询) |
| **跨平台一致性**| 100% (Dart 实现) | 依赖原生实现差异 | 依赖原生实现差异 | 100% (自包含引擎) |
| **包体积** | 小 | 中 | 极小 (内置) | 大 |

## 2. 选型决策：Hive

### 理由
1.  **性能**: 监控数据主要为高频写入（每5秒）和按时间范围的批量读取。Hive 的二进制读写性能远优于 SQLite，非常适合时序数据存储。
2.  **开发效率**: 纯 Dart 实现，无需处理 Native 桥接问题，调试方便。
3.  **加密**: 内置 AES-256 加密支持，满足安全合规要求。
4.  **轻量级**: 对于移动端应用，无需完整的关系型数据库功能，Key-Value 模型配合合理设计的 Key（如 `metric_timestamp`）足以满足需求。

## 3. 存储架构设计

### 核心层 (Core Layer)
- **`StorageService`**: 定义通用接口 (`init`, `get`, `put`, `delete`, `watch`)。
- **`HiveStorageService`**: `StorageService` 的 Hive 实现，封装加密逻辑和 Box 管理。

### 业务层 (Feature Layer)
- **`MonitorLocalDataSource`**:
  - 依赖 `HiveStorageService`。
  - 实现监控数据的业务逻辑：
    - **Key生成策略**: `${metric}_${yyyyMMddHH}` (按小时分桶)。
    - **数据压缩**: 超过24小时的数据进行降采样。
    - **过期清理**: 定时任务清理超过7天的数据。

### 性能基准 (参考)
- **写入**: 1000条记录 < 10ms (Hive) vs ~500ms (SQLite)。
- **读取**: 1000条记录 < 5ms (Hive) vs ~100ms (SQLite)。

## 4. 风险与对策
- **风险**: Hive 所有打开的 Box 数据会加载到内存（虽然是引用，但大量 Key 也会占用内存）。
- **对策**: 采用懒加载策略 (`LazyBox`) 或按需打开/关闭 Box（如按天分 Box，只打开当天的 Box）。目前方案采用按小时分 Key 存入同一个 Box，若数据量过大需升级为 `LazyBox`。
