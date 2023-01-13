import 'package:flutter/material.dart';
import 'package:noti_buddy/models/app_data.dart';
import 'package:noti_buddy/pages/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppData.instance.then((value) {
    // value.notificationItems.clear();
    // value.save();
    runApp(const MyApp());
  });
  // runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noti Buddy',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MainPage(),
    );
  }
}
