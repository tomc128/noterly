import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:noterly/managers/app_manager.dart';
import 'package:noterly/managers/notification_manager.dart';
import 'package:noterly/pages/main_page/active_notifications_page.dart';
import 'package:noterly/pages/main_page/archived_notifications_page.dart';

import '../managers/log.dart';
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

  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      setState(() {}); // Rebuild so that relative times are updated
    });

    _scrollControllers = [
      _activeNotificationsPageScrollController,
      _archivedNotificationsPageScrollController,
    ];

    _activeNotificationsPageScrollController.addListener(() => setState(() {}));
    _archivedNotificationsPageScrollController.addListener(() => setState(() {}));

    NotificationManager.instance.requestAndroid13Permissions();

    // Ensure app manager has been initialised, then update notifications
    AppManager.instance.ensureInitialised().then((value) => NotificationManager.instance.updateAllNotifications());
  }

  @override
  void dispose() {
    _timer.cancel();

    super.dispose();
  }

  double _getAppBarElevation() {
    var controller = _scrollControllers[_selectedDestination];
    return (controller.hasClients && controller.offset > 0) ? 3.0 : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: AppManager.instance.notifier,
      builder: (context, value, child) {
        var activeNotifications = value.where((element) => !element.archived).toList();
        var archivedNotifications = value.where((element) => element.archived).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Noterly'),
            elevation: _getAppBarElevation(),
            actions: [
              IconButton(
                onPressed: () async {
                  await FirebaseAnalytics.instance.logEvent(name: 'test');
                  Log.logger.d('Analytics event sent');
                },
                icon: const Icon(Icons.analytics),
              ),
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
          body: PageView(
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (value) {
              setState(() => _selectedDestination = value);
            },
            controller: _pageController,
            children: [
              ActiveNotificationsPage(
                items: activeNotifications,
                scrollController: _activeNotificationsPageScrollController,
              ),
              ArchivedNotificationsPage(
                items: archivedNotifications,
                scrollController: _archivedNotificationsPageScrollController,
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
          bottomNavigationBar: NavigationBar(
            destinations: [
              NavigationDestination(
                icon: Badge.count(
                  isLabelVisible: activeNotifications.isNotEmpty,
                  count: activeNotifications.length,
                  child: Icon(activeNotifications.isNotEmpty ? Icons.notifications : Icons.notifications_none),
                ),
                label: 'Active',
              ),
              const NavigationDestination(
                icon: Icon(Icons.history),
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
      },
    );
  }
}