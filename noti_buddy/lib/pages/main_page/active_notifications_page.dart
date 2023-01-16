import 'package:flutter/material.dart';
import 'package:noti_buddy/extensions/date_time_extensions.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/models/navigation_screen.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/pages/edit_notification_page.dart';

class ActiveNotificationsPage extends NavigationScreen {
  const ActiveNotificationsPage({
    super.key,
    required Function refresh,
  }) : super(refresh: refresh);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppManager.instance.notifier,
      builder: (context, value, child) {
        var items = value.where((element) => !element.archived).toList();

        if (items.isEmpty) {
          return const Center(
            child: Text('No active notifications.'),
          );
        }

        items.sort((a, b) {
          if (a.dateTime == null && b.dateTime == null) {
            return a.title.compareTo(b.title);
          } else if (a.dateTime == null) {
            return -1;
          } else if (b.dateTime == null) {
            return 1;
          } else {
            return a.dateTime!.compareTo(b.dateTime!);
          }
        });

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: Text(item.title),
              subtitle: _getSubtitle(item),
              leading: SizedBox(
                width: 32,
                child: Align(
                  alignment: Alignment.center,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: item.colour,
                  ),
                ),
              ),
              onTap: () => _onItemTap(context, item),
            );
          },
        );
      },
    );
  }

  Widget? _getSubtitle(NotificationItem item) {
    String text = '';
    if (item.body != null && item.body!.isNotEmpty) {
      text += item.body!;
    }

    if (item.dateTime != null) {
      if (text.isNotEmpty) {
        text += '\n';
      }

      text += item.dateTime!.toRelativeDateTimeString();
    }

    return text.isEmpty ? null : Text(text);
  }

  void _onItemTap(BuildContext context, NotificationItem item) => Navigator.of(context)
      .push(
        MaterialPageRoute(
          builder: (context) => EditNotificationPage(
            item: item,
          ),
        ),
      )
      .then((value) => refresh());
}
