# 修复文件管理功能错误 Spec (第二轮)

## Why
用户测试发现多个功能仍有错误：wget 下载提示失败但实际成功、收藏夹页面无法进入且不显示星标、回收站为空、文件下载权限处理不完善。

## What Changes
- 修复 wget 下载结果解析（服务器返回 key 字段而非 success）
- 修复 BottomSheet 中的 Provider 问题
- 修复收藏夹页面入口和星标显示
- 修复回收站数据解析
- 完善文件下载权限处理（iOS/Android）

## Impact
- Affected code:
  - `lib/features/files/files_provider.dart` - wget 结果解析
  - `lib/features/files/files_page.dart` - BottomSheet Provider、收藏星标
  - `lib/features/files/favorites_page.dart` - 页面入口
  - `lib/features/files/recycle_bin_page.dart` - 数据解析
  - `lib/features/files/files_service.dart` - 下载权限
  - `lib/data/models/file_models.dart` - FileWgetResult 模型

## ADDED Requirements

### Requirement: wget 下载结果正确解析
wget 下载成功时应正确显示结果。

### Requirement: 收藏状态正确显示
已收藏的文件应显示星标，且收藏夹页面可正常进入。

### Requirement: 回收站数据正确解析
回收站应正确显示已删除的文件。

### Requirement: 文件下载权限引导
下载文件时如遇权限问题，应引导用户申请权限。
