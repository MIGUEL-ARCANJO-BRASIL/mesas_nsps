import 'package:flutter/material.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/screens/table_map_screen.dart';
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
    final dateController = TextEditingController(); // Controller para a data
    DateTime? selectedDate;
    bool isLoading = false;
    String? nameError;
    String? dateError;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
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
                      enabled: !isLoading,
                      errorText:
                          nameError, // Adicione este parâmetro se o seu _buildField suportar
                    ),
                    const SizedBox(height: 20),
                    // CAMPO DE DATA
                    TextField(
                      controller: dateController,
                      readOnly:
                          true, // Mantém apenas leitura para forçar o uso do calendário
                      enabled: !isLoading,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          // IMPORTANTE: Use o setModalState para atualizar o diálogo
                          setModalState(() {
                            selectedDate = pickedDate;
                            dateController.text =
                                "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                            dateError = null; // Limpa o erro ao selecionar
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Data do Evento",
                        errorText: dateError,
                        prefixIcon: const Icon(Icons.calendar_month, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: isLoading,
                        fillColor: isLoading
                            ? Colors.grey[100]
                            : Colors.transparent,
                      ),
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
                            enabled: !isLoading,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            priceController,
                            "Preço (R\$)",
                            Icons.payments,
                            isNumber: true,
                            enabled: !isLoading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text("CANCELAR"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  minimumSize: const Size(140, 48),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setModalState(() {
                          nameError = null;
                          dateError = null;
                        });
                        bool isValid = true;

                        if (nameController.text.trim().isEmpty) {
                          setModalState(
                            () => nameError = "O nome é obrigatório",
                          );
                          isValid = false;
                        }
                        if (dateController.text.isEmpty) {
                          setModalState(() => dateError = "Selecione uma data");
                          isValid = false;
                        }
                        if (!isValid) return;

                        setModalState(() => isLoading = true);

                        await Future.delayed(const Duration(milliseconds: 800));

                        try {
                          provider.addEvent(
                            nameController.text,
                            int.tryParse(countController.text) ?? 100,
                            double.tryParse(priceController.text) ?? 20.0,
                            // date: selectedDate, // Enviar a data para o provider se necessário
                          );

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Evento criado com sucesso!"),
                                backgroundColor: Color(0xFF2D3250),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.pop(context);
                          }
                        } catch (e) {
                          if (context.mounted)
                            setModalState(() => isLoading = false);
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "CRIAR EVENTO",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmEventSelection(
    BuildContext context,
    TableProvider provider,
    EventModel event,
  ) {
    bool isSelecting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: primaryDark.withOpacity(0.1),
                  child: Icon(
                    Icons.touch_app_rounded,
                    color: primaryDark,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Trocar Evento?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  "Deseja gerenciar as mesas de\n'${event.name}'?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSelecting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text("AGORA NÃO"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDark,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: isSelecting
                            ? null
                            : () async {
                                setModalState(() => isSelecting = true);
                                await Future.delayed(
                                  const Duration(milliseconds: 600),
                                );
                                provider.setCurrentEvent(event);
                                if (context.mounted) Navigator.pop(context);
                              },
                        child: isSelecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("CONFIRMAR"),
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

  Widget _buildEventCard(
    BuildContext context,
    TableProvider provider,
    EventModel event,
    bool isSelected,
  ) {
    // Formata a data para dd/MM/yy
    // Garante que a data seja uma String e esteja no formato correto
    String formattedDate = event.date?.toString() ?? "Sem data";

    // Se a data vier no formato ISO (2026-01-23), invertemos para o padrão BR
    if (formattedDate.contains('-')) {
      try {
        DateTime dt = DateTime.parse(formattedDate);
        formattedDate =
            "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      } catch (e) {
        // Caso falhe, mantém o que está
      }
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? primaryDark.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
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
              // Indicador lateral de seleção
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                color: isSelected ? primaryDark : Colors.grey[300],
              ),
              Expanded(
                child: InkWell(
                  onTap: () => isSelected
                      ? null
                      : _confirmEventSelection(context, provider, event),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LINHA SUPERIOR: ÍCONE + NOME + MENU
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? primaryDark.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isSelected
                                    ? Icons.event_available
                                    : Icons.event,
                                color: isSelected
                                    ? primaryDark
                                    : Colors.grey[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.name.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                      color: isSelected
                                          ? primaryDark
                                          : Colors.black87,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  if (isSelected)
                                    Text(
                                      "Evento em Gerenciamento",
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _buildPopupMenu(context, provider, event),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // GRID DE INFORMAÇÕES (Data, Mesas, Valor)
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
                              "VALOR",
                              "R\$${event.tablePrice.toStringAsFixed(0)}",
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

  // Widget Auxiliar para os itens de informação
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
            Icon(icon, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? Colors.blue[800] : Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.grey[200]);
  }

  Widget _buildPopupMenu(
    BuildContext context,
    TableProvider provider,
    EventModel event,
  ) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
      onSelected: (val) => val == 'archive'
          ? _showArchiveDialog(context, provider, event)
          : _showDeleteDialog(context, provider, event),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'archive', child: Text("Arquivar")),
        const PopupMenuItem(
          value: 'delete',
          child: Text("Excluir", style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    TableProvider provider,
    EventModel event,
  ) {
    bool isDeleting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          icon: Icon(
            Icons.delete_forever_rounded,
            color: Colors.red[400],
            size: 40,
          ),
          title: const Text("Excluir Evento"),
          content: Text(
            "Esta ação é definitiva. Todos os dados de '${event.name}' serão apagados para sempre.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(context),
              child: Text(
                "CANCELAR",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[50],
                foregroundColor: Colors.red,
                elevation: 0,
                minimumSize: const Size(120, 45),
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      setModalState(() => isDeleting = true);
                      await Future.delayed(const Duration(milliseconds: 800));
                      provider.deleteEvent(event.id);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Evento removido"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Text(
                      "EXCLUIR AGORA",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showArchiveDialog(
    BuildContext context,
    TableProvider provider,
    EventModel event,
  ) {
    bool isArchiving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          icon: Icon(Icons.archive_rounded, color: Colors.blue[700], size: 40),
          title: const Text("Arquivar Evento"),
          content: const Text(
            "O evento sairá da visualização principal, mas poderá ser recuperado nos arquivos.",
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isArchiving
                        ? null
                        : () => Navigator.pop(context),
                    child: const Text("VOLTAR"),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isArchiving
                        ? null
                        : () async {
                            setModalState(() => isArchiving = true);
                            await Future.delayed(
                              const Duration(milliseconds: 600),
                            );
                            // provider.toggleArchiveEvent(event.id); // Implementar no provider
                            if (context.mounted) Navigator.pop(context);
                          },
                    child: isArchiving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("ARQUIVAR"),
                  ),
                ),
              ],
            ),
          ],
        ),
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
    bool enabled = true,
    String? errorText, // Adicione isso
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText, // E isso
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
