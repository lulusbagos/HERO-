import 'package:hero/core/enums/app_role.dart';

class AuthService {
  Future<void> signIn({
    required String employeeId,
    required String password,
    required AppRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (employeeId.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Employee ID dan password wajib diisi.');
    }
    if (password.length < 4) {
      throw Exception('Password minimal 4 karakter.');
    }
  }
}
