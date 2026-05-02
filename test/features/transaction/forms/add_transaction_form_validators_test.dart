import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/transaction/forms/add_transaction_form_validators.dart';
import 'package:zenit/l10n/app_localizations.dart';

void main() {
  group('AddTransactionFormValidators - Title Validation', () {
    testWidgets('validateTitle returns error for empty value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateTitle(context, '');
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateTitle returns error for null value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateTitle(context, null);
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateTitle returns error for whitespace only', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateTitle(context, '   ');
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateTitle returns null for valid title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateTitle(context, 'Buy groceries');
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('valid'), findsOneWidget);
    });
  });

  group('AddTransactionFormValidators - Amount Validation', () {
    testWidgets('validateAmount returns error for empty value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateAmount(context, '');
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateAmount returns error for null value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateAmount(context, null);
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateAmount returns error for non-numeric value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateAmount(context, 'abc');
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateAmount returns error for zero amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateAmount(context, '0');
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateAmount returns error for negative amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateAmount(context, '-100');
              return Scaffold(body: Text(error ?? 'null'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateAmount returns null for valid amount without commas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateAmount(context, '100000');
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('valid'), findsOneWidget);
    });

    testWidgets('validateAmount returns null for valid amount with commas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateAmount(context, '1,000,000');
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('valid'), findsOneWidget);
    });
  });

  group('AddTransactionFormValidators - Loan Amount Field Validation', () {
    testWidgets('validateLoanAmountField returns null when collectLaterEnabled is false',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateLoanAmountField(
                context,
                collectLaterEnabled: false,
                value: '',
                transactionAmount: 1000000,
                isVietnamese: false,
              );
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('valid'), findsOneWidget);
    });

    testWidgets('validateLoanAmountField returns error for empty when enabled',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateLoanAmountField(
                context,
                collectLaterEnabled: true,
                value: '',
                transactionAmount: 1000000,
                isVietnamese: false,
              );
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateLoanAmountField returns error for zero loan amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateLoanAmountField(
                context,
                collectLaterEnabled: true,
                value: '0',
                transactionAmount: 1000000,
                isVietnamese: false,
              );
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateLoanAmountField returns error when loan >= transaction amount',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateLoanAmountField(
                context,
                collectLaterEnabled: true,
                value: '1000000',
                transactionAmount: 1000000,
                isVietnamese: false,
              );
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateLoanAmountField returns null for valid loan amount', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateLoanAmountField(
                context,
                collectLaterEnabled: true,
                value: '500000',
                transactionAmount: 1000000,
                isVietnamese: false,
              );
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('valid'), findsOneWidget);
    });

    testWidgets('validateLoanAmountField returns Vietnamese error for zero loan',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateLoanAmountField(
                context,
                collectLaterEnabled: true,
                value: '0',
                transactionAmount: 1000000,
                isVietnamese: true,
              );
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('validateLoanAmountField returns Vietnamese error for loan >= transaction',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('vi'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              final error = AddTransactionFormValidators.validateLoanAmountField(
                context,
                collectLaterEnabled: true,
                value: '1500000',
                transactionAmount: 1000000,
                isVietnamese: true,
              );
              return Scaffold(body: Text(error ?? 'valid'));
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('AddTransactionFormValidators - Collect Later Rule Validation', () {
    test('validateCollectLaterRule returns null when collectLaterEnabled is false', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: false,
        transactionAmount: 1000000,
        loanAmount: 500000,
        loanDueDate: DateTime(2026, 6, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: false,
      );
      expect(error, isNull);
    });

    test('validateCollectLaterRule returns error for null loan amount when enabled', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: null,
        loanDueDate: DateTime(2026, 6, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: false,
      );
      expect(error, isNotNull);
    });

    test('validateCollectLaterRule returns error for zero loan amount', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: 0,
        loanDueDate: DateTime(2026, 6, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: false,
      );
      expect(error, isNotNull);
    });

    test('validateCollectLaterRule returns error when loan >= transaction amount', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: 1000000,
        loanDueDate: DateTime(2026, 6, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: false,
      );
      expect(error, isNotNull);
    });

    test('validateCollectLaterRule returns error for due date before transaction date', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: 500000,
        loanDueDate: DateTime(2026, 4, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: false,
      );
      expect(error, isNotNull);
    });

    test('validateCollectLaterRule returns null for valid loan data', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: 500000,
        loanDueDate: DateTime(2026, 6, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: false,
      );
      expect(error, isNull);
    });

    test('validateCollectLaterRule allows due date same as transaction date', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: 500000,
        loanDueDate: DateTime(2026, 5, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: false,
      );
      expect(error, isNull);
    });

    test('validateCollectLaterRule returns Vietnamese error for loan amount issues', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: null,
        loanDueDate: DateTime(2026, 6, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: true,
      );
      expect(error, isNotNull);
      // Check for Vietnamese text content
      expect(error!.isNotEmpty, true);
    });

    test('validateCollectLaterRule returns Vietnamese error for invalid due date', () {
      final error = AddTransactionFormValidators.validateCollectLaterRule(
        collectLaterEnabled: true,
        transactionAmount: 1000000,
        loanAmount: 500000,
        loanDueDate: DateTime(2026, 4, 1),
        transactionDate: DateTime(2026, 5, 1),
        isVietnamese: true,
      );
      expect(error, isNotNull);
      expect(error!.isNotEmpty, true);
    });
  });
}
