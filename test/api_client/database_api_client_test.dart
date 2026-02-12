/// Database API客户端测试
///
/// 测试DatabaseV2Api客户端的所有方法
/// 复用现有的DatabaseV2Api代码

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../api_client_test_base.dart';
import '../core/test_config_manager.dart';
import '../../lib/api/v2/database_v2.dart';
import '../../lib/core/network/dio_client.dart';
import '../../lib/data/models/database_models.dart';
import '../../lib/data/models/common_models.dart';

void main() {
  late DioClient client;
  late DatabaseV2Api api;
  bool hasApiKey = false;

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = DatabaseV2Api(client);
    }
  });

  group('Database API客户端测试', () {
    test('配置验证 - API密钥已配置', () {
      print('\n========================================');
      print('Database API测试配置');
      print('========================================');
      print('服务器地址: ${TestEnvironment.baseUrl}');
      print('API密钥: ${hasApiKey ? "已配置" : "未配置"}');
      print('========================================\n');
      
      expect(hasApiKey, isTrue, reason: 'API密钥应该已配置');
    });

    group('searchDatabases - 搜索数据库', () {
      test('应该成功获取数据库列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = DatabaseSearch(
          page: 1,
          pageSize: 10,
        );
        final response = await api.searchDatabases(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<PageResult<DatabaseInfo>>());

        final result = response.data!;
        print('\n========================================');
        print('✅ 数据库列表测试成功');
        print('========================================');
        print('总数: ${result.total}');
        print('当前页: ${result.items?.length ?? 0} 个数据库');
        
        if (result.items != null && result.items!.isNotEmpty) {
          print('\n数据库列表:');
          for (var i = 0; i < (result.items!.length > 5 ? 5 : result.items!.length); i++) {
            final db = result.items![i];
            print('  - ${db.name} (${db.type}) - ${db.status}');
          }
        }
        print('========================================\n');
      });
    });
  });

  group('Database API性能测试', () {
    test('searchDatabases响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('searchDatabases');
      timer.start();
      await api.searchDatabases(DatabaseSearch(page: 1, pageSize: 10));
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });
  });
}
