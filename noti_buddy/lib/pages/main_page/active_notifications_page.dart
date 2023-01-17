import 'package:boxy/slivers.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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

        var immediateItems = items.where((element) => element.dateTime == null).toList();
        var scheduledItems = items.where((element) => element.dateTime != null).toList();

        var immediateWidgets = immediateItems.isEmpty
            ? []
            : [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Shown immediately',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _getItem(context, immediateItems[index]),
                      childCount: immediateItems.length,
                    ),
                  ),
                ),
              ];

        var scheduledWidgets = scheduledItems.isEmpty
            ? []
            : [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Scheduled',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  clipBehavior: Clip.antiAlias,
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _getItem(context, scheduledItems[index]),
                      childCount: scheduledItems.length,
                    ),
                  ),
                ),
              ];

        var emptyWidgets = [
          const SliverToBoxAdapter(
            child: Center(
              child: Text('No active notifications.'),
            ),
          ),
        ];

        return CustomScrollView(
          slivers: [
            ...immediateWidgets,
            if (immediateWidgets.isNotEmpty && scheduledWidgets.isNotEmpty)
              const SliverToBoxAdapter(
                child: SizedBox(height: 16.0),
              ),
            ...scheduledWidgets,
            if (immediateWidgets.isEmpty && scheduledWidgets.isEmpty) ...emptyWidgets,
          ],
        );
      },
    );
  }

  Widget _getItem(BuildContext context, NotificationItem item) => Dismissible(
        key: ValueKey(item.id),
        background: _getDismissibleBackground(context),
        secondaryBackground: _getDismissibleBackground(context, isSecondary: true),
        onDismissed: (direction) {
          AppManager.instance.archiveItem(item.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Notification archived.'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => AppManager.instance.restoreArchivedItem(item.id),
              ),
            ),
          );
        },
        child: ListTile(
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
        ),
      );

  Widget _getDismissibleBackground(BuildContext context, {bool isSecondary = false}) => Container(
        color: Theme.of(context).colorScheme.primary,
        child: Align(
          alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              FluentIcons.archive_16_filled,
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
