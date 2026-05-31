import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hero/core/widgets/feature_placeholder.dart';

class MealAttendancePage extends StatelessWidget {
  const MealAttendancePage({super.key});

  static const String routeName = '/meal-attendance';

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Absen Makan',
      icon: PhosphorIconsFill.forkKnife,
      accent: Color(0xFF16A34A),
      description:
          'Catat kehadiran makan siang harian Anda.\nData digunakan untuk laporan konsumsi kantor.',
    );
  }
}
