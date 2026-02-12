/// Website API客户端测试
///
/// 测试WebsiteV2Api客户端的所有方法
/// 复用现有的WebsiteV2Api代码

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../api_client_test_base.dart';
import '../core/test_config_manager.dart';
import '../../lib/api/v2/website_v2.dart';
import '../../lib/core/network/dio_client.dart';
import '../../lib/data/models/website_models.dart';
import '../../lib/data/models/common_models.dart';

void main() {
  late DioClient client;
  late WebsiteV2Api api;
  bool hasApiKey = false;

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = WebsiteV2Api(client);
    }
  });

  group('Website API客户端测试', () {
    test('配置验证 - API密钥已配置', () {
      print('\n========================================');
      print('Website API测试配置');
      print('========================================');
      print('服务器地址: ${TestEnvironment.baseUrl}');
      print('API密钥: ${hasApiKey ? "已配置" : "未配置"}');
      print('========================================\n');
      
      expect(hasApiKey, isTrue, reason: 'API密钥应该已配置');
    });

    group('getWebsites - 获取网站列表', () {
      test('应该成功获取网站列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getWebsites(page: 1, pageSize: 10);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<PageResult<WebsiteInfo>>());

        final result = response.data!;
        print('\n========================================');
        print('✅ 网站列表测试成功');
        print('========================================');
        print('总数: ${result.total}');
        print('当前页: ${result.items?.length ?? 0} 个网站');
        
        if (result.items != null && result.items!.isNotEmpty) {
          print('\n网站列表:');
          for (var i = 0; i < (result.items!.length > 5 ? 5 : result.items!.length); i++) {
            final site = result.items![i];
            print('  - ${site.domain} (${site.status})');
          }
        }
        print('========================================\n');
      });
    });
  });

  group('Website API性能测试', () {
    test('getWebsites响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getWebsites');
      timer.start();
      await api.getWebsites(page: 1, pageSize: 10);
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });
  });
}
