import 'package:flutter/material.dart';
import 'package:noterly/extensions/date_time_extensions.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/models/navigation_screen.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:noterly/pages/edit_notification_page.dart';

class ActiveNotificationsPage extends NavigationScreen {
  final ScrollController scrollController;
  final List<NotificationItem> items;

  const ActiveNotificationsPage({
    super.key,
    required this.items,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
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

    var immediateItems = items.where((element) => element.dateTime == null && !element.isRepeating).toList();
    var scheduledItems = items.where((element) => element.dateTime != null && !element.isRepeating).toList();
    var repeatingItems = items.where((element) => element.isRepeating).toList();

    var immediateWidgets = immediateItems.isEmpty
        ? []
        : [
            _getListHeader(context, 'Shown immediately'),
            _getCard(context, immediateItems),
          ];

    var scheduledWidgets = scheduledItems.isEmpty
        ? []
        : [
            _getListHeader(context, 'Scheduled'),
            _getCard(context, scheduledItems),
          ];

    var repeatingWidgets = repeatingItems.isEmpty
        ? []
        : [
            _getListHeader(context, 'Repeating'),
            _getCard(context, repeatingItems),
          ];

    var emptyWidgets = [
      const SliverToBoxAdapter(
        child: Center(
          child: Text('No active notifications.'),
        ),
      ),
    ];

    bool isEmpty = immediateWidgets.isEmpty && scheduledWidgets.isEmpty && repeatingWidgets.isEmpty;

    var widgets = isEmpty
        ? emptyWidgets
        : [
            ...immediateWidgets,
            if (immediateWidgets.isNotEmpty && scheduledWidgets.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            ...scheduledWidgets,
            if (scheduledWidgets.isNotEmpty && repeatingWidgets.isNotEmpty) const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            ...repeatingWidgets,
          ];

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        ...widgets,
        const SliverToBoxAdapter(child: SizedBox(height: 86)), // Add some padding at the bottom so the FAB doesn't overlap with the last item
      ],
    );
  }

  Widget _getListHeader(BuildContext context, String title) => SliverToBoxAdapter(
        child: ListTile(
          title: Text(title),
        ),
      );

  Widget _getCard(BuildContext context, List<NotificationItem> items) => SliverToBoxAdapter(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          elevation: 1,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++)
                if (i == items.length - 1) _getItem(context, items[i]) else _wrapItem(context, _getItem(context, items[i])),
            ],
          ),
        ),
      );

  Widget _wrapItem(BuildContext context, Widget child) => Column(
        children: [
          child,
          Divider(
            thickness: 2,
            height: 2,
            color: Theme.of(context).colorScheme.background,
          ),
        ],
      );

  Widget _getItem(BuildContext context, NotificationItem item) => Dismissible(
        key: ValueKey(item.id),
        background: _getDismissibleBackground(context),
        secondaryBackground: _getDismissibleBackground(context, isSecondary: true),
        onDismissed: (direction) {
          AppManager.instance.archiveItem(item.id);
          ScaffoldMessenger.of(context).clearSnackBars(); // Prevents multiple snackbars from building up
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
          subtitle: _getSubtitle(context, item),
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

  Widget _getDismissibleBackground(BuildContext context, {bool isSecondary = false}) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Align(
          alignment: isSecondary ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.archive,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      );

  Widget? _getSubtitle(BuildContext context, NotificationItem item) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.body != null && item.body!.isNotEmpty) Text(item.body!),
          if (item.body != null && (item.dateTime != null || item.isRepeating)) const SizedBox(height: 4),
          if (item.dateTime != null)
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(item.dateTime!.toRelativeDateTimeString(), style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          if (item.isRepeating)
            Row(
              children: [
                const Icon(Icons.repeat, size: 16),
                const SizedBox(width: 8),
                Text('Repeats ${item.repetitionData!.toReadableString()}', style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
        ],
      );

  void _onItemTap(BuildContext context, NotificationItem item) => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => EditNotificationPage(
            item: item,
          ),
        ),
      );
}
