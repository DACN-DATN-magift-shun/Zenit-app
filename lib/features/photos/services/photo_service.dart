import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/local/storage_service.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/photos/models/photo_model.dart';

class PhotoService {
  PhotoService({ApiClient? apiClient, StorageService? storageService})
    : _api = apiClient ?? ApiClient(),
      _storageService = storageService ?? StorageService();

  final ApiClient _api;
  final StorageService _storageService;

  static const List<String> _fileFieldCandidates = <String>[
    'File',
    'file',
    'Photo',
    'photo',
    'Avatar',
    'avatar',
  ];

  Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String && data.isNotEmpty) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return <String, dynamic>{};
  }

  Future<Options> _authorizedOptions({Options? baseOptions}) async {
    final token = await _storageService.getAccessToken();
    final headers = <String, dynamic>{
      ...?baseOptions?.headers,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    return (baseOptions ?? Options()).copyWith(headers: headers);
  }

  void _logPhotoResponse(String operation, Response response) {
    // Explicit logs to quickly identify auth/form-data issues from BE responses.
    print('[PhotoService][$operation] statusCode: ${response.statusCode}');
    print('[PhotoService][$operation] data: ${response.data}');
  }

  void _logPhotoDioError(String operation, DioException error) {
    print('[PhotoService][$operation] statusCode: ${error.response?.statusCode}');
    print('[PhotoService][$operation] data: ${error.response?.data ?? error.message}');
  }

  MediaType? _parseMediaType(String? mimeType) {
    if (mimeType == null || mimeType.isEmpty) {
      return null;
    }

    final parts = mimeType.split('/');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      return null;
    }

    return MediaType(parts[0], parts[1]);
  }

  Future<void> _logLocalFileSignature(XFile file) async {
    final bytes = await file.readAsBytes();
    final head = bytes.length > 12 ? bytes.sublist(0, 12) : bytes;
    final hexHead = head
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ')
        .toUpperCase();

    print('[PhotoService][uploadPhoto] local file: ${file.path}');
    print('[PhotoService][uploadPhoto] local mimeType: ${file.mimeType}');
    print('[PhotoService][uploadPhoto] local size: ${bytes.length}');
    print('[PhotoService][uploadPhoto] local header: $hexHead');
  }

  Future<PhotoUploadResult> uploadPhoto({
    required XFile file,
    String? transactionId,
  }) async {
    DioException? lastDioError;
    Exception? lastPlainError;

    await _logLocalFileSignature(file);

    final multipartFile = await MultipartFile.fromFile(
      file.path,
      filename: file.name,
      contentType: _parseMediaType(file.mimeType),
    );

    for (final fileField in _fileFieldCandidates) {
      try {
        final formData = FormData.fromMap({
          fileField: multipartFile.clone(),
          if (transactionId != null && transactionId.isNotEmpty)
            'TransactionId': transactionId,
        });

        final response = await _api.post(
          ApiEndpoints.photos,
          data: formData,
          options: await _authorizedOptions(baseOptions: Options(
            // BE endpoint is [FromForm], force multipart explicitly.
            contentType: 'multipart/form-data',
          )),
        );

        _logPhotoResponse('uploadPhoto', response);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return PhotoUploadResult.fromJson(response.data);
        }

        lastPlainError = Exception(
          'Failed to upload photo: ${response.statusCode}',
        );
      } on DioException catch (e) {
        _logPhotoDioError('uploadPhoto', e);
        lastDioError = e;
      } catch (e) {
        lastPlainError = Exception(e.toString());
      }
    }

    if (lastDioError != null) {
      throw Exception(
        'Failed to upload photo: ${lastDioError!.response?.statusCode} '
        '${lastDioError!.response?.data ?? lastDioError!.message}',
      );
    }

    throw (lastPlainError ?? Exception('Failed to upload photo'));
  }

  Future<PhotoListResponse> getPhotos({
    String? transactionId,
    String? search,
    String? beforeId,
    required int pageSize,
    bool? useCountTotal,
  }) async {
    final query = <String, dynamic>{'PageSize': pageSize};

    if (transactionId != null && transactionId.isNotEmpty) {
      query['TransactionId'] = transactionId;
    }
    if (search != null && search.isNotEmpty) {
      query['Search'] = search;
    }
    if (beforeId != null && beforeId.isNotEmpty) {
      query['BeforeId'] = beforeId;
    }
    if (useCountTotal != null) {
      query['UseCountTotal'] = useCountTotal;
    }

    final response = await _api.get(
      ApiEndpoints.photos,
      queryParameters: query,
      options: await _authorizedOptions(),
    );

    _logPhotoResponse('getPhotos', response);

    if (response.statusCode == 200) {
      return PhotoListResponse.fromJson(response.data);
    }

    throw Exception('Failed to get photos: ${response.statusCode}');
  }

  Future<PhotoModel> getPhotoById(String id) async {
    final response = await _api.get(
      ApiEndpoints.photoById(id),
      options: await _authorizedOptions(),
    );

    _logPhotoResponse('getPhotoById', response);

    if (response.statusCode == 200) {
      final raw = _toMap(response.data);
      final payload = raw['data'] ?? raw['item'] ?? raw['result'] ?? raw;
      return PhotoModel.fromJson(payload);
    }

    throw Exception('Failed to get photo: ${response.statusCode}');
  }

  Future<void> deletePhoto(String id) async {
    final response = await _api.delete(
      ApiEndpoints.photoById(id),
      options: await _authorizedOptions(),
    );

    _logPhotoResponse('deletePhoto', response);

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception('Failed to delete photo: ${response.statusCode}');
  }
}
