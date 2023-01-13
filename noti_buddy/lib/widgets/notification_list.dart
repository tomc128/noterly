import 'package:flutter/material.dart';
import 'package:noti_buddy/extensions/date_time_extensions.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/pages/edit_notification_page.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationItem> items;
  final Function onRefresh;

  const NotificationList({
    required this.items,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget emptyListView() {
      return const Center(
        child: Text('No notifications found, create one!'),
      );
    }

    return items.isEmpty
        ? emptyListView()
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return ListTile(
                title: Text(item.title),
                subtitle: item.body != null ? Text(item.body!) : null,
                trailing: item.dateTime != null
                    ? Text(item.dateTime!.toDateTimeString())
                    : null,
                leading: SizedBox(
                  width: 8,
                  child: CircleAvatar(
                    backgroundColor: item.colour,
                  ),
                ),
                onTap: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                          builder: (context) => EditNotificationPage(
                            item: item,
                          ),
                        ),
                      )
                      .then((value) => onRefresh());
                },
              );
            },
          );
  }
}
