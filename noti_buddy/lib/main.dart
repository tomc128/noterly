import 'package:flutter/material.dart';
import 'package:noti_buddy/managers/isolate_manager.dart';
import 'package:noti_buddy/pages/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  IsolateManager.init();

  runApp(const MyApp());
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
