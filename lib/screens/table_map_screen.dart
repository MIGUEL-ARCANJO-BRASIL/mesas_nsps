import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/screens/config_screen.dart';
import 'package:provider/provider.dart';

class TableMapScreen extends StatelessWidget {
  const TableMapScreen({super.key});

  // --- CONFIGURAÇÃO VISUAL ---
  static const Color primaryDark = Color(0xFF2D3250);
  static const Color accentBlue = Color(0xFF7077A1);
  static const Color bgCanvas = Color(0xFFF6F6F9);

  static const Color colorLivre = Color(0xFFE8F5E9);
  static const Color colorLivreText = Color(0xFF2E7D32);
  static const Color colorReservada = Color(0xFFFFF3E0);
  static const Color colorReservadaText = Color(0xFFE65100);
  static const Color colorPaga = Color(0xFFFFEBEE);
  static const Color colorPagaText = Color(0xFFC62828);
  static const Color colorSelecionada = Color(0xFFE8EAF6);
  static const Color colorSelecionadaBorder = Color(0xFF3F51B5);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TableProvider>(context);

    // Identificação de dados para Edição
    String? editingName;
    String? editingPhone;
    String? editingMethod;
    bool wasPaid = false;

    if (provider.selectedNumbers.isNotEmpty) {
      final firstTable = provider.tables.firstWhere(
        (t) => t.number == provider.selectedNumbers.first,
        orElse: () => provider.tables.first,
      );
      if (firstTable.userName != null) {
        editingName = firstTable.userName;
        editingPhone = firstTable.phoneNumber;
        editingMethod = firstTable.paymentMethod;
        wasPaid = firstTable.status == TableStatusEnum.paid;
      }
    }

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        centerTitle: false,
        toolbarHeight: 70,
        title: const Text(
          "Mapa de Mesas",
          style: TextStyle(fontWeight: FontWeight.w900, color: primaryDark),
        ),
        actions: [
          if (provider.selectedNumbers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: TextButton.icon(
                onPressed: () => provider.clearSelection(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  backgroundColor: Colors.red.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  "LIMPAR",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: primaryDark),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConfigsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _legendItemCompact(
                    colorLivreText,
                    "Livre",
                    provider.tables
                        .where((t) => t.status == TableStatusEnum.available)
                        .length,
                  ),
                  _vDivider(),
                  _legendItemCompact(
                    colorReservadaText,
                    "Reserva",
                    provider.tables
                        .where((t) => t.status == TableStatusEnum.reserved)
                        .length,
                  ),
                  _vDivider(),
                  _legendItemCompact(
                    colorPagaText,
                    "Paga",
                    provider.tables
                        .where((t) => t.status == TableStatusEnum.paid)
                        .length,
                  ),
                  _vDivider(),
                  _legendItemCompact(
                    colorSelecionadaBorder,
                    "Sua Seleção",
                    provider.selectedNumbers.length,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(100),
            minScale: 0.1,
            maxScale: 3.0,
            child: GridView.builder(
              // Aumentamos o padding inferior para 200 para a lista rolar livre atrás de tudo
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 200),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: provider.tables.length,
              itemBuilder: (context, index) {
                final table = provider.tables[index];
                final isSelected = provider.selectedNumbers.contains(
                  table.number,
                );
                bool isHisTable =
                    editingName != null && table.userName == editingName;

                return GestureDetector(
                  onTap: () {
                    if (table.status == TableStatusEnum.available ||
                        isSelected ||
                        isHisTable) {
                      provider.toggleTableSelection(table.number);
                    }
                  },
                  onLongPress: () {
                    // Se a mesa estiver ocupada ou paga, abre direto a edição dela
                    if (table.status != TableStatusEnum.available) {
                      provider.clearSelection();
                      provider.toggleTableSelection(table.number);
                      _showReservationDialog(
                        context,
                        [table.number],
                        provider,
                        initialName: table.userName,
                        initialPhone: table.phoneNumber,
                        initialPaid: table.status == TableStatusEnum.paid,
                        initialMethod: table.paymentMethod,
                      );
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorSelecionada
                          : _getBgColor(table.status),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colorSelecionadaBorder
                            : _getTextColor(table.status).withOpacity(0.2),
                        width: isSelected ? 2.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "${table.number}",
                        style: TextStyle(
                          color: isSelected
                              ? colorSelecionadaBorder
                              : _getTextColor(table.status),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. A LEGENDA POSICIONADA E O BOTÃO (Unificados para não bugarem)
          Positioned(
            left: 0,
            right: 0,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.selectedNumbers.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () => _showReservationDialog(
                          context,
                          provider.selectedNumbers.toList(),
                          provider,
                          initialName: editingName,
                          initialPhone: editingPhone,
                          initialPaid: wasPaid,
                          initialMethod: editingMethod,
                        ),
                        icon: const Icon(Icons.check_circle_outline, size: 25),
                        label: const Text(
                          "CONFIRMAR SELEÇÃO",
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      // Remova o floatingActionButton: do Scaffold, pois agora ele está dentro do Stack acima!
      floatingActionButton: null,
    );
  }

  Color _getBgColor(TableStatusEnum status) {
    if (status == TableStatusEnum.available) return colorLivre;
    if (status == TableStatusEnum.reserved) return colorReservada;
    return colorPaga;
  }

  Color _getTextColor(TableStatusEnum status) {
    if (status == TableStatusEnum.available) return colorLivreText;
    if (status == TableStatusEnum.reserved) return colorReservadaText;
    return colorPagaText;
  }
}

void _showReservationDialog(
  BuildContext context,
  List<int> selectedNumbers,
  TableProvider provider, {
  String? initialName,
  String? initialPhone,
  bool initialPaid = false,
  String? initialMethod,
}) {
  final nameController = TextEditingController(text: initialName);
  final phoneController = TextEditingController(text: initialPhone);
  final _formKey = GlobalKey<FormState>();

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    initialText: initialPhone,
  );

  // Cálculos de Valores
  final double unitPrice = provider.globalPrice;
  final double totalPrice = unitPrice * selectedNumbers.length;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool isPaid = initialPaid;
      String? method = (initialMethod == "Pix" || initialMethod == "Dinheiro")
          ? initialMethod
          : null;
      XFile? imageFile;
      final ImagePicker picker = ImagePicker();

      return StatefulBuilder(
        builder: (context, setState) {
          bool _isPicking = false;

          Future<void> pickImage() async {
            if (_isPicking) return;
            _isPicking = true;
            try {
              final XFile? selected = await picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 85, // Otimiza o tamanho da imagem
              );
              if (selected != null) {
                setState(() => imageFile = selected);
              }
            } finally {
              _isPicking = false;
            }
          }

          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      initialName != null
                          ? Icons.edit_calendar
                          : Icons.add_task,
                      color: TableMapScreen.primaryDark,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      initialName != null ? "Editar Reserva" : "Nova Reserva",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- CARD DE VALORES ---
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: TableMapScreen.primaryDark.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: TableMapScreen.primaryDark.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "VALOR UNIT.",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "R\$ ${unitPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: Colors.grey,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${selectedNumbers.length} MESA(S) - TOTAL",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "R\$ ${totalPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- CAMPOS DE TEXTO ---
                      TextFormField(
                        controller: nameController,
                        decoration: _inputStyle(
                          "Nome do Cliente",
                          Icons.person_outline,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? "Preencha o nome"
                            : null,
                      ),
                      const SizedBox(height: 15),

                      TextFormField(
                        controller: phoneController,
                        inputFormatters: [phoneMask],
                        keyboardType: TextInputType.phone,
                        decoration: _inputStyle(
                          "WhatsApp / Telefone",
                          Icons.phone_android,
                        ),
                        validator: (v) => (v == null || v.length < 14)
                            ? "Telefone inválido"
                            : null,
                      ),
                      const SizedBox(height: 15),

                      // --- PAGAMENTO ---
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "Pagamento Confirmado?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: isPaid,
                        activeColor: Colors.green,
                        onChanged: (v) => setState(() {
                          isPaid = v;
                          if (!v) {
                            method = null;
                            imageFile = null;
                          }
                        }),
                      ),

                      if (isPaid) ...[
                        DropdownButtonFormField<String>(
                          value: method,
                          decoration: _inputStyle(
                            "Forma de Pagamento",
                            Icons.payments_outlined,
                          ),
                          items: ["Pix", "Dinheiro"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          validator: (v) =>
                              v == null ? "Selecione o método" : null,
                          onChanged: (v) => setState(() => method = v),
                        ),

                        if (method == "Pix") ...[
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: pickImage,
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: imageFile == null
                                      ? Colors.blue
                                      : Colors.green,
                                ),
                              ),
                              child: imageFile == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          "Subir Comprovante Pix",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        File(imageFile!.path),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          ),
                          if (imageFile != null)
                            TextButton.icon(
                              onPressed: () => setState(() => imageFile = null),
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                                size: 16,
                              ),
                              label: const Text(
                                "Remover foto",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "CANCELAR",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TableMapScreen.primaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // SE TUDO ESTIVER OK
                    if (initialName != null) {
                      provider.updateReservation(
                        oldUserName: initialName,
                        newTableNumbers: selectedNumbers,
                        name: nameController.text,
                        phone: phoneMask.getMaskedText(),
                        isPaid: isPaid,
                        method: method,
                        // path: imageFile?.path, // Adicionar no seu provider se quiser salvar no update
                      );
                    } else {
                      provider.confirmReservation(
                        tableNumbers: selectedNumbers,
                        name: nameController.text,
                        phone: phoneMask.getMaskedText(),
                        isPaid: isPaid,
                        method: method,
                        path: imageFile?.path,
                      );
                    }
                    Navigator.pop(context);
                    ScaffoldMessenger.of(
                      context,
                    ).clearSnackBars(); // Limpa as anteriores
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 12),
                            Text("Mesas Reservadas com sucesso!"),
                          ],
                        ),
                        backgroundColor: Color(0xFF2D3250),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                    provider.clearSelection();
                  } else {
                    // FEEDBACK DE ERRO
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "⚠️ Preencha todos os campos obrigatórios!",
                        ),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text(
                  "CONFIRMAR",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

// --- ESTILOS AUXILIARES ---
Widget _buildField(
  TextEditingController controller,
  String label,
  IconData icon, {
  MaskTextInputFormatter? mask,
}) {
  return TextField(
    controller: controller,
    keyboardType: mask != null ? TextInputType.phone : TextInputType.text,
    inputFormatters: mask != null ? [mask] : [],
    decoration: _inputStyle(label, icon),
  );
}

InputDecoration _inputStyle(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: TableMapScreen.accentBlue),
    filled: true,
    fillColor: Colors.grey.withOpacity(0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}

Widget _countBadge(String label, Color color) {
  return Container(
    margin: const EdgeInsets.only(right: 8, top: 4),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
    ),
  );
}

Widget _legendItemCompact(Color color, String label, int count) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        "$label: ",
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
      Text(
        "$count",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    ],
  );
}

Widget _vDivider() => Container(
  height: 12,
  width: 1,
  color: Colors.grey.withOpacity(0.3),
  margin: const EdgeInsets.symmetric(horizontal: 12),
);
