import 'package:flutter/material.dart';
import 'package:noti_buddy/managers/notification_manager.dart';
import 'package:noti_buddy/pages/main_page/active_notifications_page.dart';
import 'package:noti_buddy/pages/main_page/archived_notifications_page.dart';

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
            icon: Icon(Icons.notifications_active),
            label: 'Active',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
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
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      // body: _getPage(_selectedDestination),
      body: PageView(
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
