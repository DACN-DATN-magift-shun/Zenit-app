// List payload format
const categoryListAsListData = [
  {
    'id': 'c1',
    'name': 'Food',
    'icon': 'restaurant',
    'groupType': 0,
    'color': '#111111',
    'backgroundColor': '#EEEEEE',
    'expenseLimit': 5000000,
  },
];

// Nested data.categories format
const categoryListNestedDataFormat = {
  'data': {
    'categories': [
      {
        'id': 'c2',
        'name': 'Transport',
        'icon': 'directions_car',
        'groupType': 0,
        'color': '#222222',
        'backgroundColor': '#DDDDDD',
      },
    ],
  },
};

// Nested items format
const categoryListNestedItemsFormat = {
  'items': [
    {
      'id': 'c3',
      'name': 'Entertainment',
      'icon': 'movie',
      'groupType': 0,
      'color': '#333333',
      'backgroundColor': '#CCCCCC',
    },
  ],
};

// Multiple categories with different groupTypes
const categoryMultipleGroupsData = {
  'items': [
    {
      'id': 'c1',
      'name': 'Food',
      'icon': 'restaurant',
      'groupType': 0,
      'color': '#111111',
      'backgroundColor': '#EEEEEE',
    },
    {
      'id': 'c2',
      'name': 'Transport',
      'icon': 'directions_car',
      'groupType': 0,
      'color': '#222222',
      'backgroundColor': '#DDDDDD',
    },
    {
      'id': 'c5',
      'name': 'Salary',
      'icon': 'attach_money',
      'groupType': 5,
      'color': '#555555',
      'backgroundColor': '#999999',
    },
  ],
};

// Payload with meta for retry test
const categoryEmptyWithMeta = {
  'items': [],
  'meta': {
    'totalItems': 2,
    'pageSize': 0,
  },
};

const categoryEmptyWithMetaRetry = {
  'items': [
    {
      'id': 'c1',
      'name': 'Food',
      'icon': 'restaurant',
      'groupType': 0,
      'color': '#111111',
      'backgroundColor': '#EEEEEE',
    },
    {
      'id': 'c2',
      'name': 'Transport',
      'icon': 'directions_car',
      'groupType': 0,
      'color': '#222222',
      'backgroundColor': '#DDDDDD',
    },
  ],
  'meta': {
    'totalItems': 2,
    'pageSize': 10,
  },
};

// All income categories (groupType 5)
const incomeCategories = {
  'items': [
    {
      'id': 'inc1',
      'name': 'Salary',
      'icon': 'attach_money',
      'groupType': 5,
      'color': '#00AA00',
      'backgroundColor': '#CCFFCC',
    },
    {
      'id': 'inc2',
      'name': 'Bonus',
      'icon': 'card_giftcard',
      'groupType': 5,
      'color': '#00BB00',
      'backgroundColor': '#CCEECC',
    },
  ],
};

// Single category response
const singleCategoryData = {
  'id': 'c1',
  'name': 'Food',
  'icon': 'restaurant',
  'groupType': 0,
  'color': '#111111',
  'backgroundColor': '#EEEEEE',
  'expenseLimit': 5000000,
  'expenseAlertThreshold': 4000000,
};

// Create category response
const createCategoryResponse = {
  'id': 'c_new',
  'name': 'Shopping',
  'icon': 'shopping_bag',
  'groupType': 0,
  'color': '#FF0000',
  'backgroundColor': '#FFE0E0',
};

// Update category response
const updateCategoryResponse = {
  'id': 'c1',
  'name': 'Food Updated',
  'icon': 'restaurant',
  'groupType': 0,
  'color': '#111111',
  'backgroundColor': '#EEEEEE',
};

// Error response in 200 status
const categoryUpdateErrorData = {
  'code': 'INVALID',
  'details': 'Cannot update category',
};
