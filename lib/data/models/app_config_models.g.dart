// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfig _$AppConfigFromJson(Map<String, dynamic> json) => AppConfig(
      params: (json['params'] as List<dynamic>)
          .map((e) => InstallParams.fromJson(e as Map<String, dynamic>))
          .toList(),
      rawCompose: json['rawCompose'] as String?,
      cpuQuota: (json['cpuQuota'] as num).toDouble(),
      memoryLimit: (json['memoryLimit'] as num).toDouble(),
      memoryUnit: json['memoryUnit'] as String,
      containerName: json['containerName'] as String,
      allowPort: json['allowPort'] as bool,
      dockerCompose: json['dockerCompose'] as String,
      hostMode: json['hostMode'] as bool?,
      type: json['type'] as String,
      webUI: json['webUI'] as String,
      specifyIP: json['specifyIP'] as String?,
      restartPolicy: json['restartPolicy'] as String?,
    );

Map<String, dynamic> _$AppConfigToJson(AppConfig instance) => <String, dynamic>{
      'params': instance.params,
      'rawCompose': instance.rawCompose,
      'cpuQuota': instance.cpuQuota,
      'memoryLimit': instance.memoryLimit,
      'memoryUnit': instance.memoryUnit,
      'containerName': instance.containerName,
      'allowPort': instance.allowPort,
      'dockerCompose': instance.dockerCompose,
      'hostMode': instance.hostMode,
      'type': instance.type,
      'webUI': instance.webUI,
      'specifyIP': instance.specifyIP,
      'restartPolicy': instance.restartPolicy,
    };

InstallParams _$InstallParamsFromJson(Map<String, dynamic> json) =>
    InstallParams(
      labelZh: json['labelZh'] as String,
      labelEn: json['labelEn'] as String,
      value: json['value'],
      edit: json['edit'] as bool,
      key: json['key'] as String,
      rule: json['rule'] as String?,
      type: json['type'] as String,
      values: json['values'],
      showValue: json['showValue'] as String?,
      required: json['required'] as bool?,
      multiple: json['multiple'] as bool?,
      label: json['label'] == null
          ? null
          : Locale.fromJson(json['label'] as Map<String, dynamic>),
      showPassword: json['showPassword'] as bool?,
    );

Map<String, dynamic> _$InstallParamsToJson(InstallParams instance) =>
    <String, dynamic>{
      'labelZh': instance.labelZh,
      'labelEn': instance.labelEn,
      'value': instance.value,
      'edit': instance.edit,
      'key': instance.key,
      'rule': instance.rule,
      'type': instance.type,
      'values': instance.values,
      'showValue': instance.showValue,
      'required': instance.required,
      'multiple': instance.multiple,
      'label': instance.label,
      'showPassword': instance.showPassword,
    };

Locale _$LocaleFromJson(Map<String, dynamic> json) => Locale(
      zh: json['zh'] as String,
      en: json['en'] as String,
      zhHant: json['zh-Hant'] as String?,
      ja: json['ja'] as String?,
      ms: json['ms'] as String?,
      ptBr: json['pt-br'] as String?,
      ru: json['ru'] as String?,
      ko: json['ko'] as String?,
      tr: json['tr'] as String?,
      esEs: json['es-es'] as String?,
    );

Map<String, dynamic> _$LocaleToJson(Locale instance) => <String, dynamic>{
      'zh': instance.zh,
      'en': instance.en,
      'zh-Hant': instance.zhHant,
      'ja': instance.ja,
      'ms': instance.ms,
      'pt-br': instance.ptBr,
      'ru': instance.ru,
      'ko': instance.ko,
      'tr': instance.tr,
      'es-es': instance.esEs,
    };
