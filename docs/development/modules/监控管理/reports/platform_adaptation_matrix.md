# 平台适配矩阵 (Platform Adaptation Matrix)

## 1. 操作系统支持范围

| 平台 | 最低版本 | 推荐版本 | 备注 |
|---|---|---|---|
| **iOS** | iOS 15.0 | iOS 17+ | 需适配灵动岛（Dynamic Island）和安全区域 |
| **Android** | Android 8.0 (API 26) | Android 14+ | 需适配动态取色 (Material You) |

## 2. 设备适配清单

### iOS 设备
| 设备型号 | 屏幕尺寸 | 逻辑分辨率 | 适配要点 |
|---|---|---|---|
| iPhone SE (3rd) | 4.7" | 375 x 667 | 小屏布局紧凑，避免溢出 |
| iPhone 13/14/15 | 6.1" | 390 x 844 | 标准参考机型 |
| iPhone Pro Max | 6.7" | 430 x 932 | 大屏利用，展示更多图表数据点 |
| iPad mini | 8.3" | 744 x 1133 | 平板布局，支持侧边导航 |
| iPad Pro 12.9" | 12.9" | 1024 x 1366 | 多分栏布局 (Split View) |

### Android 设备
| 设备类型 | 屏幕密度 (dpi) | 典型分辨率 | 适配要点 |
|---|---|---|---|
| 入门机型 | hdpi / xhdpi | 720p | 性能优化，减少过度绘制 |
| 主流旗舰 | xxhdpi | 1080p+ | 动态刷新率支持 (90Hz/120Hz) |
| 折叠屏 | 变化 | 变化 | 适配 `DisplayFeature`，处理折叠态 |
| 平板 | tvdpi / mdpi | 宽屏 | 使用 `NavigationRail` 替代底部导航 |

## 3. UI/UX 适配差异

| 功能点 | iOS 实现规范 | Android 实现规范 |
|---|---|---|
| **导航** | 底部 TabBar (半透明磨砂) | NavigationBar (M3 样式) |
| **返回** | 边缘右滑手势 | 系统返回键 / 侧滑手势 |
| **对话框** | CupertinoAlertDialog | AlertDialog (Material 3) |
| **滚动** | 弹性回弹 (BouncingScrollPhysics) | 墨水波纹尽头 (ClampingScrollPhysics - Android 12+ stretch) |
| **图表交互** | 长按触发 Haptic Touch | 长按触发普通震动反馈 |
| **字体** | San Francisco | Roboto / Product Sans |

## 4. 不支持/降级支持清单

- **Android 7.1 及以下**: 不支持，系统 API 限制。
- **32位 Android 设备**: 可能存在性能问题，不作为重点优化对象。
- **非标准屏幕比例**: 如手表、车载大屏，暂不适配。
