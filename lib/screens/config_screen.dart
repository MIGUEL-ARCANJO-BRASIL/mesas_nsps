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

  // 1. Variável para controlar o estado do loading
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TableProvider>(context, listen: false);
      _countController.text = provider.tables.length.toString();
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
              "Informações Atuais",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 12),

            // CARDS DE RESUMO ATUAL
            Row(
              children: [
                _buildSummaryCard(
                  title: "Total de Mesas",
                  value: "${provider.tables.length}",
                  icon: Icons.table_restaurant_rounded,
                  color: primaryDark,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  title: "Preço Unitário",
                  value: "R\$ ${provider.globalPrice.toStringAsFixed(2)}",
                  icon: Icons.payments_outlined,
                  color: Colors.green[700]!,
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            const Text(
              "Editar Configurações",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 20),

            _buildConfigTile(
              label: "Quantidade Total de Mesas",
              subtitle: "Define o tamanho do mapa visual",
              icon: Icons.grid_view_rounded,
              controller: _countController,
              keyboardType: TextInputType.number,
              suffix: "mesas",
            ),

            const SizedBox(height: 16),

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

            // 2. Botão com Animação de Loading
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _isUpdating ? 0 : 4, // Remove sombra no loading
                ),
                onPressed: _isUpdating
                    ? null
                    : _handleUpdate, // Desabilita se estiver carregando
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isUpdating
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "ATUALIZAR INFORMAÇÕES",
                          key: ValueKey("text_btn"),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Função de atualização separada para organizar o código
  Future<void> _handleUpdate() async {
    setState(() => _isUpdating = true);

    final provider = Provider.of<TableProvider>(context, listen: false);
    final int count = int.tryParse(_countController.text) ?? 0;
    final double price = double.tryParse(_priceController.text) ?? 0.0;

    // Simula um delay para a animação ficar visível (opcional)
    await Future.delayed(const Duration(seconds: 1));

    // Atualiza o Provider
    provider.updateEventConfig(count, price);

    if (mounted) {
      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Text("Configurações atualizadas!"),
            ],
          ),
          backgroundColor: const Color(0xFF2D3250),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ... (Widget _buildConfigTile permanece o mesmo)
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

// Widget para os Cards de Resumo (no topo)
Widget _buildSummaryCard({
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            radius: 18,
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
