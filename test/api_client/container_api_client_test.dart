/// Container API客户端测试
///
/// 测试ContainerV2Api客户端的所有方法
/// 复用现有的ContainerV2Api代码

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../api_client_test_base.dart';
import '../core/test_config_manager.dart';
import '../../lib/api/v2/container_v2.dart';
import '../../lib/core/network/dio_client.dart';
import '../../lib/data/models/container_models.dart';
import '../../lib/data/models/common_models.dart';

void main() {
  late DioClient client;
  late ContainerV2Api api;
  bool hasApiKey = false;

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = ContainerV2Api(client);
    }
  });

  group('Container API客户端测试', () {
    test('配置验证 - API密钥已配置', () {
      print('\n========================================');
      print('Container API测试配置');
      print('========================================');
      print('服务器地址: ${TestEnvironment.baseUrl}');
      print('API密钥: ${hasApiKey ? "已配置" : "未配置"}');
      print('========================================\n');
      
      expect(hasApiKey, isTrue, reason: 'API密钥应该已配置');
    });

    group('getContainerStatus - 获取容器状态统计', () {
      test('应该成功获取容器状态统计', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getContainerStatus();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<ContainerStatus>());

        final status = response.data!;
        print('\n========================================');
        print('✅ 容器状态统计测试成功');
        print('========================================');
        print('运行中: ${status.running}');
        print('已停止: ${status.exited}');
        print('已暂停: ${status.paused}');
        print('总数: ${status.all}');
        print('镜像数量: ${status.imageCount}');
        print('网络数量: ${status.networkCount}');
        print('卷数量: ${status.volumeCount}');
        print('Compose数量: ${status.composeCount}');
        print('========================================\n');

        TestDataValidator.expectNonNegativeInt(status.running, fieldName: 'running');
        TestDataValidator.expectNonNegativeInt(status.exited, fieldName: 'exited');
        TestDataValidator.expectNonNegativeInt(status.all, fieldName: 'all');
      });
    });

    group('searchContainers - 搜索容器列表', () {
      test('应该成功获取容器列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = PageContainer(page: 1, pageSize: 10);
        final response = await api.searchContainers(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<PageResult<ContainerInfo>>());

        final result = response.data!;
        print('\n========================================');
        print('✅ 容器列表测试成功');
        print('========================================');
        print('总数: ${result.total}');
        print('当前页: ${result.items?.length ?? 0} 个容器');
        
        if (result.items != null && result.items!.isNotEmpty) {
          print('\n容器列表:');
          for (var i = 0; i < (result.items!.length > 5 ? 5 : result.items!.length); i++) {
            final container = result.items![i];
            print('  - ${container.name} (${container.status})');
          }
        }
        print('========================================\n');
      });
    });

    group('listContainerStats - 获取容器统计列表', () {
      test('应该成功获取容器统计列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.listContainerStats();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<List<ContainerListStats>>());

        final stats = response.data!;
        print('\n========================================');
        print('✅ 容器统计列表测试成功');
        print('========================================');
        print('统计数量: ${stats.length}');
        print('========================================\n');
      });
    });

    group('getImageOptions - 获取镜像选项', () {
      test('应该成功获取镜像选项', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getImageOptions();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<List<Map<String, dynamic>>>());

        print('\n========================================');
        print('✅ 镜像选项测试成功');
        print('========================================');
        print('选项数量: ${response.data!.length}');
        print('========================================\n');
      });
    });

    group('getAllImages - 获取所有镜像', () {
      test('应该成功获取所有镜像', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getAllImages();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<List<Map<String, dynamic>>>());

        final images = response.data!;
        print('\n========================================');
        print('✅ 镜像列表测试成功');
        print('========================================');
        print('镜像数量: ${images.length}');
        if (images.isNotEmpty) {
          print('\n镜像列表:');
          for (var i = 0; i < (images.length > 5 ? 5 : images.length); i++) {
            final image = images[i];
            print('  - ${image['repoTags'] ?? image['id']}');
          }
        }
        print('========================================\n');
      });
    });

    group('getNetworkOptions - 获取网络选项', () {
      test('应该成功获取网络选项', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getNetworkOptions();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);

        print('\n========================================');
        print('✅ 网络选项测试成功');
        print('========================================');
        print('选项数量: ${response.data!.length}');
        print('========================================\n');
      });
    });

    group('searchNetworks - 搜索网络列表', () {
      test('应该成功获取网络列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = SearchWithPage(page: 1, pageSize: 10);
        final response = await api.searchNetworks(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<PageResult<Map<String, dynamic>>>());

        final result = response.data!;
        print('\n========================================');
        print('✅ 网络列表测试成功');
        print('========================================');
        print('总数: ${result.total}');
        if (result.items != null && result.items!.isNotEmpty) {
          print('网络列表:');
          for (var item in result.items!) {
            print('  - ${item['name']} (${item['driver']})');
          }
        }
        print('========================================\n');
      });
    });

    group('getVolumeOptions - 获取卷选项', () {
      test('应该成功获取卷选项', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getVolumeOptions();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);

        print('\n========================================');
        print('✅ 卷选项测试成功');
        print('========================================');
        print('选项数量: ${response.data!.length}');
        print('========================================\n');
      });
    });

    group('searchVolumes - 搜索卷列表', () {
      test('应该成功获取卷列表', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = SearchWithPage(page: 1, pageSize: 10);
        final response = await api.searchVolumes(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<PageResult<Map<String, dynamic>>>());

        final result = response.data!;
        print('\n========================================');
        print('✅ 卷列表测试成功');
        print('========================================');
        print('总数: ${result.total}');
        print('========================================\n');
      });
    });
  });

  group('Container API性能测试', () {
    test('getContainerStatus响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getContainerStatus');
      timer.start();
      await api.getContainerStatus();
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });

    test('searchContainers响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('searchContainers');
      timer.start();
      await api.searchContainers(PageContainer(page: 1, pageSize: 10));
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });

    test('getAllImages响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getAllImages');
      timer.start();
      await api.getAllImages();
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });
  });
}
