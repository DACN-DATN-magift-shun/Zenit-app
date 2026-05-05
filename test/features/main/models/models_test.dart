import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenit/features/main/models/action_item.dart';
import 'package:zenit/features/main/models/home_action_item.dart';

void main() {
  group('ActionTypeExtension', () {
    test('label returns expected text', () {
      expect(ActionType.transaction.label, 'Transaction');
      expect(ActionType.moreActions.label, 'More actions');
    });
  });

  group('HomeActionItem', () {
    test('copyWith overrides selected fields', () {
      const item = HomeActionItem(
        title: 'Old',
        icon: Icons.add,
        backgroundColor: Colors.blue,
        iconColor: Colors.white,
        type: ActionType.transaction,
      );

      final copied = item.copyWith(
        title: 'New',
        type: ActionType.transfer,
        useGradient: true,
      );

      expect(copied.title, 'New');
      expect(copied.type, ActionType.transfer);
      expect(copied.useGradient, true);
      expect(copied.icon, Icons.add);
    });
  });
}
