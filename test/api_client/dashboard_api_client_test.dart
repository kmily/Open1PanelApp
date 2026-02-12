/// Dashboard API客户端测试
///
/// 测试DashboardV2Api客户端的所有方法
/// 复用现有的DashboardV2Api代码

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../api_client_test_base.dart';
import '../core/test_config_manager.dart';
import '../../lib/api/v2/dashboard_v2.dart';
import '../../lib/core/network/dio_client.dart';
import '../../lib/data/models/monitoring_models.dart';
import '../../lib/data/models/common_models.dart';

void main() {
  late DioClient client;
  late DashboardV2Api api;
  bool hasApiKey = false;

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = DashboardV2Api(client);
    }
  });

  group('Dashboard API客户端测试', () {
    test('配置验证 - API密钥已配置', () {
      print('\n========================================');
      print('测试配置信息');
      print('========================================');
      print('服务器地址: ${TestEnvironment.baseUrl}');
      print('API密钥: ${hasApiKey ? "已配置" : "未配置"}');
      print('========================================\n');
      
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
      }
      expect(hasApiKey, isTrue, reason: 'API密钥应该已配置');
    });

    group('getOperatingSystemInfo - 获取操作系统信息', () {
      test('应该成功获取操作系统信息', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getOperatingSystemInfo();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<SystemInfo>());

        final info = response.data!;
        print('\n========================================');
        print('✅ 操作系统信息测试成功');
        print('========================================');
        print('操作系统: ${info.os}');
        print('平台: ${info.platform}');
        print('内核版本: ${info.kernelVersion}');
        print('架构: ${info.architecture}');
        print('主机名: ${info.hostname}');
        print('========================================\n');

        TestDataValidator.expectNonEmptyString(info.os, fieldName: 'os');
        TestDataValidator.expectNonEmptyString(info.platform, fieldName: 'platform');
      });
    });

    group('getDashboardBase - 获取仪表板基础指标', () {
      test('应该成功获取基础指标（默认参数）', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getDashboardBase();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<Map<String, dynamic>>());

        final data = response.data!;
        print('\n========================================');
        print('✅ 仪表板基础指标测试成功');
        print('========================================');

        if (data.containsKey('hostname')) {
          print('主机名: ${data['hostname']}');
        }
        if (data.containsKey('cpuCores')) {
          print('CPU核心数: ${data['cpuCores']}');
        }
        if (data.containsKey('ipV4Addr')) {
          print('IPv4地址: ${data['ipV4Addr']}');
        }
        if (data.containsKey('websiteNumber')) {
          print('网站数量: ${data['websiteNumber']}');
        }
        if (data.containsKey('databaseNumber')) {
          print('数据库数量: ${data['databaseNumber']}');
        }
        if (data.containsKey('appInstalledNumber')) {
          print('已安装应用: ${data['appInstalledNumber']}');
        }
        print('========================================\n');
      });

      test('应该成功获取基础指标（自定义参数）', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getDashboardBase(
          ioOption: 'default',
          netOption: 'default',
        );

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        print('✅ 自定义参数测试成功');
      });
    });

    group('getCurrentMetrics - 获取当前指标', () {
      test('应该成功获取当前系统指标', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getCurrentMetrics();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<SystemMetrics>());

        final metrics = response.data!;
        print('\n========================================');
        print('✅ 当前系统指标测试成功');
        print('========================================');
        print('指标类型: ${metrics.type?.value}');
        print('单位: ${metrics.unit}');
        print('当前值: ${metrics.current}');
        print('最小值: ${metrics.min}');
        print('最大值: ${metrics.max}');
        print('平均值: ${metrics.avg}');
        print('========================================\n');
      });
    });

    group('getCurrentNode - 获取当前节点信息', () {
      test('应该成功获取节点信息', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getCurrentNode();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);

        final data = response.data!;
        print('\n========================================');
        print('✅ 节点信息测试成功');
        print('========================================');
        data.forEach((key, value) {
          if (value != null && value.toString().length < 100) {
            print('$key: $value');
          }
        });
        print('========================================\n');
      });
    });
  });

  group('Dashboard API性能测试', () {
    test('getOperatingSystemInfo响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getOperatingSystemInfo');
      timer.start();
      await api.getOperatingSystemInfo();
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });

    test('getDashboardBase响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getDashboardBase');
      timer.start();
      await api.getDashboardBase();
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });

    test('getCurrentMetrics响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getCurrentMetrics');
      timer.start();
      await api.getCurrentMetrics();
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });
  });
}
