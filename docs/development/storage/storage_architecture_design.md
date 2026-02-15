# 存储模块架构设计文档

## 1. 架构概览

本项目的存储模块采用分层架构设计，旨在提供统一、安全、高性能的本地数据存储服务。

### 1.1 架构图

```mermaid
graph TD
    subgraph "Application Layer"
        UI[UI Components]
        Provider[State Management (Providers)]
    end

    subgraph "Domain Layer"
        Repo[Repositories]
    end

    subgraph "Data Layer"
        DS[Data Sources]
        MonitorDS[MonitorLocalDataSource]
        AuthDS[AuthLocalDataSource]
        
        StorageInterface[<<Interface>> StorageService]
        HiveImpl[HiveStorageService]
        SecureImpl[SecureStorageService]
    end

    subgraph "Infrastructure"
        Hive[Hive DB (NoSQL)]
        FSS[Flutter Secure Storage (Keychain/Keystore)]
    end

    UI --> Provider
    Provider --> Repo
    Repo --> DS
    
    DS --> MonitorDS
    DS --> AuthDS
    
    MonitorDS --> StorageInterface
    AuthDS --> StorageInterface
    
    StorageInterface <|.. HiveImpl
    StorageInterface <|.. SecureImpl
    
    HiveImpl --> Hive
    SecureImpl --> FSS
```

## 2. 核心组件

### 2.1 StorageService 接口
定义了通用的存储操作契约，确保上层业务逻辑与具体存储实现解耦。

```dart
abstract class StorageService {
  Future<void> init();
  Future<void> put(String key, dynamic value);
  dynamic get(String key, {dynamic defaultValue});
  Future<void> delete(String key);
  Future<void> clear();
  // ...
}
```

### 2.2 HiveStorageService
基于 Hive 的高性能键值对存储实现，支持 AES-256 加密。

- **适用场景**: 结构化数据、缓存、配置、监控历史数据。
- **特性**: 
  - 强类型支持
  - 自动加密（使用 Flutter Secure Storage 存储密钥）
  - 懒加载（LazyBox）支持大数据集

### 2.3 MonitorLocalDataSource
专门用于监控数据的本地数据源，封装了特定业务逻辑。

- **功能**:
  - **分表策略**: 按 `metric_yyyyMMddHH` 格式分表存储，避免单表过大。
  - **数据压缩**: 支持 7天/30天/90天 不同粒度的降采样。
  - **自动清理**: 定期清理过期数据。
  - **离线支持**: 网络不可用时自动降级读取本地数据。

## 3. API 文档

### 3.1 HiveStorageService

#### `init()`
初始化存储服务，包括打开 Box、获取或生成加密密钥。

#### `put(String key, dynamic value)`
存储数据。
- `key`: 唯一标识符。
- `value`: 可序列化的数据对象。

#### `get(String key, {dynamic defaultValue})`
获取数据。
- `defaultValue`: 当 key 不存在时返回的默认值。

### 3.2 MonitorLocalDataSource

#### `savePoints(String metric, List<MonitorDataPoint> points)`
批量保存监控数据点。内部会自动按小时分桶存储。

#### `getPoints(String metric, DateTime start, DateTime end)`
获取指定时间范围内的监控数据。自动聚合多个时间桶的数据。

#### `cleanAndCompressData()`
执行数据清理和压缩任务。建议在后台 isolate 或低频定时器中调用。

#### `uploadColdData()`
上传冷数据（24小时前）到服务器，并在成功后删除本地副本。仅在 Wi-Fi 环境且电量充足时执行。

## 4. 安全设计

- **密钥管理**: 使用 `flutter_secure_storage` 生成并存储 32 字节的 AES 密钥。
- **数据加密**: Hive Box 使用 AES-256 算法对磁盘数据进行加密。
- **内存安全**: 密钥仅在初始化时读取，尽量减少在内存中的暴露时间。

## 5. 性能优化

- **分箱存储**: 避免单个 Box 文件过大影响加载速度。
- **异步操作**: 所有 I/O 操作均为异步，避免阻塞 UI 线程。
- **降采样**: 对历史数据进行降采样，减少存储空间占用和读取解析时间。
