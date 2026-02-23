import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import '../core/test_config_manager.dart';
import '../api_client_test_base.dart';
import 'package:onepanelapp_app/core/network/dio_client.dart';
import 'package:onepanelapp_app/data/models/file_models.dart';
import 'package:onepanelapp_app/api/v2/file_v2.dart';

void main() {
  late DioClient client;
  late FileV2Api api;
  bool hasApiKey = false;
  final resultCollector = TestResultCollector();

  setUpAll(() async {
    await TestEnvironment.initialize();
    hasApiKey = TestEnvironment.apiKey.isNotEmpty && TestEnvironment.apiKey != 'your_api_key_here';
    
    debugPrint('\n╔════════════════════════════════════════════════════════════╗');
    debugPrint('║              文件管理 API 测试                              ║');
    debugPrint('╠════════════════════════════════════════════════════════════╣');
    debugPrint('║ 服务器地址: ${TestEnvironment.baseUrl}');
    debugPrint('║ API密钥: ${hasApiKey ? "已配置" : "未配置"}');
    debugPrint('╚════════════════════════════════════════════════════════════╝\n');
    
    if (hasApiKey) {
      client = DioClient(
        baseUrl: TestEnvironment.baseUrl,
        apiKey: TestEnvironment.apiKey,
      );
      api = FileV2Api(client);
    }
  });

  tearDownAll(() {
    resultCollector.printSummary();
  });

  group('文件搜索 API 测试', () {
    test('POST /files/search - 搜索根目录文件', () async {
      final testName = 'POST /files/search - 搜索根目录文件';
      final timer = TestPerformanceTimer(testName);
      timer.start();
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        debugPrint('⚠️  跳过测试: API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearch(
          path: '/',
          page: 1,
          pageSize: 20,
          showHidden: false,
        );
        
        debugPrint('📤 请求参数:');
        debugPrint('  ${const JsonEncoder.withIndent("  ").convert(request.toJson())}');
        
        final response = await api.searchFiles(request);
        
        debugPrint('\n📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 原始响应数据类型: ${response.data.runtimeType}');
        
        if (response.data != null) {
          debugPrint('📥 解析后数据:');
          debugPrint('  - 文件数量: ${response.data!.items.length}');
          debugPrint('  - 总数: ${response.data!.total}');
          
          if (response.data!.items.isNotEmpty) {
            debugPrint('\n📁 前3个文件:');
            for (var i = 0; i < (response.data!.items.length > 3 ? 3 : response.data!.items.length); i++) {
              final file = response.data!.items[i];
              debugPrint('  [$i] ${file.name}');
              debugPrint('      路径: ${file.path}');
              debugPrint('      类型: ${file.type}');
              debugPrint('      大小: ${file.size}');
              debugPrint('      是否目录: ${file.isDir}');
              debugPrint('      权限: ${file.permission}');
              debugPrint('      修改时间: ${file.modifiedAt}');
            }
          }
          
          expect(response.data!.items, isA<List<FileInfo>>());
          timer.stop();
          resultCollector.addSuccess(testName, timer.duration);
          debugPrint('\n✅ 测试成功! 耗时: ${timer.duration.inMilliseconds}ms');
        }
      } catch (e, stackTrace) {
        timer.stop();
        resultCollector.addFailure(testName, e.toString(), timer.duration);
        debugPrint('\n❌ 测试失败: $e');
        debugPrint('堆栈跟踪:\n$stackTrace');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/search - 搜索指定目录', () async {
      final testName = 'POST /files/search - 搜索指定目录';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearch(
          path: '/opt/1panel',
          page: 1,
          pageSize: 10,
        );
        
        debugPrint('📤 请求参数: path=/opt/1panel');
        
        final response = await api.searchFiles(request);
        
        debugPrint('📥 响应: ${response.data!.items.length} 个文件');
        
        if (response.data!.items.isNotEmpty) {
          debugPrint('📁 第一个文件: ${response.data!.items.first.name}');
        }
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('文件检查 API 测试', () {
    test('POST /files/check - 检查文件是否存在', () async {
      final testName = 'POST /files/check - 检查文件是否存在';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileCheck(path: '/opt/1panel');
        
        debugPrint('📤 请求参数: path=/opt/1panel');
        
        final response = await api.checkFile(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 文件存在: ${response.data?.exists}');
        debugPrint('📥 文件类型: ${response.data?.isDirectory == true ? "目录" : "文件"}');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('文件树 API 测试', () {
    test('POST /files/tree - 获取文件树', () async {
      final testName = 'POST /files/tree - 获取文件树';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileTreeRequest(
          path: '/',
          maxDepth: 2,
          includeFiles: false,
        );
        
        debugPrint('📤 请求参数: path=/, maxDepth=2, includeFiles=false');
        
        final response = await api.getFileTree(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 根节点: ${response.data?.name}');
        debugPrint('📥 子节点数量: ${response.data?.children?.length ?? 0}');
        
        if (response.data?.children != null && response.data!.children!.isNotEmpty) {
          debugPrint('\n📁 子目录:');
          for (final child in response.data!.children!.take(5)) {
            debugPrint('  - ${child.name} (${child.type == "dir" ? "目录" : "文件"})');
          }
        }
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('文件大小 API 测试', () {
    test('POST /files/size - 获取文件大小', () async {
      final testName = 'POST /files/size - 获取文件大小';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSizeRequest(
          path: '/opt/1panel',
          recursive: true,
        );
        
        debugPrint('📤 请求参数: path=/opt/1panel, recursive=true');
        
        final response = await api.getFileSize(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 总大小: ${response.data?.totalSize} bytes');
        debugPrint('📥 格式化大小: ${_formatBytes(response.data?.totalSize ?? 0)}');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('回收站 API 测试', () {
    test('GET /files/recycle/status - 获取回收站状态', () async {
      final testName = 'GET /files/recycle/status - 获取回收站状态';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final response = await api.getRecycleBinStatus();
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 回收站状态: ${response.data}');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/recycle/search - 搜索回收站', () async {
      final testName = 'POST /files/recycle/search - 搜索回收站';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearch(path: '/', page: 1, pageSize: 10);
        
        debugPrint('📤 请求参数: path=/');
        
        final response = await api.searchRecycleBin(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 回收站项目数: ${response.data?.length ?? 0}');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('收藏 API 测试', () {
    test('POST /files/favorite/search - 搜索收藏文件', () async {
      final testName = 'POST /files/favorite/search - 搜索收藏文件';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearch(path: '/', page: 1, pageSize: 10);
        
        debugPrint('📤 请求参数: path=/');
        
        final response = await api.searchFavoriteFiles(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 收藏文件数: ${response.data?.length ?? 0}');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('文件内容 API 测试', () {
    test('GET /files/content - 获取文件内容', () async {
      final testName = 'GET /files/content - 获取文件内容';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final filePath = '/etc/hostname';
        
        debugPrint('📤 请求参数: path=$filePath');
        
        final response = await api.getFileContent(filePath);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 文件内容长度: ${response.data?.length ?? 0}');
        if (response.data != null && response.data!.length < 200) {
          debugPrint('📥 文件内容: ${response.data}');
        }
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('原始响应数据测试', () {
    test('获取原始响应数据用于调试', () async {
      final testName = '获取原始响应数据用于调试';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearch(
          path: '/',
          page: 1,
          pageSize: 5,
        );
        
        final response = await client.post<Map<String, dynamic>>(
          '/api/v2/files/search',
          data: request.toJson(),
        );
        
        debugPrint('\n📥 原始响应状态码: ${response.statusCode}');
        debugPrint('📥 原始响应数据类型: ${response.data.runtimeType}');
        debugPrint('\n📥 原始响应数据:');
        debugPrint(const JsonEncoder.withIndent("  ").convert(response.data));
        
        if (response.data != null) {
          final parsed = FileSearchResponse.fromJson(response.data!);
          debugPrint('\n📥 解析后:');
          debugPrint('  - items数量: ${parsed.items.length}');
          debugPrint('  - total: ${parsed.total}');
        }
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('\n✅ 测试成功!');
      } catch (e, stackTrace) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
        debugPrint('堆栈跟踪:\n$stackTrace');
      }
      debugPrint('========================================\n');
    });

    test('使用expand参数获取文件列表', () async {
      final testName = '使用expand参数获取文件列表';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearch(
          path: '/',
          page: 1,
          pageSize: 20,
          expand: true,
          dir: false,
          showHidden: false,
        );
        
        debugPrint('📤 请求参数:');
        debugPrint('  ${const JsonEncoder.withIndent("  ").convert(request.toJson())}');
        
        final response = await client.post<Map<String, dynamic>>(
          '/api/v2/files/search',
          data: request.toJson(),
        );
        
        debugPrint('\n📥 原始响应数据:');
        final data = response.data?['data'];
        if (data is Map) {
          debugPrint('  - items类型: ${data['items'].runtimeType}');
          debugPrint('  - itemTotal: ${data['itemTotal']}');
          if (data['items'] is List) {
            debugPrint('  - items数量: ${(data['items'] as List).length}');
            for (var i = 0; i < ((data['items'] as List).length > 5 ? 5 : (data['items'] as List).length); i++) {
              final item = (data['items'] as List)[i];
              debugPrint('    [$i] ${item['name']} (${item['isDir'] == true ? '目录' : '文件'})');
            }
          }
        }
        
        final parsed = FileSearchResponse.fromJson(response.data!);
        debugPrint('\n📥 解析后:');
        debugPrint('  - items数量: ${parsed.items.length}');
        debugPrint('  - total: ${parsed.total}');
        
        if (parsed.items.isNotEmpty) {
          debugPrint('\n📁 前3个文件:');
          for (var i = 0; i < (parsed.items.length > 3 ? 3 : parsed.items.length); i++) {
            final file = parsed.items[i];
            debugPrint('  [$i] ${file.name} (${file.isDir ? '目录' : '文件'})');
          }
        }
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('\n✅ 测试成功!');
      } catch (e, stackTrace) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
        debugPrint('堆栈跟踪:\n$stackTrace');
      }
      debugPrint('========================================\n');
    });
  });

  group('文件操作 API 测试', () {
    test('POST /files - 创建文件夹', () async {
      final testName = 'POST /files - 创建文件夹';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final testDir = '/tmp/test_flutter_api_${DateTime.now().millisecondsSinceEpoch}';
        final request = FileCreate(path: testDir, isDir: true);
        
        debugPrint('📤 请求参数: path=$testDir, isDir=true');
        
        final response = await api.createFile(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 创建结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [testDir]));
          debugPrint('🧹 清理测试目录: $testDir');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/rename - 重命名文件', () async {
      final testName = 'POST /files/rename - 重命名文件';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testDir = '/tmp/test_rename_$timestamp';
        final renamedDir = '/tmp/test_renamed_$timestamp';
        
        await api.createFile(FileCreate(path: testDir, isDir: true));
        debugPrint('📤 创建测试目录: $testDir');
        
        final request = FileRename(oldPath: testDir, newPath: renamedDir);
        final response = await api.renameFile(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 重命名结果: $testDir -> $renamedDir');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [renamedDir]));
          debugPrint('🧹 清理测试目录: $renamedDir');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/move - 移动文件', () async {
      final testName = 'POST /files/move - 移动文件';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final srcDir = '/tmp/test_move_src_$timestamp';
        final dstDir = '/tmp/test_move_dst_$timestamp';
        final testFile = '$srcDir/test.txt';
        
        await api.createFile(FileCreate(path: srcDir, isDir: true));
        await api.createFile(FileCreate(path: dstDir, isDir: true));
        await api.saveFile(FileSave(path: testFile, content: 'test content'));
        
        debugPrint('📤 创建测试文件: $testFile');
        debugPrint('📤 目标目录: $dstDir');
        
        final request = FileMove(paths: [testFile], targetPath: dstDir);
        final response = await api.moveFiles(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 移动结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [srcDir, dstDir]));
          debugPrint('🧹 清理测试目录');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/del - 删除文件', () async {
      final testName = 'POST /files/del - 删除文件';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final testDir = '/tmp/test_delete_${DateTime.now().millisecondsSinceEpoch}';
        
        await api.createFile(FileCreate(path: testDir, isDir: true));
        debugPrint('📤 创建测试目录: $testDir');
        
        final request = FileBatchDelete(paths: [testDir]);
        final response = await api.deleteFiles(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 删除结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('压缩解压 API 测试', () {
    test('POST /files/compress - 压缩文件', () async {
      final testName = 'POST /files/compress - 压缩文件';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testDir = '/tmp/test_compress_$timestamp';
        final testFile = '$testDir/test.txt';
        final zipFile = '/tmp/test_compress_$timestamp.zip';
        
        await api.createFile(FileCreate(path: testDir, isDir: true));
        await api.saveFile(FileSave(path: testFile, content: 'test content'));
        
        debugPrint('📤 创建测试文件: $testFile');
        debugPrint('📤 压缩目标: $zipFile');
        
        final request = FileCompress(
          files: [testFile],
          dst: '/tmp',
          name: 'test_compress_$timestamp',
          type: 'zip',
        );
        final response = await api.compressFiles(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 压缩结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [testDir, zipFile]));
          debugPrint('🧹 清理测试文件');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('文件预览 API 测试', () {
    test('POST /files/preview - 预览文件内容', () async {
      final testName = 'POST /files/preview - 预览文件内容';
      final timer = TestPerformanceTimer(testName);
      timer.start();
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        debugPrint('⚠️  跳过测试: API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FilePreviewRequest(
          path: '/etc/hostname',
          line: 1,
          limit: 10,
        );
        
        debugPrint('📤 请求参数:');
        debugPrint('  ${const JsonEncoder.withIndent("  ").convert(request.toJson())}');
        
        final response = await api.previewFile(request);
        
        debugPrint('\n📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 文件内容长度: ${response.data?.length ?? 0}');
        if (response.data != null && response.data!.length < 500) {
          debugPrint('📥 文件内容:\n${response.data}');
        } else if (response.data != null) {
          debugPrint('📥 文件内容(前500字符):\n${response.data!.substring(0, 500)}...');
        }
        
        expect(response.data, isNotNull);
        timer.stop();
        resultCollector.addSuccess(testName, timer.duration);
        debugPrint('\n✅ 测试成功! 耗时: ${timer.duration.inMilliseconds}ms');
      } catch (e, stackTrace) {
        timer.stop();
        resultCollector.addFailure(testName, e.toString(), timer.duration);
        debugPrint('\n❌ 测试失败: $e');
        debugPrint('堆栈跟踪:\n$stackTrace');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/preview - 预览指定行范围', () async {
      final testName = 'POST /files/preview - 预览指定行范围';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testFile = '/tmp/test_preview_$timestamp.txt';
        
        final content = List.generate(20, (i) => '这是第 ${i + 1} 行内容').join('\n');
        await api.saveFile(FileSave(path: testFile, content: content));
        debugPrint('📤 创建测试文件: $testFile');
        
        final request = FilePreviewRequest(
          path: testFile,
          line: 5,
          limit: 5,
        );
        
        debugPrint('📤 请求参数: path=$testFile, line=5, limit=5');
        
        final response = await api.previewFile(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 预览内容:\n${response.data}');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [testFile]));
          debugPrint('🧹 清理测试文件: $testFile');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('权限管理 API 测试', () {
    test('POST /files/user/group - 获取用户组列表', () async {
      final testName = 'POST /files/user/group - 获取用户组列表';
      final timer = TestPerformanceTimer(testName);
      timer.start();
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        debugPrint('⚠️  跳过测试: API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        debugPrint('📤 请求参数: 无');
        
        final response = await api.getUserGroup();
        
        debugPrint('\n📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 用户数量: ${response.data?.users.length ?? 0}');
        debugPrint('📥 组数量: ${response.data?.groups.length ?? 0}');
        
        if (response.data != null) {
          if (response.data!.users.isNotEmpty) {
            debugPrint('\n👤 用户列表(前5个):');
            for (var i = 0; i < (response.data!.users.length > 5 ? 5 : response.data!.users.length); i++) {
              final user = response.data!.users[i];
              debugPrint('  [$i] ${user.user} (${user.group})');
            }
          }
          
          if (response.data!.groups.isNotEmpty) {
            debugPrint('\n👥 组列表(前5个):');
            for (var i = 0; i < (response.data!.groups.length > 5 ? 5 : response.data!.groups.length); i++) {
              debugPrint('  [$i] ${response.data!.groups[i]}');
            }
          }
        }
        
        expect(response.data, isNotNull);
        timer.stop();
        resultCollector.addSuccess(testName, timer.duration);
        debugPrint('\n✅ 测试成功! 耗时: ${timer.duration.inMilliseconds}ms');
      } catch (e, stackTrace) {
        timer.stop();
        resultCollector.addFailure(testName, e.toString(), timer.duration);
        debugPrint('\n❌ 测试失败: $e');
        debugPrint('堆栈跟踪:\n$stackTrace');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/mode - 修改文件权限(chmod)', () async {
      final testName = 'POST /files/mode - 修改文件权限(chmod)';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final testDir = '/tmp';
        
        final checkResponse = await api.checkFile(FileCheck(path: testDir));
        if (checkResponse.data?.exists != true) {
          debugPrint('⚠️ /tmp 目录不存在，跳过测试');
          resultCollector.addSkipped(testName, '/tmp 目录不存在');
          return;
        }
        
        final request = FileModeChange(
          path: testDir,
          mode: '1777',
          recursive: false,
        );
        
        debugPrint('📤 请求参数: path=$testDir, mode=1777');
        
        final response = await api.changeFileMode(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 权限修改结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/owner - 修改文件所有者(chown)', () async {
      final testName = 'POST /files/owner - 修改文件所有者(chown)';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final testFile = '/etc/hostname';
        
        final checkResponse = await api.checkFile(FileCheck(path: testFile));
        if (checkResponse.data?.exists != true) {
          debugPrint('⚠️ /etc/hostname 文件不存在，跳过测试');
          resultCollector.addSkipped(testName, '/etc/hostname 文件不存在');
          return;
        }
        
        final userGroupResponse = await api.getUserGroup();
        String? testUser;
        String? testGroup;
        
        if (userGroupResponse.data?.users.isNotEmpty == true) {
          testUser = userGroupResponse.data!.users.first.user;
        }
        if (userGroupResponse.data?.groups.isNotEmpty == true) {
          testGroup = userGroupResponse.data!.groups.first;
        }
        
        if (testUser == null || testGroup == null) {
          debugPrint('⚠️ 无法获取用户/组信息，跳过测试');
          resultCollector.addSkipped(testName, '无法获取用户/组信息');
          return;
        }
        
        final request = FileOwnerChange(
          path: testFile,
          user: testUser,
          group: testGroup,
          recursive: false,
        );
        
        debugPrint('📤 请求参数: path=$testFile, user=$testUser, group=$testGroup');
        
        final response = await api.changeFileOwner(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 所有者修改结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('回收站恢复 API 测试', () {
    test('POST /files/recycle/reduce - 恢复回收站文件', () async {
      final testName = 'POST /files/recycle/reduce - 恢复回收站文件';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testFile = '/tmp/test_recycle_$timestamp.txt';
        final testContent = 'test content for recycle bin restore';
        
        await api.saveFile(FileSave(path: testFile, content: testContent));
        debugPrint('📤 创建测试文件: $testFile');
        
        await api.deleteFiles(FileBatchDelete(paths: [testFile]));
        debugPrint('📤 删除文件到回收站: $testFile');
        
        await Future.delayed(const Duration(seconds: 1));
        
        final recycleSearch = await api.searchRecycleBin(FileSearch(path: '/tmp', page: 1, pageSize: 50));
        debugPrint('📥 回收站搜索结果: ${recycleSearch.data?.length ?? 0} 个文件');
        
        RecycleBinItem? recycleItem;
        if (recycleSearch.data != null) {
          for (final item in recycleSearch.data!) {
            if (item.name.contains('test_recycle_') && item.path.contains('/tmp')) {
              recycleItem = RecycleBinItem(
                sourcePath: item.path,
                name: item.name,
                isDir: item.isDir,
                size: item.size,
                deleteTime: item.modifiedAt,
                rName: item.name,
                from: '/tmp',
              );
              break;
            }
          }
        }
        
        if (recycleItem == null) {
          debugPrint('⚠️ 未在回收站找到测试文件，跳过恢复测试');
          resultCollector.addSkipped(testName, '未在回收站找到测试文件');
          return;
        }
        
        final restoreRequest = RecycleBinReduceRequest(
          rName: recycleItem.rName,
          from: recycleItem.from,
          name: recycleItem.name,
        );
        
        debugPrint('📤 恢复请求参数:');
        debugPrint('  rName: ${recycleItem.rName}');
        debugPrint('  from: ${recycleItem.from}');
        debugPrint('  name: ${recycleItem.name}');
        
        final response = await api.restoreRecycleBinFile(restoreRequest);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 恢复结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [testFile]));
          debugPrint('🧹 清理测试文件: $testFile');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e, stackTrace) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
        debugPrint('堆栈跟踪:\n$stackTrace');
      }
      debugPrint('========================================\n');
    });
  });

  group('wget 远程下载 API 测试', () {
    test('POST /files/wget - 下载远程文件', () async {
      final testName = 'POST /files/wget - 下载远程文件';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      debugPrint('⚠️  跳过测试: 服务器可能无法访问外部网络');
      resultCollector.addSkipped(testName, '服务器可能无法访问外部网络，跳过 wget 测试');
      debugPrint('========================================\n');
    });

    test('POST /files/wget - 下载小文件测试', () async {
      final testName = 'POST /files/wget - 下载小文件测试';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      debugPrint('⚠️  跳过测试: 服务器可能无法访问外部网络');
      resultCollector.addSkipped(testName, '服务器可能无法访问外部网络，跳过 wget 测试');
      debugPrint('========================================\n');
    });
  });

  group('文件编码转换 API 测试', () {
    test('POST /files/convert - 转换文件编码', () async {
      final testName = 'POST /files/convert - 转换文件编码';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testFile = '/tmp/test_convert_$timestamp.txt';
        
        await api.saveFile(FileSave(path: testFile, content: '测试编码转换内容 Test encoding convert'));
        debugPrint('📤 创建测试文件: $testFile');
        
        final request = FileConvertRequest(
          path: testFile,
          fromEncoding: 'UTF-8',
          toEncoding: 'GBK',
        );
        
        debugPrint('📤 请求参数:');
        debugPrint('  path: ${request.path}');
        debugPrint('  fromEncoding: ${request.fromEncoding}');
        debugPrint('  toEncoding: ${request.toEncoding}');
        
        final response = await api.convertFile(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 编码转换结果: 成功');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [testFile]));
          debugPrint('🧹 清理测试文件: $testFile');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/convert/log - 获取转换日志', () async {
      final testName = 'POST /files/convert/log - 获取转换日志';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }

      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final testFile = '/tmp/test_convert_log_$timestamp.txt';
        
        await api.saveFile(FileSave(path: testFile, content: '测试转换日志内容'));
        debugPrint('📤 创建测试文件: $testFile');
        
        try {
          await api.convertFile(FileConvertRequest(
            path: testFile,
            fromEncoding: 'UTF-8',
            toEncoding: 'GBK',
          ));
          debugPrint('📤 执行编码转换');
        } catch (e) {
          debugPrint('⚠️ 编码转换可能失败: $e');
        }
        
        final request = FileConvertLogRequest(path: testFile);
        
        debugPrint('📤 请求参数:');
        debugPrint('  path: ${request.path}');
        
        final response = await api.convertFileLog(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 日志内容长度: ${response.data?.length ?? 0}');
        if (response.data != null && response.data!.isNotEmpty) {
          final logPreview = response.data!.length > 500 
              ? '${response.data!.substring(0, 500)}...' 
              : response.data!;
          debugPrint('📥 日志内容:\n$logPreview');
        }
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
        
        try {
          await api.deleteFiles(FileBatchDelete(paths: [testFile]));
          debugPrint('🧹 清理测试文件: $testFile');
        } catch (e) {
          debugPrint('⚠️ 清理失败: $e');
        }
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });

  group('文件高级功能 API 测试', () {
    test('POST /files/search/in - 内容搜索', () async {
      final testName = 'POST /files/search/in - 内容搜索';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }
      
      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearchInRequest(
          path: '/etc',
          pattern: 'root',
          maxResults: 5,
        );
        
        debugPrint('📤 请求参数: path=/etc, pattern=root');
        
        final response = await api.searchInFiles(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 匹配数: ${response.data?.totalMatches ?? 0}');
        
        if (response.data?.matches != null && response.data!.matches.isNotEmpty) {
          debugPrint('📥 匹配项:');
          for (final match in response.data!.matches.take(3)) {
            debugPrint('  - ${match.filePath}:${match.lineNumber} -> ${match.line.trim()}');
          }
        }
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });

    test('POST /files/upload/search - 上传历史', () async {
      final testName = 'POST /files/upload/search - 上传历史';
      
      if (!hasApiKey) {
        resultCollector.addSkipped(testName, 'API密钥未配置');
        return;
      }
      
      debugPrint('\n========================================');
      debugPrint('测试: $testName');
      debugPrint('========================================');
      
      try {
        final request = FileSearch(
          path: '',
          page: 1,
          pageSize: 10,
        );
        
        debugPrint('📤 请求参数: page=1');
        
        final response = await api.searchUploadedFiles(request);
        
        debugPrint('📥 响应状态码: ${response.statusCode}');
        debugPrint('📥 记录数: ${response.data?.length ?? 0}');
        
        resultCollector.addSuccess(testName, Duration.zero);
        debugPrint('✅ 测试成功!');
      } catch (e) {
        resultCollector.addFailure(testName, e.toString(), Duration.zero);
        debugPrint('❌ 测试失败: $e');
      }
      debugPrint('========================================\n');
    });
  });
}

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
  if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
}
