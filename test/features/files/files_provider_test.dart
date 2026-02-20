import 'package:flutter_test/flutter_test.dart';
import 'package:onepanelapp_app/features/files/models/models.dart';
import 'package:onepanelapp_app/data/models/file_models.dart';

void main() {
  group('FilesData 模型测试', () {
    group('FilesData 初始化', () {
      test('初始状态应该正确', () {
        const data = FilesData();
        
        expect(data.files, isEmpty);
        expect(data.currentPath, equals('/'));
        expect(data.isLoading, isFalse);
        expect(data.error, isNull);
        expect(data.selectedFiles, isEmpty);
        expect(data.searchQuery, isNull);
      });
    });

    group('FilesData copyWith', () {
      test('应该正确更新文件列表', () {
        final files = <FileInfo>[
          FileInfo(
            name: 'test.txt',
            path: '/test.txt',
            type: 'file',
            size: 1024,
          ),
        ];

        final data = const FilesData().copyWith(files: files);
        
        expect(data.files.length, equals(1));
        expect(data.files.first.name, equals('test.txt'));
      });

      test('应该正确更新当前路径', () {
        final data = const FilesData().copyWith(currentPath: '/opt/1panel');
        
        expect(data.currentPath, equals('/opt/1panel'));
      });

      test('应该正确更新加载状态', () {
        final data = const FilesData().copyWith(isLoading: true);
        
        expect(data.isLoading, isTrue);
      });

      test('应该正确更新错误信息', () {
        final data = const FilesData().copyWith(error: '测试错误');
        
        expect(data.error, equals('测试错误'));
      });

      test('应该正确更新搜索关键词', () {
        final data = const FilesData().copyWith(searchQuery: 'test');
        
        expect(data.searchQuery, equals('test'));
      });

      test('应该正确更新选中文件', () {
        final data = const FilesData().copyWith(selectedFiles: {'/test.txt'});
        
        expect(data.selectedFiles.length, equals(1));
        expect(data.selectedFiles.contains('/test.txt'), isTrue);
      });
    });

    group('FilesData 路径历史', () {
      test('应该正确更新路径历史', () {
        final history = ['/', '/opt', '/opt/1panel'];
        final data = const FilesData().copyWith(pathHistory: history);
        
        expect(data.pathHistory.length, equals(3));
        expect(data.pathHistory, equals(history));
      });
    });

    group('FilesData 排序', () {
      test('应该正确更新排序字段', () {
        final data = const FilesData().copyWith(sortBy: 'name');
        
        expect(data.sortBy, equals('name'));
      });

      test('应该正确更新排序顺序', () {
        final data = const FilesData().copyWith(sortOrder: 'desc');
        
        expect(data.sortOrder, equals('desc'));
      });
    });
  });

  group('FileInfo 模型测试', () {
    test('应该正确创建文件信息', () {
      final file = FileInfo(
        name: 'test.txt',
        path: '/test.txt',
        type: 'file',
        size: 1024,
      );

      expect(file.name, equals('test.txt'));
      expect(file.path, equals('/test.txt'));
      expect(file.size, equals(1024));
      expect(file.type, equals('file'));
      expect(file.isDir, isFalse);
    });

    test('应该正确创建目录信息', () {
      final dir = FileInfo(
        name: 'testdir',
        path: '/testdir',
        type: 'dir',
        size: 0,
        isDir: true,
      );

      expect(dir.name, equals('testdir'));
      expect(dir.isDir, isTrue);
      expect(dir.type, equals('dir'));
    });

    test('应该正确从 JSON 解析', () {
      final json = {
        'name': 'test.txt',
        'path': '/test.txt',
        'size': 1024,
        'isDir': false,
        'type': 'file',
      };

      final file = FileInfo.fromJson(json);

      expect(file.name, equals('test.txt'));
      expect(file.path, equals('/test.txt'));
      expect(file.size, equals(1024));
      expect(file.isDir, isFalse);
    });
  });

  group('RecycleBinItem 模型测试', () {
    test('应该正确创建回收站项目', () {
      final item = RecycleBinItem(
        sourcePath: '/original/path/file.txt',
        name: 'file.txt',
        size: 1024,
        isDir: false,
        rName: 'r_file.txt',
        from: '/original/path',
      );

      expect(item.sourcePath, equals('/original/path/file.txt'));
      expect(item.name, equals('file.txt'));
      expect(item.size, equals(1024));
      expect(item.isDir, isFalse);
      expect(item.rName, equals('r_file.txt'));
      expect(item.from, equals('/original/path'));
    });
  });
}
