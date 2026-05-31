import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum AttendanceRecordType { checkIn, checkOut }

class AttendanceRecord {
  const AttendanceRecord({required this.date, required this.type, required this.time, required this.location});
  final DateTime date;
  final AttendanceRecordType type;
  final String time;
  final String location;
}

class _P {
  static const navy      = Color(0xFF061B49);
  static const blue      = Color(0xFF156DFF);
  static const softBlue  = Color(0xFFEAF2FF);
  static const muted     = Color(0xFF718096);
  static const green     = Color(0xFF16A75C);
  static const softGreen = Color(0xFFECFDF5);
  static const red       = Color(0xFFE24C4B);
  static const softRed   = Color(0xFFFFF1F1);
  static const bg        = Color(0xFFF3F7FF);
  static const card      = Color(0xFFFFFFFF);
}

class AttendanceCalendarPage extends StatefulWidget {
  const AttendanceCalendarPage({super.key, required this.records});
  static const String routeName = '/attendance/calendar';
  final List<AttendanceRecord> records;
  @override
  State<AttendanceCalendarPage> createState() => _AttendanceCalendarPageState();
}

class _AttendanceCalendarPageState extends State<AttendanceCalendarPage>
    with SingleTickerProviderStateMixin {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  late AnimationController _detailAnim;
  late Animation<double> _detailFade;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay  = DateTime.now();
    _detailAnim   = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
    _detailFade   = CurvedAnimation(parent: _detailAnim, curve: Curves.easeOut);
    _detailAnim.forward();
  }

  @override
  void dispose() { _detailAnim.dispose(); super.dispose(); }

  List<AttendanceRecord> _recordsForDay(DateTime day) => widget.records
      .where((r) => r.date.year == day.year && r.date.month == day.month && r.date.day == day.day)
      .toList()..sort((a, b) => a.time.compareTo(b.time));

  List<DateTime> _daysInMonth(DateTime m) {
    final last = DateTime(m.year, m.month + 1, 0);
    return List.generate(last.day, (i) => DateTime(m.year, m.month, i + 1));
  }

  void _selectDay(DateTime day) {
    setState(() => _selectedDay = day);
    _detailAnim.forward(from: 0);
  }

  int get _monthPresent {
    return _daysInMonth(_focusedMonth).where((d) => _recordsForDay(d).isNotEmpty).length;
  }

  String _avgTime(AttendanceRecordType type) {
    final list = widget.records.where((r) => r.type == type &&
        r.date.year == _focusedMonth.year && r.date.month == _focusedMonth.month).toList();
    if (list.isEmpty) return '--:--';
    final total = list.fold<int>(0, (s, r) {
      final p = r.time.split(':');
      return s + int.parse(p[0]) * 60 + int.parse(p[1]);
    });
    final avg = total ~/ list.length;
    return '${(avg ~/ 60).toString().padLeft(2, '0')}:${(avg % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay;
    final records  = selected != null ? _recordsForDay(selected) : <AttendanceRecord>[];
    final checkIn  = records.where((r) => r.type == AttendanceRecordType.checkIn).firstOrNull;
    final checkOut = records.where((r) => r.type == AttendanceRecordType.checkOut).firstOrNull;
    return Scaffold(
      backgroundColor: _P.bg,
      body: SafeArea(
        child: Column(children: [
          _buildAppBar(context),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 16),
              _buildSummaryRow(),
              const SizedBox(height: 14),
              _buildCalendarCard(),
              const SizedBox(height: 18),
              if (selected != null)
                FadeTransition(opacity: _detailFade,
                    child: _buildDetailPanel(selected, checkIn, checkOut)),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      child: Row(children: [
        _BackBtn(onTap: () => Navigator.of(context).maybePop()),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Riwayat Absensi',
              style: TextStyle(color: _P.navy, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.4)),
          Text(DateFormat('MMMM yyyy').format(_focusedMonth),
              style: const TextStyle(color: _P.muted, fontSize: 13, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  Widget _buildSummaryRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: _P.card, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _P.navy.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))]),
      child: Row(children: [
        _SummaryChip(icon: Icons.calendar_today_rounded, label: 'Hadir', value: '$_monthPresent', color: _P.blue, bg: _P.softBlue),
        const SizedBox(width: 10),
        _SummaryChip(icon: Icons.login_rounded, label: 'Avg In', value: _avgTime(AttendanceRecordType.checkIn), color: _P.green, bg: _P.softGreen),
        const SizedBox(width: 10),
        _SummaryChip(icon: Icons.logout_rounded, label: 'Avg Out', value: _avgTime(AttendanceRecordType.checkOut), color: _P.red, bg: _P.softRed),
      ]),
    );
  }

  Widget _buildCalendarCard() {
    final days    = _daysInMonth(_focusedMonth);
    final leading = days.first.weekday == 7 ? 0 : days.first.weekday;
    return Container(
      decoration: BoxDecoration(color: _P.card, borderRadius: BorderRadius.circular(28),
          boxShadow: [BoxShadow(color: _P.navy.withValues(alpha: 0.07), blurRadius: 24, offset: const Offset(0, 8))]),
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        Row(children: [
          _NavBtn(icon: Icons.chevron_left_rounded,
              onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1))),
          Expanded(child: Text(DateFormat('MMMM yyyy').format(_focusedMonth),
              textAlign: TextAlign.center,
              style: const TextStyle(color: _P.navy, fontSize: 15, fontWeight: FontWeight.w900))),
          _NavBtn(icon: Icons.chevron_right_rounded,
              onTap: () => setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1))),
        ]),
        const SizedBox(height: 14),
        Row(children: ['Mo','Tu','We','Th','Fr','Sa','Su'].map((d) => Expanded(
            child: Text(d, textAlign: TextAlign.center,
                style: const TextStyle(color: _P.muted, fontSize: 11.5, fontWeight: FontWeight.w700)))).toList()),
        const SizedBox(height: 8),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 0.82),
          itemCount: leading + days.length,
          itemBuilder: (ctx, i) {
            if (i < leading) return const SizedBox();
            final day       = days[i - leading];
            final recs      = _recordsForDay(day);
            final hasIn     = recs.any((r) => r.type == AttendanceRecordType.checkIn);
            final hasOut    = recs.any((r) => r.type == AttendanceRecordType.checkOut);
            final isSel     = _selectedDay != null &&
                _selectedDay!.year == day.year && _selectedDay!.month == day.month && _selectedDay!.day == day.day;
            final isToday   = day.year == DateTime.now().year && day.month == DateTime.now().month && day.day == DateTime.now().day;
            final isWeekend = day.weekday == 6 || day.weekday == 7;
            return GestureDetector(
              onTap: () => _selectDay(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180), margin: const EdgeInsets.all(1.5),
                decoration: BoxDecoration(
                  color: isSel ? _P.blue : isToday ? _P.softBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: isToday && !isSel ? Border.all(color: _P.blue.withValues(alpha: 0.35), width: 1.2) : null,
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${day.day}', style: TextStyle(
                    color: isSel ? Colors.white : isToday ? _P.blue : isWeekend ? _P.muted : _P.navy,
                    fontSize: 13, fontWeight: isSel || isToday ? FontWeight.w800 : FontWeight.w600)),
                  const SizedBox(height: 2),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (hasIn)  _Dot(color: isSel ? Colors.white : _P.green),
                    if (hasOut) _Dot(color: isSel ? Colors.white.withValues(alpha: 0.7) : _P.red),
                    if (!hasIn && !hasOut) const SizedBox(width: 8, height: 5),
                  ]),
                ]),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _LegendDot(color: _P.green, label: 'Check In'),
          const SizedBox(width: 16),
          _LegendDot(color: _P.red, label: 'Check Out'),
        ]),
      ]),
    );
  }

  Widget _buildDetailPanel(DateTime day, AttendanceRecord? checkIn, AttendanceRecord? checkOut) {
    final dayLabel  = DateFormat('EEEE').format(day);
    final dateLabel = DateFormat('d MMMM yyyy').format(day);
    final records   = _recordsForDay(day);
    String? duration;
    if (checkIn != null && checkOut != null) {
      final ip   = checkIn.time.split(':');
      final op   = checkOut.time.split(':');
      final diff = (int.parse(op[0]) * 60 + int.parse(op[1])) - (int.parse(ip[0]) * 60 + int.parse(ip[1]));
      if (diff > 0) { final h = diff ~/ 60; final m = diff % 60; duration = h > 0 ? '${h}j ${m}m' : '${m}m'; }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(dayLabel, style: const TextStyle(color: _P.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(dateLabel, style: const TextStyle(color: _P.navy, fontSize: 16, fontWeight: FontWeight.w900)),
        ])),
        if (duration != null)
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: _P.softBlue, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.timer_rounded, color: _P.blue, size: 14), const SizedBox(width: 4),
              Text(duration, style: const TextStyle(color: _P.blue, fontSize: 12, fontWeight: FontWeight.w800)),
            ]))
        else if (records.isEmpty)
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(12)),
            child: const Text('Tidak ada data', style: TextStyle(color: _P.muted, fontSize: 11.5, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 12),
      if (records.isEmpty) _EmptyDay()
      else Row(children: [
        Expanded(child: _TimeCard(label: 'Check In', time: checkIn?.time ?? '--:--',
            color: _P.green, bg: _P.softGreen, icon: Icons.login_rounded, available: checkIn != null)),
        const SizedBox(width: 10),
        Expanded(child: _TimeCard(label: 'Check Out', time: checkOut?.time ?? '--:--',
            color: _P.red, bg: _P.softRed, icon: Icons.logout_rounded, available: checkOut != null)),
      ]),
      if (records.isNotEmpty) ...[
        const SizedBox(height: 10),
        _LocationStrip(location: (checkIn ?? checkOut)!.location),
      ],
    ]);
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({required this.label, required this.time, required this.color,
      required this.bg, required this.icon, required this.available});
  final String label; final String time; final Color color;
  final Color bg; final IconData icon; final bool available;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _P.card, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _P.navy.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 34, height: 34,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        available
            ? Text(time, style: const TextStyle(color: _P.navy, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5))
            : const Text('--', style: TextStyle(color: _P.muted, fontSize: 28, fontWeight: FontWeight.w300)),
        const SizedBox(height: 4),
        const Text('WIB', style: TextStyle(color: _P.muted, fontSize: 11, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _LocationStrip extends StatelessWidget {
  const _LocationStrip({required this.location});
  final String location;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: _P.card, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _P.navy.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(width: 36, height: 36,
            decoration: BoxDecoration(color: _P.softBlue, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.location_on_rounded, color: _P.blue, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Lokasi', style: TextStyle(color: _P.muted, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(location, style: const TextStyle(color: _P.navy, fontSize: 13.5, fontWeight: FontWeight.w800)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _P.softGreen, borderRadius: BorderRadius.circular(8)),
            child: const Text('Verified', style: TextStyle(color: _P.green, fontSize: 10.5, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(color: _P.card, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: _P.navy.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Column(children: [
        Icon(Icons.event_busy_rounded, size: 36, color: Colors.grey.shade300),
        const SizedBox(height: 8),
        const Text('Tidak ada absensi di hari ini',
            style: TextStyle(color: _P.muted, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.icon, required this.label, required this.value, required this.color, required this.bg});
  final IconData icon; final String label; final String value; final Color color; final Color bg;
  @override
  Widget build(BuildContext context) {
    return Expanded(child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 16), const SizedBox(height: 5),
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: _P.muted, fontSize: 9.5, fontWeight: FontWeight.w600)),
      ]),
    ));
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 0.8),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color; final String label;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 5),
    Text(label, style: const TextStyle(color: _P.muted, fontSize: 11, fontWeight: FontWeight.w600)),
  ]);
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: _P.softBlue, borderRadius: BorderRadius.circular(10),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10),
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, color: _P.blue, size: 20))));
}

class _BackBtn extends StatelessWidget {
  const _BackBtn({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: _P.card, borderRadius: BorderRadius.circular(16),
    child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(16),
      child: Container(width: 48, height: 48,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8EEF7)),
          boxShadow: [BoxShadow(color: _P.navy.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 3))]),
        child: const Icon(Icons.arrow_back_rounded, color: _P.navy, size: 20))));
}