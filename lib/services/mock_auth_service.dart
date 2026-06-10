import 'dart:async';
import '../models/user.dart';

// Layanan simulasi Firebase Authentication
class MockAuthService {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Simulasi Login Firebase Auth
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulasi delay jaringan/firebase sebesar 800ms
    await Future.delayed(const Duration(milliseconds: 800));

    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Format email tidak valid');
    }
    if (password.length < 4) {
      throw Exception('Password/NRP harus minimal 4 karakter');
    }

    // Ekstrak nama mahasiswa dari email
    final emailPrefix = email.split('@')[0];
    final nameParts = emailPrefix.split('.');
    final capitalizedName = nameParts.map((part) {
      if (part.isEmpty) return '';
      return part[0].toUpperCase() + part.substring(1);
    }).join(' ');

    // Gunakan password/NRP input sebagai NRP jika berupa angka,
    // atau buat NRP mock jika berisi karakter non-angka
    final nrp = RegExp(r'^\d+$').hasMatch(password) ? password : '5025211042';

    _currentUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: capitalizedName.isNotEmpty ? capitalizedName : 'Mahasiswa Akhir',
      nrp: nrp,
    );

    return _currentUser!;
  }

  // Simulasi Sign Out
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }
}
