# Checklist

## 历史记录存储支持
- [x] 添加 `_historyBoxName` 常量和历史记录 Box
- [x] 在 `init()` 中初始化历史记录 Box
- [x] 添加 `_defaultHistoryRetentionDays` 默认值（30天）

## 历史记录保存和加载
- [x] `_saveToHistory()` 方法已实现
- [x] `_loadHistory()` 方法已实现
- [x] 完成的任务保存到历史记录而非删除

## 历史记录清理机制
- [x] `_cleanupHistory()` 方法已实现（根据用户设置的天数清理）
- [x] 启动时加载历史记录

## 用户可配置
- [x] 历史保留天数可由用户配置（`setHistoryRetentionDays()`）
- [x] UI 设置对话框已实现
- [x] 本地化字符串已添加

## 测试验证
- [x] flutter analyze 无错误
- [x] 历史记录持久化正常
