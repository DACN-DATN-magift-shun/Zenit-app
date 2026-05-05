import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class IconWithCircleBackground extends StatelessWidget {
  const IconWithCircleBackground({
    super.key,
    this.icon = Symbols.help_outline,
    this.size = 56.0,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.borderRadius = 14.0,
  });

  final IconData icon;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final double iconSize = size * 0.6;

    final Widget innerIcon = Icon(
      icon,
      size: iconSize,
      color: iconColor,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: innerIcon,
        ),
      ),
    );
  }
}