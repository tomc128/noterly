import 'package:flutter/material.dart';
import 'package:noterly/extensions/date_time_extensions.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/models/navigation_screen.dart';
import 'package:noterly/models/notification_item.dart';

import '../edit_notification_page.dart';

class ArchivedNotificationsPage extends NavigationScreen {
  final ScrollController scrollController;

  const ArchivedNotificationsPage({
    super.key,
    required this.scrollController,
    required Function refresh,
  }) : super(refresh: refresh);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppManager.instance.notifier,
      builder: (context, value, child) {
        var items = value.where((element) => element.archived).toList();

        if (items.isEmpty) {
          return const Center(
            child: Text('Archived notifications will appear here.'),
          );
        }

        items.sort((a, b) => b.archivedDateTime!.compareTo(a.archivedDateTime!));

        // TODO: rework to allow for card design
        return ListView.builder(
          controller: scrollController,
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return Dismissible(
              key: ValueKey(item.id),
              background: _getDismissibleBackground(context),
              secondaryBackground: _getDismissibleBackground(context, isSecondary: true),
              onDismissed: (direction) {
                AppManager.instance.deleteItem(item.id);
                ScaffoldMessenger.of(context).clearSnackBars(); // Clear any existing snackbars, as only one item can be restored.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Notification deleted.'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => AppManager.instance.restoreLastDeletedItem(),
                    ),
                  ),
                );
              },
              child: ListTile(
                title: Text(item.title),
                subtitle: _getSubtitle(item),
                minVerticalPadding: 12,
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
              ),
            );
          },
        );
      },
    );
  }

  Widget _getDismissibleBackground(BuildContext context, {bool isSecondary = false}) => Container(
        color: Theme.of(context).colorScheme.primary,
        child: Align(
          alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      );

  Widget? _getSubtitle(NotificationItem item) {
    String text = '';
    if (item.body != null && item.body!.isNotEmpty) {
      text += item.body!;
    }

    if (text.isNotEmpty) {
      text += '\n';
    }

    text += 'Archived ${item.archivedDateTime!.toRelativeDateTimeString()}';

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
