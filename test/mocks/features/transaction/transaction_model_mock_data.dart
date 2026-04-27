const transactionFromJsonMockData = {
  'data': {
    'transactionId': 't1',
    'title': 'Lunch',
    'note': 'team meal',
    'amount': '120000',
    'transactionDate': '2026-04-25T12:00:00Z',
    'categoryId': 'c1',
    'wallet': {'id': 'w-from-nested'},
    'photos': [
      {'id': 'p1', 'url': 'https://cdn/p1.jpg'},
    ],
  },
};

const transactionListResponseMockData = {
  'items': [
    {
      'id': 'tx1',
      'title': 'A',
      'amount': 1,
      'transactionDate': '2026-04-20T00:00:00Z',
      'categoryId': 'c',
      'walletId': 'w',
    },
  ],
  'meta': {
    'totalItems': 1,
    'pageCount': 1,
    'page': 1,
    'pageSize': 10,
  },
};
