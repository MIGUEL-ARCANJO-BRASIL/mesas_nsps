import 'package:flutter/material.dart';
import 'package:mesasnsps/screens/home_navigation_screen.dart';
import 'package:mesasnsps/screens/welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late String _greeting;

  @override
  void initState() {
    super.initState();
    _greeting = _getGreeting();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _navigateToNext();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Bom dia";
    if (hour >= 12 && hour < 18) return "Boa tarde";
    return "Boa noite";
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (!mounted) return;

    final bool showWelcome = await _checkSessionExpired();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (_, __, ___) => showWelcome
              ? const WelcomeScreen()
              : const HomeNavigationScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  Future<bool> _checkSessionExpired() async {
    final prefs = await SharedPreferences.getInstance();
    final int? lastEntry = prefs.getInt('last_interaction');
    if (lastEntry == null) return true;
    final lastDate = DateTime.fromMillisecondsSinceEpoch(lastEntry);
    return DateTime.now().difference(lastDate).inMinutes > 240;
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color mantoBlue = Color(0xFF0F1A44);
    const Color goldenDetail = Color(0xFFD4AF37);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF1B2655).withOpacity(0.9), mantoBlue],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // Logo Animado
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.05).animate(
                CurvedAnimation(
                  parent: _logoController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: Hero(
                tag: 'logo',
                child: Container(
                  width: 160,
                  height: 160,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: goldenDetail,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/nsps.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- NOME DO APP ---
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(letterSpacing: 2),
                children: [
                  TextSpan(
                    text: "N.S.P.S ",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  TextSpan(
                    text: "Mesas",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      color: goldenDetail,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // --- SAUDAÇÃO DINÂMICA ---
            Text(
              "$_greeting, seja bem-vindo(a)!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 50),

            // Bolinha de Loading
            const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(goldenDetail),
              ),
            ),

            const SizedBox(height: 40),

            // Barra de Progresso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 3000),
                curve: Curves.easeInOutQuart,
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, value, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        goldenDetail,
                      ),
                      minHeight: 3,
                    ),
                  );
                },
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
