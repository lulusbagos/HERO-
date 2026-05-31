import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hero/core/widgets/feature_placeholder.dart';

class HerRegistrationPage extends StatelessWidget {
  const HerRegistrationPage({super.key});

  static const String routeName = '/her-registration';

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Her Registration',
      icon: PhosphorIconsFill.identificationCard,
      accent: Color(0xFF1D4ED8),
      description:
          'Daftarkan atau perbarui data registrasi ulang karyawan.\nDokumen dan formulir tersedia di sini.',
    );
  }
}
