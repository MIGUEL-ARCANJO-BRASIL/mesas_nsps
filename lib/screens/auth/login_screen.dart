import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mesasnsps/model/provider/auth_provider.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/screens/auth/register_screen.dart';
import 'package:mesasnsps/screens/main/home_navigation_screen.dart';
import 'package:mesasnsps/screens/auth/restricted_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  static const Color _primary = Color(0xFF2D3250);
  static const Color _accent = Color(0xFFD4AF37);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final tableProvider = context.read<TableProvider>();

    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (success && mounted) {
      if (auth.isOrganizador) {
        tableProvider.listenToEvents(auth.uid!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeNavigationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RestrictedScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1A44),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 30),

                // Logo
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _accent,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
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

                const SizedBox(height: 32),

                const Text(
                  'Bem-vindo de volta!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça login para acessar seus eventos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 48),

                // E-mail
                _buildField(
                  controller: _emailController,
                  label: 'E-mail',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
                    if (!v.contains('@')) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Senha
                _buildField(
                  controller: _passwordController,
                  label: 'Senha',
                  icon: Icons.lock_outline,
                  obscure: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a senha';
                    return null;
                  },
                ),

                // Erro
                if (auth.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Botão Login
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: _primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: auth.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF0F1A44),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'ENTRAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Link para cadastro
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem uma conta? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: _accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
      validator: validator,
    );
  }
}
