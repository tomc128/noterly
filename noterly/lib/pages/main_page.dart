import 'package:flutter/material.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/pages/main_page/active_notifications_page.dart';
import 'package:noterly/pages/main_page/archived_notifications_page.dart';
import 'package:noterly/pages/main_page/settings_page.dart';

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

  final ScrollController _activeNotificationsPageScrollController = ScrollController();
  final ScrollController _archivedNotificationsPageScrollController = ScrollController();
  final ScrollController _settingsPageScrollController = ScrollController();

  late final List<ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();

    _scrollControllers = [
      _activeNotificationsPageScrollController,
      _archivedNotificationsPageScrollController,
      _settingsPageScrollController,
    ];

    _activeNotificationsPageScrollController.addListener(() => setState(() {}));
    _archivedNotificationsPageScrollController.addListener(() => setState(() {}));
    _settingsPageScrollController.addListener(() => setState(() {}));

    NotificationManager.instance.requestAndroid13Permissions();
  }

  double _getAppBarElevation() {
    for (int i = 0; i < _scrollControllers.length; i++) {
      if (i != _selectedDestination) {
        continue;
      }

      var controller = _scrollControllers[i];

      if (controller.hasClients && controller.offset > 0) {
        return 3.0;
      }
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        destinations: [
          NavigationDestination(
            icon: Icon(AppManager.instance.notifier.value.where((element) => !element.archived).isNotEmpty ? Icons.notifications_active : Icons.notifications_none),
            label: 'Active',
          ),
          const NavigationDestination(
            icon: Icon(Icons.archive),
            label: 'Archive',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onDestinationSelected: (value) {
          setState(() {
            if (_selectedDestination == value) {
              // Already on this page, scroll to top
              if (_scrollControllers[value].hasClients) {
                _scrollControllers[value].animateTo(
                  0,
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOutCirc,
                );
              }
            } else {
              _selectedDestination = value;
              _pageController.animateToPage(
                value,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCirc,
              );
            }
          });
        },
        selectedIndex: _selectedDestination,
      ),
      appBar: AppBar(
        title: const Text('Noterly'),
        elevation: _getAppBarElevation(),
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (value) {
          setState(() => _selectedDestination = value);
        },
        controller: _pageController,
        children: [
          ActiveNotificationsPage(
            refresh: () => setState(() {}),
            scrollController: _activeNotificationsPageScrollController,
          ),
          ArchivedNotificationsPage(
            refresh: () => setState(() {}),
            scrollController: _archivedNotificationsPageScrollController,
          ),
          SettingsPage(
            refresh: () => setState(() {}),
            scrollController: _settingsPageScrollController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateNotificationPage(),
            ),
          );

          setState(() {});
        },
        label: const Text('Create'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
