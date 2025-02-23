import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stubit/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/auth_wrapper.dart';
import 'package:stubit/screens/register_habits_screens/register_T_habit_screen.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromRGBO(139, 34, 227, 1),
  background: const Color.fromRGBO(139, 34, 227, 1),
);

final theme = ThemeData().copyWith(
  useMaterial3: true,
  scaffoldBackgroundColor: colorScheme.background,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleMedium: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.ubuntuCondensed(
      fontWeight: FontWeight.bold,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Color(0xFF181A25),
    filled: true,
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
    ),
    labelStyle: TextStyle(
      color: Colors.white,
    ),
    hintStyle: TextStyle(
      color: Colors.white,
    ),
  ),
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stu-bit',
      theme: theme,
      locale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: RegisterTHabitScreen(),
    );
  }
}
