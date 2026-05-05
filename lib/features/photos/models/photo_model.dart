Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return <String, dynamic>{};
}

String? _firstString(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}

Map<String, dynamic> _extractPayload(dynamic rawJson) {
  final json = _asMap(rawJson);
  if (json['data'] is Map || json['item'] is Map || json['result'] is Map) {
    return _asMap(json['data'] ?? json['item'] ?? json['result']);
  }
  return json;
}

class PhotoModel {
  final String id;
  final String? name;
  final String? url;

  const PhotoModel({required this.id, this.name, this.url});

  factory PhotoModel.fromJson(dynamic rawJson) {
    final payload = _extractPayload(rawJson);
    final id = _firstString(payload, const ['id', 'photoId', 'photoID']) ?? '';
    final name = _firstString(payload, const [
      'name',
      'fileName',
      'filename',
      'title',
    ]);
    final url = _firstString(payload, const [
      'filePath',
      'url',
      'photoUrl',
      'avatarUrl',
      'downloadUrl',
      'path',
    ]);

    return PhotoModel(id: id, name: name, url: url);
  }
}

class PhotoUploadResult {
  final String? photoId;
  final String? url;
  final Map<String, dynamic> raw;

  const PhotoUploadResult({
    required this.photoId,
    required this.url,
    required this.raw,
  });

  factory PhotoUploadResult.fromJson(dynamic rawJson) {
    final payload = _extractPayload(rawJson);
    return PhotoUploadResult(
      photoId: _firstString(payload, const ['photoId', 'id', 'photoID']),
      url: _firstString(payload, const [
        'filePath',
        'url',
        'photoUrl',
        'avatarUrl',
        'downloadUrl',
        'path',
      ]),
      raw: payload,
    );
  }
}

class PhotoListResponse {
  final List<PhotoModel> items;
  final Map<String, dynamic> raw;

  const PhotoListResponse({required this.items, required this.raw});

  factory PhotoListResponse.fromJson(dynamic rawJson) {
    final json = _asMap(rawJson);
    final dynamic listDynamic =
        json['items'] ?? json['data'] ?? json['result'] ?? [];

    final items = (listDynamic is List)
        ? listDynamic.map((item) => PhotoModel.fromJson(item)).toList()
        : <PhotoModel>[];

    return PhotoListResponse(items: items, raw: json);
  }
}
