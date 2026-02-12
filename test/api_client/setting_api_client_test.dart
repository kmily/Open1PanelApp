/// Setting API客户端测试
///
/// 测试SettingV2Api客户端的所有方法
/// 复用现有的SettingV2Api代码

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import '../api_client_test_base.dart';
import '../core/test_config_manager.dart';
import '../../lib/api/v2/setting_v2.dart';
import '../../lib/core/network/dio_client.dart';
import '../../lib/data/models/setting_models.dart';

void main() {
  late DioClient client;
  late SettingV2Api api;
  bool hasApiKey = false;

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = SettingV2Api(client);
    }
  });

  group('Setting API客户端测试', () {
    test('配置验证 - API密钥已配置', () {
      print('\n========================================');
      print('Setting API测试配置');
      print('========================================');
      print('服务器地址: ${TestEnvironment.baseUrl}');
      print('API密钥: ${hasApiKey ? "已配置" : "未配置"}');
      print('========================================\n');
      
      expect(hasApiKey, isTrue, reason: 'API密钥应该已配置');
    });

    group('getSystemSettings - 获取系统设置', () {
      test('应该成功获取系统设置', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getSystemSettings();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<SystemSettings>());

        final settings = response.data!;
        print('\n========================================');
        print('✅ 系统设置测试成功');
        print('========================================');
        print('系统设置已获取');
        print('========================================\n');
      });
    });

    group('getPanelSettings - 获取面板设置', () {
      test('应该成功获取面板设置', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getPanelSettings();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<PanelSettings>());

        final settings = response.data!;
        print('\n========================================');
        print('✅ 面板设置测试成功');
        print('========================================');
        print('面板设置已获取');
        print('========================================\n');
      });
    });

    group('getSystemTime - 获取系统时间', () {
      test('应该成功获取系统时间', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getSystemTime();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<SystemTime>());

        final time = response.data!;
        print('\n========================================');
        print('✅ 系统时间测试成功');
        print('========================================');
        print('系统时间: ${time.time}');
        print('时区: ${time.timeZone}');
        print('========================================\n');
      });
    });

    group('getSecuritySettings - 获取安全设置', () {
      test('应该成功获取安全设置', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.getSecuritySettings();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<SecuritySettings>());

        print('\n========================================');
        print('✅ 安全设置测试成功');
        print('========================================\n');
      });
    });

    group('MFA相关API', () {
      test('loadMfaInfo - 应该成功加载MFA信息', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final request = MfaCredential(
          code: '',
          interval: '30',
          secret: '',
        );
        
        final response = await api.loadMfaInfo(request);

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);
        expect(response.data, isA<MfaOtp>());

        final otp = response.data!;
        print('\n========================================');
        print('✅ MFA信息加载成功');
        print('========================================');
        print('Secret: ${otp.secret}');
        print('QR Image: ${otp.qrImage != null ? "已生成" : "未生成"}');
        print('========================================\n');
      });
    });

    group('generateApiKey - 生成API密钥', () {
      test('应该成功生成API密钥', () async {
        if (!hasApiKey) {
          print('⚠️  跳过测试: API密钥未配置');
          return;
        }

        final response = await api.generateApiKey();

        expect(response.statusCode, equals(200));
        expect(response.data, isNotNull);

        print('\n========================================');
        print('✅ API密钥生成测试成功');
        print('========================================\n');
      });
    });
  });

  group('Setting API性能测试', () {
    test('getSystemSettings响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getSystemSettings');
      timer.start();
      await api.getSystemSettings();
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });

    test('getPanelSettings响应时间应该小于3秒', () async {
      if (!hasApiKey) {
        print('⚠️  跳过测试: API密钥未配置');
        return;
      }

      final timer = TestPerformanceTimer('getPanelSettings');
      timer.start();
      await api.getPanelSettings();
      timer.stop();
      timer.logResult();
      expect(timer.duration.inMilliseconds, lessThan(3000));
    });
  });
}
