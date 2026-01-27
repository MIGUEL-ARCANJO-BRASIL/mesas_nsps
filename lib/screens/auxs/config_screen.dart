import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:provider/provider.dart';

class ConfigsScreen extends StatefulWidget {
  const ConfigsScreen({super.key});

  @override
  State<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends State<ConfigsScreen> {
  // Remova o 'late' e inicialize aqui ou deixe como nulo
  TextEditingController? _countController;
  TextEditingController? _priceController;
  bool _isUpdating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Pegamos o evento atual do Provider
    final provider = Provider.of<TableProvider>(context);
    final currentEvent = provider.selectedEvent;

    if (currentEvent != null) {
      // Sincronizamos os controllers APENAS se eles ainda não foram criados
      // ou se o valor atual deles for diferente do que está no provider
      // (e não estivermos no meio de uma edição ativa)

      final currentTables = currentEvent.tables.length.toString();
      final currentPrice = currentEvent.tablePrice.toStringAsFixed(2);

      if (_countController == null) {
        _countController = TextEditingController(text: currentTables);
        _priceController = TextEditingController(text: currentPrice);
      } else if (!_isUpdating) {
        // Se o evento mudou "por fora", atualizamos o texto dos campos
        _countController!.text = currentTables;
        _priceController!.text = currentPrice;
      }
    }
  }

  @override
  void dispose() {
    _countController?.dispose();
    _priceController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TableProvider>(context);
    final currentEvent = provider.selectedEvent;
    const primaryDark = Color(0xFF2D3250);

    // Caso de segurança: Nenhum evento selecionado
    if (currentEvent == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F6F9),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: const Text(
            "Configurações",
            style: TextStyle(
              color: Color(0xFF2D3250),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone ilustrativo com fundo suave
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D3250).withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.event_busy_rounded,
                    size: 80,
                    color: Color(0xFF2D3250),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Nenhum evento ativo",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D3250),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Para ajustar as configurações, você precisa selecionar um evento na tela de gestão primeiro.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Botão de ação para facilitar o fluxo
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      appBar: AppBar(
        title: const Text(
          "Configurações  ",
          style: TextStyle(fontWeight: FontWeight.w900, color: primaryDark),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- NOVO: CARD DO EVENTO ATUAL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryDark, Color(0xFF424769)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryDark.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "EVENTO ATUAL",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentEvent.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              "Resumo Operacional",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryDark,
              ),
            ),
            const SizedBox(height: 16),

            // CARDS DE RESUMO ATUAL
            Row(
              children: [
                _buildSummaryCard(
                  title: "Mesas Totais",
                  value: "${provider.tables.length}",
                  icon: Icons.table_restaurant_rounded,
                  color: primaryDark,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  title: "Preço por Mesa",
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
              label: "Quantidade de Mesas",
              subtitle: "Aumentar ou diminuir o mapa",
              icon: Icons.grid_view_rounded,
              controller: _countController!,
              keyboardType: TextInputType.number,
              suffix: "unid",
            ),

            const SizedBox(height: 16),

            _buildConfigTile(
              label: "Novo Valor Unitário",
              subtitle: "Altera o preço de todas as mesas",
              icon: Icons.monetization_on_outlined,
              controller: _priceController!,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              suffix: "R\$",
            ),

            const SizedBox(height: 40),

            // BOTÃO DE ATUALIZAÇÃO
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: _isUpdating ? 0 : 4,
                ),
                onPressed: _isUpdating ? null : _handleUpdate,
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
                          "SALVAR ALTERAÇÕES",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    setState(() => _isUpdating = true);

    final provider = Provider.of<TableProvider>(context, listen: false);
    final int count = int.tryParse(_countController!.text) ?? 0;
    final double price = double.tryParse(_priceController!.text) ?? 0.0;

    await Future.delayed(const Duration(milliseconds: 800));

    // Chama a função do seu Provider que já lida com a lógica de ajuste de lista
    provider.updateEventConfig(count, price);

    if (mounted) {
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dados do evento sincronizados com sucesso!"),
          backgroundColor: Color(0xFF2D3250),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
            color: Colors.black.withOpacity(0.03),
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
            style: const TextStyle(fontWeight: FontWeight.bold),
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
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
