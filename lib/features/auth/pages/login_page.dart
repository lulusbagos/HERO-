import 'package:flutter/material.dart';
import 'package:hero/core/enums/app_role.dart';
import 'package:hero/core/repositories/menu_repository.dart';
import 'package:hero/core/services/auth_service.dart';
import 'package:hero/features/auth/widgets/company_logo.dart';
import 'package:hero/features/auth/widgets/glow_orb.dart';
import 'package:hero/features/auth/widgets/login_card.dart';
import 'package:hero/features/auth/widgets/uniform_visual.dart';
import 'package:hero/features/home/pages/home_shell.dart';
import 'package:hero/features/menu/repositories/mock_menu_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  static const _logoAssetPath = 'assets/images/indexim_logo.png';
  static const _uniformAssetPath = 'assets/images/indexim_uniform_person.png';

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
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          // ── animated ambient background ────────────────────────
          AnimatedBuilder(
            animation: _ambientController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -0.8 + _ambientController.value * 0.25,
                      -1,
                    ),
                    end: const Alignment(1, 1),
                    colors: const [
                      Color(0xFF0B1113),
                      Color(0xFF112124),
                      Color(0xFF1B3236),
                    ],
                  ),
                ),
                child: child,
              );
            },
            child: const SizedBox.expand(),
          ),
          // ── decorative glow orbs ───────────────────────────────
          Positioned(
            top: -90,
            right: -60,
            child: GlowOrb(
              size: 280,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.22),
            ),
          ),
          Positioned(
            left: -80,
            bottom: -120,
            child: GlowOrb(
              size: 320,
              color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
            ),
          ),
          // ── main content ───────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 980),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth > 760;

                      final visualPanel = Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ScaleTransition(
                              scale: _logoPulse,
                              child: const CompanyLogo(
                                assetPath: _logoAssetPath,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'HERO',
                              style: TextStyle(
                                fontSize: isDesktop ? 52 : 40,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Human Enterprise Resource Operations\nby PT INDEXIM COALINDO',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.84),
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Platform mobile premium untuk proses HR & GA modern, termasuk approval bertingkat lintas role.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.75),
                                height: 1.55,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const UniformVisual(assetPath: _uniformAssetPath),
                          ],
                        ),
                      );

                      final formPanel = FadeTransition(
                        opacity: _cardOpacity,
                        child: SlideTransition(
                          position: _cardOffset,
                          child: LoginCard(
                            employeeIdController: _employeeIdController,
                            passwordController: _passwordController,
                            selectedRole: _selectedRole,
                            onRoleChanged: (role) {
                              if (role != null) {
                                setState(() => _selectedRole = role);
                              }
                            },
                            isSubmitting: _isSubmitting,
                            onSignIn: _onSignIn,
                          ),
                        ),
                      );

                      if (!isDesktop) {
                        return Column(
                          children: [
                            visualPanel,
                            const SizedBox(height: 12),
                            formPanel,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: visualPanel),
                          const SizedBox(width: 24),
                          Expanded(child: formPanel),
                        ],
                      );
                    },
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
