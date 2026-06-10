import 'package:flutter/material.dart';
import '../services/app_state.dart';
import 'login_screen.dart';
import 'home_screen.dart';

// Halaman Splash Screen yang bersih dan minimalis dengan logo Rentalin
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Tampilkan splash screen selama 2.5 detik
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final appState = AppState.instance;
    
    // Navigasi ke halaman utama jika sudah login, atau ke login jika belum
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => appState.isAuthenticated 
            ? const HomeScreen() 
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFD0D47A1); // Deep Campus Blue

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFFF5F7FB),
              themeColor.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Rentalin
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.autorenew_rounded,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Nama Platform
                  const Text(
                    'Rentalin',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1E1E1E),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Tagline Mahasiswa
                  Text(
                    'One-Stop Rent Solution Mahasiswa Surabaya',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 120),
                  // Indikator loading halus di bagian bawah
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
