import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'attendance_calendar_page.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  static const String routeName = '/attendance';

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

enum AttendanceType { checkIn, checkOut }

class _AttendancePageState extends State<AttendancePage> {
  static const MethodChannel _locationChannel =
      MethodChannel('hero/location_security');

  static const Color navy = Color(0xFF061B49);
  static const Color blue = Color(0xFF156DFF);
  static const Color softBlue = Color(0xFFEAF2FF);
  static const Color mutedText = Color(0xFF718096);
  static const Color green = Color(0xFF16A75C);
  static const Color orange = Color(0xFFF59E0B);

  static const double officeLat = -6.2088;
  static const double officeLng = 106.8456;

  /// Geofence polygon — titik-titik yang membentuk area absensi yang valid
  static const List<LatLng> officePolygon = [
    LatLng(-6.2081, 106.8449), // NW
    LatLng(-6.2081, 106.8463), // NE
    LatLng(-6.2088, 106.8467), // E
    LatLng(-6.2095, 106.8463), // SE
    LatLng(-6.2095, 106.8449), // SW
    LatLng(-6.2088, 106.8445), // W
  ];

  double userLat = -6.2092;
  double userLng = 106.8450;

  AttendanceType selectedType = AttendanceType.checkIn;

  bool isLoadingLocation = false;
  bool isWithinArea = false;
  bool isLocationTrusted = false;

  String trustMessage = 'Checking location integrity...';
  List<String> trustFlags = <String>[];
  double distanceToOfficeMeter = 0;
  String currentTime = DateFormat('HH:mm').format(DateTime.now());

  double? _lastLat;
  double? _lastLng;
  DateTime? _lastFixTime;

