# Category Color Palette

## Mục đích
File này chứa bộ 10 cặp màu được thiết kế kỹ lưỡng để sử dụng cho categories trong ứng dụng.

## Cách hoạt động

### 1. Khi thêm category mới
- Hệ thống sẽ **tự động random** một cặp màu từ 10 cặp màu có sẵn
- Người dùng **không được phép** chọn màu thủ công
- Màu được gửi lên API khi tạo category

### 2. Khi sửa category
- Người dùng **không được phép** thay đổi màu
- Màu sẽ được giữ nguyên từ lần tạo ban đầu
- API edit không trả về màu, nên ta giữ lại màu cũ

## Bộ màu

Mỗi cặp màu gồm:
- **Icon Color**: Màu của icon
- **Background Color**: Màu nền

### Danh sách 10 cặp màu:

1. **Blue Theme** - Xanh dương nhẹ nhàng
   - Icon: `#1E88E5`
   - Background: `#E3F2FD`

2. **Green Theme** - Xanh lá tươi mát
   - Icon: `#43A047`
   - Background: `#E8F5E9`

3. **Orange Theme** - Cam ấm áp
   - Icon: `#FB8C00`
   - Background: `#FFF3E0`

4. **Purple Theme** - Tím thanh lịch
   - Icon: `#8E24AA`
   - Background: `#F3E5F5`

5. **Red Theme** - Đỏ nổi bật
   - Icon: `#E53935`
   - Background: `#FFEBEE`

6. **Teal Theme** - Xanh ngọc hiện đại
   - Icon: `#00897B`
   - Background: `#E0F2F1`

7. **Indigo Theme** - Xanh chàm sâu lắng
   - Icon: `#3949AB`
   - Background: `#E8EAF6`

8. **Pink Theme** - Hồng dịu dàng
   - Icon: `#D81B60`
   - Background: `#FCE4EC`

9. **Amber Theme** - Hổ phách ấm cúng
   - Icon: `#FFB300`
   - Background: `#FFF8E1`

10. **Deep Purple Theme** - Tím đậm sang trọng
    - Icon: `#5E35B1`
    - Background: `#EDE7F6`

## API sử dụng

### `CategoryColorPalette.getRandomColorPair()`
Trả về một cặp màu ngẫu nhiên từ bộ 10 cặp màu.

**Sử dụng:**
```dart
final colorPair = CategoryColorPalette.getRandomColorPair();
final iconColorHex = colorPair.iconColorHex;
final bgColorHex = colorPair.backgroundColorHex;
```

### `CategoryColorPalette.getColorPairByIndex(int index)`
Trả về cặp màu tại vị trí index (0-9).

**Sử dụng:**
```dart
final colorPair = CategoryColorPalette.getColorPairByIndex(0); // Blue theme
```

## Lưu ý
- Các màu được thiết kế để đảm bảo tỷ lệ tương phản tốt (accessibility)
- Màu icon đậm, màu nền nhạt để dễ đọc
- Tất cả các cặp màu đều hài hòa và chuyên nghiệp
