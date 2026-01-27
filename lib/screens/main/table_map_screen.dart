import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/screens/auxs/config_screen.dart';
import 'package:provider/provider.dart';

class TableMapScreen extends StatelessWidget {
  const TableMapScreen({super.key});

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

    String? editingName;
    String? editingPhone;
    String? editingMethod;
    String? editingPath;
    bool wasPaid = false;

    if (provider.selectedNumbers.isNotEmpty) {
      try {
        final firstTable = provider.tables.firstWhere(
          (t) =>
              provider.selectedNumbers.contains(t.number) && t.userName != null,
        );
        editingName = firstTable.userName;
        editingPhone = firstTable.phoneNumber;
        editingMethod = firstTable.paymentMethod;
        editingPath = firstTable.receiptPath;
        wasPaid = firstTable.status == TableStatusEnum.paid;
      } catch (_) {
        editingName = null;
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
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            padding: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(100),
        minScale: 0.1,
        maxScale: 2.0,
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 250),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: provider.tables.length + 18,
          itemBuilder: (context, index) {
            List<int> areaCentral = [3, 4, 5, 12, 13, 14];
            if (areaCentral.contains(index)) {
              return Container(
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: index == 4
                    ? const Icon(
                        Icons.mic_external_on,
                        color: Colors.white,
                        size: 18,
                      )
                    : null,
              );
            }

            int tablesToSubtract = 0;
            if (index > 5) tablesToSubtract += 3;
            if (index > 14) tablesToSubtract += 3;
            int tableIndex = index - tablesToSubtract;

            if (tableIndex >= provider.tables.length || tableIndex < 0)
              return const SizedBox.shrink();

            final table = provider.tables[tableIndex];
            final isSelected = provider.selectedNumbers.contains(table.number);
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
                // Lógica de "segurar" (clique longo)
                if (table.status != TableStatusEnum.available) {
                  _showReservationDialog(
                    context,
                    [table.number],
                    provider,
                    initialName: table.userName,
                    initialPhone: table.phoneNumber,
                    initialPaid: table.status == TableStatusEnum.paid,
                    initialMethod: table.paymentMethod,
                    initialPath: table.receiptPath,
                  );
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorSelecionada
                      : _getBgColor(table.status),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? colorSelecionadaBorder
                        : _getTextColor(table.status).withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    "${table.number}",
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? colorSelecionadaBorder
                          : _getTextColor(table.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: provider.selectedNumbers.isNotEmpty
          ? Padding(
              // Adiciona um recuo no fundo para subir o botão acima da HomeNavigationScreen
              padding: const EdgeInsets.only(bottom: 150),
              child: FloatingActionButton.extended(
                key: const ValueKey('confirm_fab'),
                backgroundColor: primaryDark,
                elevation: 8, // Aumentamos a sombra para dar profundidade
                icon: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                ),
                label: Text(
                  "CONFIRMAR ${provider.selectedNumbers.length == 1 ? '1 MESA' : '${provider.selectedNumbers.length} MESAS'}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  _showReservationDialog(
                    context,
                    provider.selectedNumbers.toList(),
                    provider,
                    initialName: editingName,
                    initialPhone: editingPhone,
                    initialMethod: editingMethod,
                    initialPath: editingPath,
                    initialPaid: wasPaid,
                  );
                },
              ),
            )
          : null,
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
  String? initialPath,
}) {
  final nameController = TextEditingController(text: initialName);
  final phoneController = TextEditingController(text: initialPhone);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
  );

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
      XFile? imageFile = initialPath != null ? XFile(initialPath) : null;
      bool isLoading = false;

      return StatefulBuilder(
        builder: (context, setState) {
          final ImagePicker picker = ImagePicker();

          return AlertDialog(
            insetPadding: const EdgeInsets.all(20),
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            titlePadding: EdgeInsets.zero,
            title: Container(
              padding: const EdgeInsets.all(24),
              color: TableMapScreen.primaryDark,
              child: Row(
                children: [
                  Icon(
                    initialName != null ? Icons.edit_calendar : Icons.add_task,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    initialName != null ? "Editar Reserva" : "Nova Reserva",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.95,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Card de Resumo de Preço
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
                      // ... dentro do Column, logo após o Container do resumo de preço:
                      const SizedBox(height: 15),

                      // NOVO: Listagem das mesas selecionadas
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: selectedNumbers.map((number) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: TableMapScreen.primaryDark,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.chair_alt_rounded,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Mesa $number",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 20),
                      // ... segue o TextFormField de Nome

                      // Campo Nome
                      TextFormField(
                        controller: nameController,
                        decoration: _inputStyle(
                          "Nome do Cliente",
                          Icons.person_outline,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return "O nome é obrigatório";
                          if (v.trim().length < 3) return "Nome muito curto";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Campo Telefone
                      TextFormField(
                        controller: phoneController,
                        inputFormatters: [phoneMask],
                        keyboardType: TextInputType.phone,
                        decoration: _inputStyle(
                          "WhatsApp / Telefone",
                          Icons.phone_android,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty)
                            return "O telefone é obrigatório";
                          if (v.length < 14) return "Telefone incompleto";
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Switch de Pagamento
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          "Pagamento Confirmado?",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: isPaid,
                        activeColor: Colors.green,
                        onChanged: (v) => setState(() => isPaid = v),
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
                          onChanged: (v) => setState(() => method = v),
                        ),
                        if (method == "Pix") ...[
                          const SizedBox(height: 15),
                          InkWell(
                            onTap: () async {
                              final XFile? selected = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (selected != null)
                                setState(() => imageFile = selected);
                            },
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
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.cloud_upload_outlined,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          "Subir Comprovante",
                                          style: TextStyle(color: Colors.blue),
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
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              if (!isLoading)
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
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => isLoading = true);

                          try {
                            if (initialName != null) {
                              await provider.updateReservation(
                                oldUserName: initialName,
                                newTableNumbers: selectedNumbers,
                                name: nameController.text,
                                phone: phoneController.text,
                                isPaid: isPaid,
                                method: method,
                                path: imageFile?.path,
                              );
                            } else {
                              await provider.confirmReservation(
                                tableNumbers: selectedNumbers,
                                name: nameController.text,
                                phone: phoneController.text,
                                isPaid: isPaid,
                                method: method,
                                path: imageFile?.path,
                              );
                            }

                            if (context.mounted) {
                              Navigator.pop(context); // Fecha o Dialog

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    initialName != null
                                        ? "Atualizado!"
                                        : "Reservado!",
                                  ),
                                  backgroundColor: TableMapScreen.primaryDark,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              provider.clearSelection();
                            }
                          } catch (e) {
                            setState(() => isLoading = false);
                            // Opcional: mostrar erro se a gravação falhar
                          }
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "CONFIRMAR",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      );
    },
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

Widget _legendItemCompact(Color color, String label, int count) {
  return Row(
    children: [
      Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        "$label: ",
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),
      Text(
        "$count",
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
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
