import 'package:flutter/material.dart';
import 'package:noterly/models/notification_item.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationItem> items;
  final Function onRefresh;
  final String emptyText;
  final Widget? Function(BuildContext, int) itemBuilder;

  const NotificationList({
    required this.items,
    required this.onRefresh,
    required this.emptyText,
    required this.itemBuilder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget emptyListView() {
      return Center(
        child: Text(emptyText),
      );
    }

    return items.isEmpty
        ? emptyListView()
        : ListView.builder(
            itemCount: items.length,
            itemBuilder: itemBuilder,
          );
  }
}
