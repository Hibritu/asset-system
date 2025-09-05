import 'package:asset/providers/rental_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:asset/providers/auth_provider.dart';
import 'package:asset/screens/auth/login_screen.dart';
//import 'package:asset/home.dart'; // HomeScreen
//import 'package:shared_preferences/shared_preferences.dart';
//// "email": "hjk@example.com",
  //"password": "12345678"
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Preload SharedPreferences data
  final authProvider = AuthProvider();
  await authProvider.loadAuthData();

  runApp(
    MultiProvider(
      providers: [
        
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
           ChangeNotifierProvider(create: (_) => RentalProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeMode = authProvider.themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Asset Lending System',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
          primary: const Color(0xFF2E7D32),
          secondary: const Color(0xFF8BC34A),
          surface: Colors.white,
          background: const Color(0xFFF5F5F5),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
          primary: const Color(0xFF4CAF50),
          secondary: const Color(0xFF7CB342),
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: themeMode,
      home: const LoginScreen(),
     
    );
  }
}
