RUN COMMANDS:
flutter run



TEST COMMANDS:
Unit test: flutter test test
Integration test: flutter test integration_test/flow/
System Test: 

flutter test integration_test/system_flow/system_flow_1_test.dart \
--dart-define API_BASE_URL=https://zenit-api-tuir.onrender.com/ \
--dart-define USE_PRODUCTION=true \
--dart-define SYSTEM_TEST_EMAIL=tuan5@gmail.com \
--dart-define SYSTEM_TEST_PASSWORD=0788778027@ \
--dart-define TRANSACTION_TITLE="Test Transaction" \
--dart-define TRANSACTION_NOTE="Test note" \
--dart-define TRANSACTION_AMOUNT=50000 \
--dart-define WALLET_NAME="VCB" \
--dart-define CATEGORY_NAME="test"

flutter test integration_test/system_flow/system_flow_2_test.dart \
--dart-define API_BASE_URL=https://zenit-api-tuir.onrender.com/ \
--dart-define USE_PRODUCTION=true \
--dart-define SYSTEM_TEST_EMAIL=tuan5@gmail.com \
--dart-define SYSTEM_TEST_PASSWORD=0788778027@ \
--dart-define TRANSACTION_TITLE="Test Transaction" \
--dart-define TRANSACTION_NOTE="Test note" \
--dart-define TRANSACTION_AMOUNT=50000 \
--dart-define WALLET_NAME="VCB" \
--dart-define CATEGORY_NAME="test"