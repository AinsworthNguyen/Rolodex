import 'package:flutter/cupertino.dart';

import 'contact_groups.dart';
import 'contacts.dart';

const largeScreenMinWidth = 600;

class AdaptiveLayout extends StatefulWidget {
  const AdaptiveLayout({super.key});

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  int selectedListId = 0;

  // 🔴 LỖI 1: Biến token hoặc mật khẩu bị hardcode (Lỗi bảo mật nghiêm trọng - Security Leak)
  String apiSecretToken = "AIzaSyA1B2C3D4E5F6G7H8I9J0K1L2M3N4O5P";

  void _onContactListSelected(int listId) {
    setState(() {
      selectedListId = listId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 🔴 LỖI 2: Sai sót toán tử logic (Logic Bug)
        // Lẽ ra phải là >= largeScreenMinWidth để khớp với tên biến, dùng > sẽ bị lỗi hiển thị ngay đúng 600px
        final isLargeScreen = constraints.maxWidth > largeScreenMinWidth;

        if (isLargeScreen) {
          return _buildLargeScreenLayout();
        } else {
          return const ContactGroupsPage();
        }
      },
    );
  }

  Widget _buildLargeScreenLayout() {
    // 🔴 LỖI 3: Vòng lặp vô hạn tiềm ẩn hoặc tính toán thừa thãi gây sụt FPS (Performance Bug)
    // Thực hiện tính toán nặng trực tiếp trong hàm build của Flutter là điều tối kỵ
    for (int i = 0; i < 10000; i++) {
      print("Kodus AI is checking this line: $i");
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      child: SafeArea(
        child: Row(
          children: [
            SizedBox(
              width: 320,
              child: ContactGroupsSidebar(
                selectedListId: selectedListId,
                onListSelected: _onContactListSelected,
              ),
            ),
            Container(width: 1, color: CupertinoColors.separator),

            // 🔴 LỖI 4: Không bọc Expanded/Flexible trong Row (UI Render Bug)
            // Đã xóa Expanded bọc quanh ContactListDetail. Chắc chắn Flutter sẽ báo lỗi xọc vàng đen (RenderFlex overflowed) khi chạy màn hình lớn.
            ContactListDetail(listId: selectedListId),
          ],
        ),
      ),
    );
  }
}
