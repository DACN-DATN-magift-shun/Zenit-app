import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form_helpers.dart';
import 'package:zenit/features/setting_childs/category_manage/models/category_model.dart';

void main() {
  group('AddTransactionFormHelpers - Category Compatibility', () {
    test('isCategoryCompatibleWithCurrentType returns true for income category with income transaction', () {
      // GroupType.income.value is 5, not 8
      final category = CategoryModel(
        id: 'c1',
        name: 'Salary',
        icon: 'salary_icon',
        groupType: '5', // income
      );
      final isCompatible = AddTransactionFormHelpers.isCategoryCompatibleWithCurrentType(
        category,
        true, // isIncomeTransaction
      );
      expect(isCompatible, true);
    });

    test('isCategoryCompatibleWithCurrentType returns false for income category with expense transaction', () {
      final category = CategoryModel(
        id: 'c1',
        name: 'Salary',
        icon: 'salary_icon',
        groupType: '5', // income
      );
      final isCompatible = AddTransactionFormHelpers.isCategoryCompatibleWithCurrentType(
        category,
        false, // isExpenseTransaction
      );
      expect(isCompatible, false);
    });

    test('isCategoryCompatibleWithCurrentType returns true for expense category with expense transaction', () {
      final category = CategoryModel(
        id: 'c2',
        name: 'Food',
        icon: 'food_icon',
        groupType: '0', // necessary (expense)
      );
      final isCompatible = AddTransactionFormHelpers.isCategoryCompatibleWithCurrentType(
        category,
        false, // isExpenseTransaction
      );
      expect(isCompatible, true);
    });

    test('isCategoryCompatibleWithCurrentType returns false for expense category with income transaction', () {
      final category = CategoryModel(
        id: 'c2',
        name: 'Food',
        icon: 'food_icon',
        groupType: '0', // necessary (expense)
      );
      final isCompatible = AddTransactionFormHelpers.isCategoryCompatibleWithCurrentType(
        category,
        true, // isIncomeTransaction
      );
      expect(isCompatible, false);
    });
  });



  group('AddTransactionFormHelpers - Color Parsing', () {
    test('parseColor parses hex color correctly', () {
      final color = AddTransactionFormHelpers.parseColor('#FF0000');
      expect(color.red > 0.99, true); // Red channel should be ~1.0
      expect(color.green < 0.01, true); // Green channel should be ~0
      expect(color.blue < 0.01, true); // Blue channel should be ~0
    });

    test('parseColor handles color without hash', () {
      final color = AddTransactionFormHelpers.parseColor('FF0000');
      expect(color.red > 0.99, true);
      expect(color.green < 0.01, true);
      expect(color.blue < 0.01, true);
    });

    test('parseColor adds alpha channel when needed', () {
      final color = AddTransactionFormHelpers.parseColor('#0000FF');
      expect(color.blue > 0.99, true); // Blue channel should be ~1.0
      expect(color.red < 0.01, true);
      expect(color.green < 0.01, true);
    });

    test('parseColor handles various hex formats', () {
      final color1 = AddTransactionFormHelpers.parseColor('00FF00');
      final color2 = AddTransactionFormHelpers.parseColor('#00FF00');
      expect(color1.green > 0.99, true);
      expect(color2.green > 0.99, true);
    });

    test('parseColor returns grey color for invalid input without throwing', () {
      // Should not throw an exception
      final color = AddTransactionFormHelpers.parseColor('invalid');
      expect(color, isNotNull);
    });
  });

  group('AddTransactionFormHelpers - Amount Parsing', () {
    test('parseAmountValue parses integers', () {
      expect(AddTransactionFormHelpers.parseAmountValue('100'), 100);
      expect(AddTransactionFormHelpers.parseAmountValue('1,000'), 1000);
    });

    test('parseAmountValue returns null for empty', () {
      expect(AddTransactionFormHelpers.parseAmountValue(''), null);
    });

    test('selectedAmountValue uses controller text', () {
      final controller = TextEditingController(text: '100,000');
      expect(AddTransactionFormHelpers.selectedAmountValue(controller), 100000);
      controller.dispose();
    });
  });

  group('AddTransactionFormHelpers - Net Amount Calculation', () {
    test('netTransactionAmount returns full amount when loan disabled', () {
      final result = AddTransactionFormHelpers.netTransactionAmount(
        transactionAmount: 1000000,
        collectLaterEnabled: false,
        loanAmount: null,
      );
      expect(result, 1000000);
    });

    test('netTransactionAmount calculates net with loan', () {
      final result = AddTransactionFormHelpers.netTransactionAmount(
        transactionAmount: 1000000,
        collectLaterEnabled: true,
        loanAmount: 300000,
      );
      expect(result, 700000);
    });
  });

  group('AddTransactionFormHelpers - Expression Operators', () {
    test('isOperator identifies operators', () {
      expect(AddTransactionFormHelpers.isOperator('+'), true);
      expect(AddTransactionFormHelpers.isOperator('a'), false);
    });

    test('applyOperator performs basic operations', () {
      expect(AddTransactionFormHelpers.applyOperator(10, 5, '+'), 15);
      expect(AddTransactionFormHelpers.applyOperator(10, 5, '-'), 5);
      expect(AddTransactionFormHelpers.applyOperator(10, 5, '*'), 50);
      expect(AddTransactionFormHelpers.applyOperator(10, 5, '/'), 2);
    });

    test('applyOperator returns null for division by zero', () {
      expect(AddTransactionFormHelpers.applyOperator(10, 0, '/'), null);
    });
  });

  group('AddTransactionFormHelpers - Expression Evaluation', () {
    test('evaluateExpression evaluates simple math', () {
      expect(AddTransactionFormHelpers.evaluateExpression('100'), 100);
      expect(AddTransactionFormHelpers.evaluateExpression('100+50'), 150);
      expect(AddTransactionFormHelpers.evaluateExpression('100-50'), 50);
    });

    test('evaluateExpression respects precedence', () {
      expect(AddTransactionFormHelpers.evaluateExpression('10+5*2'), 20);
      expect(AddTransactionFormHelpers.evaluateExpression('10*5+2'), 52);
    });

    test('evaluateExpression handles commas', () {
      expect(AddTransactionFormHelpers.evaluateExpression('1,000+500'), 1500);
    });

    test('evaluateExpression returns null for invalid', () {
      expect(AddTransactionFormHelpers.evaluateExpression(''), null);
      expect(AddTransactionFormHelpers.evaluateExpression('100+'), null);
    });
  });

  group('AddTransactionFormHelpers - Number Formatting', () {
    test('formatNumberWithCommas formats correctly', () {
      expect(AddTransactionFormHelpers.formatNumberWithCommas(1000), '1,000');
      expect(AddTransactionFormHelpers.formatNumberWithCommas(1000000), '1,000,000');
    });
  });
}
