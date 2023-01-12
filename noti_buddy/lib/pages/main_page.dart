import 'package:flutter/material.dart';
import 'package:noti_buddy/models/notification_item.dart';

class MainPage extends StatefulWidget {
  final List<NotificationItem> items;

  const MainPage({
    required this.items,
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
        child: ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];

            return ListTile(
              title: Text(item.title),
              subtitle: item.body != null ? Text(item.body!) : null,
              trailing: item.dateTime != null ? Text('${item.dateTime}') : null,
              leading: SizedBox(
                width: 8,
                child: CircleAvatar(
                  backgroundColor: item.colour,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
