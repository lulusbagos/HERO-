import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Attendance Rate (ATR) page — professional premium design.
class AttendanceRatePage extends StatefulWidget {
  const AttendanceRatePage({super.key});

  static const String routeName = '/attendance-rate';

  @override
  State<AttendanceRatePage> createState() => _AttendanceRatePageState();
}

class _AttendanceRatePageState extends State<AttendanceRatePage>
    with TickerProviderStateMixin {
  late final AnimationController _arcCtrl;
  late final AnimationController _staggerCtrl;
  late final Animation<double> _arcAnim;

  static const double _rate = 0.88;

  // Mock data — month breakdown
  static const List<_MonthBar> _months = [
    _MonthBar('Jan', 0.95),
    _MonthBar('Feb', 0.91),
    _MonthBar('Mar', 0.88),
    _MonthBar('Apr', 0.93),
    _MonthBar('May', 0.88),
  ];

  static const List<_StatItem> _stats = [
    _StatItem('Hadir', '22', PhosphorIconsFill.checkCircle, Color(0xFF22C55E), Color(0xFFDCFCE7)),
    _StatItem('Terlambat', '2', PhosphorIconsFill.clockCountdown, Color(0xFFF59E0B), Color(0xFFFEF3C7)),
    _StatItem('Izin/Cuti', '1', PhosphorIconsFill.calendar, Color(0xFF8B5CF6), Color(0xFFF5F3FF)),
    _StatItem('Alfa', '0', PhosphorIconsFill.xCircle, Color(0xFFEF4444), Color(0xFFFEF2F2)),
  ];

  // Recent week detail
  static const List<_DayRow> _recent = [
    _DayRow('Senin', '26 Mei', '08:02', '17:05', _RowStatus.hadir),
    _DayRow('Selasa', '27 Mei', '08:14', '17:00', _RowStatus.hadir),
    _DayRow('Rabu', '28 Mei', '09:02', '17:10', _RowStatus.terlambat),
    _DayRow('Kamis', '29 Mei', '08:00', '17:00', _RowStatus.hadir),
    _DayRow('Jumat', '30 Mei', '08:05', '16:30', _RowStatus.hadir),
    _DayRow('Senin', '2 Jun', '—', '—', _RowStatus.libur),
  ];

  @override
  void initState() {
    super.initState();
    _arcCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _arcAnim = CurvedAnimation(parent: _arcCtrl, curve: Curves.easeOutCubic);
    _arcCtrl.forward();
    _staggerCtrl.forward();
  }

  @override
  void dispose() {
    _arcCtrl.dispose();
    _staggerCtrl.dispose();
    super.dispose();
  }

  // ─── palette ─────────────────────────────────────────────────────────────
  static const Color _navy = Color(0xFF0D1C3F);
  static const Color _blue = Color(0xFF156DFF);
  static const Color _muted = Color(0xFF7A8CA5);
  static const Color _bg = Color(0xFFF4F7FD);
  static const Color _card = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildHeroSection()),
          SliverToBoxAdapter(child: _buildStatsGrid()),
          SliverToBoxAdapter(child: _buildTrendSection()),
          SliverToBoxAdapter(child: _buildRecentSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─── app bar ─────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: _card,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(PhosphorIconsRegular.arrowLeft, color: _navy, size: 18),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Attendance Rate',
        style: TextStyle(
          color: _navy,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(PhosphorIconsRegular.export, color: _navy, size: 18),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── hero section (arc gauge) ─────────────────────────────────────────────
  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1863FF), Color(0xFF0A3DB0)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF156DFF).withValues(alpha: 0.38),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'MEI 2026',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Attendance\nRate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '22 dari 25 hari kerja',
                      style: TextStyle(
                        color: Color(0xFFB8D0FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRatingBadge(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildArcGauge(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBadge() {
    const grade = 'A';
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF22C55E).withValues(alpha: 0.50),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(PhosphorIconsFill.trendUp, color: Color(0xFF4ADE80), size: 14),
              SizedBox(width: 5),
              Text(
                'Grade $grade  •  Sangat Baik',
                style: TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArcGauge() {
    return AnimatedBuilder(
      animation: _arcAnim,
      builder: (context, _) {
        return SizedBox(
          width: 130,
          height: 130,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(130, 130),
                painter: _ArcGaugePainter(progress: _arcAnim.value * _rate),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_arcAnim.value * _rate * 100).round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ATR',
                    style: TextStyle(
                      color: Color(0xFFB8D0FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── stats grid ──────────────────────────────────────────────────────────
  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.75,
        ),
        itemCount: _stats.length,
        itemBuilder: (context, index) {
          return _buildStatCard(_stats[index], index);
        },
      ),
    );
  }

  Widget _buildStatCard(_StatItem item, int index) {
    final delay = index * 0.12;
    return AnimatedBuilder(
      animation: _staggerCtrl,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          ((_staggerCtrl.value - delay).clamp(0.0, 1.0 - delay) / (1.0 - delay)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - t)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.value,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── trend chart ─────────────────────────────────────────────────────────
  Widget _buildTrendSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(PhosphorIconsFill.chartBar, color: _blue, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tren Kehadiran',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '5 bulan terakhir',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _arcAnim,
            builder: (context, _) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: _months.map((m) {
                  final barH = 90.0 * m.rate * _arcAnim.value;
                  final isActive = m.label == 'May';
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        children: [
                          Text(
                            '${(m.rate * 100).round()}%',
                            style: TextStyle(
                              color: isActive ? _blue : _muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 800),
                            height: barH,
                            decoration: BoxDecoration(
                              gradient: isActive
                                  ? const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Color(0xFF4D94FF), Color(0xFF156DFF)],
                                    )
                                  : null,
                              color: isActive ? null : const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            m.label,
                            style: TextStyle(
                              color: isActive ? _navy : _muted,
                              fontSize: 12,
                              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─── recent attendance ────────────────────────────────────────────────────
  Widget _buildRecentSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(PhosphorIconsFill.calendarBlank, color: _blue, size: 18),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Riwayat Terkini',
                    style: TextStyle(
                      color: _navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Minggu ini',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._recent.asMap().entries.map((e) => _buildDayRow(e.value, e.key)),
        ],
      ),
    );
  }

  Widget _buildDayRow(_DayRow day, int index) {
    final isLast = index == _recent.length - 1;
    final statusColor = switch (day.status) {
      _RowStatus.hadir => const Color(0xFF22C55E),
      _RowStatus.terlambat => const Color(0xFFF59E0B),
      _RowStatus.libur => const Color(0xFF94A3B8),
    };
    final statusLabel = switch (day.status) {
      _RowStatus.hadir => 'Hadir',
      _RowStatus.terlambat => 'Terlambat',
      _RowStatus.libur => 'Libur',
    };
    final statusBg = switch (day.status) {
      _RowStatus.hadir => const Color(0xFFDCFCE7),
      _RowStatus.terlambat => const Color(0xFFFEF3C7),
      _RowStatus.libur => const Color(0xFFF1F5F9),
    };

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // Day dot
              Column(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Center(
                      child: Text(
                        day.day.substring(0, 3),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${day.day}, ${day.date}',
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (day.status != _RowStatus.libur)
                      Text(
                        'In: ${day.inTime}  •  Out: ${day.outTime}',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(color: Colors.black.withValues(alpha: 0.05), height: 1),
      ],
    );
  }
}

// ─── Arc Gauge Painter ───────────────────────────────────────────────────────
class _ArcGaugePainter extends CustomPainter {
  const _ArcGaugePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    // track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    // progress
    final shader = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + sweepFull * progress,
      colors: const [Color(0xFF7DBCFF), Color(0xFFFFFFFF)],
    ).createShader(Rect.fromCircle(center: center, radius: radius));

    final progressPaint = Paint()
      ..shader = shader
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull * progress,
      false,
      progressPaint,
    );

    // end dot
    if (progress > 0.01) {
      final endAngle = startAngle + sweepFull * progress;
      final dotX = center.dx + radius * math.cos(endAngle);
      final dotY = center.dy + radius * math.sin(endAngle);
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcGaugePainter old) => old.progress != progress;
}

// ─── Data Models ─────────────────────────────────────────────────────────────
class _MonthBar {
  const _MonthBar(this.label, this.rate);
  final String label;
  final double rate;
}

class _StatItem {
  const _StatItem(this.label, this.value, this.icon, this.color, this.bgColor);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bgColor;
}

enum _RowStatus { hadir, terlambat, libur }

class _DayRow {
  const _DayRow(this.day, this.date, this.inTime, this.outTime, this.status);
  final String day;
  final String date;
  final String inTime;
  final String outTime;
  final _RowStatus status;
}
