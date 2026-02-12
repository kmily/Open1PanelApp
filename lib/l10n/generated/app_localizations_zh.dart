// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '1Panel Open';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonRetry => '重试';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonRefresh => '刷新';

  @override
  String get commonComingSoon => '即将支持';

  @override
  String get navServer => '服务器';

  @override
  String get navFiles => '文件';

  @override
  String get navSecurity => '动态验证';

  @override
  String get navSettings => '设置';

  @override
  String get serverPageTitle => '服务器';

  @override
  String get serverSearchHint => '请输入服务器名称或 IP';

  @override
  String get serverAdd => '添加';

  @override
  String get serverListEmptyTitle => '暂无服务器';

  @override
  String get serverListEmptyDesc => '先添加一个 1Panel 服务器开始使用。';

  @override
  String get serverOnline => '在线';

  @override
  String get serverOffline => '离线';

  @override
  String get serverCurrent => '当前';

  @override
  String get serverDefault => '默认';

  @override
  String get serverIpLabel => 'IP';

  @override
  String get serverCpuLabel => 'CPU';

  @override
  String get serverMemoryLabel => '内存';

  @override
  String get serverLoadLabel => '负载';

  @override
  String get serverDiskLabel => '磁盘';

  @override
  String get serverMetricsUnavailable => '监控数据暂不可用';

  @override
  String get serverOpenDetail => '查看详情';

  @override
  String get serverDetailTitle => '服务器详情';

  @override
  String get serverModulesTitle => '功能模块';

  @override
  String get serverModuleApps => '应用';

  @override
  String get serverModuleContainers => '容器';

  @override
  String get serverModuleWebsites => '网站';

  @override
  String get serverModuleDatabases => '数据库';

  @override
  String get serverModuleFirewall => '防火墙';

  @override
  String get serverModuleTerminal => '终端';

  @override
  String get serverModuleMonitoring => '监控';

  @override
  String get serverModuleFiles => '文件管理';

  @override
  String get serverInsightsTitle => '运行概览';

  @override
  String get serverActionsTitle => '快捷操作';

  @override
  String get serverActionRefresh => '刷新';

  @override
  String get serverActionSwitch => '切换服务器';

  @override
  String get serverActionSecurity => '动态验证';

  @override
  String get serverFormTitle => '添加服务器';

  @override
  String get serverFormName => '服务器名称';

  @override
  String get serverFormNameHint => '例如：生产环境';

  @override
  String get serverFormUrl => '服务器地址';

  @override
  String get serverFormUrlHint => '例如：https://panel.example.com';

  @override
  String get serverFormApiKey => 'API 密钥';

  @override
  String get serverFormApiKeyHint => '请输入 API 密钥';

  @override
  String get serverFormSaveConnect => '保存并继续';

  @override
  String get serverFormTest => '测试连接';

  @override
  String get serverFormRequired => '该字段不能为空';

  @override
  String get serverFormSaveSuccess => '服务器已保存';

  @override
  String serverFormSaveFailed(String error) {
    return '保存服务器失败：$error';
  }

  @override
  String get serverFormTestHint => '连接测试可在 client 适配后接入。';

  @override
  String get filesPageTitle => '文件';

  @override
  String get filesPath => '路径';

  @override
  String get filesRoot => '根目录';

  @override
  String get filesEmptyTitle => '文件页占位已完成';

  @override
  String get filesEmptyDesc => '页面结构已就绪，后续接入文件 API 即可。';

  @override
  String get filesActionUpload => '上传';

  @override
  String get filesActionNewFile => '新建文件';

  @override
  String get filesActionNewFolder => '新建文件夹';

  @override
  String get securityPageTitle => '动态验证';

  @override
  String get securityStatusTitle => 'MFA 状态';

  @override
  String get securityStatusEnabled => '已启用';

  @override
  String get securityStatusDisabled => '未启用';

  @override
  String get securitySecretLabel => '密钥';

  @override
  String get securityCodeLabel => '验证码';

  @override
  String get securityCodeHint => '输入 6 位验证码';

  @override
  String get securityLoadInfo => '加载 MFA 信息';

  @override
  String get securityBind => '绑定 MFA';

  @override
  String get securityBindSuccess => 'MFA 绑定请求已提交';

  @override
  String securityBindFailed(String error) {
    return '绑定 MFA 失败：$error';
  }

  @override
  String get securityMockNotice => '当前页面运行在 UI 适配模式，后续可直接接入 API client。';

  @override
  String get settingsPageTitle => '设置';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsTheme => '主题';

  @override
  String get settingsServerManagement => '服务器管理';

  @override
  String get settingsResetOnboarding => '重新查看引导';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsResetOnboardingDone => '已重置引导状态';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageSystem => '系统';

  @override
  String get languageZh => '中文';

  @override
  String get languageEn => '英文';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingStart => '开始使用';

  @override
  String get onboardingTitle1 => '统一管理 1Panel 服务器';

  @override
  String get onboardingDesc1 => '在移动端完成监控、文件与安全相关操作。';

  @override
  String get onboardingTitle2 => '快速切换与清晰状态';

  @override
  String get onboardingDesc2 => '卡片化信息让你快速判断服务器运行状态。';

  @override
  String get onboardingTitle3 => '先稳 UI，再接 API';

  @override
  String get onboardingDesc3 => '缺失接口会记录在评审文档，便于后续并行适配。';

  @override
  String get coachServerAddTitle => '先添加一个服务器';

  @override
  String get coachServerAddDesc => '点击这里创建服务器配置。';

  @override
  String get coachServerCardTitle => '点击卡片进入详情';

  @override
  String get coachServerCardDesc => '在详情页中访问各个功能模块与快捷操作。';

  @override
  String get coachDone => '我知道了';

  @override
  String get notFoundTitle => '页面不存在';

  @override
  String get notFoundDesc => '请求的页面不存在或已迁移。';

  @override
  String get legacyRouteRedirect => '该旧路由已跳转到新版主界面。';
}
