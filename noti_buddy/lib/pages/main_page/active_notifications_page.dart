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

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return ListTile(
              title: Text(item.title),
              subtitle: item.body != null ? Text(item.body!) : null,
              trailing: item.dateTime != null ? Text(item.dateTime!.toDateTimeString()) : null,
              leading: SizedBox(
                width: 8,
                child: CircleAvatar(
                  backgroundColor: item.colour,
                ),
              ),
              onTap: () => _onItemTap(context, item),
            );
          },
        );
      },
    );
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
