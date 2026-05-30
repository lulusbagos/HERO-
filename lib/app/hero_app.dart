import 'package:flutter/material.dart';
import 'package:hero/app/app_routes.dart';
import 'package:hero/app/app_theme.dart';

class HeroApp extends StatelessWidget {
  const HeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HERO',
      theme: AppTheme.darkTheme(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
