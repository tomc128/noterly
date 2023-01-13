import 'package:flutter/material.dart';
import 'package:noti_buddy/models/app_data.dart';
import 'package:noti_buddy/widgets/notification_list.dart';

import 'create_notification_page.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (context) => const CreateNotificationPage(),
                ),
              )
              .then((value) => setState(() {})); // Refresh the list
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
