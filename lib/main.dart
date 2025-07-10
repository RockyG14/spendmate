import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'local_storage.dart';
import 'screens/home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendMate',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Color(0xFF43B581), // playful green
          secondary: Color(0xFFB6F09C), // light green accent
          background: Color(0xFFF7FFF7),
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Color(0xFF22223B),
          onBackground: Color(0xFF22223B),
          onSurface: Color(0xFF22223B),
        ),
        scaffoldBackgroundColor: Color(0xFFF7FFF7),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF43B581),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF43B581),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF43B581), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF43B581), width: 2),
          ),
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
