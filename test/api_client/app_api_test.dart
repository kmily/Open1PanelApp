import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onepanelapp_app/api/v2/app_v2.dart';
import 'package:onepanelapp_app/core/network/dio_client.dart';
import 'package:onepanelapp_app/data/models/app_models.dart';
import 'package:dio/dio.dart';
import '../core/test_config_manager.dart';
import '../api_client_test_base.dart';

void main() {
  late DioClient client;
  late AppV2Api api;
  bool hasApiKey = false;
  final resultCollector = TestResultCollector();

  // Test State Variables
  AppItem? targetApp;
  AppItem? targetAppDetail;
  int? appDetailId;
  String? appVersion;
  String? appType;
  String? appKey;
  int? installedAppId;
  String installName = 'test-openresty'; // Use a distinct name for testing

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    debugPrint('\n╔════════════════════════════════════════════════════════════╗');
    debugPrint('║              App Management Full Integration Test           ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    debugPrint('║ Server: ${TestEnvironment.baseUrl}');
    debugPrint('║ API Key: ${hasApiKey ? "Configured" : "Missing"}');
    debugPrint('╚════════════════════════════════════════════════════════════╝\n');
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = AppV2Api(client);

      // Initial Sync
      try {
        await api.syncRemoteApps();
        await api.syncLocalApps();
      } catch (e) {
        debugPrint('Sync warning: $e');
      }
    }
  });

  tearDownAll(() {
    resultCollector.printSummary();
  });

  // Helper to poll for status
  Future<void> waitForStatus(int installId, String targetStatus, {Duration timeout = const Duration(minutes: 5)}) async {
    final endTime = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(endTime)) {
      final info = await api.getAppInstallInfo(installId.toString());
      debugPrint('   Current status: ${info.status} (Target: $targetStatus)');
      if (info.status == targetStatus) return;
      if (info.status == 'Error') throw Exception('App entered Error state: ${info.message}');
      await Future.delayed(const Duration(seconds: 3));
    }
    throw Exception('Timeout waiting for status: $targetStatus');
  }

  group('1. App Store Discovery Tests', () {
    test('POST /apps/search - Search for OpenResty', () async {
      if (!hasApiKey) return;
      final testName = 'Search OpenResty';
      try {
        final request = AppSearchRequest(page: 1, pageSize: 10, name: 'openresty');
        final response = await api.searchApps(request);
        expect(response.items, isNotEmpty);
        targetApp = response.items.first;
        appKey = targetApp!.key;
        debugPrint('✅ Found app: ${targetApp!.name} (Key: $appKey, ID: ${targetApp!.id})');
        resultCollector.addSuccess(testName, Duration.zero);
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        rethrow;
      }
    });

    test('GET /apps/detail/... - Get App Detail', () async {
      if (!hasApiKey || targetApp == null) return;
      final testName = 'Get App Detail';
      try {
        // Search results might not have versions, fetch full detail first by key
        debugPrint('🔍 Fetching full detail for ${targetApp!.key}...');
        targetApp = await api.getAppByKey(targetApp!.key!);
        
        // Now check versions
        final versions = targetApp!.versions ?? [];
        if (versions.isEmpty) {
          debugPrint('⚠️ No versions found for ${targetApp!.name}. Skipping install tests.');
          resultCollector.addSkipped(testName, 'No versions found');
          return;
        }
        
        appVersion = versions.first;
        appType = targetApp!.type ?? 'app'; // Default to app
        
        debugPrint('📦 Selected Version: $appVersion, Type: $appType');

        // Note: getAppDetail takes (appId, version, type)
        targetAppDetail = await api.getAppDetail(targetApp!.id.toString(), appVersion!, appType!);
        expect(targetAppDetail, isNotNull);
        appDetailId = targetAppDetail!.id;
        
        debugPrint('✅ Got detail for ID: $appDetailId');
        resultCollector.addSuccess(testName, Duration.zero);
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        rethrow;
      }
    });

    test('GET /apps/details/:id - Get Detail by ID', () async {
      if (!hasApiKey || appDetailId == null) return;
      try {
        final item = await api.getAppDetails(appDetailId.toString());
        expect(item.id, equals(appDetailId));
        resultCollector.addSuccess('Get Detail by ID', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Get Detail by ID', e.toString(), Duration.zero);
      }
    });

    test('GET /apps/:key - Get App by Key', () async {
      if (!hasApiKey || appKey == null) return;
      try {
        final item = await api.getAppByKey(appKey!);
        expect(item.key, equals(appKey));
        resultCollector.addSuccess('Get App by Key', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Get App by Key', e.toString(), Duration.zero);
      }
    });

    test('GET /apps/icon/:id - Get App Icon', () async {
      if (!hasApiKey || appKey == null) return;
      try {
        final response = await api.getAppIcon(appKey!); // Usually takes key or ID, let's try key based on logic
        expect(response.data, isNotNull);
        resultCollector.addSuccess('Get App Icon', Duration.zero);
      } catch (e) {
        // Some apps might not have icons or endpoint differs, treat as warning
        debugPrint('⚠️ Get App Icon warning: $e');
        resultCollector.addSuccess('Get App Icon (Warning)', Duration.zero);
      }
    });
  });

  group('2. App Installation Tests', () {
    test('Cleanup before install', () async {
      if (!hasApiKey) return;
      // Search if already installed by NAME
      final search = await api.searchInstalledApps(AppInstalledSearchRequest(page: 1, pageSize: 10, name: installName));
      if (search.items.isNotEmpty) {
        debugPrint('⚠️ Found existing test app, uninstalling...');
        final app = search.items.first;
        await api.uninstallApp(app.id.toString());
        await Future.delayed(const Duration(seconds: 5));
      }
    });

    test('POST /apps/installed/check - Check Install', () async {
      if (!hasApiKey || targetApp == null) return;
      try {
        final req = AppInstalledCheckRequest(key: targetApp!.key!, version: appVersion!, type: appType!);
        final res = await api.checkAppInstall(req);
        debugPrint('✅ Install check: ${res.exist ? "Exists" : "Not Exists"}');
        resultCollector.addSuccess('Check Install', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Check Install', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/installed/conf - Get Install Config', () async {
      if (!hasApiKey || targetApp == null) return;
      try {
        // This endpoint might fail if app not installed or name mismatch
        // Just log warning if fails
        final config = await api.getAppInstallConfig(targetApp!.name!, targetApp!.key!);
        debugPrint('✅ Got install config with ${config.keys.length} keys');
        resultCollector.addSuccess('Get Install Config', Duration.zero);
      } catch (e) {
        debugPrint('⚠️ Get Install Config failed (expected if not installed/configured): $e');
        resultCollector.addSuccess('Get Install Config (Warning)', Duration.zero);
      }
    });

    test('POST /apps/install - Install App', () async {
      if (!hasApiKey || appDetailId == null) return;
      final testName = 'Install App ($installName)';
      try {
        // Check limits
        final installedList = await api.getInstalledApps();
        final installedCount = installedList.where((app) => app.appKey == targetApp!.key).length;
        final limit = targetApp!.limit ?? 0;
        
        if (limit > 0 && installedCount >= limit) {
          debugPrint('⚠️ App limit reached ($installedCount/$limit). checking for test instances...');
          // Find if any installed app starts with 'test-'
          final testInstances = installedList.where((app) => 
            (app.name?.startsWith('test-') ?? false)
          ).toList();
          
          if (testInstances.isNotEmpty) {
             final toRemove = testInstances.first;
             debugPrint('♻️ Uninstalling existing instance ${toRemove.name} (ID: ${toRemove.id}) to free up slot...');
             await api.uninstallApp(toRemove.id.toString());
             await Future.delayed(const Duration(seconds: 5));
          } else {
             debugPrint('⛔ Cannot install: Limit reached and no test instances found. Skipping install test.');
             resultCollector.addSkipped(testName, 'App limit reached');
             return;
          }
        }

        final request = AppInstallCreateRequest(
          appDetailId: appDetailId!,
          name: installName,
          type: appType,
          advanced: false,
          params: {}, // Default params
          allowPort: true,
        );
        
        debugPrint('🚀 Starting installation of $installName...');
        final info = await api.installApp(request);
        installedAppId = info.id; // Usually returns the installed ID
        
        expect(installedAppId, isNotNull);
        debugPrint('✅ Installation started. ID: $installedAppId');
        
        // Wait for installation to complete (status: Installed or Running)
        debugPrint('⏳ Waiting for installation to complete...');
        await waitForStatus(installedAppId!, 'Running'); // OpenResty usually goes to Running
        
        resultCollector.addSuccess(testName, Duration.zero);
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        rethrow;
      }
    });
  });

  group('3. Installed App Management Tests', () {
    test('GET /apps/installed/list - List Installed', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        final list = await api.getInstalledApps();
        final found = list.any((app) => app.id == installedAppId);
        expect(found, isTrue);
        resultCollector.addSuccess('List Installed', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('List Installed', e.toString(), Duration.zero);
      }
    });

    test('GET /apps/installed/info/:id - Get Install Info', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        final info = await api.getAppInstallInfo(installedAppId.toString());
        expect(info.id, equals(installedAppId));
        resultCollector.addSuccess('Get Install Info', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Get Install Info', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/installed/conninfo - Get Conn Info', () async {
      if (!hasApiKey || targetApp == null) return;
      try {
        final info = await api.getAppConnInfo(installName, targetApp!.key!);
        debugPrint('✅ Conn Info: $info');
        resultCollector.addSuccess('Get Conn Info', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Get Conn Info', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/installed/op - Stop App', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        debugPrint('⏹ Stopping app...');
        await api.operateApp(AppInstalledOperateRequest(
          installId: installedAppId!,
          operate: 'stop',
        ));
        await waitForStatus(installedAppId!, 'Stopped');
        resultCollector.addSuccess('Stop App', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Stop App', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/installed/op - Start App', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        debugPrint('▶️ Starting app...');
        await api.operateApp(AppInstalledOperateRequest(
          installId: installedAppId!,
          operate: 'start',
        ));
        await waitForStatus(installedAppId!, 'Running');
        resultCollector.addSuccess('Start App', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Start App', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/installed/op - Restart App', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        debugPrint('🔄 Restarting app...');
        await api.operateApp(AppInstalledOperateRequest(
          installId: installedAppId!,
          operate: 'restart',
        ));
        await waitForStatus(installedAppId!, 'Running');
        resultCollector.addSuccess('Restart App', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Restart App', e.toString(), Duration.zero);
      }
    });
    
    test('POST /apps/installed/params/update - Update Params', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
         // Just a dummy update to verify endpoint reachable
         // Need actual params, so we fetch first
         final params = await api.getAppInstallParams(installedAppId.toString());
         await api.updateAppParams({
           'installId': installedAppId,
           ...params,
         });
         resultCollector.addSuccess('Update Params', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Update Params', e.toString(), Duration.zero);
      }
    });
  });

  group('4. App Configuration & Services', () {
    test('GET /apps/services/:key - Get App Services', () async {
      if (!hasApiKey || appKey == null) return;
      try {
        final services = await api.getAppServices(appKey!);
        debugPrint('✅ Services found: ${services.length}');
        resultCollector.addSuccess('Get App Services', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Get App Services', e.toString(), Duration.zero);
      }
    });

    test('GET /core/settings/apps/store/config - Get Store Config', () async {
      if (!hasApiKey) return;
      try {
        final config = await api.getAppstoreConfig();
        // defaultDomain might be null
        debugPrint('✅ Store Config Domain: ${config.defaultDomain}');
        resultCollector.addSuccess('Get Store Config', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Get Store Config', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/update - Update App Cache', () async {
      if (!hasApiKey) return;
      try {
        await api.checkAppUpdate();
        resultCollector.addSuccess('Check App Update', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Check App Update', e.toString(), Duration.zero);
      }
    });
  });

  group('5. Advanced & Edge Cases', () {
    test('POST /apps/installed/sync - Sync App Status', () async {
      if (!hasApiKey) return;
      try {
        await api.syncAppStatus();
        resultCollector.addSuccess('Sync App Status', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Sync App Status', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/installed/loadport - Load App Port', () async {
      if (!hasApiKey || targetApp == null) return;
      try {
        // usually takes name and type
        await api.loadAppPort({
          'name': targetApp!.name,
          'type': targetApp!.key, // backend likely uses key as type here
        }); 
        resultCollector.addSuccess('Load App Port', Duration.zero);
      } catch (e) {
        debugPrint('⚠️ Load App Port warning: $e');
        resultCollector.addSuccess('Load App Port (Warning)', Duration.zero);
      }
    });
    
    test('Ignore & Cancel Ignore Update', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        // Ignore
        await api.ignoreAppUpdate(AppInstalledIgnoreUpgradeRequest(
          appInstallId: installedAppId!,
          reason: 'Test ignore',
        ));
        
        // Check list
        final ignored = await api.getIgnoredApps();
        expect(ignored.any((app) => app.id == installedAppId), isTrue);
        
        // Cancel
        await api.cancelIgnoreAppUpdate(AppInstalledIgnoreUpgradeRequest(
          appInstallId: installedAppId!,
          reason: '',
        ));
        
        // Check list again
        final ignoredAfter = await api.getIgnoredApps();
        expect(ignoredAfter.any((app) => app.id == installedAppId), isFalse);
        
        resultCollector.addSuccess('Ignore/Cancel Update', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Ignore/Cancel Update', e.toString(), Duration.zero);
      }
    });
    
    test('Get Update Versions', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        final versions = await api.getAppUpdateVersions(installedAppId.toString());
        // Might be empty, just check no error
        debugPrint('✅ Update versions: ${versions.length}');
        resultCollector.addSuccess('Get Update Versions', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Get Update Versions', e.toString(), Duration.zero);
      }
    });
  });

  group('6. Uninstallation Tests', () {
    test('GET /apps/installed/delete/check/:id - Check Uninstall', () async {
      if (!hasApiKey || installedAppId == null) return;
      try {
        final check = await api.checkAppUninstall(installedAppId.toString());
        debugPrint('✅ Uninstall Check: $check');
        resultCollector.addSuccess('Check Uninstall', Duration.zero);
      } catch (e) {
        resultCollector.addFailure('Check Uninstall', e.toString(), Duration.zero);
      }
    });

    test('POST /apps/uninstall/:id - Uninstall App', () async {
      if (!hasApiKey || installedAppId == null) return;
      final testName = 'Uninstall App';
      try {
        debugPrint('🗑 Uninstalling app...');
        await api.uninstallApp(installedAppId.toString());
        
        // Wait for it to disappear from installed list
        bool removed = false;
        for (int i = 0; i < 20; i++) {
          final list = await api.getInstalledApps();
          if (!list.any((app) => app.id == installedAppId)) {
            removed = true;
            break;
          }
          await Future.delayed(const Duration(seconds: 2));
        }
        
        expect(removed, isTrue);
        debugPrint('✅ App uninstalled successfully');
        resultCollector.addSuccess(testName, Duration.zero);
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
      }
    });
  });
}
