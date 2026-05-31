import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key, required this.title});

  static const routeName = '/menu';
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title module is ready for lazy-loaded feature implementation.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
