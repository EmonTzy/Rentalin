import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const RentalinApp());
}

// Aplikasi Utama Rentalin
class RentalinApp extends StatelessWidget {
  const RentalinApp({super.key});

  @override
  Widget build(BuildContext context) {
    const campusBlue = Color(0xFD0D47A1); // Deep Campus Blue (#0D47A1)
    const slateBackground = Color(0xFFF8FAFC); // Abu-abu muda bersih

    return MaterialApp(
      title: 'Rentalin',
      debugShowCheckedModeBanner: false,
      
      // Pengaturan Tema Global
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: campusBlue,
        scaffoldBackgroundColor: slateBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: campusBlue,
          primary: campusBlue,
          secondary: const Color(0xFF1565C0),
          surface: slateBackground,
        ),
        
        // Desain Font Default (System Sans-Serif)
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E)),
          bodyLarge: TextStyle(color: Color(0xFF424242)),
          bodyMedium: TextStyle(color: Color(0xFF555555)),
        ),

        // Konfigurasi Input Form
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        // Konfigurasi ChoiceChip secara global
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: campusBlue,
          brightness: Brightness.light,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      
      // Halaman Awal
      home: const SplashScreen(),
    );
  }
}
