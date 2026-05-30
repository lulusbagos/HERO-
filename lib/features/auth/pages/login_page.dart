import 'package:flutter/material.dart';
import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/repositories/menu_repository.dart';
import 'package:hero/core/services/auth_service.dart';
import 'package:hero/features/auth/widgets/company_logo.dart';
import 'package:hero/features/auth/widgets/login_card.dart';
import 'package:hero/features/home/pages/home_shell.dart';
import 'package:hero/features/menu/repositories/mock_menu_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  static const _logoAssetPath = 'assets/logo/company_logo.png';
  static const _navy = Color(0xFF082A63);
  static const _blue = Color(0xFF0A56C2);
  static const _softText = Color(0xFF6D7A90);
  static const _headingFont = 'Poppins';
  static const _bodyFont = 'Poppins';

  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final MenuRepository _menuRepository = MockMenuRepository();

  late final AnimationController _entryController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();

  late final AnimationController _ambientController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  )..repeat(reverse: true);

  late final Animation<double> _cardOpacity = CurvedAnimation(
    parent: _entryController,
    curve: const Interval(0.3, 1, curve: Curves.easeOut),
  );

  late final Animation<Offset> _cardOffset =
      Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
      );

  late final Animation<double> _headlineOpacity = CurvedAnimation(
    parent: _entryController,
    curve: const Interval(0.05, 0.55, curve: Curves.easeOut),
  );

  late final Animation<Offset> _headlineOffset =
      Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(
        CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
      );

  late final Animation<double> _footerOpacity = CurvedAnimation(
    parent: _entryController,
    curve: const Interval(0.5, 1, curve: Curves.easeOut),
  );

  late final Animation<double> _logoPulse =
      Tween<double>(begin: 0.96, end: 1.04).animate(
        CurvedAnimation(parent: _ambientController, curve: Curves.easeInOut),
      );

  AppRole _selectedRole = AppRole.staff;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    _entryController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    setState(() => _isSubmitting = true);
    try {
      await _authService.signIn(
        employeeId: _employeeIdController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              HomeShell(role: _selectedRole, menuRepository: _menuRepository),
        ),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: const [
                      Color(0xFFF8FBFF),
                      Color(0xFFEAF1FB),
                      Color(0xFFFDFEFF),
                    ],
                    begin: Alignment(-1 + (_ambientController.value * 0.2), -1),
                    end: const Alignment(1, 1),
                  ),
                ),
                child: _CorporateBackground(progress: _ambientController.value),
              );
            },
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      const SizedBox(height: 58),
                      FadeTransition(
                        opacity: _headlineOpacity,
                        child: SlideTransition(
                          position: _headlineOffset,
                          child: _BrandIdentityHeader(
                            logoPulse: _logoPulse,
                            ambientProgress: _ambientController.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      FadeTransition(
                        opacity: _cardOpacity,
                        child: SlideTransition(
                          position: _cardOffset,
                          child: AnimatedBuilder(
                            animation: _ambientController,
                            builder: (context, _) {
                              return Transform.translate(
                                offset: Offset(
                                  0,
                                  _FastMath.sin(
                                        _ambientController.value * 6.283185307179586,
                                      ) *
                                      3,
                                ),
                                child: LoginCard(
                                  employeeIdController: _employeeIdController,
                                  passwordController: _passwordController,
                                  isSubmitting: _isSubmitting,
                                  onSignIn: _onSignIn,
                                  ambientProgress: _ambientController.value,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _footerOpacity,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.headset_mic_outlined,
                              color: Color(0xFF5D6D82),
                              size: 22,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Need help? ',
                              style: TextStyle(
                                color: _softText,
                                fontFamily: _bodyFont,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Contact Administrator',
                              style: TextStyle(
                                color: _blue,
                                fontFamily: _bodyFont,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandIdentityHeader extends StatelessWidget {
  const _BrandIdentityHeader({
    required this.logoPulse,
    required this.ambientProgress,
  });

  final Animation<double> logoPulse;
  final double ambientProgress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: logoPulse,
              builder: (context, child) {
                final wave = _FastMath.sin(ambientProgress * 6.283185307179586);
                return Transform.translate(
                  offset: Offset(0, wave * 1.8),
                  child: ScaleTransition(scale: logoPulse, child: child),
                );
              },
              child: const CompanyLogo(assetPath: _LoginPageState._logoAssetPath),
            ),
            const SizedBox(height: 18),
            const Text(
              'HERO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _LoginPageState._navy,
                fontFamily: _LoginPageState._headingFont,
                fontSize: 64,
                fontWeight: FontWeight.w700,
                letterSpacing: 5.5,
                height: 0.95,
              ),
            ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'Human Enterprise Resource Operations',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _LoginPageState._softText,
                  fontFamily: _LoginPageState._bodyFont,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.15,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 176,
              height: 1,
              color: const Color(0xFFC9D7EE),
            ),
            const SizedBox(height: 12),
            const Text(
              'PT INDEXIM COALINDO',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _LoginPageState._navy,
                fontFamily: _LoginPageState._bodyFont,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 3.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CorporateBackground extends StatelessWidget {
  const _CorporateBackground({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CorporateBackgroundPainter(progress),
      child: const SizedBox.expand(),
    );
  }
}

class _CorporateBackgroundPainter extends CustomPainter {
  const _CorporateBackgroundPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFB8C6DA).withValues(alpha: 0.32)
      ..strokeWidth = 1.1
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = const Color(0xFF0A56C2).withValues(alpha: 0.055)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = const Color(0xFF0A56C2).withValues(alpha: 0.13)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * (0.08 + (progress * 0.02)), size.height * 0.22),
      180,
      glowPaint,
    );

    canvas.drawCircle(
      Offset(size.width * (0.92 - (progress * 0.03)), size.height * 0.82),
      210,
      glowPaint,
    );

    final arcRect1 = Rect.fromCircle(
      center: Offset(size.width * (0.52 + (progress * 0.015)), size.height * 0.42),
      radius: size.width * 0.82,
    );
    canvas.drawArc(arcRect1, -2.6, 1.9, false, linePaint);

    final arcRect2 = Rect.fromCircle(
      center: Offset(size.width * 0.18, size.height * (0.85 - (progress * 0.02))),
      radius: size.width * 0.76,
    );
    canvas.drawArc(arcRect2, -0.7, 2.2, false, linePaint);

    final rightPath = Path()
      ..moveTo(size.width * 0.78, 0)
      ..lineTo(size.width, size.height * 0.18)
      ..lineTo(size.width * 0.88, size.height * 0.38)
      ..lineTo(size.width, size.height * 0.58)
      ..lineTo(size.width * 0.86, size.height * 0.74)
      ..lineTo(size.width, size.height * 0.92);
    canvas.drawPath(rightPath, linePaint);

    final leftPath = Path()
      ..moveTo(0, size.height * 0.08)
      ..lineTo(size.width * 0.18, size.height * 0.14)
      ..lineTo(size.width * 0.18, size.height * 0.22)
      ..lineTo(0, size.height * 0.30);
    canvas.drawPath(leftPath, linePaint);

    _drawHexagon(canvas, Offset(size.width * 0.08, size.height * 0.18), 42, linePaint);
    _drawHexagon(canvas, Offset(size.width * 0.90, size.height * 0.88), 64, linePaint);

    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 9; j++) {
        canvas.drawCircle(
          Offset(
            size.width * 0.82 + (i * 9) + (progress * 6),
            size.height * 0.17 + (j * 9),
          ),
          1.2,
          dotPaint,
        );
      }
    }

    for (int i = 0; i < 7; i++) {
      for (int j = 0; j < 7; j++) {
        canvas.drawCircle(
          Offset(
            size.width * 0.03 + (i * 9) - (progress * 5),
            size.height * 0.78 + (j * 9),
          ),
          1.1,
          dotPaint,
        );
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (3.141592653589793 / 3) * i;
      final point = Offset(
        center.dx + radius * _FastMath.cos(angle),
        center.dy + radius * _FastMath.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CorporateBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _FastMath {
  static double sin(double value) {
    return _TaylorMath.sin(value);
  }

  static double cos(double value) {
    return _TaylorMath.cos(value);
  }
}

class _TaylorMath {
  static double sin(double value) {
    double term = value;
    double sum = value;

    for (int i = 1; i < 8; i++) {
      term *= -1 * value * value / ((2 * i) * (2 * i + 1));
      sum += term;
    }

    return sum;
  }

  static double cos(double value) {
    double term = 1;
    double sum = 1;

    for (int i = 1; i < 8; i++) {
      term *= -1 * value * value / ((2 * i - 1) * (2 * i));
      sum += term;
    }

    return sum;
  }
}
