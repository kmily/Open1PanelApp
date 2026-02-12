/// File API客户端测试
///
/// 测试FileV2Api客户端的所有方法
/// 复用现有的FileV2Api代码

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../api_client_test_base.dart';
import '../core/test_config_manager.dart';
import '../../lib/api/v2/file_v2.dart';
import '../../lib/core/network/dio_client.dart';
import '../../lib/data/models/file_models.dart';

void main() {
  late DioClient client;
  late FileV2Api api;
  bool hasApiKey = false;

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = FileV2Api(client);
    }
  });

  group('File API客户端测试', () {
    test('配置验证 - API密钥已配置', () {
      print('\n========================================');
      print('File API测试配置');
      print('========================================');
      print('服务器地址: ${TestEnvironment.baseUrl}');
      print('API密钥: ${hasApiKey ? "已配置" : "未配置"}');
      print('========================================\n');
      
      expect(hasApiKey, isTrue, reason: 'API密钥应该已配置');
    });

    group('getFiles - 获取文件列表', () {
      test('应该成功获取根目录文件列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = FileSearch(path: '/');
        final response = await api.getFiles(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<List<FileInfo>>());

        final files = response.data!;
        print('\n========================================');
        print('✅ 文件列表测试成功');
        print('========================================');
        print('文件数量: ${files.length}');
        
        if (files.isNotEmpty) {
          print('\n文件列表:');
          for (var i = 0; i < (files.length > 10 ? 10 : files.length); i++) {
            final file = files[i];
            final type = file.isDir ? '📁' : '📄';
            print('  $type ${file.name}');
          }
        }
        print('========================================\n');
      });

      test('应该成功获取指定目录文件列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = FileSearch(path: '/opt');
        final response = await api.getFiles(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);

        final files = response.data!;
        print('✅ /opt目录文件数量: ${files.length}');
      });
    });

    group('getFileTree - 获取文件树', () {
      test('应该成功获取文件树结构', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = FileTreeRequest(path: '/');
        final response = await api.getFileTree(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);

        print('\n========================================');
        print('✅ 文件树测试成功');
        print('========================================\n');
      });
    });

    group('getRecycleBinStatus - 获取回收站状态', () {
      test('应该成功获取回收站状态', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getRecycleBinStatus();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);

        final status = response.data!;
        print('\n========================================');
        print('✅ 回收站状态测试成功');
        print('========================================');
        print('回收站大小: ${status.totalSize}');
        print('文件数量: ${status.fileCount}');
        print('========================================\n');
      });
    });
  });

  group('File API性能测试', () {
    test('getFiles响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getFiles');
      timer.start();
      await api.getFiles(FileSearch(path: '/'));
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });
  });
}
