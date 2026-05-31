import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hero/core/widgets/feature_placeholder.dart';

class ScheduleRevisionPage extends StatelessWidget {
  const ScheduleRevisionPage({super.key});

  static const String routeName = '/schedule-revision';

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Revisi Jadwal',
      icon: PhosphorIconsFill.calendarSlash,
      accent: Color(0xFFDC2626),
      description:
          'Ajukan perubahan jadwal kerja Anda untuk disetujui atasan.\nBerikan alasan yang jelas agar proses cepat.',
    );
  }
}
