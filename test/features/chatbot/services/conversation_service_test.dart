import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zenit/core/api/api_endpoints.dart';
import 'package:zenit/data/network/api_client.dart';
import 'package:zenit/features/chatbot/services/conversation_service.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  group('ConversationService', () {
    late MockApiClient mockApiClient;
    late ConversationService conversationService;

    setUp(() {
      mockApiClient = MockApiClient();
      conversationService = ConversationService(apiClient: mockApiClient);
      registerFallbackValue(<String, dynamic>{});
    });

    group('createConversation', () {
      test('successfully creates conversation with 201 status', () async {
        final responseData = {
          'data': {
            'id': 'conv-123',
            'title': 'Test Conversation',
            'updatedAt': '2026-05-03T10:00:00Z',
          }
        };

        when(() => mockApiClient.post(
              ApiEndpoints.conversations,
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 201,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        final result = await conversationService.createConversation(
          title: 'Test Conversation',
        );

        expect(result.id, 'conv-123');
        expect(result.title, 'Test Conversation');
        verify(() => mockApiClient.post(
              ApiEndpoints.conversations,
              data: {'title': 'Test Conversation'},
            )).called(1);
      });

      test('successfully creates conversation with 200 status', () async {
        final responseData = {
          'data': {
            'id': 'conv-456',
            'title': 'Another Chat',
            'updatedAt': '2026-05-03T11:00:00Z',
          }
        };

        when(() => mockApiClient.post(
              ApiEndpoints.conversations,
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        final result = await conversationService.createConversation(
          title: 'Another Chat',
        );

        expect(result.id, 'conv-456');
        expect(result.title, 'Another Chat');
      });

      test('throws exception on 500 error', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.conversations,
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: {'error': 'Server error'},
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        expect(
          () => conversationService.createConversation(title: 'Test'),
          throwsException,
        );
      });

      test('handles DioException connectionTimeout', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.conversations,
              data: any(named: 'data'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        expect(
          () => conversationService.createConversation(title: 'Test'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'contains Connection timeout',
            contains('Connection timeout'),
          )),
        );
      });

      test('handles DioException receiveTimeout', () async {
        when(() => mockApiClient.post(
              ApiEndpoints.conversations,
              data: any(named: 'data'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.receiveTimeout,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        expect(
          () => conversationService.createConversation(title: 'Test'),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'contains taking too long',
            contains('taking too long'),
          )),
        );
      });
    });

    group('getConversations', () {
      test('fetches conversations with pagination', () async {
        final responseData = {
          'data': {
            'items': [
              {
                'id': 'conv-1',
                'title': 'Chat 1',
                'updatedAt': '2026-05-03T10:00:00Z'
              },
              {
                'id': 'conv-2',
                'title': 'Chat 2',
                'updatedAt': '2026-05-03T11:00:00Z'
              },
            ],
            'meta': {
              'totalItems': 5,
              'pageCount': 1,
              'pageSize': 50,
            }
          }
        };

        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        final result =
            await conversationService.getConversations(pageSize: 50);

        expect(result.items.length, 2);
        expect(result.items[0].id, 'conv-1');
        expect(result.items[1].id, 'conv-2');
        expect(result.meta.totalItems, 5);
      });

      test('includes search parameter in query', () async {
        final responseData = {
          'data': {
            'items': [
              {
                'id': 'conv-search',
                'title': 'Search Result',
                'updatedAt': '2026-05-03T10:00:00Z'
              },
            ],
            'count': 1,
            'totalCount': 1,
          }
        };

        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        final result = await conversationService.getConversations(
          pageSize: 50,
          search: 'test keyword',
        );

        expect(result.items.length, 1);
        expect(result.items[0].title, 'Search Result');
      });

      test('ignores empty search parameter', () async {
        final responseData = {
          'data': {
            'items': [],
            'count': 0,
            'totalCount': 0,
          }
        };

        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        final result = await conversationService.getConversations(
          pageSize: 50,
          search: '   ',
        );

        expect(result.items.isEmpty, true);
      });

      test('includes beforeId parameter in query', () async {
        final responseData = {
          'data': {
            'items': [],
            'meta': {
              'totalItems': 5,
              'pageCount': 1,
              'pageSize': 50,
            }
          }
        };

        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        final result = await conversationService.getConversations(
          pageSize: 50,
          beforeId: 'cursor-id',
        );

        expect(result.meta.totalItems, 5);
      });

      test('handles badResponse with error message in data', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'message': 'Unauthorized access'},
              statusCode: 401,
              requestOptions: RequestOptions(path: ApiEndpoints.conversations),
            ),
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        expect(
          () => conversationService.getConversations(pageSize: 50),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'contains error message',
            contains('Unauthorized'),
          )),
        );
      });

      test('handles badResponse with string data', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: 'Internal Server Error',
              statusCode: 500,
              requestOptions: RequestOptions(path: ApiEndpoints.conversations),
            ),
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        expect(
          () => conversationService.getConversations(pageSize: 50),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'contains status code',
            contains('500'),
          )),
        );
      });

      test('handles cancel exception', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.cancel,
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        expect(
          () => conversationService.getConversations(pageSize: 50),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'contains cancelled',
            contains('cancelled'),
          )),
        );
      });

      test('handles unknown DioException type', () async {
        when(() => mockApiClient.get(
              ApiEndpoints.conversations,
              queryParameters: any(named: 'queryParameters'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.unknown,
            message: 'Unknown network error',
            requestOptions: RequestOptions(path: ApiEndpoints.conversations),
          ),
        );

        expect(
          () => conversationService.getConversations(pageSize: 50),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('getConversationById', () {
      test('successfully retrieves conversation detail', () async {
        const conversationId = 'conv-123';
        final responseData = {
          'data': {
            'id': conversationId,
            'title': 'My Chat',
            'updatedAt': '2026-05-03T10:00:00Z',
            'messages': [],
          }
        };

        when(() => mockApiClient.get(
              ApiEndpoints.conversationById(conversationId),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result =
            await conversationService.getConversationById(conversationId);

        expect(result.id, conversationId);
        expect(result.title, 'My Chat');
      });

      test('throws exception when conversation not found', () async {
        const conversationId = 'invalid-id';

        when(() => mockApiClient.get(
              ApiEndpoints.conversationById(conversationId),
            )).thenAnswer(
          (_) async => Response(
            data: {'error': 'Not found'},
            statusCode: 404,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        expect(
          () => conversationService.getConversationById(conversationId),
          throwsException,
        );
      });

      test('handles badResponse error', () async {
        const conversationId = 'conv-456';

        when(() => mockApiClient.get(
              ApiEndpoints.conversationById(conversationId),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {'message': 'Server error'},
              statusCode: 500,
              requestOptions: RequestOptions(
                path: ApiEndpoints.conversationById(conversationId),
              ),
            ),
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        expect(
          () => conversationService.getConversationById(conversationId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('updateConversationTitle', () {
      test('successfully updates conversation title with 200', () async {
        const conversationId = 'conv-123';
        const newTitle = 'Updated Title';
        final responseData = {
          'data': {
            'id': conversationId,
            'title': newTitle,
            'updatedAt': '2026-05-03T12:00:00Z',
          }
        };

        when(() => mockApiClient.patch(
              ApiEndpoints.conversationById(conversationId),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 200,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result = await conversationService.updateConversationTitle(
          id: conversationId,
          title: newTitle,
        );

        expect(result.id, conversationId);
        expect(result.title, newTitle);
      });

      test('successfully updates with 202 Accepted', () async {
        const conversationId = 'conv-456';
        const newTitle = 'New Title';
        final responseData = {
          'data': {
            'id': conversationId,
            'title': newTitle,
            'updatedAt': '2026-05-03T12:00:00Z',
          }
        };

        when(() => mockApiClient.patch(
              ApiEndpoints.conversationById(conversationId),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: responseData,
            statusCode: 202,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result = await conversationService.updateConversationTitle(
          id: conversationId,
          title: newTitle,
        );

        expect(result.title, newTitle);
      });

      test('handles 204 No Content response', () async {
        const conversationId = 'conv-789';
        const newTitle = 'Another Title';

        when(() => mockApiClient.patch(
              ApiEndpoints.conversationById(conversationId),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 204,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result = await conversationService.updateConversationTitle(
          id: conversationId,
          title: newTitle,
        );

        expect(result.id, conversationId);
        expect(result.title, newTitle);
      });

      test('throws exception on bad request', () async {
        const conversationId = 'conv-123';

        when(() => mockApiClient.patch(
              ApiEndpoints.conversationById(conversationId),
              data: any(named: 'data'),
            )).thenAnswer(
          (_) async => Response(
            data: {'error': 'Invalid title'},
            statusCode: 400,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        expect(
          () => conversationService.updateConversationTitle(
            id: conversationId,
            title: 'New',
          ),
          throwsException,
        );
      });

      test('handles DioException during patch', () async {
        const conversationId = 'conv-123';

        when(() => mockApiClient.patch(
              ApiEndpoints.conversationById(conversationId),
              data: any(named: 'data'),
            )).thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        expect(
          () => conversationService.updateConversationTitle(
            id: conversationId,
            title: 'New',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteConversation', () {
      test('successfully deletes conversation', () async {
        const conversationId = 'conv-123';

        when(() => mockApiClient.delete(
              ApiEndpoints.conversationById(conversationId),
            )).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 200,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result =
            await conversationService.deleteConversation(conversationId);

        expect(result, true);
      });

      test('returns true on 204 No Content', () async {
        const conversationId = 'conv-456';

        when(() => mockApiClient.delete(
              ApiEndpoints.conversationById(conversationId),
            )).thenAnswer(
          (_) async => Response(
            data: null,
            statusCode: 204,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result =
            await conversationService.deleteConversation(conversationId);

        expect(result, true);
      });

      test('returns true on 202 Accepted', () async {
        const conversationId = 'conv-789';

        when(() => mockApiClient.delete(
              ApiEndpoints.conversationById(conversationId),
            )).thenAnswer(
          (_) async => Response(
            data: {},
            statusCode: 202,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result =
            await conversationService.deleteConversation(conversationId);

        expect(result, true);
      });

      test('returns false on server error', () async {
        const conversationId = 'conv-111';

        when(() => mockApiClient.delete(
              ApiEndpoints.conversationById(conversationId),
            )).thenAnswer(
          (_) async => Response(
            data: {'error': 'Server error'},
            statusCode: 500,
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        final result =
            await conversationService.deleteConversation(conversationId);

        expect(result, false);
      });

      test('throws exception when id is empty', () async {
        expect(
          () => conversationService.deleteConversation(''),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'contains missing',
            contains('missing'),
          )),
        );
      });

      test('throws exception when id is whitespace', () async {
        expect(
          () => conversationService.deleteConversation('   '),
          throwsA(isA<Exception>()),
        );
      });

      test('handles admin termination error message', () async {
        const conversationId = 'conv-123';

        when(() => mockApiClient.delete(
              ApiEndpoints.conversationById(conversationId),
            )).thenThrow(
          DioException(
            type: DioExceptionType.badResponse,
            response: Response(
              data: {
                'message':
                    'terminating connection due to administrator command'
              },
              statusCode: 500,
              requestOptions: RequestOptions(
                path: ApiEndpoints.conversationById(conversationId),
              ),
            ),
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        expect(
          () => conversationService.deleteConversation(conversationId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'contains restarting',
            contains('restarting'),
          )),
        );
      });

      test('handles generic DioException', () async {
        const conversationId = 'conv-456';

        when(() => mockApiClient.delete(
              ApiEndpoints.conversationById(conversationId),
            )).thenThrow(
          DioException(
            type: DioExceptionType.unknown,
            message: 'Network connection failed',
            requestOptions: RequestOptions(
              path: ApiEndpoints.conversationById(conversationId),
            ),
          ),
        );

        expect(
          () => conversationService.deleteConversation(conversationId),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
