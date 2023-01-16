import 'package:flutter/material.dart';
import 'package:noti_buddy/managers/app_manager.dart';
import 'package:noti_buddy/models/navigation_screen.dart';
import 'package:noti_buddy/widgets/notification_list.dart';

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
        print('Building list');
        return NotificationList(
          items: value,
          onRefresh: () => refresh(),
        );
      },
    );
  }
}
