import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hero/core/enums/app_role.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    super.key,
    required this.employeeIdController,
    required this.passwordController,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.isSubmitting,
    required this.onSignIn,
  });

  final TextEditingController employeeIdController;
  final TextEditingController passwordController;
  final AppRole selectedRole;
  final ValueChanged<AppRole?> onRoleChanged;
  final bool isSubmitting;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 28,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Masuk ke sistem HERO PT INDEXIM COALINDO',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: employeeIdController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Employee ID / Username',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<AppRole>(
                initialValue: selectedRole,
                borderRadius: BorderRadius.circular(14),
                dropdownColor: const Color(0xFF1A2528),
                onChanged: onRoleChanged,
                decoration: const InputDecoration(
                  labelText: 'Role Access',
                  prefixIcon: Icon(Icons.account_tree_outlined),
                ),
                items: AppRole.values
                    .map(
                      (role) => DropdownMenuItem<AppRole>(
                        value: role,
                        child: Text(role.label),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSubmitting ? null : onSignIn,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: const Color(0xFF08110A),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSubmitting
                        ? const SizedBox(
                            key: ValueKey('loader'),
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2.3),
                          )
                        : const Text('Sign In', key: ValueKey('text')),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Menu driven by database · Lazy loading modules · Role-based access',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
