import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/screens/home_navigation_screen.dart';
import 'package:mesasnsps/screens/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // O Provider precisa envolver toda a árvore de widgets que vai usá-lo
    ChangeNotifierProvider(
      create: (context) => TableProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mesas NSPS',
      theme: ThemeData(useMaterial3: true),
      home: const WelcomeScreen(), // Começa pela tela de boas-vindas
    );
  }
}
