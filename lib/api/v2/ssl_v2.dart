/// 1Panel V2 API - SSL 相关接口
///
/// 此文件包含与SSL证书管理相关的所有API接口，
/// 包括证书的创建、删除、更新、查询等操作。

import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/config/api_constants.dart';
import '../../data/models/ssl_models.dart';
import '../../data/models/common_models.dart';

class SSLV2Api {
  final DioClient _client;

  SSLV2Api(this._client);

  /// 创建SSL证书
  ///
  /// 创建一个新的SSL证书
  /// @param ssl 证书配置信息
  /// @return 创建结果
  Future<Response> createSSL(SSLCertificateCreate ssl) async {
    return await _client.post(
      ApiConstants.buildApiPath('/ssl'),
      data: ssl.toJson(),
    );
  }

  /// 删除SSL证书
  ///
  /// 删除指定的SSL证书
  /// @param ids 证书ID列表
  /// @return 删除结果
  Future<Response> deleteSSL(List<int> ids) async {
    final operation = BatchDelete(ids: ids);
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/del'),
      data: operation.toJson(),
    );
  }

  /// 更新SSL证书
  ///
  /// 更新指定的SSL证书
  /// @param ssl 证书更新信息
  /// @return 更新结果
  Future<Response> updateSSL(SSLCertificateUpdate ssl) async {
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/${ssl.id}/update'),
      data: ssl.toJson(),
    );
  }

  /// 获取SSL证书列表
  ///
  /// 获取所有SSL证书列表
  /// @param search 搜索关键词（可选）
  /// @param certificateType 证书类型（可选）
  /// @param status 证书状态（可选）
  /// @param domain 域名（可选）
  /// @param page 页码（可选，默认为1）
  /// @param pageSize 每页数量（可选，默认为10）
  /// @return 证书列表
  Future<Response<PageResult<SSLCertificateInfo>>> getSSLCertificates({
    String? search,
    String? certificateType,
    SSLCertificateStatus? status,
    String? domain,
    int page = 1,
    int pageSize = 10,
  }) async {
    final request = SSLCertificateSearch(
      page: page,
      pageSize: pageSize,
      search: search,
      certificateType: certificateType,
      status: status,
      domain: domain,
    );
    final response = await _client.post(
      ApiConstants.buildApiPath('/ssl/search'),
      data: request.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => SSLCertificateInfo.fromJson(json as Map<String, dynamic>),
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取SSL证书详情
  ///
  /// 获取指定SSL证书的详细信息
  /// @param id 证书ID
  /// @return 证书详情
  Future<Response<SSLCertificateInfo>> getSSLCertificateDetail(int id) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/ssl/$id'),
    );
    return Response(
      data: SSLCertificateInfo.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 申请Let's Encrypt证书
  ///
  /// 申请Let's Encrypt免费SSL证书
  /// @param ssl SSL申请配置
  /// @return 申请结果
  Future<Response> applyLetsEncrypt(SSLApply ssl) async {
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/letsencrypt/apply'),
      data: ssl.toJson(),
    );
  }

  /// 验证SSL证书
  ///
  /// 验证SSL证书的有效性
  /// @param id 证书ID
  /// @return 验证结果
  Future<Response<SSLCertificateValidation>> validateSSLCertificate(int id) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/ssl/$id/validate'),
    );
    return Response(
      data: SSLCertificateValidation.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 续期SSL证书
  ///
  /// 续期即将过期的SSL证书
  /// @param id 证书ID
  /// @return 续期结果
  Future<Response> renewSSLCertificate(int id) async {
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/$id/renew'),
    );
  }

  /// 批量续期SSL证书
  ///
  /// 批量续期即将过期的SSL证书
  /// @param ids 证书ID列表
  /// @return 续期结果
  Future<Response> renewSSLCertificates(List<int> ids) async {
    final operation = BatchDelete(ids: ids);
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/batch/renew'),
      data: operation.toJson(),
    );
  }

  /// 启用SSL证书自动续期
  ///
  /// 启用指定SSL证书的自动续期功能
  /// @param id 证书ID
  /// @return 操作结果
  Future<Response> enableSSLCertificateAutoRenewal(int id) async {
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/$id/auto-renewal/enable'),
    );
  }

  /// 禁用SSL证书自动续期
  ///
  /// 禁用指定SSL证书的自动续期功能
  /// @param id 证书ID
  /// @return 操作结果
  Future<Response> disableSSLCertificateAutoRenewal(int id) async {
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/$id/auto-renewal/disable'),
    );
  }

  /// 获取ACME账户列表
  ///
  /// 获取所有ACME账户列表
  /// @return ACME账户列表
  Future<Response<List<ACMEAccount>>> getACMEAccounts() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/ssl/acme/accounts'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => ACMEAccount.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 创建ACME账户
  ///
  /// 创建新的ACME账户
  /// @param email 邮箱地址
  /// @param server ACME服务器地址
  /// @return 创建结果
  Future<Response<ACMEAccount>> createACMEAccount({
    required String email,
    required String server,
  }) async {
    final data = {
      'email': email,
      'server': server,
    };
    final response = await _client.post(
      ApiConstants.buildApiPath('/ssl/acme/accounts'),
      data: data,
    );
    return Response(
      data: ACMEAccount.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 删除ACME账户
  ///
  /// 删除指定的ACME账户
  /// @param id 账户ID
  /// @return 删除结果
  Future<Response> deleteACMEAccount(int id) async {
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/acme/accounts/$id/del'),
    );
  }

  /// 获取SSL证书挑战信息
  ///
  /// 获取SSL证书申请的挑战信息
  /// @param id 申请ID
  /// @return 挑战信息
  Future<Response<List<SSLCertificateChallenge>>> getSSLChallenges(int id) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/ssl/$id/challenges'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => SSLCertificateChallenge.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取SSL证书统计信息
  ///
  /// 获取SSL证书的统计信息
  /// @return 统计信息
  Future<Response> getSSLStats() async {
    return await _client.get(
      ApiConstants.buildApiPath('/ssl/stats'),
    );
  }

  /// 导入SSL证书
  ///
  /// 从文件导入SSL证书
  /// @param certificate 证书内容
  /// @param privateKey 私钥内容
  /// @param chain 证书链内容（可选）
  /// @return 导入结果
  Future<Response> importSSLCertificate({
    required String certificate,
    required String privateKey,
    String? chain,
  }) async {
    final data = {
      'certificate': certificate,
      'privateKey': privateKey,
      if (chain != null) 'chain': chain,
    };
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/import'),
      data: data,
    );
  }

  /// 导出SSL证书
  ///
  /// 导出SSL证书到文件
  /// @param id 证书ID
  /// @param format 导出格式
  /// @return 导出结果
  Future<Response> exportSSLCertificate({
    required int id,
    String format = 'pem',
  }) async {
    final data = {
      'format': format,
    };
    return await _client.post(
      ApiConstants.buildApiPath('/ssl/$id/export'),
      data: data,
    );
  }

  // 系统 SSL 证书管理相关方法
  /// 下载系统证书
  ///
  /// 下载系统 SSL 证书文件
  /// @return 证书下载链接
  Future<Response<String>> downloadSystemCert() async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/core/settings/ssl/download'),
    );
    return Response(
      data: response.data.toString(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取系统证书信息
  ///
  /// 获取系统 SSL 证书的详细信息
  /// @return 系统证书信息
  Future<Response<Map<String, dynamic>>> loadSystemCertInfo() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/core/settings/ssl/info'),
    );
    return Response(
      data: response.data as Map<String, dynamic>,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 更新系统SSL证书
  ///
  /// 更新系统 SSL 证书
  /// @param certData 证书数据
  /// @return 更新结果
  Future<Response> updateSystemSSL(Map<String, dynamic> certData) async {
    return await _client.post(
      ApiConstants.buildApiPath('/core/settings/ssl/update'),
      data: certData,
    );
  }

  // Website SSL 证书管理相关方法
  /// 创建网站SSL证书
  ///
  /// 为网站创建SSL证书
  /// @param ssl 网站SSL配置
  /// @return 创建结果
  Future<Response> createWebsiteSSL(WebsiteSSLCreate ssl) async {
    return await _client.post(
      ApiConstants.buildApiPath('/websites/ssl'),
      data: ssl.toJson(),
    );
  }

  /// 根据ID搜索网站SSL证书
  ///
  /// 获取指定ID的网站SSL证书详情
  /// @param id SSL证书ID
  /// @return SSL证书详情
  Future<Response<WebsiteSSL>> getWebsiteSSLById(int id) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/websites/ssl/$id'),
    );
    return Response(
      data: WebsiteSSL.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 删除网站SSL证书
  ///
  /// 删除指定的网站SSL证书
  /// @param ids SSL证书ID列表
  /// @return 删除结果
  Future<Response> deleteWebsiteSSL(List<int> ids) async {
    final operation = BatchDelete(ids: ids);
    return await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/del'),
      data: operation.toJson(),
    );
  }

  /// 下载SSL文件
  ///
  /// 下载网站SSL证书文件
  /// @param id SSL证书ID
  /// @return 下载链接
  Future<Response<String>> downloadSSLFile(int id) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/download'),
      data: {'id': id},
    );
    return Response(
      data: response.data.toString(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 申请SSL证书
  ///
  /// 为网站申请SSL证书
  /// @param sslApply SSL申请配置
  /// @return 申请结果
  Future<Response> applySSL(WebsiteSSLApply sslApply) async {
    return await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/obtain'),
      data: sslApply.toJson(),
    );
  }

  /// 解析网站SSL
  ///
  /// 解析网站SSL证书状态和配置
  /// @param sslResolve SSL解析配置
  /// @return 解析结果
  Future<Response<WebsiteSSL>> resolveWebsiteSSL(WebsiteSSLResolve sslResolve) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/resolve'),
      data: sslResolve.toJson(),
    );
    return Response(
      data: WebsiteSSL.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 分页搜索网站SSL证书
  ///
  /// 分页搜索网站SSL证书列表
  /// @param search 搜索请求
  /// @return SSL证书分页列表
  Future<Response<PageResult<WebsiteSSL>>> searchWebsiteSSL(WebsiteSSLSearch search) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/search'),
      data: search.toJson(),
    );
    return Response(
      data: PageResult.fromJson(
        response.data as Map<String, dynamic>,
        (json) => WebsiteSSL.fromJson(json as Map<String, dynamic>),
      ),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 更新SSL证书
  ///
  /// 更新网站SSL证书配置
  /// @param ssl SSL更新配置
  /// @return 更新结果
  Future<Response> updateWebsiteSSL(WebsiteSSLUpdate ssl) async {
    return await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/update'),
      data: ssl.toJson(),
    );
  }

  /// 上传SSL证书
  ///
  /// 上传SSL证书文件
  /// @param sslUpload SSL上传配置
  /// @return 上传结果
  Future<Response> uploadSSL(WebsiteSSLUpload sslUpload) async {
    return await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/upload'),
      data: sslUpload.toJson(),
    );
  }

  /// 根据网站ID搜索SSL证书
  ///
  /// 获取指定网站的SSL证书信息
  /// @param websiteId 网站ID
  /// @return SSL证书信息
  Future<Response<WebsiteSSL>> getWebsiteSSLByWebsiteId(int websiteId) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/websites/ssl/website/$websiteId'),
    );
    return Response(
      data: WebsiteSSL.fromJson(response.data as Map<String, dynamic>),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 获取SSL选项
  ///
  /// 获取SSL证书操作的可用选项
  /// @return SSL选项列表
  Future<Response<List<Map<String, dynamic>>>> getSSLOptions() async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/websites/ssl/options'),
    );
    return Response(
      data: (response.data as List?)
          ?.map((item) => item as Map<String, dynamic>)
          .toList() ?? [],
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 验证SSL证书配置
  ///
  /// 验证SSL证书配置的正确性
  /// @param sslConfig SSL配置信息
  /// @return 验证结果
  Future<Response<Map<String, dynamic>>> validateSSLConfig(Map<String, dynamic> sslConfig) async {
    final response = await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/validate'),
      data: sslConfig,
    );
    return Response(
      data: response.data as Map<String, dynamic>,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  /// 自动续期SSL证书
  ///
  /// 自动续期即将过期的SSL证书
  /// @param ids SSL证书ID列表
  /// @return 续期结果
  Future<Response> autoRenewSSL(List<int> ids) async {
    final operation = BatchDelete(ids: ids);
    return await _client.post(
      ApiConstants.buildApiPath('/websites/ssl/auto-renew'),
      data: operation.toJson(),
    );
  }

  /// 获取SSL证书申请状态
  ///
  /// 获取SSL证书申请的当前状态
  /// @param id 申请ID
  /// @return 申请状态
  Future<Response<Map<String, dynamic>>> getSSLApplicationStatus(int id) async {
    final response = await _client.get(
      ApiConstants.buildApiPath('/websites/ssl/application/$id/status'),
    );
    return Response(
      data: response.data as Map<String, dynamic>,
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }
}