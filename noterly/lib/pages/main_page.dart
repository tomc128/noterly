import 'package:flutter/material.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/pages/main_page/active_notifications_page.dart';
import 'package:noterly/pages/main_page/archived_notifications_page.dart';

import 'create_notification_page.dart';
import 'settings_page.dart';

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

  late final List<ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();

    _scrollControllers = [
      _activeNotificationsPageScrollController,
      _archivedNotificationsPageScrollController,
    ];

    _activeNotificationsPageScrollController.addListener(() => setState(() {}));
    _archivedNotificationsPageScrollController.addListener(() => setState(() {}));

    NotificationManager.instance.requestAndroid13Permissions();
  }

  double _getAppBarElevation() {
    var controller = _scrollControllers[_selectedDestination];
    return (controller.hasClients && controller.offset > 0) ? 3.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noterly'),
        elevation: _getAppBarElevation(),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: AppManager.instance.notifier,
        builder: (context, value, child) => PageView(
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (value) {
            setState(() => _selectedDestination = value);
          },
          controller: _pageController,
          children: [
            ActiveNotificationsPage(
              items: value.where((element) => !element.archived).toList(),
              scrollController: _activeNotificationsPageScrollController,
            ),
            ArchivedNotificationsPage(
              items: value.where((element) => element.archived).toList(),
              scrollController: _archivedNotificationsPageScrollController,
            ),
          ],
        ),
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
    );
  }
}
