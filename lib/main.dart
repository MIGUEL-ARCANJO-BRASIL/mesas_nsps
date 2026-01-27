import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/preferences_provider.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/screens/auxs/splash_screen.dart'; // Importe sua nova tela aqui
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // O TableProvider que você já tinha
        ChangeNotifierProvider(create: (_) => TableProvider()),

        // ADICIONE O PreferencesProvider AQUI:
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Adiciona o observador para detectar quando o app minimiza ou fecha
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Remove o observador ao destruir o widget
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Monitora as mudanças de estado do aplicativo
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Salva o momento exato que o usuário saiu ou minimizou o app
      _saveTimestamp();
    }
  }

  /// Salva o timestamp atual no SharedPreferences
  Future<void> _saveTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_interaction',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mesas NSPS',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Português Brasil
      ],
      locale: const Locale('pt', 'BR'),
      theme: ThemeData(
        useMaterial3: true,
        // Define a fonte padrão ou cores globais se desejar
        primarySwatch: Colors.blue,
      ),
      // A porta de entrada agora é SEMPRE a SplashScreen
      // Ela será responsável por decidir se vai para Welcome ou Home após o loading
      home: const SplashScreen(),
    );
  }
}
