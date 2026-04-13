import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/photos/models/photo_model.dart';

class PhotoService {
  final _api = ApiClient();

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

  Future<PhotoUploadResult> uploadPhoto({
    required XFile file,
    String? transactionId,
  }) async {
    final formData = FormData.fromMap({
      'File': await MultipartFile.fromFile(file.path, filename: file.name),
      if (transactionId != null && transactionId.isNotEmpty)
        'TransactionId': transactionId,
    });

    final response = await _api.post(
      ApiEndpoints.photos,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return PhotoUploadResult.fromJson(response.data);
    }

    throw Exception('Failed to upload photo: ${response.statusCode}');
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
    );

    if (response.statusCode == 200) {
      return PhotoListResponse.fromJson(response.data);
    }

    throw Exception('Failed to get photos: ${response.statusCode}');
  }

  Future<PhotoModel> getPhotoById(String id) async {
    final response = await _api.get(ApiEndpoints.photoById(id));

    if (response.statusCode == 200) {
      return PhotoModel.fromJson(_toMap(response.data));
    }

    throw Exception('Failed to get photo: ${response.statusCode}');
  }

  Future<void> deletePhoto(String id) async {
    final response = await _api.delete(ApiEndpoints.photoById(id));

    if (response.statusCode == 200 || response.statusCode == 204) {
      return;
    }

    throw Exception('Failed to delete photo: ${response.statusCode}');
  }
}
