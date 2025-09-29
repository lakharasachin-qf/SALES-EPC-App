import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Parth'),
            accountEmail: Text('9723321270'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(),
            ),
          ),
        ],
      ),
    );
  }
}
