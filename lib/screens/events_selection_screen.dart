import 'package:flutter/material.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:provider/provider.dart';

class EventSelectionScreen extends StatefulWidget {
  const EventSelectionScreen({super.key});

  @override
  State<EventSelectionScreen> createState() => _EventSelectionScreenState();
}

class _EventSelectionScreenState extends State<EventSelectionScreen> {
  String _searchQuery = "";
  final Color primaryDark = const Color(0xFF2D3250);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TableProvider>(context);

    List<EventModel> filteredEvents = provider.events
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    filteredEvents.sort((a, b) {
      if (provider.selectedEvent?.id == a.id) return -1;
      if (provider.selectedEvent?.id == b.id) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Gestão de Eventos",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF2D3250),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined, color: Color(0xFF2D3250)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchArea(),
          Expanded(
            child: provider.events.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final bool isSelected =
                          provider.selectedEvent?.id == event.id;
                      return _buildEventCard(
                        context,
                        provider,
                        event,
                        isSelected,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryDark,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "NOVO EVENTO",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => _showAddEventDialog(context, provider),
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, TableProvider provider) {
    final nameController = TextEditingController();
    final countController = TextEditingController(text: "100");
    final priceController = TextEditingController(text: "20.00");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(24),
          color: primaryDark,
          child: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.white, size: 44),
              SizedBox(width: 12),
              Text(
                "Novo Evento",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _buildField(
                  nameController,
                  "Nome do Evento",
                  Icons.drive_file_rename_outline,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        countController,
                        "Qtd Mesas",
                        Icons.grid_view,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        priceController,
                        "Preço (R\$)",
                        Icons.payments,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              provider.addEvent(
                nameController.text,
                int.tryParse(countController.text) ?? 100,
                double.tryParse(priceController.text) ?? 20.0,
              );
              Navigator.pop(context);
            },
            child: const Text(
              "CRIAR EVENTO",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmEventSelection(
    BuildContext context,
    TableProvider provider,
    EventModel event,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text("Selecionar Evento"),
        content: Text("Deseja gerenciar as mesas de '${event.name}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("NÃO"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryDark),
            onPressed: () {
              provider.setCurrentEvent(event);
              Navigator.pop(context);
            },
            child: const Text("SIM", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    TableProvider provider,
    EventModel event,
    bool isSelected,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? primaryDark : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: ListTile(
        onTap: () {
          if (!isSelected) _confirmEventSelection(context, provider, event);
        },
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? primaryDark : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.event,
            color: isSelected ? Colors.white : primaryDark,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                event.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryDark : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(
                    0.1,
                  ), // COR AQUI DENTRO, PORRA!
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "SELECIONADO",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        subtitle: Text(
          "${event.tables.length} Mesas • R\$ ${event.tablePrice.toStringAsFixed(2)}",
        ),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget _buildSearchArea() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: "Pesquisar evento...",
          prefixIcon: Icon(Icons.search_rounded, color: primaryDark),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded, size: 80, color: Colors.grey[300]),
          const Text(
            "Nenhum evento encontrado",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
