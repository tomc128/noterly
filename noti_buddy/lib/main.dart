import 'package:flutter/material.dart';
import 'package:noti_buddy/models/notification_item.dart';
import 'package:noti_buddy/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noti Buddy',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MainPage(
        items: [
          NotificationItem(
            title: 'Test',
            colour: Colors.red,
          ),
          NotificationItem(
            title: 'Test',
            body: 'Test body',
            colour: Colors.green,
          ),
          NotificationItem(
            title: 'Test',
            body: 'Test body',
            dateTime: DateTime.now().add(const Duration(days: 7)),
            colour: Colors.blue,
          ),
        ],
      ),
    );
  }
}
