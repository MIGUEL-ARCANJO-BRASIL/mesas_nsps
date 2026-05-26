import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mesasnsps/model/provider/auth_provider.dart';
import 'package:mesasnsps/screens/auth/login_screen.dart';

class RestrictedScreen extends StatelessWidget {
  const RestrictedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A44),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_clock,
                    color: Color(0xFFD4AF37),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Acesso em Breve',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sua conta ainda não tem permissão para acessar os eventos.\nEntre em contato com o organizador.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (_) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFD4AF37),
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'SAIR DA CONTA',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
