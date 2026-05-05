
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/utils/validators/money_source_manage_form_validator.dart';

void main() {
	group('MoneySourceManageFormValidator.moneySourceName', () {
		test('returns error when null or empty (Vietnamese)', () {
			expect(
				MoneySourceManageFormValidator.moneySourceName(null, isVietnamese: true),
				'Vui lòng nhập tên nguồn tiền',
			);
			expect(
				MoneySourceManageFormValidator.moneySourceName('', isVietnamese: true),
				'Vui lòng nhập tên nguồn tiền',
			);
			expect(
				MoneySourceManageFormValidator.moneySourceName('   ', isVietnamese: true),
				'Vui lòng nhập tên nguồn tiền',
			);
		});

		test('returns error when null or empty (English)', () {
			expect(
				MoneySourceManageFormValidator.moneySourceName(null, isVietnamese: false),
				'Please enter money source name',
			);
			expect(
				MoneySourceManageFormValidator.moneySourceName('', isVietnamese: false),
				'Please enter money source name',
			);
		});

		test('returns error when too long', () {
			final longName = List.filled(26, 'a').join();
			expect(
				MoneySourceManageFormValidator.moneySourceName(longName, isVietnamese: true),
				'Tên nguồn tiền không được vượt quá 25 ký tự',
			);
			expect(
				MoneySourceManageFormValidator.moneySourceName(longName, isVietnamese: false),
				'Money source name must not exceed 25 characters',
			);
		});

		test('returns null for valid names', () {
			expect(
				MoneySourceManageFormValidator.moneySourceName('Tiền mặt', isVietnamese: true),
				isNull,
			);
			expect(
				MoneySourceManageFormValidator.moneySourceName('Savings 1', isVietnamese: false),
				isNull,
			);
		});
	});

	group('MoneySourceManageFormValidator.amount', () {
		test('returns null when empty or null', () {
			expect(
				MoneySourceManageFormValidator.amount(null, invalidAmountMessage: 'Invalid'),
				isNull,
			);
			expect(
				MoneySourceManageFormValidator.amount('', invalidAmountMessage: 'Invalid'),
				isNull,
			);
			expect(
				MoneySourceManageFormValidator.amount('   ', invalidAmountMessage: 'Invalid'),
				isNull,
			);
		});

		test('returns error when not an integer', () {
			expect(
				MoneySourceManageFormValidator.amount('abc', invalidAmountMessage: 'Invalid'),
				'Invalid',
			);
			expect(
				MoneySourceManageFormValidator.amount('12.34', invalidAmountMessage: 'Invalid'),
				'Invalid',
			);
		});

		test('parses trimmed integer and negative ints', () {
			expect(
				MoneySourceManageFormValidator.amount(' 123 ', invalidAmountMessage: 'Invalid'),
				isNull,
			);
			expect(
				MoneySourceManageFormValidator.amount('-5', invalidAmountMessage: 'Invalid'),
				isNull,
			);
		});
	});
}

