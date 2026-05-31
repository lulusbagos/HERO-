import 'package:hero/core/enums/app_role.dart';

class AuthService {
  Future<void> signIn({
    required String employeeId,
    required String password,
    required AppRole role,
  }) async {
    // Bypass sementara: input apa pun dianggap valid dan langsung lanjut ke home.
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}
