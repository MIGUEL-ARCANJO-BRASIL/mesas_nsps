import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/screens/table_map_screen.dart';
import 'package:provider/provider.dart';

class ReservationDetailScreen extends StatelessWidget {
  final String userName;
  final List<TableModel> tables;

  const ReservationDetailScreen({
    super.key,
    required this.userName,
    required this.tables,
  });

  static const Color primaryDark = Color(0xFF2D3250);
  static const Color accentBlue = Color(0xFF7077A1);
  static const Color bgCanvas = Color(0xFFF6F6F9);

  @override
  Widget build(BuildContext context) {
    final firstTable = tables.first;
    final bool isPaid = tables.any((t) => t.status == TableStatusEnum.paid);

    final bool isPix = firstTable.paymentMethod == "Pix";
    final String? imagePath = firstTable.receiptPath;

    final Color statusColor = isPaid
        ? const Color(0xFF2E7D32)
        : const Color(0xFFE65100);

    return Scaffold(
      backgroundColor: bgCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: primaryDark),
        title: const Text(
          "Detalhes da Reserva",
          style: TextStyle(color: primaryDark, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- HEADER DE PERFIL ---
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: primaryDark,
                          child: Text(
                            userName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: primaryDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(
                          isPaid
                              ? "PAGAMENTO CONFIRMADO"
                              : "PAGAMENTO PENDENTE",
                          statusColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- INFO CARDS ---
                  _buildInfoTile(
                    label: "Telefone de Contato",
                    value: firstTable.phoneNumber ?? "Não informado",
                    icon: Icons.phone_android_rounded,
                  ),
                  const SizedBox(height: 16),

                  _buildInfoTile(
                    label: "Mesas Alocadas",
                    value: "Mesa(s): ${tables.map((t) => t.number).join(', ')}",
                    icon: Icons.grid_view_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoTile(
                    label: "Método de Pagamento",
                    value: isPaid
                        ? (isPix ? "Pix" : "Dinheiro")
                        : "Aguardando Pagamento",
                    icon: Icons.payment_rounded,
                  ),
                  const SizedBox(height: 16),

                  if (isPaid && isPix && firstTable.receiptPath != null) ...[
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "COMPROVANTE PIX",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(
                        File(firstTable.receiptPath!),
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 100,
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // --- BARRA DE AÇÕES INFERIOR ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // BOTÃO EDITAR
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final provider = Provider.of<TableProvider>(
                            context,
                            listen: false,
                          );
                          provider.prepareForEdit(
                            tables.map((t) => t.number).toList(),
                          );
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TableMapScreen(),
                            ),
                            (route) => route.isFirst,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Modo de Edição Ativo: Altere as mesas e salve.",
                              ),
                              backgroundColor: Color(0xFF2D3250),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bgCanvas,
                          foregroundColor: primaryDark,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.edit_document),
                        label: const Text(
                          "EDITAR",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),

                  // --- BOTÃO LIBERAR (AGORA FUNCIONAL) ---
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Abre diálogo de confirmação
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Liberar Mesas?"),
                              content: Text(
                                "Deseja realmente remover a reserva de $userName?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    "CANCELAR",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final provider = Provider.of<TableProvider>(
                                      context,
                                      listen: false,
                                    );
                                    // Chama o método para limpar as mesas do usuário
                                    provider.clearReservation(userName);

                                    Navigator.pop(context); // Fecha o diálogo
                                    Navigator.pop(
                                      context,
                                    ); // Volta para a tela de listagem

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Reserva de $userName liberada!",
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "LIBERAR",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFEBEE),
                          foregroundColor: Colors.redAccent,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 55),
                          side: const BorderSide(
                            color: Colors.redAccent,
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(Icons.no_meeting_room_rounded),
                        label: const Text(
                          "LIBERAR MESAS",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgCanvas,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentBlue, size: 22),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: accentBlue.withOpacity(0.7),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: primaryDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 10,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
