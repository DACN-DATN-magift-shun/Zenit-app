const conversationListResponseMockJson = {
  'items': [
    {
      'id': 'c1',
      'title': 'My conversation',
      'updatedAt': '2026-04-20T10:00:00Z',
    },
  ],
  'meta': {
    'totalItems': 1,
    'pageCount': 1,
    'page': 1,
    'pageSize': 10,
  },
};

const assistantMessageMockJson = {
  'id': '01967690-0abc-7def-8000-aaaaaaaaaaaa',
  'conversationId': 'conv-1',
  'accountId': '00000000-0000-0000-0000-000000000001',
  'text': 'Hello from AI',
  'createdAt': '2026-04-21T07:00:00Z',
};

const conversationDetailMockJson = {
  'id': 'conv-2',
  'title': 'Thread',
  'messages': [
    {
      'id': 'm1',
      'accountId': 'u1',
      'text': 'Hi',
      'createdAt': '2026-04-22T01:00:00Z',
    },
    {
      'id': 'm2',
      'accountId': '00000000-0000-0000-0000-000000000001',
      'text': 'Hello',
      'createdAt': '2026-04-22T01:01:00Z',
    },
  ],
};
