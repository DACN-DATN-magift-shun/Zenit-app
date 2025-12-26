import 'dart:math';
import 'package:flutter/material.dart';

/// Cặp màu cho category (icon color và background color)
class CategoryColorPair {
  final Color iconColor;
  final Color backgroundColor;
  final String iconColorHex;
  final String backgroundColorHex;

  const CategoryColorPair({
    required this.iconColor,
    required this.backgroundColor,
    required this.iconColorHex,
    required this.backgroundColorHex,
  });
}

/// Bộ 10 cặp màu được thiết kế kỹ lưỡng, đảm bảo hài hòa
class CategoryColorPalette {
  static const List<CategoryColorPair> colorPairs = [
    // 1. Blue theme - Xanh dương nhẹ nhàng
    CategoryColorPair(
      iconColor: Color(0xFF1E88E5),
      backgroundColor: Color(0xFFE3F2FD),
      iconColorHex: '#1E88E5',
      backgroundColorHex: '#E3F2FD',
    ),
    
    // 2. Green theme - Xanh lá tươi mát
    CategoryColorPair(
      iconColor: Color(0xFF43A047),
      backgroundColor: Color(0xFFE8F5E9),
      iconColorHex: '#43A047',
      backgroundColorHex: '#E8F5E9',
    ),
    
    // 3. Orange theme - Cam ấm áp
    CategoryColorPair(
      iconColor: Color(0xFFFB8C00),
      backgroundColor: Color(0xFFFFF3E0),
      iconColorHex: '#FB8C00',
      backgroundColorHex: '#FFF3E0',
    ),
    
    // 4. Purple theme - Tím thanh lịch
    CategoryColorPair(
      iconColor: Color(0xFF8E24AA),
      backgroundColor: Color(0xFFF3E5F5),
      iconColorHex: '#8E24AA',
      backgroundColorHex: '#F3E5F5',
    ),
    
    // 5. Red theme - Đỏ nổi bật
    CategoryColorPair(
      iconColor: Color(0xFFE53935),
      backgroundColor: Color(0xFFFFEBEE),
      iconColorHex: '#E53935',
      backgroundColorHex: '#FFEBEE',
    ),
    
    // 6. Teal theme - Xanh ngọc hiện đại
    CategoryColorPair(
      iconColor: Color(0xFF00897B),
      backgroundColor: Color(0xFFE0F2F1),
      iconColorHex: '#00897B',
      backgroundColorHex: '#E0F2F1',
    ),
    
    // 7. Indigo theme - Xanh chàm sâu lắng
    CategoryColorPair(
      iconColor: Color(0xFF3949AB),
      backgroundColor: Color(0xFFE8EAF6),
      iconColorHex: '#3949AB',
      backgroundColorHex: '#E8EAF6',
    ),
    
    // 8. Pink theme - Hồng dịu dàng
    CategoryColorPair(
      iconColor: Color(0xFFD81B60),
      backgroundColor: Color(0xFFFCE4EC),
      iconColorHex: '#D81B60',
      backgroundColorHex: '#FCE4EC',
    ),
    
    // 9. Amber theme - Hổ phách ấm cúng
    CategoryColorPair(
      iconColor: Color(0xFFFFB300),
      backgroundColor: Color(0xFFFFF8E1),
      iconColorHex: '#FFB300',
      backgroundColorHex: '#FFF8E1',
    ),
    
    // 10. Deep Purple theme - Tím đậm sang trọng
    CategoryColorPair(
      iconColor: Color(0xFF5E35B1),
      backgroundColor: Color(0xFFEDE7F6),
      iconColorHex: '#5E35B1',
      backgroundColorHex: '#EDE7F6',
    ),
  ];

  /// Random một cặp màu từ bộ palette
  static CategoryColorPair getRandomColorPair() {
    final random = Random();
    final index = random.nextInt(colorPairs.length);
    return colorPairs[index];
  }

  /// Lấy cặp màu theo index (0-9)
  static CategoryColorPair getColorPairByIndex(int index) {
    if (index < 0 || index >= colorPairs.length) {
      return colorPairs[0]; // Default to first color
    }
    return colorPairs[index];
  }
}
