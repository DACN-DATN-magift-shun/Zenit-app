import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/data/network/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockStorageService extends Mock implements StorageService {}

Response<dynamic> buildResponse({
  required int statusCode,
  dynamic data,
  String path = '/test',
}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: path),
    statusCode: statusCode,
    data: data,
  );
}

DioException buildDioException({
  required DioExceptionType type,
  int? statusCode,
  dynamic data,
  String path = '/test',
  String message = 'dio error',
}) {
  return DioException(
    requestOptions: RequestOptions(path: path),
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: RequestOptions(path: path),
            statusCode: statusCode,
            data: data,
          ),
    message: message,
  );
}
