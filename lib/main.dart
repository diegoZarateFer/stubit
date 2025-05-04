import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:stubit/firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stubit/screens/InitWrapper.dart';

/// Handler para mensajes recibidos en background o cuando la app está terminada
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message ID: ${message.messageId}');
}

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

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    // Solicitar permisos (más relevante para iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Permiso concedido para notificaciones');
    } else {
      print('❌ Permiso denegado para notificaciones');
    }

    // Obtener token del dispositivo
    String? token = await _messaging.getToken();
    print('📱 FCM Token: $token');

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 Mensaje en foreground: ${message.notification?.title}');
      // Puedes mostrar un diálogo, snackbar, etc.
    });

    // Cuando el usuario toca la notificación y abre la app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          '📬 Mensaje abierto desde background: ${message.notification?.title}');
      // Puedes navegar a una pantalla específica aquí
    });
  }

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
      home: const InitWrapper(),
    );
  }
}
