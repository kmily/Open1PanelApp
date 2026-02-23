import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:onepanelapp_app/api/v2/app_v2.dart';
import 'package:onepanelapp_app/core/network/dio_client.dart';

import 'compose_api_test.mocks.dart'; // Reuse existing mock

void main() {
  late AppV2Api api;
  late MockDioClient mockClient;

  setUp(() {
    mockClient = MockDioClient();
    api = AppV2Api(mockClient);
  });

  group('AppV2Api - getAppInstallParams', () {
    test('should return params map on success', () async {
      final installId = '123';
      final jsonResponse = {
        'code': 200,
        'data': {
          'formFields': [],
          'env': {'KEY': 'VALUE'},
          'dockerCompose': 'version: "3"'
        }
      };

      // When mockClient.get is called, return mocked Response
      when(mockClient.get<dynamic>(
        any,
        queryParameters: anyNamed('queryParameters'),
        options: anyNamed('options'),
      )).thenAnswer((invocation) async {
         // Check if the path matches the expected one
         final path = invocation.positionalArguments[0] as String;
         if (path.contains('/apps/installed/params/$installId')) {
            return Response(
              data: jsonResponse,
              statusCode: 200,
              requestOptions: RequestOptions(path: path),
            );
         }
         throw Exception('Unexpected call: $path');
      });

      final result = await api.getAppInstallParams(installId);

      expect(result, isA<Map<String, dynamic>>());
      expect(result['env']['KEY'], equals('VALUE'));
      expect(result['dockerCompose'], equals('version: "3"'));
    });
  });
}