  // Attendance history (mock data — replace with API in production)
  final List<AttendanceRecord> _history = [
    AttendanceRecord(date: DateTime(2026, 5, 31), type: AttendanceRecordType.checkIn,  time: '08:12', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 31), type: AttendanceRecordType.checkOut, time: '17:03', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 30), type: AttendanceRecordType.checkIn,  time: '08:47', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 30), type: AttendanceRecordType.checkOut, time: '17:11', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 29), type: AttendanceRecordType.checkIn,  time: '09:02', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 28), type: AttendanceRecordType.checkIn,  time: '08:30', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 28), type: AttendanceRecordType.checkOut, time: '16:55', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 27), type: AttendanceRecordType.checkIn,  time: '08:22', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 27), type: AttendanceRecordType.checkOut, time: '17:30', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 26), type: AttendanceRecordType.checkIn,  time: '08:10', location: 'Office Area'),
    AttendanceRecord(date: DateTime(2026, 5, 26), type: AttendanceRecordType.checkOut, time: '17:05', location: 'Office Area'),
  ];

  @override
  void initState() {
    super.initState();
    _calculateDistanceStatus();
    _getCurrentLocation();
  }

  void _calculateDistanceStatus() {
    final distance = _distanceInMeters(userLat, userLng, officeLat, officeLng);
    final inPolygon = _isPointInPolygon(LatLng(userLat, userLng), officePolygon);

    setState(() {
      distanceToOfficeMeter = distance;
      isWithinArea = inPolygon && isLocationTrusted;
    });
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    final n = polygon.length;
    bool inside = false;
    final px = point.longitude;
    final py = point.latitude;
    for (int i = 0, j = n - 1; i < n; j = i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;
      final intersect =
          ((yi > py) != (yj > py)) && (px < (xj - xi) * (py - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  double _distanceInMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double degree) => degree * (math.pi / 180.0);

  Future<void> _getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      final result = await _locationChannel.invokeMapMethod<String, dynamic>(
        'getSecureLocation',
      );

      if (result == null) {
        setState(() {
          isLoadingLocation = false;
          isLocationTrusted = false;
          trustMessage = 'Unable to read GPS coordinates.';
        });
        return;
      }

      final lat = (result['latitude'] as num?)?.toDouble();
      final lng = (result['longitude'] as num?)?.toDouble();
      final accuracy = (result['accuracy'] as num?)?.toDouble() ?? 999;
      final speed = (result['speed'] as num?)?.toDouble() ?? 0;
      final isMock = result['isMock'] == true;
      final ageSeconds = (result['ageSeconds'] as num?)?.toDouble() ?? 999;

      if (lat == null || lng == null) {
        setState(() {
          isLoadingLocation = false;
          isLocationTrusted = false;
          trustMessage = 'Unable to read GPS coordinates.';
        });
        return;
      }

      final now = DateTime.now();
      final flaggedReasons = <String>[];

      if (isMock) {
        flaggedReasons.add('Mock location detected');
      }

      if (accuracy <= 0 || accuracy > 35) {
        flaggedReasons.add('GPS accuracy is too low');
      }

      if (ageSeconds > 15) {
        flaggedReasons.add('Location fix is stale');
      }

      if (speed > 45) {
        flaggedReasons.add('Unrealistic speed detected');
      }

      if (_lastLat != null && _lastLng != null && _lastFixTime != null) {
        final jumpDistance = _distanceInMeters(_lastLat!, _lastLng!, lat, lng);
        final elapsedSeconds = now.difference(_lastFixTime!).inSeconds;

        if (elapsedSeconds > 0) {
          final jumpSpeed = jumpDistance / elapsedSeconds;
          if (jumpSpeed > 55) {
            flaggedReasons.add('Abnormal jump pattern detected');
          }
        }
      }

      final trusted = flaggedReasons.isEmpty;

      setState(() {
        userLat = lat;
        userLng = lng;
        currentTime = DateFormat('HH:mm').format(now);
        isLoadingLocation = false;
        isLocationTrusted = trusted;
        trustFlags = flaggedReasons;
        trustMessage = trusted
            ? 'Secure area. Location signal verified.'
            : 'Untrusted location signal. Attendance blocked.';
      });

      _lastLat = lat;
      _lastLng = lng;
      _lastFixTime = now;

      _calculateDistanceStatus();
    } on PlatformException catch (e) {
      setState(() {
        isLoadingLocation = false;
        isLocationTrusted = false;
        trustMessage = e.message ?? 'Unable to verify GPS right now.';
      });
    } catch (_) {
      setState(() {
        isLoadingLocation = false;
        isLocationTrusted = false;
        trustMessage = 'Unable to verify GPS right now.';
      });
    }
  }

  void _submitAttendance() {
    if (!isLocationTrusted) {
      _showResultDialog(
        title: 'Location Security Check Failed',
        message:
            'Attendance cannot be submitted because the location signal is not trusted. Disable fake GPS/mock location and use real GPS.',
        success: false,
      );
      return;
    }

    if (!isWithinArea) {
      _showResultDialog(
        title: 'Outside Attendance Area',
        message:
            'You must be inside the registered attendance area to submit attendance.',
        success: false,
      );
      return;
    }

    final typeText =
        selectedType == AttendanceType.checkIn ? 'Check In' : 'Check Out';

    _showResultDialog(
      title: '$typeText Submitted',
      message:
          'Your attendance has been recorded successfully at $currentTime.',
      success: true,
    );
  }

  void _showResultDialog({
    required String title,
    required String message,
    required bool success,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: success ? green : orange,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: navy, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(color: mutedText, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(color: blue, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _ProfessionalBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    onBack: () => Navigator.of(context).maybePop(),
                    onCalendar: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AttendanceCalendarPage(records: _history),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _CompactInfoStrip(
                    currentTime: currentTime,
                    distanceText: '${distanceToOfficeMeter.toStringAsFixed(1)} m',
                    isLocationTrusted: isLocationTrusted,
                    isWithinArea: isWithinArea,
                  ),
                  const SizedBox(height: 14),
                  _AttendanceAreaCard(
                    officeLat: officeLat,
                    officeLng: officeLng,
                    userLat: userLat,
                    userLng: userLng,
                    polygonPoints: officePolygon,
                    isWithinArea: isWithinArea,
                    isLoadingLocation: isLoadingLocation,
                    isLocationTrusted: isLocationTrusted,
                    trustMessage: trustMessage,
                    onRefreshLocation: _getCurrentLocation,
                  ),
                  const SizedBox(height: 14),
                  _SelectTypeCard(
                    selectedType: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _SubmitButton(
                    enabled: isWithinArea && isLocationTrusted,
                    onTap: _submitAttendance,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactInfoStrip extends StatelessWidget {
  const _CompactInfoStrip({
    required this.currentTime,
    required this.distanceText,
    required this.isLocationTrusted,
    required this.isWithinArea,
  });

  final String currentTime;
  final String distanceText;
  final bool isLocationTrusted;
  final bool isWithinArea;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: _softCardDecoration(radius: 18),
      child: Row(
        children: [
          Expanded(
            child: _MiniStat(
              icon: Icons.access_time_rounded,
              label: 'Time',
              value: currentTime,
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFE3E9F3)),
          Expanded(
            child: _MiniStat(
              icon: Icons.pin_drop_outlined,
              label: 'Distance',
              value: distanceText,
            ),
          ),
          Container(width: 1, height: 28, color: const Color(0xFFE3E9F3)),
          Expanded(
            child: _MiniStat(
              icon: isLocationTrusted
                  ? Icons.verified_rounded
                  : Icons.warning_amber_rounded,
              label: 'Signal',
              value: isLocationTrusted ? 'Trusted' : 'Blocked',
              valueColor: isLocationTrusted
                  ? _AttendancePageState.green
                  : _AttendancePageState.orange,
              helper: isWithinArea ? 'In Area' : 'Out Area',
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.helper,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: _AttendancePageState.blue),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: _AttendancePageState.mutedText,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? _AttendancePageState.navy,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (helper != null)
            Text(
              helper!,
              style: const TextStyle(
                color: _AttendancePageState.mutedText,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onCalendar});

  final VoidCallback onBack;
  final VoidCallback onCalendar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 390;
        final iconSize = compact ? 52.0 : 58.0;
        return Row(
          children: [
            _SquareIconButton(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
              size: iconSize,
            ),
            SizedBox(width: compact ? 12 : 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance',
                    style: TextStyle(
                      color: _AttendancePageState.navy,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Record your attendance',
                    style: TextStyle(
                      color: _AttendancePageState.mutedText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _SquareIconButton(
              icon: Icons.calendar_month_rounded,
              onTap: onCalendar,
              size: iconSize,
            ),
          ],
        );
      },
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.size = 58,
  });

  final IconData icon;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8EEF7), width: 1),
            boxShadow: [
              BoxShadow(
                color: _AttendancePageState.navy.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(icon, color: _AttendancePageState.navy, size: size * 0.45),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.statusText,
    required this.description,
    required this.date,
    required this.day,
  });

  final String statusText;
  final String description;
  final String date;
  final String day;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _softCardDecoration(radius: 24),
      padding: const EdgeInsets.all(22),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 440;
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Today\'s Status',
                      style: TextStyle(
                        color: _AttendancePageState.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F8EF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        statusText,
                        style: const TextStyle(
                          color: _AttendancePageState.green,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    color: _AttendancePageState.mutedText,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: const Color(0xFFE2E8F0)),
                const SizedBox(height: 12),
                const Text(
                  'Date',
                  style: TextStyle(
                    color: _AttendancePageState.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  date,
                  style: const TextStyle(
                    color: _AttendancePageState.navy,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  day,
                  style: const TextStyle(
                    color: _AttendancePageState.mutedText,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Today\'s Status',
                          style: TextStyle(
                            color: _AttendancePageState.navy,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8EF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusText,
                            style: const TextStyle(
                              color: _AttendancePageState.green,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      description,
                      style: const TextStyle(
                        color: _AttendancePageState.mutedText,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 70, color: const Color(0xFFE2E8F0)),
              const SizedBox(width: 24),
              SizedBox(
                width: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Date',
                      style: TextStyle(
                        color: _AttendancePageState.navy,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      date,
                      style: const TextStyle(
                        color: _AttendancePageState.navy,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      day,
                      style: const TextStyle(
                        color: _AttendancePageState.mutedText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AttendanceAreaCard extends StatefulWidget {
  const _AttendanceAreaCard({
    required this.officeLat,
    required this.officeLng,
    required this.userLat,
    required this.userLng,
    required this.polygonPoints,
    required this.isWithinArea,
    required this.isLoadingLocation,
    required this.isLocationTrusted,
    required this.trustMessage,
    required this.onRefreshLocation,
  });

  final double officeLat;
  final double officeLng;
  final double userLat;
  final double userLng;
  final List<LatLng> polygonPoints;
  final bool isWithinArea;
  final bool isLoadingLocation;
  final bool isLocationTrusted;
  final String trustMessage;
  final VoidCallback onRefreshLocation;

  @override
  State<_AttendanceAreaCard> createState() => _AttendanceAreaCardState();
}

class _AttendanceAreaCardState extends State<_AttendanceAreaCard> {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(_AttendanceAreaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userLat != widget.userLat || oldWidget.userLng != widget.userLng) {
      if (widget.userLat != 0 && widget.userLng != 0) {
        _mapController.move(
          LatLng(widget.userLat, widget.userLng),
          _mapController.camera.zoom,
        );
      }
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final officeLat    = widget.officeLat;
    final officeLng    = widget.officeLng;
    final userLat      = widget.userLat;
    final userLng      = widget.userLng;
    final polygon      = widget.polygonPoints;
    final isWithinArea      = widget.isWithinArea;
    final isLoadingLocation = widget.isLoadingLocation;
    final isLocationTrusted = widget.isLocationTrusted;
    final trustMessage      = widget.trustMessage;
    final onRefreshLocation = widget.onRefreshLocation;

    final statusColor = isWithinArea
        ? _AttendancePageState.green
        : _AttendancePageState.orange;
    final statusIcon = isWithinArea
        ? Icons.check_circle_rounded
        : Icons.warning_rounded;
    final statusText = isWithinArea
        ? 'Di dalam area absensi'
        : 'Di luar area absensi';

    return Container(
      decoration: _softCardDecoration(radius: 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Office info header ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _AttendancePageState.softBlue,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: _AttendancePageState.blue,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance Area',
                        style: TextStyle(
                          color: _AttendancePageState.mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Text(
                            'Office Area',
                            style: TextStyle(
                              color: _AttendancePageState.navy,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const _ActiveBadge(),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Jl. Sudirman No.123, Jakarta Pusat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _AttendancePageState.mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Map ──────────────────────────────────────────────────────
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(officeLat, officeLng),
                    initialZoom: 16.5,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom |
                             InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.indexim.hero',
                      maxZoom: 19,
                    ),
                    // Geofence polygon
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: polygon,
                          color: const Color(0xFF156DFF).withValues(alpha: 0.13),
                          borderColor: const Color(0xFF156DFF),
                          borderStrokeWidth: 2.0,
                        ),
                      ],
                    ),
                    // Polyline user → office
                    if (userLat != 0 && userLng != 0)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              LatLng(userLat, userLng),
                              LatLng(officeLat, officeLng),
                            ],
                            color: const Color(0xFF156DFF).withValues(alpha: 0.55),
                            strokeWidth: 2.2,
                            isDotted: true,
                          ),
                        ],
                      ),
                    // Markers
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(officeLat, officeLng),
                          width: 44,
                          height: 52,
                          alignment: Alignment.bottomCenter,
                          child: const _OfficePinMarker(),
                        ),
                        if (userLat != 0 && userLng != 0)
                          Marker(
                            point: LatLng(userLat, userLng),
                            width: 80,
                            height: 88,
                            alignment: Alignment.bottomCenter,
                            child: const _UserLocationPin(),
                          ),
                      ],
                    ),
                  ],
                ),

                // Location button — bottom right
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: _LocationFab(
                    isLoading: isLoadingLocation,
                    onTap: onRefreshLocation,
                  ),
                ),
              ],
            ),
          ),

          // ── Status strip below map ───────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFEDF2F7), width: 1),
              ),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLocationTrusted
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    trustMessage,
                    style: TextStyle(
                      color: isLocationTrusted
                          ? _AttendancePageState.green
                          : _AttendancePageState.orange,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationFab extends StatelessWidget {
  const _LocationFab({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _AttendancePageState.blue,
                ),
              )
            : const Icon(
                Icons.my_location_rounded,
                color: _AttendancePageState.blue,
                size: 20,
              ),
      ),
    );
  }
}
class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: _AttendancePageState.softBlue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Active',
        style: TextStyle(
          color: _AttendancePageState.blue,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E8F2)),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _AttendancePageState.navy.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: _AttendancePageState.blue, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: _AttendancePageState.blue,
                  fontSize: 11.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfficePinMarker extends StatelessWidget {
  const _OfficePinMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _AttendancePageState.blue,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: _AttendancePageState.blue.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 22),
        ),
        CustomPaint(
          size: const Size(14, 9),
          painter: _PinTailPainter(color: _AttendancePageState.blue),
        ),
      ],
    );
  }
}

class _PinTailPainter extends CustomPainter {
  const _PinTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PinTailPainter oldDelegate) => oldDelegate.color != color;
}

