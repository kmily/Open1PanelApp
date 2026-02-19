// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnapshotOperate _$SnapshotOperateFromJson(Map<String, dynamic> json) =>
    SnapshotOperate(
      id: (json['id'] as num?)?.toInt(),
      operate: json['operate'] as String,
    );

Map<String, dynamic> _$SnapshotOperateToJson(SnapshotOperate instance) =>
    <String, dynamic>{
      'id': instance.id,
      'operate': instance.operate,
    };

SnapshotOperateRequest _$SnapshotOperateRequestFromJson(
        Map<String, dynamic> json) =>
    SnapshotOperateRequest(
      ids: (json['ids'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      operate: json['operate'] as String,
    );

Map<String, dynamic> _$SnapshotOperateRequestToJson(
        SnapshotOperateRequest instance) =>
    <String, dynamic>{
      'ids': instance.ids,
      'operate': instance.operate,
    };

SnapshotInfo _$SnapshotInfoFromJson(Map<String, dynamic> json) => SnapshotInfo(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      createTime: json['createTime'] as String?,
      status: json['status'] as String?,
      path: json['path'] as String?,
      size: json['size'] as String?,
      version: json['version'] as String?,
      isDefault: json['isDefault'] as bool?,
      appCount: (json['appCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SnapshotInfoToJson(SnapshotInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'createTime': instance.createTime,
      'status': instance.status,
      'path': instance.path,
      'size': instance.size,
      'version': instance.version,
      'isDefault': instance.isDefault,
      'appCount': instance.appCount,
    };

SnapshotCreateRequest _$SnapshotCreateRequestFromJson(
        Map<String, dynamic> json) =>
    SnapshotCreateRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      source: json['source'] as String?,
      ignoreApps: (json['ignoreApps'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ignoreDatabases: (json['ignoreDatabases'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      ignoreDirectories: (json['ignoreDirectories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      encryptConfig: json['encryptConfig'] as bool?,
      encryptApp: json['encryptApp'] as bool?,
      encryptDatabase: json['encryptDatabase'] as bool?,
    );

Map<String, dynamic> _$SnapshotCreateRequestToJson(
        SnapshotCreateRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'source': instance.source,
      'ignoreApps': instance.ignoreApps,
      'ignoreDatabases': instance.ignoreDatabases,
      'ignoreDirectories': instance.ignoreDirectories,
      'encryptConfig': instance.encryptConfig,
      'encryptApp': instance.encryptApp,
      'encryptDatabase': instance.encryptDatabase,
    };

SnapshotCreateResult _$SnapshotCreateResultFromJson(
        Map<String, dynamic> json) =>
    SnapshotCreateResult(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      snapshotId: (json['snapshotId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$SnapshotCreateResultToJson(
        SnapshotCreateResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'snapshotId': instance.snapshotId,
    };

SnapshotRecoverRequest _$SnapshotRecoverRequestFromJson(
        Map<String, dynamic> json) =>
    SnapshotRecoverRequest(
      id: (json['id'] as num?)?.toInt(),
      deleteLocal: json['deleteLocal'] as bool?,
      encryptionPassword: json['encryptionPassword'] as String?,
    );

Map<String, dynamic> _$SnapshotRecoverRequestToJson(
        SnapshotRecoverRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deleteLocal': instance.deleteLocal,
      'encryptionPassword': instance.encryptionPassword,
    };

SnapshotRecoverResult _$SnapshotRecoverResultFromJson(
        Map<String, dynamic> json) =>
    SnapshotRecoverResult(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      snapshotInfo: json['snapshotInfo'] == null
          ? null
          : SnapshotInfo.fromJson(json['snapshotInfo'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SnapshotRecoverResultToJson(
        SnapshotRecoverResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'snapshotInfo': instance.snapshotInfo,
    };
