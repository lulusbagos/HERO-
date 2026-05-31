import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

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
  static const double attendanceRadiusMeter = 100;

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

  @override
  void initState() {
    super.initState();
    _calculateDistanceStatus();
    _getCurrentLocation();
  }

  void _calculateDistanceStatus() {
    final distance = _distanceInMeters(userLat, userLng, officeLat, officeLng);
    final withinArea = distance <= attendanceRadiusMeter;

    setState(() {
      distanceToOfficeMeter = distance;
      isWithinArea = withinArea && isLocationTrusted;
    });
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
    final todayDate = DateFormat('MMM dd, yyyy').format(DateTime.now());
    final todayDay = DateFormat('EEEE').format(DateTime.now());

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
                    onCalendar: () {},
                  ),
                  const SizedBox(height: 22),
                  _StatusCard(
                    statusText: 'Not Checked In',
                    description: 'You have not checked in today',
                    date: todayDate,
                    day: todayDay,
                  ),
                  const SizedBox(height: 18),
                  _AttendanceAreaCard(
                    officeLat: officeLat,
                    officeLng: officeLng,
                    userLat: userLat,
                    userLng: userLng,
                    radiusMeter: attendanceRadiusMeter,
                    isWithinArea: isWithinArea,
                    isLoadingLocation: isLoadingLocation,
                    isLocationTrusted: isLocationTrusted,
                    trustMessage: trustMessage,
                    trustFlags: trustFlags,
                    onRefreshLocation: _getCurrentLocation,
                  ),
                  const SizedBox(height: 18),
                  _SelectTypeCard(
                    selectedType: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 18),
                  _InformationCard(
                    currentTime: currentTime,
                    locationName: 'Office Area',
                    city: 'Jakarta, ID',
                    radiusText: '${attendanceRadiusMeter.toInt()} m',
                    distanceText: '${distanceToOfficeMeter.toStringAsFixed(1)} m',
                  ),
                  const SizedBox(height: 22),
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

class _AttendanceAreaCard extends StatelessWidget {
  const _AttendanceAreaCard({
    required this.officeLat,
    required this.officeLng,
    required this.userLat,
    required this.userLng,
    required this.radiusMeter,
    required this.isWithinArea,
    required this.isLoadingLocation,
    required this.isLocationTrusted,
    required this.trustMessage,
    required this.trustFlags,
    required this.onRefreshLocation,
  });