class _UserLocationPin extends StatelessWidget {
  const _UserLocationPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // label card
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _AttendancePageState.blue,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: _AttendancePageState.blue.withValues(alpha: 0.40),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Text(
            'Saya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
        // triangle tail
        CustomPaint(
          size: const Size(10, 6),
          painter: _DownTrianglePainter(color: _AttendancePageState.blue),
        ),
        // pulsing dot
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _AttendancePageState.blue,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: _AttendancePageState.blue.withValues(alpha: 0.45),
                blurRadius: 12,
                spreadRadius: 4,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DownTrianglePainter extends CustomPainter {
  const _DownTrianglePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DownTrianglePainter old) => old.color != color;
}

class _SelectTypeCard extends StatelessWidget {
  const _SelectTypeCard({
    required this.selectedType,
    required this.onChanged,
  });

  final AttendanceType selectedType;
  final ValueChanged<AttendanceType> onChanged;

  @override
  Widget build(BuildContext context) {
    final isCheckIn = selectedType == AttendanceType.checkIn;
    final activeColor = isCheckIn
        ? _AttendancePageState.green
        : const Color(0xFFE24C4B);

    return Container(
      decoration: _softCardDecoration(radius: 24),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Type',
            style: TextStyle(
              color: _AttendancePageState.navy,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FC),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFD9E3F0)),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final knobSize = 20.0;
                final sliderWidth = (constraints.maxWidth - 6) / 2;
                return Stack(
                  children: [
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      alignment:
                          isCheckIn ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        width: sliderWidth,
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              if (!isCheckIn)
                                Container(
                                  width: knobSize,
                                  height: knobSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _AttendancePageState.navy.withValues(alpha: 0.15),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              const Spacer(),
                              if (isCheckIn)
                                Container(
                                  width: knobSize,
                                  height: knobSize,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: _AttendancePageState.navy.withValues(alpha: 0.15),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => onChanged(AttendanceType.checkIn),
                            child: Center(
                              child: Text(
                                'IN',
                                style: TextStyle(
                                  color: isCheckIn
                                      ? Colors.white
                                      : const Color(0xFF617086),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => onChanged(AttendanceType.checkOut),
                            child: Center(
                              child: Text(
                                'OUT',
                                style: TextStyle(
                                  color: !isCheckIn
                                      ? Colors.white
                                      : const Color(0xFF617086),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.currentTime,
    required this.locationName,
    required this.city,
    required this.radiusText,
    required this.distanceText,
  });

  final String currentTime;
  final String locationName;
  final String city;
  final String radiusText;
  final String distanceText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _softCardDecoration(radius: 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'Current Time',
            value: currentTime,
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: locationName,
            subValue: city,
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.wifi_rounded,
            label: 'Method',
            value: 'GPS',
            subValue: 'Radius $radiusText',
          ),
          const SizedBox(height: 18),
          _InfoRow(
            icon: Icons.pin_drop_outlined,
            label: 'Distance',
            value: distanceText,
            subValue: 'to office center',
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _AttendancePageState.softBlue.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: _AttendancePageState.blue,
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Attendance requires trusted GPS signal (anti-mock checks).\nServer-side verification should be added for maximum protection.',
                    style: TextStyle(
                      color: _AttendancePageState.navy,
                      height: 1.45,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _AttendancePageState.blue, size: 23),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _AttendancePageState.mutedText,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: _AttendancePageState.navy,
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (subValue != null) ...[
              const SizedBox(height: 3),
              Text(
                subValue!,
                style: const TextStyle(
                  color: _AttendancePageState.mutedText,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1677FF), Color(0xFF0A52E8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _AttendancePageState.blue.withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint_rounded, color: Colors.white, size: 24),
                SizedBox(width: 10),
                Text(
                  'ABSEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfessionalBackground extends StatelessWidget {
  const _ProfessionalBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProfessionalBackgroundPainter(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFF6FAFF), Color(0xFFEDF4FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _ProfessionalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = const Color(0xFF156DFF).withValues(alpha: 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final Paint glowPaint = Paint()
      ..color = const Color(0xFF156DFF).withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    final Paint dotPaint = Paint()
      ..color = const Color(0xFF156DFF).withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.90, size.height * 0.12), 160, glowPaint);
    canvas.drawCircle(Offset(size.width * 0.04, size.height * 0.82), 180, glowPaint);

    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(size.width * 0.58 + i * 18, 0),
        Offset(size.width + i * 18, size.height * 0.32),
        linePaint,
      );
    }

    final Rect arcRect = Rect.fromCircle(
      center: Offset(size.width * 0.80, size.height * 0.42),
      radius: size.width * 0.42,
    );

    canvas.drawArc(arcRect, math.pi * 0.85, math.pi * 0.95, false, linePaint);

    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 6; j++) {
        canvas.drawCircle(
          Offset(size.width * 0.64 + i * 10, size.height * 0.36 + j * 10),
          1.25,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

BoxDecoration _softCardDecoration({double radius = 22}) {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: 0.96),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: Colors.white, width: 1.1),
    boxShadow: [
      BoxShadow(
        color: _AttendancePageState.navy.withValues(alpha: 0.075),
        blurRadius: 24,
        offset: const Offset(0, 12),
      ),
    ],
  );
}
