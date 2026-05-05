// Payload unwrapping - data wrapper
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

// Payload unwrapping - result wrapper
const transactionResultWrapper = {
  'result': {
    'id': 't2',
    'title': 'Dinner',
    'note': 'with friends',
    'amount': 200000,
    'transactionDate': '2026-04-26T18:00:00Z',
    'categoryId': 'c2',
    'walletId': 'w2',
  },
};

// Payload unwrapping - transaction wrapper
const transactionTransactionWrapper = {
  'transaction': {
    'id': 't3',
    'title': 'Coffee',
    'amount': 50000,
    'transactionDate': '2026-04-27T10:00:00Z',
    'categoryId': 'c3',
    'walletId': 'w3',
  },
};

// Payload unwrapping - item wrapper
const transactionItemWrapper = {
  'item': {
    'id': 't4',
    'title': 'Snack',
    'amount': 30000,
    'transactionDate': '2026-04-28T15:00:00Z',
    'categoryId': 'c4',
    'walletId': 'w4',
  },
};

// Payload unwrapping - record wrapper
const transactionRecordWrapper = {
  'record': {
    'id': 't5',
    'title': 'Dessert',
    'amount': 40000,
    'transactionDate': '2026-04-29T20:00:00Z',
    'categoryId': 'c5',
    'walletId': 'w5',
  },
};

// Payload unwrapping - entity wrapper
const transactionEntityWrapper = {
  'entity': {
    'id': 't6',
    'title': 'Beverage',
    'amount': 25000,
    'transactionDate': '2026-04-30T09:00:00Z',
    'categoryId': 'c6',
    'walletId': 'w6',
  },
};

// Transaction with full details
const fullTransactionData = {
  'id': 't_full',
  'title': 'Full Transaction',
  'note': 'Complete info',
  'amount': 500000,
  'transactionDate': '2026-04-20T12:00:00Z',
  'categoryId': 'c1',
  'walletId': 'w1',
  'category': {
    'id': 'c1',
    'name': 'Food',
    'icon': 'restaurant',
    'color': '#FF5722',
    'backgroundColor': '#FFEBEE',
    'groupType': 0,
  },
  'accountId': 'acc123',
  'createdById': 'user1',
  'createdAt': '2026-04-20T12:00:00Z',
  'isDeleted': false,
  'modifiedById': 'user2',
  'lastModifiedAt': '2026-04-21T12:00:00Z',
  'photos': [
    {'id': 'p1', 'url': 'https://cdn/photo1.jpg'},
    {'id': 'p2', 'url': 'https://cdn/photo2.jpg'},
  ],
};

// Transaction with deleted info
const deletedTransactionData = {
  'id': 't_deleted',
  'title': 'Deleted Transaction',
  'amount': 100000,
  'transactionDate': '2026-04-15T10:00:00Z',
  'categoryId': 'c1',
  'walletId': 'w1',
  'isDeleted': true,
  'deletedById': 'user3',
  'deletedAt': '2026-04-22T10:00:00Z',
};

// Transaction with minimal data
const minimalTransactionData = {
  'id': 't_min',
  'title': 'Minimal',
  'amount': 0,
  'categoryId': 'c1',
  'walletId': 'w1',
};

// Transaction with multiple photos
const transactionWithPhotos = {
  'id': 't_photos',
  'title': 'With Photos',
  'amount': 300000,
  'transactionDate': '2026-04-18T14:00:00Z',
  'categoryId': 'c2',
  'walletId': 'w2',
  'photos': [
    {'id': 'p1', 'url': 'https://cdn/p1.jpg'},
    {'id': 'p2', 'url': 'https://cdn/p2.jpg'},
    {'id': 'p3', 'url': 'https://cdn/p3.jpg'},
  ],
};

// Transaction with no photos
const transactionNoPhotos = {
  'id': 't_nophoto',
  'title': 'No Photos',
  'amount': 50000,
  'transactionDate': '2026-04-17T16:00:00Z',
  'categoryId': 'c3',
  'walletId': 'w3',
  'photos': [],
};

// Transaction response list
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

// Multiple transactions in list
const transactionListMultipleData = {
  'items': [
    {
      'id': 'tx1',
      'title': 'Breakfast',
      'amount': 150000,
      'transactionDate': '2026-04-20T08:00:00Z',
      'categoryId': 'c1',
      'walletId': 'w1',
    },
    {
      'id': 'tx2',
      'title': 'Lunch',
      'amount': 200000,
      'transactionDate': '2026-04-20T12:00:00Z',
      'categoryId': 'c1',
      'walletId': 'w1',
    },
    {
      'id': 'tx3',
      'title': 'Dinner',
      'amount': 300000,
      'transactionDate': '2026-04-20T18:00:00Z',
      'categoryId': 'c1',
      'walletId': 'w1',
    },
  ],
  'meta': {
    'totalItems': 3,
    'pageCount': 1,
    'page': 1,
    'pageSize': 10,
  },
};
