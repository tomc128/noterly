import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/managers/notification_manager.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/pages/main_page/active_notifications_page.dart';
import 'package:noti_buddy/pages/main_page/archived_notifications_page.dart';
import 'package:uuid/uuid.dart';

import 'create_notification_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedDestination = 0;
  final _pageController = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();

    NotificationManager.instance.requestAndroid13Permissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(
            icon: Icon(FluentIcons.alert_16_filled),
            label: 'Active',
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.archive_16_filled),
            label: 'Archive',
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.settings_16_filled),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            _selectedDestination = value;
            _pageController.animateToPage(
              value,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCirc,
            );
          });
        },
        selectedIndex: _selectedDestination,
      ),
      appBar: AppBar(
        title: const Text('Noti Buddy'),
        actions: [
          IconButton(
            onPressed: () async {
              NotificationManager.instance.updateAllNotifications();
            },
            icon: const Icon(FluentIcons.alert_badge_16_filled),
          ),
          IconButton(
            onPressed: () {
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
            icon: const Icon(FluentIcons.list_16_filled),
          ),
        ],
      ),
      // body: _getPage(_selectedDestination),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) {
          setState(() => _selectedDestination = value);
        },
        controller: _pageController,
        children: [
          ActiveNotificationsPage(
            refresh: () => setState(() {}),
          ),
          ArchivedNotificationsPage(
            refresh: () => setState(() {}),
          ),
          const Placeholder(),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateNotificationPage(),
            ),
          );

          setState(() {});
        },
        child: const Icon(FluentIcons.add_16_filled),
      ),
    );
  }
}
