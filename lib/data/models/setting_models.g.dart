// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemSettings _$SystemSettingsFromJson(Map<String, dynamic> json) =>
    SystemSettings(
      siteName: json['siteName'] as String?,
      language: json['language'] as String?,
      theme: json['theme'] as String?,
      timeZone: json['timeZone'] as String?,
      sessionTimeout: json['sessionTimeout'] as String?,
      defaultPassword: json['defaultPassword'] as String?,
      allowAccessKey: json['allowAccessKey'] as bool?,
      complexity: json['complexity'] as String?,
      minPasswordLength: (json['minPasswordLength'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SystemSettingsToJson(SystemSettings instance) =>
    <String, dynamic>{
      'siteName': instance.siteName,
      'language': instance.language,
      'theme': instance.theme,
      'timeZone': instance.timeZone,
      'sessionTimeout': instance.sessionTimeout,
      'defaultPassword': instance.defaultPassword,
      'allowAccessKey': instance.allowAccessKey,
      'complexity': instance.complexity,
      'minPasswordLength': instance.minPasswordLength,
    };

SystemInfo _$SystemInfoFromJson(Map<String, dynamic> json) => SystemInfo(
      version: json['version'] as String?,
      build: json['build'] as String?,
      arch: json['arch'] as String?,
      os: json['os'] as String?,
      goVersion: json['goVersion'] as String?,
      dockerVersion: json['dockerVersion'] as String?,
      uptime: json['uptime'] as String?,
      totalMemory: (json['totalMemory'] as num?)?.toInt(),
      usedMemory: (json['usedMemory'] as num?)?.toInt(),
      totalDisk: (json['totalDisk'] as num?)?.toInt(),
      usedDisk: (json['usedDisk'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SystemInfoToJson(SystemInfo instance) =>
    <String, dynamic>{
      'version': instance.version,
      'build': instance.build,
      'arch': instance.arch,
      'os': instance.os,
      'goVersion': instance.goVersion,
      'dockerVersion': instance.dockerVersion,
      'uptime': instance.uptime,
      'totalMemory': instance.totalMemory,
      'usedMemory': instance.usedMemory,
      'totalDisk': instance.totalDisk,
      'usedDisk': instance.usedDisk,
    };

SystemTime _$SystemTimeFromJson(Map<String, dynamic> json) => SystemTime(
      time: json['time'] as String?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$SystemTimeToJson(SystemTime instance) =>
    <String, dynamic>{
      'time': instance.time,
      'timeZone': instance.timeZone,
    };

SystemTimeSet _$SystemTimeSetFromJson(Map<String, dynamic> json) =>
    SystemTimeSet(
      time: json['time'] as String?,
      timeZone: json['timeZone'] as String?,
    );

Map<String, dynamic> _$SystemTimeSetToJson(SystemTimeSet instance) =>
    <String, dynamic>{
      'time': instance.time,
      'timeZone': instance.timeZone,
    };

SecuritySettings _$SecuritySettingsFromJson(Map<String, dynamic> json) =>
    SecuritySettings(
      allowIPs: json['allowIPs'] as bool?,
      allowedIPs: (json['allowedIPs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      authMethod: json['authMethod'] as String?,
      failedAttempts: (json['failedAttempts'] as num?)?.toInt(),
      lockTime: (json['lockTime'] as num?)?.toInt(),
      passwordPolicy: json['passwordPolicy'] as String?,
    );

Map<String, dynamic> _$SecuritySettingsToJson(SecuritySettings instance) =>
    <String, dynamic>{
      'allowIPs': instance.allowIPs,
      'allowedIPs': instance.allowedIPs,
      'authMethod': instance.authMethod,
      'failedAttempts': instance.failedAttempts,
      'lockTime': instance.lockTime,
      'passwordPolicy': instance.passwordPolicy,
    };

SecuritySettingsUpdate _$SecuritySettingsUpdateFromJson(
        Map<String, dynamic> json) =>
    SecuritySettingsUpdate(
      allowIPs: json['allowIPs'] as bool?,
      allowedIPs: (json['allowedIPs'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      authMethod: json['authMethod'] as String?,
      failedAttempts: (json['failedAttempts'] as num?)?.toInt(),
      lockTime: (json['lockTime'] as num?)?.toInt(),
      passwordPolicy: json['passwordPolicy'] as String?,
    );

Map<String, dynamic> _$SecuritySettingsUpdateToJson(
        SecuritySettingsUpdate instance) =>
    <String, dynamic>{
      'allowIPs': instance.allowIPs,
      'allowedIPs': instance.allowedIPs,
      'authMethod': instance.authMethod,
      'failedAttempts': instance.failedAttempts,
      'lockTime': instance.lockTime,
      'passwordPolicy': instance.passwordPolicy,
    };

PanelSettings _$PanelSettingsFromJson(Map<String, dynamic> json) =>
    PanelSettings(
      title: json['title'] as String?,
      logo: json['logo'] as String?,
      theme: json['theme'] as String?,
      language: json['language'] as String?,
      serverName: json['serverName'] as String?,
      serverAddr: json['serverAddr'] as String?,
      port: json['port'] as String?,
      ssl: json['ssl'] as String?,
      ipv6: json['ipv6'] as String?,
      bind: json['bind'] as bool?,
    );

Map<String, dynamic> _$PanelSettingsToJson(PanelSettings instance) =>
    <String, dynamic>{
      'title': instance.title,
      'logo': instance.logo,
      'theme': instance.theme,
      'language': instance.language,
      'serverName': instance.serverName,
      'serverAddr': instance.serverAddr,
      'port': instance.port,
      'ssl': instance.ssl,
      'ipv6': instance.ipv6,
      'bind': instance.bind,
    };

PanelSettingsUpdate _$PanelSettingsUpdateFromJson(Map<String, dynamic> json) =>
    PanelSettingsUpdate(
      title: json['title'] as String?,
      logo: json['logo'] as String?,
      theme: json['theme'] as String?,
      language: json['language'] as String?,
      serverName: json['serverName'] as String?,
      serverAddr: json['serverAddr'] as String?,
      port: json['port'] as String?,
      ssl: json['ssl'] as String?,
      ipv6: json['ipv6'] as String?,
      bind: json['bind'] as bool?,
    );

Map<String, dynamic> _$PanelSettingsUpdateToJson(
        PanelSettingsUpdate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'logo': instance.logo,
      'theme': instance.theme,
      'language': instance.language,
      'serverName': instance.serverName,
      'serverAddr': instance.serverAddr,
      'port': instance.port,
      'ssl': instance.ssl,
      'ipv6': instance.ipv6,
      'bind': instance.bind,
    };

UserSettings _$UserSettingsFromJson(Map<String, dynamic> json) => UserSettings(
      username: json['username'] as String?,
      email: json['email'] as String?,
      language: json['language'] as String?,
      theme: json['theme'] as String?,
      timeZone: json['timeZone'] as String?,
      failedLoginAttempts: (json['failedLoginAttempts'] as num?)?.toInt(),
      lockTime: (json['lockTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserSettingsToJson(UserSettings instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'language': instance.language,
      'theme': instance.theme,
      'timeZone': instance.timeZone,
      'failedLoginAttempts': instance.failedLoginAttempts,
      'lockTime': instance.lockTime,
    };

UserSettingsUpdate _$UserSettingsUpdateFromJson(Map<String, dynamic> json) =>
    UserSettingsUpdate(
      username: json['username'] as String?,
      email: json['email'] as String?,
      language: json['language'] as String?,
      theme: json['theme'] as String?,
      timeZone: json['timeZone'] as String?,
      failedLoginAttempts: (json['failedLoginAttempts'] as num?)?.toInt(),
      lockTime: (json['lockTime'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserSettingsUpdateToJson(UserSettingsUpdate instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'language': instance.language,
      'theme': instance.theme,
      'timeZone': instance.timeZone,
      'failedLoginAttempts': instance.failedLoginAttempts,
      'lockTime': instance.lockTime,
    };

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      emailEnabled: json['emailEnabled'] as bool?,
      emailServer: json['emailServer'] as String?,
      emailPort: json['emailPort'] as String?,
      emailUsername: json['emailUsername'] as String?,
      emailPassword: json['emailPassword'] as String?,
      emailFrom: json['emailFrom'] as String?,
      webhookEnabled: json['webhookEnabled'] as bool?,
      webhookUrl: json['webhookUrl'] as String?,
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'emailEnabled': instance.emailEnabled,
      'emailServer': instance.emailServer,
      'emailPort': instance.emailPort,
      'emailUsername': instance.emailUsername,
      'emailPassword': instance.emailPassword,
      'emailFrom': instance.emailFrom,
      'webhookEnabled': instance.webhookEnabled,
      'webhookUrl': instance.webhookUrl,
    };

NotificationSettingsUpdate _$NotificationSettingsUpdateFromJson(
        Map<String, dynamic> json) =>
    NotificationSettingsUpdate(
      emailEnabled: json['emailEnabled'] as bool?,
      emailServer: json['emailServer'] as String?,
      emailPort: json['emailPort'] as String?,
      emailUsername: json['emailUsername'] as String?,
      emailPassword: json['emailPassword'] as String?,
      emailFrom: json['emailFrom'] as String?,
      webhookEnabled: json['webhookEnabled'] as bool?,
      webhookUrl: json['webhookUrl'] as String?,
    );

Map<String, dynamic> _$NotificationSettingsUpdateToJson(
        NotificationSettingsUpdate instance) =>
    <String, dynamic>{
      'emailEnabled': instance.emailEnabled,
      'emailServer': instance.emailServer,
      'emailPort': instance.emailPort,
      'emailUsername': instance.emailUsername,
      'emailPassword': instance.emailPassword,
      'emailFrom': instance.emailFrom,
      'webhookEnabled': instance.webhookEnabled,
      'webhookUrl': instance.webhookUrl,
    };

BackupSettings _$BackupSettingsFromJson(Map<String, dynamic> json) =>
    BackupSettings(
      backupDir: json['backupDir'] as String?,
      backupType: json['backupType'] as String?,
      backupRetention: json['backupRetention'] as String?,
      backupEnabled: json['backupEnabled'] as bool?,
      backupSchedule: json['backupSchedule'] as String?,
    );

Map<String, dynamic> _$BackupSettingsToJson(BackupSettings instance) =>
    <String, dynamic>{
      'backupDir': instance.backupDir,
      'backupType': instance.backupType,
      'backupRetention': instance.backupRetention,
      'backupEnabled': instance.backupEnabled,
      'backupSchedule': instance.backupSchedule,
    };

BackupSettingsUpdate _$BackupSettingsUpdateFromJson(
        Map<String, dynamic> json) =>
    BackupSettingsUpdate(
      backupDir: json['backupDir'] as String?,
      backupType: json['backupType'] as String?,
      backupRetention: json['backupRetention'] as String?,
      backupEnabled: json['backupEnabled'] as bool?,
      backupSchedule: json['backupSchedule'] as String?,
    );

Map<String, dynamic> _$BackupSettingsUpdateToJson(
        BackupSettingsUpdate instance) =>
    <String, dynamic>{
      'backupDir': instance.backupDir,
      'backupType': instance.backupType,
      'backupRetention': instance.backupRetention,
      'backupEnabled': instance.backupEnabled,
      'backupSchedule': instance.backupSchedule,
    };

ThemeSettings _$ThemeSettingsFromJson(Map<String, dynamic> json) =>
    ThemeSettings(
      theme: json['theme'] as String?,
      primaryColor: json['primaryColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
    );

Map<String, dynamic> _$ThemeSettingsToJson(ThemeSettings instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'primaryColor': instance.primaryColor,
      'backgroundColor': instance.backgroundColor,
      'textColor': instance.textColor,
    };

ThemeSettingsUpdate _$ThemeSettingsUpdateFromJson(Map<String, dynamic> json) =>
    ThemeSettingsUpdate(
      theme: json['theme'] as String?,
      primaryColor: json['primaryColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
    );

Map<String, dynamic> _$ThemeSettingsUpdateToJson(
        ThemeSettingsUpdate instance) =>
    <String, dynamic>{
      'theme': instance.theme,
      'primaryColor': instance.primaryColor,
      'backgroundColor': instance.backgroundColor,
      'textColor': instance.textColor,
    };

LanguageSettings _$LanguageSettingsFromJson(Map<String, dynamic> json) =>
    LanguageSettings(
      language: json['language'] as String?,
      region: json['region'] as String?,
    );

Map<String, dynamic> _$LanguageSettingsToJson(LanguageSettings instance) =>
    <String, dynamic>{
      'language': instance.language,
      'region': instance.region,
    };

LanguageSet _$LanguageSetFromJson(Map<String, dynamic> json) => LanguageSet(
      language: json['language'] as String?,
      region: json['region'] as String?,
    );

Map<String, dynamic> _$LanguageSetToJson(LanguageSet instance) =>
    <String, dynamic>{
      'language': instance.language,
      'region': instance.region,
    };

NTPSync _$NTPSyncFromJson(Map<String, dynamic> json) => NTPSync(
      enabled: json['enabled'] as bool?,
      server: json['server'] as String?,
      interval: json['interval'] as String?,
      timezone: json['timezone'] as String?,
    );

Map<String, dynamic> _$NTPSyncToJson(NTPSync instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'server': instance.server,
      'interval': instance.interval,
      'timezone': instance.timezone,
    };

TimezoneInfo _$TimezoneInfoFromJson(Map<String, dynamic> json) => TimezoneInfo(
      zone: json['zone'] as String?,
      offset: json['offset'] as String?,
    );

Map<String, dynamic> _$TimezoneInfoToJson(TimezoneInfo instance) =>
    <String, dynamic>{
      'zone': instance.zone,
      'offset': instance.offset,
    };

LanguageInfo _$LanguageInfoFromJson(Map<String, dynamic> json) => LanguageInfo(
      code: json['code'] as String?,
      name: json['name'] as String?,
      nativeName: json['nativeName'] as String?,
    );

Map<String, dynamic> _$LanguageInfoToJson(LanguageInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'nativeName': instance.nativeName,
    };

ThemeInfo _$ThemeInfoFromJson(Map<String, dynamic> json) => ThemeInfo(
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
      primaryColor: json['primaryColor'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
    );

Map<String, dynamic> _$ThemeInfoToJson(ThemeInfo instance) => <String, dynamic>{
      'name': instance.name,
      'displayName': instance.displayName,
      'primaryColor': instance.primaryColor,
      'backgroundColor': instance.backgroundColor,
    };

SettingsExport _$SettingsExportFromJson(Map<String, dynamic> json) =>
    SettingsExport(
      data: json['data'] as String?,
      timestamp: json['timestamp'] as String?,
      version: json['version'] as String?,
    );

Map<String, dynamic> _$SettingsExportToJson(SettingsExport instance) =>
    <String, dynamic>{
      'data': instance.data,
      'timestamp': instance.timestamp,
      'version': instance.version,
    };

SettingsImport _$SettingsImportFromJson(Map<String, dynamic> json) =>
    SettingsImport(
      data: json['data'] as String?,
      overwrite: json['overwrite'] as bool?,
    );

Map<String, dynamic> _$SettingsImportToJson(SettingsImport instance) =>
    <String, dynamic>{
      'data': instance.data,
      'overwrite': instance.overwrite,
    };

MfaCredential _$MfaCredentialFromJson(Map<String, dynamic> json) =>
    MfaCredential(
      code: json['code'] as String,
      interval: json['interval'] as String,
      secret: json['secret'] as String,
    );

Map<String, dynamic> _$MfaCredentialToJson(MfaCredential instance) =>
    <String, dynamic>{
      'code': instance.code,
      'interval': instance.interval,
      'secret': instance.secret,
    };

MfaOtp _$MfaOtpFromJson(Map<String, dynamic> json) => MfaOtp(
      qrImage: json['qrImage'] as String?,
      secret: json['secret'] as String?,
    );

Map<String, dynamic> _$MfaOtpToJson(MfaOtp instance) => <String, dynamic>{
      'qrImage': instance.qrImage,
      'secret': instance.secret,
    };

MfaBindRequest _$MfaBindRequestFromJson(Map<String, dynamic> json) =>
    MfaBindRequest(
      code: json['code'] as String,
      interval: json['interval'] as String,
      secret: json['secret'] as String,
    );

Map<String, dynamic> _$MfaBindRequestToJson(MfaBindRequest instance) =>
    <String, dynamic>{
      'code': instance.code,
      'interval': instance.interval,
      'secret': instance.secret,
    };

MfaStatus _$MfaStatusFromJson(Map<String, dynamic> json) => MfaStatus(
      enabled: json['enabled'] as bool,
      secret: json['secret'] as String?,
    );

Map<String, dynamic> _$MfaStatusToJson(MfaStatus instance) => <String, dynamic>{
      'enabled': instance.enabled,
      'secret': instance.secret,
    };
