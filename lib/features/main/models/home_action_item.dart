import 'package:flutter/material.dart';
import 'action_item.dart';

/// Model class representing an action item in the HomeActionGrid
class HomeActionItem {
  /// The display title of the action
  final String title;

  /// The icon to display
  final IconData icon;

  /// The background color of the icon container
  final Color backgroundColor;

  /// The color of the icon itself
  final Color iconColor;

  /// The type of action (used for handling tap events)
  final ActionType type;

  /// Whether this item should use gradient background
  final bool useGradient;

  /// Optional gradient colors (if useGradient is true)
  final List<Color>? gradientColors;

  const HomeActionItem({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.type,
    this.useGradient = false,
    this.gradientColors,
  });

  /// Creates a copy of this HomeActionItem with the given fields replaced
  HomeActionItem copyWith({
    String? title,
    IconData? icon,
    Color? backgroundColor,
    Color? iconColor,
    ActionType? type,
    bool? useGradient,
    List<Color>? gradientColors,
  }) {
    return HomeActionItem(
      title: title ?? this.title,
      icon: icon ?? this.icon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      iconColor: iconColor ?? this.iconColor,
      type: type ?? this.type,
      useGradient: useGradient ?? this.useGradient,
      gradientColors: gradientColors ?? this.gradientColors,
    );
  }
}
