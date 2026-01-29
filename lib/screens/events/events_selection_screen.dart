import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mesasnsps/model/event.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/screens/main/table_map_screen.dart';
import 'package:provider/provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

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

    // 1. Pegamos a lista que o Provider já filtrou por data e status
    // 2. Aplicamos apenas o filtro de busca de texto
    List<EventModel> filteredEvents = provider.activeEvents
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
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
          // Botão de Novo Evento agora na barra superior
          TextButton.icon(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _showAddEventDialog(context, provider),
            icon: const Icon(Icons.add, color: Color(0xFFD4AF37), size: 20),
            label: const Text(
              "NOVO",
              style: TextStyle(
                color: TableMapScreen.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchArea(),
          _buildSelectionWarning(provider),
          Expanded(
            child: provider.activeEvents.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final bool isSelected =
                          provider.selectedEvent?.id == event.id;

                      // Passamos as chaves apenas para o primeiro item da lista
                      return _buildEventCard(
                        context,
                        provider,
                        event,
                        isSelected,
                        // Passamos a chave que você já tem para o menuKey
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context, TableProvider provider) {
    final GlobalKey keyFieldName = GlobalKey();
    final GlobalKey keyFieldDate = GlobalKey();
    final GlobalKey keyFieldQtd = GlobalKey();
    final GlobalKey keyFieldPrice = GlobalKey();

    final GlobalKey keyBtnSave = GlobalKey();

    final nameController = TextEditingController();
    final countController = TextEditingController();
    final priceController = TextEditingController();
    final dateController = TextEditingController();
    DateTime? selectedDate;
    bool isLoading = false;
    String? nameError;
    String? dateError;

    final currencyFormatter = CurrencyTextInputFormatter.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    bool tutorialExibido = false;
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
                    // Campo Nome com a Chave
                    _buildField(
                      nameController,
                      "Nome do Evento",
                      Icons.drive_file_rename_outline,
                      enabled: !isLoading,
                      errorText: nameError,
                      key: keyFieldName, // CHAVE AQUI
                    ),
                    const SizedBox(height: 20),
                    // Campo Data com a Chave
                    TextField(
                      key: keyFieldDate, // CHAVE AQUI
                      controller: dateController,
                      readOnly: true,
                      enabled: !isLoading,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                          locale: const Locale("pt", "BR"),
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryDark,
                                onPrimary: Colors.white,
                                onSurface: primaryDark,
                              ),
                            ),
                            child: child!,
                          ),
                        );

                        if (pickedDate != null) {
                          setModalState(() {
                            selectedDate = pickedDate;
                            dateController.text =
                                "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                            dateError = null;
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
                            key: keyFieldQtd,
                            hintText: "100",
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
                            key: keyFieldPrice,
                            hintText: "20.00",
                            inputFormatters: [currencyFormatter],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.all(16),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text("CANCELAR"),
              ),
              ElevatedButton(
                key: keyBtnSave, // CHAVE AQUI
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryDark,
                  minimumSize: const Size(140, 48),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setModalState(() => isLoading = true);

                        // Validação básica
                        if (nameController.text.trim().isEmpty ||
                            selectedDate == null) {
                          setModalState(() {
                            nameError = nameController.text.isEmpty
                                ? "Obrigatório"
                                : null;
                            dateError = selectedDate == null
                                ? "Obrigatório"
                                : null;
                            isLoading = false;
                          });
                          return;
                        }

                        try {
                          double valorFinal = currencyFormatter
                              .getUnformattedValue()
                              .toDouble();
                          await provider.addEvent(
                            nameController.text,
                            int.tryParse(countController.text)!,
                            valorFinal,
                            selectedDate!,
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // Fecha o modal
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Evento criado com sucesso!"),
                                backgroundColor: TableMapScreen.primaryDark,
                              ),
                            );
                          }
                        } catch (e) {
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
                  "Selecionar Evento?",
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Evento '${event.name}' selecionado!",
                                    ),
                                    duration: const Duration(seconds: 2),

                                    backgroundColor: primaryDark,
                                  ),
                                );
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
    String formattedDate = event.date?.toString() ?? "Sem data";

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
                            // Passamos a chave para o botão de menu
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
                              "R\$${event.tablePrice}",
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
    EventModel event, {
    GlobalKey? menuKey, // Adicionado para o tutorial
  }) {
    return PopupMenuButton<String>(
      key: menuKey, // VINCULA A CHAVE AQUI
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.more_horiz_rounded, color: Colors.grey),
      onSelected: (val) => val == 'archive'
          ? _showArchiveDialog(context, provider, event)
          : _showDeleteDialog(context, provider, event),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(Icons.archive_outlined, size: 20, color: Colors.black54),
              SizedBox(width: 8),
              Text("Arquivar"),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: Colors.red),
              SizedBox(width: 8),
              Text("Excluir", style: TextStyle(color: Colors.red)),
            ],
          ),
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
                    // Dentro do onPressed do ElevatedButton no seu _showArchiveDialog:
                    onPressed: isArchiving
                        ? null
                        : () async {
                            setModalState(() => isArchiving = true);

                            // Simula um delay para o loading
                            await Future.delayed(
                              const Duration(milliseconds: 600),
                            );

                            // EXECUTA A AÇÃO NO PROVIDER
                            provider.archiveEvent(event.id);

                            if (context.mounted) {
                              Navigator.pop(context); // Fecha o diálogo

                              // Feedback visual para o usuário
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "'${event.name}' movido para o histórico",
                                  ),
                                  backgroundColor: Colors.blue[700],
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
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
    String? errorText,
    GlobalKey? key,
    String? hintText,
    List<TextInputFormatter>? inputFormatters, // Adicionado aqui
  }) {
    return TextField(
      key: key,
      controller: controller,
      enabled: enabled,
      // Se for número, usamos a configuração de teclado específica
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      inputFormatters: inputFormatters, // Aplicamos os formatadores aqui
      decoration: InputDecoration(
        hintText: hintText,
        labelText: label,
        errorText: errorText,
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

  Widget _buildSelectionWarning(TableProvider provider) {
    // Só exibe se houver eventos na lista, mas nenhum estiver selecionado
    if (provider.activeEvents.isEmpty || provider.selectedEvent != null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.touch_app_outlined, color: Color(0xFFB8860B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Nenhum evento selecionado",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                    fontSize: 14,
                  ),
                ),
                const Text(
                  "Toque em um card abaixo para começar a gerenciar as mesas.",
                  style: TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
