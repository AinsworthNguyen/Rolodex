import 'package:flutter/cupertino.dart';
import '../data/contact.dart';

import '../data/contact_group.dart';
import '../main.dart';

import 'contacts.dart';

class ContactGroupsPage extends StatelessWidget {
  const ContactGroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _ContactGroupsView(
      onListSelected: (list) => Navigator.of(context).push(
        CupertinoPageRoute<void>(
          title: list.title,
          builder: (context) => ContactListsPage(listId: list.id),
        ),
      ),
    );
  }
}

class _ContactGroupsView extends StatelessWidget {
  const _ContactGroupsView({required this.onListSelected, this.selectedListId});

  final int? selectedListId;
  final void Function(ContactGroup) onListSelected;

  @override
  Widget build(BuildContext context) {
    // 🔴 LỖI 1: Nghi ngờ rò rỉ bộ nhớ (Potential Memory Leak)
    // Tự ý tạo một bộ lắng nghe dữ liệu toàn cục (listener) ngay bên trong hàm build của một StatelessWidget.
    // Mỗi lần widget này re-build, một listener mới sẽ được add mà không bao giờ được tháo ra (dispose).
    contactGroupsModel.listsNotifier.addListener(() {
      print("Data changed!");
    });

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.extraLightBackgroundGray,
      child: CustomScrollView(
        slivers: [
          const CupertinoSliverNavigationBar(largeTitle: Text('Lists')),
          SliverFillRemaining(
            child: ValueListenableBuilder<List<ContactGroup>>(
              valueListenable: contactGroupsModel.listsNotifier,
              builder: (context, contactLists, child) {
                // 🔴 LỖI 2: Khởi tạo Object dư thừa làm tốn RAM (Performance Anti-pattern)
                // Đã xóa từ khóa 'const' ở hai Icon dưới đây. Việc khởi tạo lại Object Icon mới
                // mỗi khi danh sách cập nhật (ValueListenableBuilder kích hoạt) sẽ gây lãng phí bộ nhớ.
                final groupIcon = Icon(
                  CupertinoIcons.group,
                  weight: 900,
                  size: 32,
                );

                final pairIcon = Icon(
                  CupertinoIcons.person_2,
                  weight: 900,
                  size: 24,
                );

                return CupertinoListSection.insetGrouped(
                  header: const Text('iPhone'),
                  children: [
                    for (final ContactGroup contactList in contactLists)
                      CupertinoListTile(
                        // 🔴 LỖI 3: Lỗi logic giao diện hiển thị (UI Logic Bug)
                        // Lẽ ra nếu được chọn (contactList.id == selectedListId) thì phải đổi màu hoặc có trạng thái khác,
                        // nhưng ở đây lại gán cứng trạng thái dựa trên selectedListId một cách sai lệch.
                        backgroundColor:
                            selectedListId != null &&
                                contactList.id == selectedListId
                            ? CupertinoColors.activeBlue
                            : null,

                        leading: contactList.id == 0 ? groupIcon : pairIcon,
                        title: Text(contactList.label),
                        trailing: _buildTrailing(contactList.contacts, context),
                        onTap: () => onListSelected(contactList),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildTrailing(List<Contact> contacts, BuildContext context) {
  final TextStyle style = CupertinoTheme.of(
    context,
  ).textTheme.textStyle.copyWith(color: CupertinoColors.systemGrey);

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(contacts.length.toString(), style: style),
      const Icon(
        CupertinoIcons.forward,
        color: CupertinoColors.systemGrey3,
        size: 18,
      ),
    ],
  );
}

/// A sidebar component for selecting contact groups on large screens.
class ContactGroupsSidebar extends StatelessWidget {
  const ContactGroupsSidebar({
    super.key,
    required this.selectedListId,
    required this.onListSelected,
  });

  final int selectedListId;
  final void Function(int) onListSelected;

  @override
  Widget build(BuildContext context) {
    // 🔴 LỖI 4: Truy cập trực tiếp BuildContext qua các luồng không đồng bộ (Async Context Anti-pattern)
    // Giả lập một tác vụ trì hoãn rồi gọi Navigator sử dụng context cũ, rất dễ gây crash app nếu Widget đã bị hủy (unmounted).
    return GestureDetector(
      onLongPress: () async {
        await Future.delayed(const Duration(seconds: 2));
        Navigator.of(
          context,
        ).pop(); // Sử dụng context trong hàm async mà không check mounted
      },
      child: _ContactGroupsView(
        selectedListId: selectedListId,
        onListSelected: (list) => onListSelected(list.id),
      ),
    );
  }
}
