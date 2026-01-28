import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mesasnsps/model/provider/preferences_provider.dart';

class WelcomeComponent {
  static Future<void> show(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Welcome",
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 25),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ícone de destaque com efeito de fundo
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3250).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 40,
                      color: Color(0xFF2D3250),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Seja bem-vindo! 👋",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2D3250),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Como você prefere explorar o Mesas NSPS pela primeira vez?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Opção: Tutorial
                  _buildOption(
                    context: context,
                    label: "QUERO O TOUR GUIADO",
                    subtitle: "Aprenda as funções passo a passo",
                    icon: Icons.lightbulb_outline_rounded,
                    isPrimary: true,
                    onTap: () {
                      context.read<PreferencesProvider>().setTutorialMode(true);
                      Navigator.pop(context);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Opção: Direto
                  _buildOption(
                    context: context,
                    label: "PULAR E IR DIRETO",
                    subtitle: "Já conheço o sistema",
                    icon: Icons.rocket_launch_outlined,
                    isPrimary: false,
                    onTap: () {
                      context.read<PreferencesProvider>().setTutorialMode(
                        false,
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          ),
        );
      },
    );
  }

  static Widget _buildOption({
    required BuildContext context,
    required String label,
    required String subtitle,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    const primaryColor = Color(0xFF2D3250);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor, width: 2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : primaryColor,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isPrimary ? Colors.white : primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isPrimary ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isPrimary ? Colors.white : primaryColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildTutorialStep(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2D3250),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
