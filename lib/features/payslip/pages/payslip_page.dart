import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:hero/core/widgets/feature_placeholder.dart';

class PayslipPage extends StatelessWidget {
  const PayslipPage({super.key});

  static const String routeName = '/payslip';

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholderPage(
      title: 'Payslip',
      icon: PhosphorIconsFill.money,
      accent: Color(0xFF059669),
      description:
          'Lihat dan unduh slip gaji bulanan Anda.\nRiwayat gaji tersedia hingga 12 bulan terakhir.',
    );
  }
}
