import 'package:zenit/core/api/api_endpoints.dart';

import 'test_http_adapter.dart';

List<StaticHttpRule> buildAuthenticatedApiRules() {
  var transactionCreated = false;

  Map<String, dynamic> buildTransactionList() {
    if (!transactionCreated) {
      return <String, dynamic>{
        'items': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{
          'totalItems': 0,
          'pageCount': 1,
          'page': 1,
          'pageSize': 10,
        },
      };
    }

    return <String, dynamic>{
      'items': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'txn-created-1',
          'title': 'Lunch',
          'note': 'Team lunch',
          'amount': 120000,
          'transactionDate': DateTime(2026, 4, 30).toUtc().toIso8601String(),
          'categoryId': 'cat-necessary-food',
          'walletId': 'wallet-cash',
        },
      ],
      'meta': <String, dynamic>{
        'totalItems': 1,
        'pageCount': 1,
        'page': 1,
        'pageSize': 10,
      },
    };
  }

  return <StaticHttpRule>[
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.accounts,
      data: <String, dynamic>{
        'data': <String, dynamic>{
          'username': 'integration-user',
          'photoId': null,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.transactions,
      dataBuilder: buildTransactionList,
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.categories &&
          options.queryParameters['groupType'] == 0,
      data: <String, dynamic>{
        'categories': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'cat-necessary-food',
            'name': 'Food',
            'icon': 'restaurant_rounded',
            'color': '#FFFFFF',
            'backgroundColor': '#FFB74D',
            'groupType': 0,
          },
        ],
        'meta': <String, dynamic>{
          'totalItems': 1,
          'pageCount': 1,
          'page': 1,
          'pageSize': 10,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.categories &&
          options.queryParameters['groupType'] == 1,
      data: <String, dynamic>{
        'categories': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{
          'totalItems': 0,
          'pageCount': 1,
          'page': 1,
          'pageSize': 10,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.categories &&
          options.queryParameters['groupType'] == 2,
      data: <String, dynamic>{
        'categories': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{
          'totalItems': 0,
          'pageCount': 1,
          'page': 1,
          'pageSize': 10,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.categories &&
          options.queryParameters['groupType'] == 3,
      data: <String, dynamic>{
        'categories': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{
          'totalItems': 0,
          'pageCount': 1,
          'page': 1,
          'pageSize': 10,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.categories &&
          options.queryParameters['groupType'] == 4,
      data: <String, dynamic>{
        'categories': <Map<String, dynamic>>[],
        'meta': <String, dynamic>{
          'totalItems': 0,
          'pageCount': 1,
          'page': 1,
          'pageSize': 10,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.categories &&
          options.queryParameters['groupType'] == 5,
      data: <String, dynamic>{
        'categories': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'cat-income-salary',
            'name': 'Salary',
            'icon': 'work_rounded',
            'color': '#FFFFFF',
            'backgroundColor': '#81C784',
            'groupType': 5,
          },
        ],
        'meta': <String, dynamic>{
          'totalItems': 1,
          'pageCount': 1,
          'page': 1,
          'pageSize': 10,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.wallets,
      data: <String, dynamic>{
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'wallet-cash',
            'name': 'Cash',
            'amount': 5000000,
            'icon': 'account_balance_wallet_rounded',
            'backgroundColor': '#E3F2FD',
            'note': 'Main cash wallet',
            'isIncludeInTotalBalance': true,
          },
          <String, dynamic>{
            'id': 'wallet-bank',
            'name': 'Bank',
            'amount': 20000000,
            'icon': 'account_balance_rounded',
            'backgroundColor': '#C8E6C9',
            'note': 'Salary account',
            'isIncludeInTotalBalance': true,
          },
        ],
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'GET' &&
          options.path == ApiEndpoints.statistics,
      data: <String, dynamic>{
        'groupStatistics': <Map<String, dynamic>>[],
        'incomeExpenseStatistics': <String, dynamic>{
          'totalIncome': 0,
          'totalExpense': 0,
          'incomePercentageChange': 0,
          'expensePercentageChange': 0,
        },
      },
    ),
    StaticHttpRule(
      matches: (options) =>
          options.method.toUpperCase() == 'POST' &&
          options.path == ApiEndpoints.createTransaction,
      data: <String, dynamic>{
        'id': 'txn-created-1',
        'title': 'Lunch',
        'note': 'Team lunch',
        'amount': 120000,
        'transactionDate': DateTime(2026, 4, 30).toUtc().toIso8601String(),
        'categoryId': 'cat-necessary-food',
        'walletId': 'wallet-cash',
      },
      statusCode: 201,
      dataBuilder: () {
        transactionCreated = true;
        return <String, dynamic>{
          'id': 'txn-created-1',
          'title': 'Lunch',
          'note': 'Team lunch',
          'amount': 120000,
          'transactionDate': DateTime(2026, 4, 30).toUtc().toIso8601String(),
          'categoryId': 'cat-necessary-food',
          'walletId': 'wallet-cash',
        };
      },
    ),
  ];
}
