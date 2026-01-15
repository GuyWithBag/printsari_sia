import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue),
          child: Text(
            'Sidebar Header',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(leading: Icon(Icons.home), title: Text('Home')),
        ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
      ],
    );
  }
}
