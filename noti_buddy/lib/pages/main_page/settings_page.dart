import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/managers/notification_manager.dart';
import 'package:noti_buddy/models/navigation_screen.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:uuid/uuid.dart';

class SettingsPage extends NavigationScreen {
  const SettingsPage({
    super.key,
    required Function refresh,
  }) : super(refresh: refresh);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Generate random items'),
          subtitle: const Text('Generate 10 random items for testing purposes.'),
          trailing: const Icon(FluentIcons.chevron_right_16_filled),
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
          trailing: const Icon(FluentIcons.chevron_right_16_filled),
          onTap: () {
            NotificationManager.instance.updateAllNotifications();
          },
        )
      ],
    );
  }
}
