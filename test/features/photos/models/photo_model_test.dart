import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/photos/models/photo_model.dart';
import '../../../mocks/features/photos/photo_model_mock_data.dart';
import '../../../mocks/json_source_mock.dart';

void main() {
  group('photo models', () {
    test('PhotoModel.fromJson supports wrapped payload', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(photoWrappedPayloadMockData);

      final model = PhotoModel.fromJson(source.value);

      expect(model.id, 'p1');
      expect(model.name, 'img.jpg');
      expect(model.url, 'https://cdn/img.jpg');
    });

    test('PhotoUploadResult.fromJson keeps raw payload', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(photoUploadResultMockData);

      final result = PhotoUploadResult.fromJson(source.value);

      expect(result.photoId, 'pid');
      expect(result.url, 'https://cdn/p.png');
      expect(result.raw['id'], 'pid');
    });

    test('PhotoListResponse.fromJson maps item list', () {
      final source = MockJsonSource();
      when(() => source.value).thenReturn(photoListResponseMockData);

      final response = PhotoListResponse.fromJson(source.value);

      expect(response.items.length, 2);
      expect(response.items.last.id, '2');
    });
  });
}