  final double officeLat;
  final double officeLng;
  final double userLat;
  final double userLng;
  final double radiusMeter;
  final bool isWithinArea;
  final bool isLoadingLocation;
  final bool isLocationTrusted;
  final String trustMessage;
  final List<String> trustFlags;
  final VoidCallback onRefreshLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _softCardDecoration(radius: 24),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 420;
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _AttendancePageState.softBlue,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.apartment_rounded,
                              color: _AttendancePageState.blue,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Attendance Area',
                                  style: TextStyle(
                                    color: _AttendancePageState.mutedText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Office Area',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: _AttendancePageState.navy,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    _ActiveBadge(),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Jl. Sudirman No.123, Jakarta Pusat, DKI Jakarta',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _AttendancePageState.mutedText,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: _MapActionButton(
                          label: 'Center',
                          icon: PhosphorIconsRegular.crosshair,
                          onTap: onRefreshLocation,
                        ),
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _AttendancePageState.softBlue,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: _AttendancePageState.blue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Attendance Area',
                            style: TextStyle(
                              color: _AttendancePageState.mutedText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'Office Area',
                                style: TextStyle(
                                  color: _AttendancePageState.navy,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(width: 8),
                              _ActiveBadge(),
                            ],
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Jl. Sudirman No.123, Jakarta Pusat, DKI Jakarta',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _AttendancePageState.mutedText,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _MapActionButton(
                      label: 'Center',
                      icon: PhosphorIconsRegular.crosshair,
                      onTap: onRefreshLocation,
                    ),
                  ],
                );
              },
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              height: 250,
              child: Stack(
                children: [
                  const Positioned.fill(child: _PseudoMapBackground()),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SecureRadiusPainter(),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: _MapPin(
                      icon: Icons.location_on_rounded,
                      color: _AttendancePageState.blue,
                    ),
                  ),
                  const Align(
                    alignment: Alignment(-0.20, 0.22),
                    child: _UserLocationDot(),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 96,
                    child: GestureDetector(
                      onTap: onRefreshLocation,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: isLoadingLocation
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _AttendancePageState.blue,
                                ),
                              )
                            : const Icon(
                                Icons.my_location_rounded,
                                color: _AttendancePageState.navy,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: _AttendancePageState.navy.withValues(alpha: 0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isWithinArea
                                    ? Icons.check_circle_rounded
                                    : Icons.warning_rounded,
                                color: isWithinArea
                                    ? _AttendancePageState.green
                                    : _AttendancePageState.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  isWithinArea
                                      ? 'You are within the attendance area'
                                      : 'You are outside or location is not trusted',
                                  style: const TextStyle(
                                    color: _AttendancePageState.navy,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trustMessage,
                            style: TextStyle(
                              color: isLocationTrusted
                                  ? _AttendancePageState.green
                                  : _AttendancePageState.orange,
                              fontSize: 12.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (trustFlags.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              trustFlags.join(' • '),
                              style: const TextStyle(
                                color: _AttendancePageState.mutedText,
                                fontSize: 11.8,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: 5),
                          Text(
                            'Office: ${officeLat.toStringAsFixed(4)}, ${officeLng.toStringAsFixed(4)} | You: ${userLat.toStringAsFixed(4)}, ${userLng.toStringAsFixed(4)}',
                            style: const TextStyle(
                              color: _AttendancePageState.mutedText,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _PseudoMapBackground extends StatelessWidget {
  const _PseudoMapBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F7FF),
      child: CustomPaint(
        painter: _PseudoMapPainter(),
      ),
    );
  }
}

class _PseudoMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFDDE7F7)
      ..strokeWidth = 2;

    for (int i = 0; i < 10; i++) {
      final y = (i + 1) * size.height / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 8), roadPaint);
    }

    for (int i = 0; i < 7; i++) {
      final x = (i + 1) * size.width / 7;
      canvas.drawLine(Offset(x, 0), Offset(x + 12, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SecureRadiusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.33;

    final fillPaint = Paint()
      ..color = _AttendancePageState.blue.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = _AttendancePageState.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;

    canvas.drawCircle(center, radius, fillPaint);
    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE1E8F2)),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _AttendancePageState.navy.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: _AttendancePageState.blue, size: 18),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  color: _AttendancePageState.blue,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: 54,
      shadows: [
        Shadow(
          color: color.withValues(alpha: 0.24),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}

class _UserLocationDot extends StatelessWidget {
  const _UserLocationDot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: _AttendancePageState.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: _AttendancePageState.blue.withValues(alpha: 0.30),
              blurRadius: 14,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
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

    return Container(
      decoration: _softCardDecoration(radius: 24),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Type',
            style: TextStyle(
              color: _AttendancePageState.navy,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Choose whether you want to check in or check out',
            style: TextStyle(
              color: _AttendancePageState.mutedText,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F7FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2EAF6)),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment:
                      isCheckIn ? Alignment.centerLeft : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _AttendancePageState.navy.withValues(alpha: 0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: _AttendanceSwitchOption(
                        label: 'Check In',
                        icon: Icons.login_rounded,
                        activeColor: _AttendancePageState.green,
                        selected: isCheckIn,
                        onTap: () => onChanged(AttendanceType.checkIn),
                      ),
                    ),
                    Expanded(
                      child: _AttendanceSwitchOption(
                        label: 'Check Out',
                        icon: Icons.logout_rounded,
                        activeColor: _AttendancePageState.orange,
                        selected: !isCheckIn,
                        onTap: () => onChanged(AttendanceType.checkOut),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSwitchOption extends StatelessWidget {
  const _AttendanceSwitchOption({
    required this.label,
    required this.icon,
    required this.activeColor,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color activeColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : const Color(0xFF8792A4);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: selected ? activeColor.withValues(alpha: 0.13) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? activeColor : const Color(0xFFC4CDDA),
                width: selected ? 5 : 2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: selected ? _AttendancePageState.navy : color,
              fontSize: 15,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
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
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 62,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1677FF), Color(0xFF0A52E8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: _AttendancePageState.blue.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fingerprint_rounded, color: Colors.white, size: 27),
                SizedBox(width: 12),
                Text(
                  'ABSEN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
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
