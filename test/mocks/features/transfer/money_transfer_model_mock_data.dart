const moneyTransferFromJsonMockData = {
  'result': {
    'id': 'mt1',
    'fromWalletId': 'w1',
    'toWalletId': 'w2',
    'amount': '100000',
    'transferDate': '2026-04-26T00:00:00Z',
    'note': 'move funds',
    'fromWallet': {'id': 'w1', 'name': 'Cash', 'amount': 1000},
    'toWallet': {'id': 'w2', 'name': 'Bank', 'amount': 2000},
  },
};

const moneyTransferListResponseMockData = {
  'items': [
    {
      'id': 'm1',
      'fromWalletId': 'a',
      'toWalletId': 'b',
      'amount': 1,
      'transferDate': '2026-04-26T00:00:00Z',
      'note': '',
    },
  ],
  'meta': {
    'totalItems': 1,
    'pageCount': 1,
    'page': 1,
    'pageSize': 10,
  },
};
