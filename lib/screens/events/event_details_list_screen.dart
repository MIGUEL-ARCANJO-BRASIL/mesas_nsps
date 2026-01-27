import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/screens/main/financial_dashboard_screen.dart';
import 'package:provider/provider.dart';

class EventDetailsListScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailsListScreen({super.key, required this.event});

  static const Color primaryDark = Color(0xFF0F1A44);
  static const Color accentBlue = Color(0xFF7077A1);
  static const Color bgCanvas = Color(0xFFF6F6F9);

  @override
  Widget build(BuildContext context) {
    // 1. Filtramos apenas as mesas que possuem reserva (ocupadas)
    final occupiedTables = event.tables
        .where((t) => t.status != TableStatusEnum.available)
        .toList();

    // 2. Agrupamos por nome do usuário
    final groupedReservations = groupBy(
      occupiedTables,
      (TableModel t) => t.userName ?? "Desconhecido",
    );

    // 3. Cálculo do faturamento total do evento (apenas mesas com status 'paid')
    final double totalEventRevenue =
        occupiedTables.where((t) => t.status == TableStatusEnum.paid).length *
        event.tablePrice;

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              event.name,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: primaryDark,
                fontSize: 18,
              ),
            ),
            Text(
              "Evento encerrado",
              style: TextStyle(
                color: accentBlue.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryDark,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // BOTÃO PARA VER O DASHBOARD
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              label: const Text(
                "Dashboard",
                style: TextStyle(
                  color: primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                context.read<TableProvider>().selectEvent(event);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FinancialDashboardScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.analytics_rounded, color: primaryDark),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // BARRA DE INFORMAÇÃO DE PREÇO E TOTAL
          _buildPriceHeader(totalEventRevenue),

          Expanded(
            child: groupedReservations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: groupedReservations.length,
                    itemBuilder: (context, index) {
                      String userName = groupedReservations.keys.elementAt(
                        index,
                      );
                      List<TableModel> userTables =
                          groupedReservations[userName]!;

                      // Ordenação numérica das mesas do cliente
                      userTables.sort((a, b) => a.number.compareTo(b.number));

                      return _buildHistoryReservationCard(userName, userTables);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHeader(double totalRevenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: bgCanvas, width: 2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "VALOR UNITÁRIO",
                style: TextStyle(
                  color: accentBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                "R\$ ${event.tablePrice.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: primaryDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "ARRECADAÇÃO FINAL",
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              Text(
                "R\$ ${totalRevenue.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryReservationCard(String name, List<TableModel> tables) {
    final bool isPaid = tables.every((t) => t.status == TableStatusEnum.paid);
    final Color statusColor = isPaid
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE65100);

    final double totalCustomerPaid =
        tables.where((t) => t.status == TableStatusEnum.paid).length *
        event.tablePrice;

    return Container(
      margin: const EdgeInsets.only(top: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: primaryDark.withOpacity(0.05),
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: primaryDark,
                                  ),
                                ),
                                Text(
                                  "Total pago: R\$ ${totalCustomerPaid.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _statusBadge(
                            isPaid ? "PAGO" : "PENDENTE",
                            statusColor,
                          ),
                        ],
                      ),
                      const Divider(height: 32, color: bgCanvas),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // Alinha ao topo caso as mesas quebrem linha
                        children: [
                          // O Expanded aqui é VITAL: ele diz ao Column/Wrap interno para não passar da largura do Card
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.grid_view_rounded,
                                      size: 16,
                                      color: accentBlue.withOpacity(0.5),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text(
                                      "MESAS:",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: accentBlue,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // O Wrap agora sabe exatamente onde deve quebrar a linha
                                Wrap(
                                  spacing: 6.0,
                                  runSpacing: 6.0,
                                  children: tables.map((t) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryDark.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        t.number.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: primaryDark,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ), // Espaço de segurança entre as mesas e o contador
                          // Contador de mesas fixo à direita
                          Text(
                            "${tables.length} mesa(s)",
                            style: TextStyle(
                              color: accentBlue.withOpacity(0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
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
                Icons.search_off,
                size: 80,
                color: Color(0xFF2D3250),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Nenhuma reserva encontrada",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D3250),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Este evento terminou sem registros de mesas ocupadas ou pagas no sistema.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Botão de ação para facilitar o fluxo
          ],
        ),
      ),
    );
  }
}
