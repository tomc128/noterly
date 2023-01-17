import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:noti_buddy/managers/notification_manager.dart';
import 'package:noti_buddy/pages/main_page/active_notifications_page.dart';
import 'package:noti_buddy/pages/main_page/archived_notifications_page.dart';
import 'package:noti_buddy/pages/main_page/settings_page.dart';

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
          SettingsPage(
            refresh: () => setState(() {}),
          ),
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
