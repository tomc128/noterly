import 'dart:math';

import 'package:flutter/material.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/models/navigation_screen.dart';
import 'package:noterly/models/notification_item.dart';
import 'package:uuid/uuid.dart';

class SettingsPage extends NavigationScreen {
  final ScrollController scrollController;

  const SettingsPage({
    super.key,
    required Function refresh,
    required this.scrollController,
  }) : super(refresh: refresh);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      children: [
        _getHeader('Debug options'),
        _getCard(context, [
          ListTile(
            title: const Text('Generate random items'),
            subtitle: const Text('Generate 10 random items for testing purposes.'),
            trailing: const Icon(Icons.chevron_right),
            minVerticalPadding: 12,
            onTap: () {
              String randomString() {
                const chars = 'abcdefghijklmnopqrstuvwxyz';
                return List.generate(10, (index) => chars[Random().nextInt(chars.length)]).join();
              }

              for (var i = 0; i < 10; i++) {
                bool shouldHaveBody = Random().nextBool();
                bool shouldBeScheduled = Random().nextBool();

                DateTime? scheduledTime = shouldBeScheduled ? DateTime.now().add(Duration(days: Random().nextInt(10) + 1)) : null;
                Color colour = Colors.primaries[Random().nextInt(Colors.primaries.length)];

                var item = NotificationItem(
                  id: const Uuid().v4(),
                  title: randomString(),
                  body: shouldHaveBody ? randomString() : null,
                  dateTime: shouldBeScheduled ? scheduledTime : null,
                  colour: colour,
                );
                AppManager.instance.addItem(item);
              }
            },
          ),
          ListTile(
            title: const Text('Resend notifications'),
            subtitle: const Text('Force all notifications to be reset.'),
            trailing: const Icon(Icons.chevron_right),
            minVerticalPadding: 12,
            onTap: () {
              NotificationManager.instance.forceUpdateAllNotifications();
            },
          ),
        ]),
      ],
    );
  }

  Widget _getCard(BuildContext context, List<Widget> children) => Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        shadowColor: Colors.transparent,
        child: Column(
          children: children.expand((child) => [child, _getDivider(context)]).take(children.length * 2 - 1).toList(),
        ),
      );

  Widget _getHeader(String title) => ListTile(title: Text(title));

  Widget _getSpacer() => const SizedBox(height: 16);

  Widget _getDivider(BuildContext context) => Divider(
        thickness: 2,
        height: 2,
        color: Theme.of(context).colorScheme.background,
      );
}
