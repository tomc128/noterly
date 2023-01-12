import 'package:flutter/material.dart';
import 'package:noti_buddy/models/app_data.dart';
import 'package:noti_buddy/widgets/notification_list.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noti Buddy'),
      ),
      body: Center(
        child: FutureBuilder(
          future: AppData.instance,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }

            return NotificationList(
              items: snapshot.data!.notificationItems,
            );
          },
        ),
      ),
    );
  }
}
