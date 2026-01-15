import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: const <Widget>[
        ListTile(leading: Icon(Icons.home), title: Text('Home')),
        ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
      ],
    );
  }
}
