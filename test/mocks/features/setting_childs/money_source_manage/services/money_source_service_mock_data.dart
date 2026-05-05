// Wallets as direct list
const walletsListResponseData = {
  'wallets': [
    {
      'id': 'w1',
      'name': 'Cash',
      'amount': 100000,
      'icon': 'account_balance_wallet_rounded',
      'backgroundColor': '#E3F2FD',
    },
  ],
};

// Items format
const walletsListItemsFormat = {
  'items': [
    {
      'id': 'w2',
      'name': 'Debit Card',
      'amount': 5000000,
      'icon': 'credit_card',
      'backgroundColor': '#FFF3E0',
    },
  ],
};

// Nested data.items format
const walletsListNestedDataFormat = {
  'data': {
    'items': [
      {
        'id': 'w3',
        'name': 'Savings',
        'amount': 50000000,
        'icon': 'savings',
        'backgroundColor': '#F3E5F5',
      },
    ],
  },
};

// Multiple wallets
const walletsListMultipleData = {
  'items': [
    {
      'id': 'w1',
      'name': 'Cash',
      'amount': 100000,
      'icon': 'account_balance_wallet_rounded',
      'backgroundColor': '#E3F2FD',
    },
    {
      'id': 'w2',
      'name': 'Debit Card',
      'amount': 5000000,
      'icon': 'credit_card',
      'backgroundColor': '#FFF3E0',
    },
    {
      'id': 'w3',
      'name': 'Savings',
      'amount': 50000000,
      'icon': 'savings',
      'backgroundColor': '#F3E5F5',
    },
  ],
};

// Empty wallets list
const walletsEmptyList = {
  'items': [],
};

// Single wallet response
const singleWalletData = {
  'id': 'w1',
  'name': 'Cash',
  'amount': 100000,
  'icon': 'account_balance_wallet_rounded',
  'backgroundColor': '#E3F2FD',
  'note': 'Personal cash',
  'isIncludeInTotalBalance': true,
};

// Create wallet response
const createWalletResponse = {
  'id': 'w_new',
  'name': 'New Wallet',
  'amount': 0,
  'icon': 'wallet',
  'backgroundColor': '#FFEBEE',
};

// Create wallet with empty response (204 No Content)
const createWalletEmptyResponse = {};

// Update wallet response
const updateWalletResponse = {
  'id': 'w1',
  'name': 'Cash Updated',
  'amount': 500000,
  'icon': 'account_balance_wallet_rounded',
  'backgroundColor': '#E3F2FD',
};
