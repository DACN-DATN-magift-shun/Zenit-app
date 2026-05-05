const transactionListResponseData = {
  'items': [
    {
      'id': 'tx1',
      'title': 'Lunch',
      'amount': 10,
      'transactionDate': '2026-01-01T00:00:00Z',
      'categoryId': 'c1',
      'walletId': 'w1',
    },
  ],
  'meta': {'totalItems': 1, 'pageCount': 1, 'page': 1, 'pageSize': 10},
};

const transactionListMultipleData = {
  'items': [
    {
      'id': 'tx1',
      'title': 'Lunch',
      'amount': 100000,
      'transactionDate': '2026-04-20T00:00:00Z',
      'categoryId': 'c1',
      'walletId': 'w1',
      'note': 'Lunch with friends',
    },
    {
      'id': 'tx2',
      'title': 'Grocery',
      'amount': 500000,
      'transactionDate': '2026-04-21T00:00:00Z',
      'categoryId': 'c2',
      'walletId': 'w1',
      'note': 'Weekly shopping',
    },
    {
      'id': 'tx3',
      'title': 'Salary',
      'amount': 15000000,
      'transactionDate': '2026-04-22T00:00:00Z',
      'categoryId': 'c3',
      'walletId': 'w2',
    },
  ],
  'meta': {'totalItems': 3, 'pageCount': 1, 'page': 1, 'pageSize': 20},
};

const singleTransactionData = {
  'id': 'tx1',
  'title': 'Lunch',
  'amount': 100000,
  'transactionDate': '2026-04-20T00:00:00Z',
  'categoryId': 'c1',
  'walletId': 'w1',
  'note': 'Lunch with friends',
};
