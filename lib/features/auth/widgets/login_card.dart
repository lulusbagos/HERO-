import 'package:flutter/material.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.employeeIdController,
    required this.passwordController,
    required this.isSubmitting,
    required this.onSignIn,
    required this.ambientProgress,
  });

  final TextEditingController employeeIdController;
  final TextEditingController passwordController;
  final bool isSubmitting;
  final VoidCallback onSignIn;
  final double ambientProgress;

  static const _navy = Color(0xFF082A63);
  static const _blue = Color(0xFF0A56C2);
  static const _softText = Color(0xFF6D7A90);
  static const _headingFont = 'Poppins';
  static const _bodyFont = 'Poppins';

  @override
  Widget build(BuildContext context) {
    final shimmerOffset = (ambientProgress * 2) - 1;
    final floatingBlur = 28 + (ambientProgress * 12);
    final submitWave = ((ambientProgress * 2) - 1).abs();

    return AnimatedScale(
      scale: isSubmitting ? 0.988 : 1,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, isSubmitting ? 24 : 30, 24, 28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isSubmitting ? 0.97 : 0.94),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSubmitting
                ? const Color(0xFFCADAF4)
                : Colors.white.withValues(alpha: 0.85),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D3557).withValues(
                alpha: isSubmitting ? 0.16 : 0.12,
              ),
              blurRadius: isSubmitting ? floatingBlur + 10 : floatingBlur,
              offset: Offset(0, isSubmitting ? 24 : 20),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -12,
              left: 24 + (shimmerOffset * 44),
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7EB7FF).withValues(
                          alpha: isSubmitting ? 0.24 : 0.18,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: isSubmitting ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              child: IgnorePointer(
                ignoring: true,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0x330A56C2),
                          const Color(0xFF0A56C2).withValues(
                            alpha: 0.55 + ((1 - submitWave) * 0.35),
                          ),
                          const Color(0x330A56C2),
                        ],
                        stops: const [0, 0.5, 1],
                        begin: Alignment(-1 + (ambientProgress * 2), 0),
                        end: Alignment(1 + (ambientProgress * 2), 0),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  child: isSubmitting
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: _SubmittingBanner(progress: ambientProgress),
                        )
                      : const SizedBox.shrink(),
                ),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: _navy,
                    fontFamily: _headingFont,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to access your workspace',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _softText,
                    fontFamily: _bodyFont,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                _InputField(
                  controller: employeeIdController,
                  icon: Icons.person_outline_rounded,
                  hint: 'Email or Employee ID',
                ),
                const SizedBox(height: 16),
                _InputField(
                  controller: passwordController,
                  icon: Icons.lock_outline_rounded,
                  hint: 'Password',
                  obscure: true,
                  suffixIcon: Icons.visibility_outlined,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: _blue,
                        fontFamily: _bodyFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: isSubmitting ? 1 : 0),
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: _navy.withValues(
                                alpha: 0.18 + (value * 0.14),
                              ),
                              blurRadius: 18 + (value * 10),
                              offset: Offset(0, 10 + (value * 4)),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : onSignIn,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            backgroundColor: _navy,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _navy.withValues(alpha: 0.78),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isSubmitting)
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withValues(alpha: 0),
                                            Colors.white.withValues(alpha: 0.08),
                                            Colors.white.withValues(alpha: 0.22),
                                            Colors.white.withValues(alpha: 0.08),
                                            Colors.white.withValues(alpha: 0),
                                          ],
                                          stops: const [0, 0.2, 0.5, 0.8, 1],
                                          begin: Alignment(
                                            -1.6 + (ambientProgress * 3),
                                            0,
                                          ),
                                          end: Alignment(
                                            -0.3 + (ambientProgress * 3),
                                            0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 260),
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: isSubmitting
                                    ? Row(
                                        key: const ValueKey('submitting'),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: Colors.white.withValues(
                                                        alpha: 0.24 +
                                                            ((1 - submitWave) * 0.2),
                                                      ),
                                                      width: 2,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2.3,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'Signing In...',
                                            style: TextStyle(
                                              fontFamily: _bodyFont,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Row(
                                        key: ValueKey('text'),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Text(
                                                'Sign In',
                                                style: TextStyle(
                                                  fontFamily: _bodyFont,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Icon(Icons.arrow_forward_rounded),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 26),
                const Row(
                  children: [
                    Expanded(child: Divider(color: Color(0xFFD5DCE8))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: _softText,
                          fontFamily: _bodyFont,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFFD5DCE8))),
                  ],
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.shield_outlined, size: 22),
                    label: const Text(
                      'Use Company SSO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _blue,
                      side: const BorderSide(
                        color: Color(0xFFB7C4D8),
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmittingBanner extends StatelessWidget {
  const _SubmittingBanner({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final pulse = 0.55 + (((progress * 2) - 1).abs() * 0.45);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD8E5F7)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A56C2).withValues(alpha: 0.08 * pulse),
                ),
              ),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0A56C2).withValues(alpha: pulse),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Authenticating your account',
              style: const TextStyle(
                color: LoginCard._navy,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _LoadingDots(progress: progress),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final base = progress * 3;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final distance = (base - index).abs();
        final intensity = (1 - distance).clamp(0.25, 1.0);
        return Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(right: index == 2 ? 0 : 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0A56C2).withValues(alpha: intensity),
          ),
        );
      }),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(
        color: Color(0xFF1A2B49),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF78869A),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF5D6D82)),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(suffixIcon, color: const Color(0xFF5D6D82)),
        filled: true,
        fillColor: const Color(0xFFFDFEFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFFD2D9E6),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: Color(0xFF0A56C2),
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
