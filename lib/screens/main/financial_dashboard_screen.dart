import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mesasnsps/services/financial_service.dart';
import 'package:provider/provider.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';

class FinancialDashboardScreen extends StatelessWidget {
  const FinancialDashboardScreen({super.key});

  // --- PADRONIZAÇÃO DE TEMA ---
  static const Color primaryDark = Color(
    0xFF0F1A44,
  ); // Azul marinho mais profundo
  static const Color accentBlue = Color(0xFF7077A1);
  static const Color bgCanvas = Color(0xFFF6F6F9);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningOrange = Color(0xFFE65100);

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no TableProvider
    final event = context.watch<TableProvider>().selectedEvent;

    if (event == null) {
      return const Scaffold(
        body: Center(child: Text("Nenhum evento selecionado")),
      );
    }

    // --- LÓGICA DE CÁLCULO ---
    final double precoUnico = event.tablePrice;
    final int totalMesasEvento = event.tables.length;
    final double precoEsperadoTotal = totalMesasEvento * precoUnico;

    final int qtdPagas = event.tables
        .where((t) => t.status == TableStatusEnum.paid)
        .length;
    final int qtdPendentes = event.tables
        .where((t) => t.status == TableStatusEnum.reserved)
        .length;

    final double precoRecebido = qtdPagas * precoUnico;
    final double precoPendente = qtdPendentes * precoUnico;
    final double precoPotencialAtual = precoRecebido + precoPendente;
    final double valorVazio = precoEsperadoTotal - precoPotencialAtual;

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Dashboard Financeiro",
          style: TextStyle(fontWeight: FontWeight.w900, color: primaryDark),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD DE PREÇO UNITÁRIO
            _buildUnitPriceCard(precoUnico),

            const SizedBox(height: 24),
            _buildSectionTitle("Visão Geral"),
            const SizedBox(height: 12),

            // GRÁFICO EM DESTAQUE
            (precoRecebido == 0 && precoPendente == 0 && valorVazio == 0)
                ? _buildEmptyState()
                : _buildChartCard(precoRecebido, precoPendente, valorVazio),

            const SizedBox(height: 24),
            _buildSectionTitle("Detalhamento de Valores"),
            const SizedBox(height: 12),

            // CARD DE DETALHES
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: primaryDark.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildDataRow(
                    "Recebido (Pago)",
                    precoRecebido,
                    successGreen,
                    Icons.check_circle_rounded,
                  ),
                  const Divider(height: 24, color: bgCanvas),
                  _buildDataRow(
                    "Pendente (Reservado)",
                    precoPendente,
                    warningOrange,
                    Icons.pending_rounded,
                  ),
                  const Divider(height: 24, color: bgCanvas),
                  _buildDataRow(
                    "Total Potencial",
                    precoPotencialAtual,
                    primaryDark,
                    Icons.pie_chart_outline_rounded,
                  ),
                  const Divider(height: 32, color: bgCanvas, thickness: 2),
                  _buildDataRow(
                    "Máximo do Evento",
                    precoEsperadoTotal,
                    accentBlue,
                    Icons.account_balance_wallet_rounded,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32), // Espaçamento maior antes do botão
            // NOVO: Botão posicionado abaixo do detalhamento
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showExportOptions(
                    context,
                    event,
                    precoRecebido,
                    precoPendente,
                    precoEsperadoTotal,
                  );
                },
                icon: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Colors.white,
                ),
                label: const Text(
                  "EXPORTAR RELATÓRIO",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: accentBlue.withOpacity(0.7),
        fontWeight: FontWeight.w900,
        fontSize: 12,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildUnitPriceCard(double preco) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_rounded,
            color: Colors.white70,
            size: 24,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "VALOR POR MESA",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                "R\$ ${preco.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(double pago, double pendente, double vazio) {
    // Evita divisão por zero para o cálculo da porcentagem central
    final double total = (pago + pendente + vazio) == 0
        ? 1
        : (pago + pendente + vazio);
    final String percentual = ((pago / total) * 100).toStringAsFixed(0);

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryDark.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "PAGO",
                      style: TextStyle(
                        color: accentBlue.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      "$percentual%",
                      style: const TextStyle(
                        color: primaryDark,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 65,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        color: successGreen,
                        value: pago > 0 ? pago : 0.001,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: warningOrange,
                        value: pendente > 0 ? pendente : 0.001,
                        radius: 20,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        color: bgCanvas,
                        value: vazio > 0 ? vazio : 0.001,
                        radius: 15,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSmallLegend("Pago", successGreen),
              _buildSmallLegend("Pendente", warningOrange),
              _buildSmallLegend("Livre", Colors.grey.shade300),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLegend(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: primaryDark,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDataRow(
    String label,
    double value,
    Color color,
    IconData icon, {
    bool isTotal = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isTotal ? primaryDark : accentBlue,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          "R\$ ${value.toStringAsFixed(2)}",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 18 : 15,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_rounded,
              color: accentBlue.withOpacity(0.2),
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              "Sem dados financeiros para exibir.",
              style: TextStyle(color: accentBlue, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(
    BuildContext context,
    dynamic event,
    double pago,
    double pendente,
    double total,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "Exportar Relatório",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F1A44),
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(
                  Icons.print_rounded,
                  color: Color(0xFF0F1A44),
                ),
                title: const Text("Visualizar e Imprimir"),
                subtitle: const Text("Abrir visualizador padrão"),
                onTap: () {
                  Navigator.pop(context);
                  FinancialService.printReport(event, pago, pendente, total);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(
                  Icons.file_download_rounded,
                  color: Colors.green,
                ),
                title: const Text("Baixar PDF"),
                subtitle: const Text("Salvar e compartilhar arquivo"),
                onTap: () {
                  Navigator.pop(context);
                  FinancialService.downloadReport(
                    context,
                    event,
                    pago,
                    pendente,
                    total,
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
