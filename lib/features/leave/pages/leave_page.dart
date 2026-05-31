import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hero/core/widgets/feature_placeholder.dart';

class LeavePage extends StatelessWidget {
  const LeavePage({super.key});

  static const String routeName = '/leave';

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Leave',
      icon: PhosphorIconsFill.umbrella,
      accent: Color(0xFF7C3AED),
      description:
          'Ajukan cuti, izin, dan sakit langsung dari sini.\nRiwayat dan status persetujuan juga tersedia.',
    );
  }
}
