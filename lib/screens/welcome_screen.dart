import 'package:flutter/material.dart';
import 'package:mesasnsps/screens/home_navigation_screen.dart';
import 'package:mesasnsps/screens/table_map_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Cor inspirada no manto de Nossa Senhora do Perpétuo Socorro
  static const Color mantoBlue = Color(0xFF0F1A44);
  static const Color goldenDetail = Color(0xFFD4AF37); // Dourado para detalhes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos o azul do manto como cor sólida ou degradê muito sutil
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B2655), // Azul um pouco mais claro no topo
              mantoBlue, // Azul profundo na base
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            // --- IMAGEM COM BORDA DOURADA (Efeito Auréola) ---
            Hero(
              tag: 'logo',
              child: Container(
                width: 260,
                height: 260,
                padding: const EdgeInsets.all(4), // Espessura da borda dourada
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: goldenDetail, // Borda dourada externa
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
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

            const SizedBox(height: 50),

            // --- TEXTOS EM BRANCO/DOURADO ---
            const Text(
              "NSPS",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Colors.white, // Texto branco sobre fundo escuro
                letterSpacing: 4,
              ),
            ),
            const Text(
              "COMUNIDADE NOSSA SENHORA DO\nPERPÉTUO SOCORRO",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: goldenDetail, // Dourado para o nome da paróquia
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),

            const Spacer(),

            // --- BOTÃO DE INICIAR (BRANCO OU DOURADO) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.white, // Botão branco para destaque total
                    foregroundColor: mantoBlue, // Texto azul no botão
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 10,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeNavigationScreen(),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "INICIAR",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Icons.login_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
