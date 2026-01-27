import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:provider/provider.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/screens/events/event_details_list_screen.dart';
import 'package:intl/intl.dart';

class EventHistoryScreen extends StatelessWidget {
  const EventHistoryScreen({super.key});

  static const Color primaryDark = Color(0xFF0F1A44);
  static const Color accentGold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    // Escutando as mudanças no Provider
    final provider = context.watch<TableProvider>();
    final List<EventModel> history = provider.historyEvents;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F9),
      appBar: AppBar(
        title: const Text(
          "Histórico de Eventos",
          style: TextStyle(fontWeight: FontWeight.w900, color: primaryDark),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final event = history[index];
                return _buildHistoryCard(context, provider, event);
              },
            ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    TableProvider provider,
    EventModel event,
  ) {
    String formattedDate = DateFormat('dd/MM/yyyy').format(event.date);

    // Cálculo do total arrecadado baseado no status das mesas
    final double totalArrecadado =
        event.tables.where((t) => t.status.name == 'paid').length *
        event.tablePrice;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Container(width: 8, color: accentGold),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EventDetailsListScreen(event: event),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: primaryDark,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                event.name.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  color: primaryDark,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // BOTÃO DE DESARQUIVAR
                            IconButton(
                              onPressed: () => _showUnarchiveDialog(
                                context,
                                provider,
                                event,
                              ),
                              icon: const Icon(
                                Icons.unarchive_rounded,
                                color: Colors.blue,
                              ),
                              tooltip: "Restaurar Evento",
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(
                              Icons.calendar_today_outlined,
                              "DATA",
                              formattedDate,
                            ),
                            _buildVerticalDivider(),
                            _buildInfoItem(
                              Icons.grid_view_rounded,
                              "MESAS",
                              "${event.tables.length}",
                            ),
                            _buildVerticalDivider(),
                            _buildInfoItem(
                              Icons.payments_outlined,
                              "ARRECADADO",
                              "R\$ ${totalArrecadado.toStringAsFixed(0)}",
                              isHighlight: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnarchiveDialog(
    BuildContext context,
    TableProvider provider,
    EventModel event,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        icon: const Icon(
          Icons.settings_backup_restore_rounded,
          color: Colors.blue,
          size: 40,
        ),
        title: const Text("Restaurar Evento"),
        content: Text(
          "O evento '${event.name}' voltará para a lista de eventos ativos.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              provider.unarchiveEvent(event.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("'${event.name}' restaurado com sucesso!"),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text("RESTAURAR"),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text(
            "Nenhum evento no histórico",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 10, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? Colors.green[700] : primaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() =>
      Container(width: 1, height: 25, color: Colors.grey[200]);
}
