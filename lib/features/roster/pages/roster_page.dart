import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hero/core/widgets/feature_placeholder.dart';

class RosterPage extends StatelessWidget {
  const RosterPage({super.key});

  static const String routeName = '/roster';

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Roster',
      icon: PhosphorIconsFill.clipboardText,
      accent: Color(0xFF0891B2),
      description:
          'Jadwal kerja mingguan dan bulanan Anda tampil di sini.\nTermasuk shift, libur, dan penugasan khusus.',
    );
  }
}
