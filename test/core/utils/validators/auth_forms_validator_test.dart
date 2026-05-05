import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/core/utils/validators/auth_forms_validator.dart';

void main() {
	group('AuthFormsValidator.email', () {
		test('returns error when email is null or empty', () {
			expect(AuthFormsValidator.email(null), 'Vui lòng nhập email');
			expect(AuthFormsValidator.email(''), 'Vui lòng nhập email');
		});

		test('returns error for invalid email formats', () {
			expect(AuthFormsValidator.email('not-an-email'), 'Email không hợp lệ');
			expect(AuthFormsValidator.email('a@b'), 'Email không hợp lệ');
			expect(AuthFormsValidator.email('user@domain.c'), 'Email không hợp lệ');
		});

		test('returns null for valid emails', () {
			expect(AuthFormsValidator.email('user@example.com'), isNull);
			expect(AuthFormsValidator.email('first.last@sub.domain.co'), isNull);
		});
	});

	group('AuthFormsValidator.username', () {
		test('null or empty username', () {
			expect(AuthFormsValidator.username(null), 'Vui lòng nhập tên đăng nhập');
			expect(AuthFormsValidator.username(''), 'Vui lòng nhập tên đăng nhập');
		});

		test('too short or too long', () {
			expect(AuthFormsValidator.username('ab'), 'Tên đăng nhập phải từ 3 đến 20 ký tự');
			final longUsername = List.filled(21, 'a').join();
			expect(AuthFormsValidator.username(longUsername), 'Tên đăng nhập phải từ 3 đến 20 ký tự');
		});

		test('invalid characters', () {
			expect(AuthFormsValidator.username('user!'), 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới');
		});

		test('valid username', () {
			expect(AuthFormsValidator.username('user_name123'), isNull);
		});
	});

	group('AuthFormsValidator.password', () {
		test('null or empty password', () {
			expect(AuthFormsValidator.password(null), 'Vui lòng nhập mật khẩu');
			expect(AuthFormsValidator.password(''), 'Vui lòng nhập mật khẩu');
		});

		test('too short password (<=8)', () {
			expect(AuthFormsValidator.password('Abc1!23'), 'Mật khẩu phải dài hơn 8 ký tự');
			expect(AuthFormsValidator.password('Abcdef12'), 'Mật khẩu phải dài hơn 8 ký tự');
		});

		test('missing number or special char', () {
			expect(AuthFormsValidator.password('Password!'), 'Mật khẩu phải chứa ít nhất một chữ số');
			expect(AuthFormsValidator.password('Password1'), 'Mật khẩu phải chứa ít nhất một ký tự đặc biệt');
		});

		test('valid password', () {
			expect(AuthFormsValidator.password('Passw0rd!'), isNull);
		});
	});

	group('AuthFormsValidator.confirmPassword', () {
		test('null or empty confirm password', () {
			final getPassword = () => 'secret123!';
			final validator = AuthFormsValidator.confirmPassword(getPassword);
			expect(validator(null), 'Vui lòng xác nhận mật khẩu');
			expect(validator(''), 'Vui lòng xác nhận mật khẩu');
		});

		test('mismatched passwords', () {
			final getPassword = () => 'secret123!';
			final validator = AuthFormsValidator.confirmPassword(getPassword);
			expect(validator('wrongpass'), 'Mật khẩu không khớp');
		});

		test('matching passwords', () {
			final getPassword = () => 'secret123!';
			final validator = AuthFormsValidator.confirmPassword(getPassword);
			expect(validator('secret123!'), isNull);
		});
	});

	group('AuthFormsValidator.phone', () {
		test('null or empty phone', () {
			expect(AuthFormsValidator.phone(null), 'Vui lòng nhập số điện thoại');
			expect(AuthFormsValidator.phone(''), 'Vui lòng nhập số điện thoại');
		});

		test('invalid format', () {
			expect(AuthFormsValidator.phone('abcd'), 'Số điện thoại không hợp lệ');
		});

		test('wrong length (not 10)', () {
			// This matches the regex (7-15 digits) but fails the length==10 check
			expect(AuthFormsValidator.phone('012345678'), 'Số điện thoại phải có 10 chữ số');
		});

		test('valid phone number', () {
			expect(AuthFormsValidator.phone('0123456789'), isNull);
		});
	});

	group('AuthFormsValidator.address', () {
		test('null or empty address', () {
			expect(AuthFormsValidator.address(null), 'Vui lòng nhập địa chỉ');
			expect(AuthFormsValidator.address(''), 'Vui lòng nhập địa chỉ');
		});

		test('too short address', () {
			expect(AuthFormsValidator.address('Abc'), 'Địa chỉ quá ngắn');
		});

		test('valid address', () {
			expect(AuthFormsValidator.address('123 Main Street'), isNull);
		});
	});

	group('AuthFormsValidator.required', () {
		test('default field name', () {
			expect(AuthFormsValidator.required(null), 'Trường này không được để trống');
		});

		test('custom field name', () {
			expect(AuthFormsValidator.required('', fieldName: 'Email'), 'Email không được để trống');
		});
	});

	group('AuthFormsValidator.compose', () {
		test('returns first error from composed validators', () {
			final validator = AuthFormsValidator.compose([
				(v) => AuthFormsValidator.required(v, fieldName: 'Email'),
				AuthFormsValidator.email,
			]);

			expect(validator(null), 'Email không được để trống');
		});

		test('returns null when all validators pass', () {
			final validator = AuthFormsValidator.compose([
				AuthFormsValidator.email,
			]);
			expect(validator('user@example.com'), isNull);
		});
	});
}

