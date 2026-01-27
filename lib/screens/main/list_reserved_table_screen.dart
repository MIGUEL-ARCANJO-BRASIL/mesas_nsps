import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/screens/main/reservation_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class ListReservedTableScreen extends StatefulWidget {
  const ListReservedTableScreen({super.key});

  @override
  State<ListReservedTableScreen> createState() =>
      _ListReservedTableScreenState();
}

class _ListReservedTableScreenState extends State<ListReservedTableScreen> {
  String _searchQuery = "";
  String _activeFilter = "Todos";

  static const Color primaryDark = Color(0xFF2D3250);
  static const Color accentBlue = Color(0xFF7077A1);
  static const Color bgCanvas = Color(0xFFF6F6F9);

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context);

    // --- CÁLCULOS FINANCEIROS ---
    // Valor de cada mesa do evento atual
    final double pricePerTable = tableProvider.globalPrice;

    // Todas as mesas ocupadas (Pagas ou Reservadas)
    final occupiedTables = tableProvider.tables
        .where((t) => t.status != TableStatusEnum.available)
        .toList();

    // Valor Total JÁ PAGO
    final double totalRecebido =
        occupiedTables.where((t) => t.status == TableStatusEnum.paid).length *
        pricePerTable;

    // Valor Total POTENCIAL (Se todas as reservas forem pagas)
    final double totalPotencial = occupiedTables.length * pricePerTable;

    // --- LÓGICA DE FILTRAGEM PARA A LISTA ---
    var filteredList = occupiedTables;

    if (_activeFilter == "Pendentes") {
      filteredList = filteredList
          .where((t) => t.status == TableStatusEnum.reserved)
          .toList();
    } else if (_activeFilter == "Pagos") {
      filteredList = filteredList
          .where((t) => t.status == TableStatusEnum.paid)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where(
            (t) => (t.userName ?? "").toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ),
          )
          .toList();
    }

    final groupedReservations = groupBy(
      filteredList,
      (TableModel t) => t.userName ?? "Cliente não identificado",
    );

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Gestão de Reservas",
          style: TextStyle(fontWeight: FontWeight.w900, color: primaryDark),
        ),
      ),
      body: Column(
        children: [
          _buildFinancialSummary(totalRecebido, totalPotencial),
          _buildSearchAndFilterArea(),

          // NOVO: RESUMO FINANCEIRO
          Expanded(
            child: filteredList.isEmpty
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
                      return _buildGroupedReservationCard(userName, userTables);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // WIDGET DO RESUMO FINANCEIRO
  Widget _buildFinancialSummary(double recebido, double potencial) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(20),
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
          _buildSummaryItem(
            "TOTAL PAGO",
            "R\$ ${recebido.toStringAsFixed(0)}",
            Colors.greenAccent,
          ),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildSummaryItem(
            "POTENCIAL TOTAL",
            "R\$ ${potencial.toStringAsFixed(0)}",
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET DE PESQUISA E FILTROS
  Widget _buildSearchAndFilterArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Campo de Texto
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: "Pesquisar por nome do cliente...",
              hintStyle: TextStyle(
                color: accentBlue.withOpacity(0.5),
                fontSize: 14,
              ),
              prefixIcon: const Icon(Icons.search_rounded, color: accentBlue),
              filled: true,
              fillColor: bgCanvas,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Chips de Filtro
          Row(
            children: [
              _filterChip("Todos"),
              const SizedBox(width: 8),
              _filterChip("Pendentes"),
              const SizedBox(width: 8),
              _filterChip("Pagos"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final bool isSelected = _activeFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryDark : bgCanvas,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : accentBlue,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedReservationCard(String name, List<TableModel> tables) {
    final firstTable = tables.first;
    final bool isPaid = tables.any((t) => t.status == TableStatusEnum.paid);
    final Color statusColor = isPaid
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE65100);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ReservationDetailScreen(userName: name, tables: tables),
          ),
        );
      },
      child: Container(
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: primaryDark.withOpacity(0.05),
                    child: Text(
                      name.isNotEmpty
                          ? name[0].toUpperCase()
                          : '?', // Check if not empty
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
                          firstTable.phoneNumber ?? "Sem contato",
                          style: TextStyle(
                            color: accentBlue.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(isPaid ? "PAGO" : "PENDENTE", statusColor),
                ],
              ),
              const Divider(height: 32, color: bgCanvas),
              Row(
                children: [
                  Icon(
                    Icons.grid_view_rounded,
                    size: 18,
                    color: accentBlue.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "MESAS: ${tables.map((t) => t.number).join(', ')}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: primaryDark,
                    ),
                  ),
                ],
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: accentBlue.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            "Nenhum resultado encontrado",
            style: TextStyle(
              color: accentBlue.withOpacity(0.4),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
