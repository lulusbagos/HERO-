import 'package:flutter/material.dart';

class AppMenuItem {
  const AppMenuItem({
    required this.title,
    required this.route,
    required this.icon,
  });

  final String title;
  final String route;
  final IconData icon;
}
