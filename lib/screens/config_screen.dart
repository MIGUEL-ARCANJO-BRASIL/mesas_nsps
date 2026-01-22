import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:provider/provider.dart';

class ConfigsScreen extends StatefulWidget {
  const ConfigsScreen({super.key});

  @override
  State<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends State<ConfigsScreen> {
  final _countController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TableProvider>(context, listen: false);
      _countController.text = provider.tables.length.toString();
      // Use o campo correto do seu provider aqui (ex: pricePerTable ou eventPrice)
      _priceController.text = provider.globalPrice.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TableProvider>(context);
    const primaryDark = Color(0xFF2D3250);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      appBar: AppBar(
        title: const Text(
          "Configurar Informações",
          style: TextStyle(fontWeight: FontWeight.w900, color: primaryDark),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Dados da Comunhão",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 20),

            // Campo: Quantidade de Mesas
            _buildConfigTile(
              label: "Quantidade Total de Mesas",
              subtitle: "Define o tamanho do mapa visual",
              icon: Icons.grid_view_rounded,
              controller: _countController,
              keyboardType: TextInputType.number,
              suffix: "mesas",
            ),

            const SizedBox(height: 16),

            // Campo: Preço por Mesa
            _buildConfigTile(
              label: "Valor da Mesa",
              subtitle: "Preço base para cada mesa",
              icon: Icons.volunteer_activism,
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              suffix: "R\$",
            ),

            const SizedBox(height: 40),

            // Botão Salvar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  final int count = int.tryParse(_countController.text) ?? 0;
                  final double price =
                      double.tryParse(_priceController.text) ?? 0.0;

                  // Atualiza o Provider (Motor do App)
                  provider.updateEventConfig(count, price);

                  // Feedback Visual: SnackBar estilizada
                  ScaffoldMessenger.of(
                    context,
                  ).clearSnackBars(); // Limpa as anteriores
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 12),
                          Text("Configurações atualizadas com sucesso!"),
                        ],
                      ),
                      backgroundColor: Color(0xFF2D3250),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  "ATUALIZAR INFORMAÇÕES",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF7077A1), size: 24),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F6F9),
              suffixText: suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
