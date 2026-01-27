import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/screens/main/table_map_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
                  // --- INFO CARDS ---
                  _buildInfoTile(
                    label: "Telefone de Contato",
                    value: firstTable.phoneNumber ?? "Não informado",
                    icon: Icons.phone_android_rounded,
                    // Adicionamos a ação do WhatsApp aqui
                    trailing: firstTable.phoneNumber != null
                        ? IconButton(
                            icon: const Icon(
                              Icons
                                  .chat_bubble_outline_rounded, // Ícone nativo que funciona como const
                              color: Color(0xFF25D366),
                              size: 28,
                            ),
                            onPressed: () => _launchWhatsApp(
                              firstTable.phoneNumber!,
                              userName,
                              isPaid,
                            ),
                          )
                        : null,
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
                    GestureDetector(
                      onTap: () => _showFullScreenImage(
                        context,
                        firstTable.receiptPath!,
                      ),
                      child: Hero(
                        tag: 'receipt_image',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            File(firstTable.receiptPath!),
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 100,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.broken_image),
                                ),
                          ),
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
                          showLiberateDialog(context, userName);
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

  void showLiberateDialog(BuildContext context, String userName) {
    // Declaramos a variável de controle FORA do builder do StatefulBuilder
    bool isClearing = false;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.fastOutSlowIn.transform(anim1.value),
          child: Opacity(
            opacity: anim1.value,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                // Renomeado para evitar conflito
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  content: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    // O layout muda suavemente quando isClearing altera
                    child: isClearing
                        ? Column(
                            key: const ValueKey('loading'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 30),
                              const CircularProgressIndicator(
                                color: Colors.redAccent,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Limpando reserva...",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          )
                        : Column(
                            key: const ValueKey('content'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.no_meeting_room_rounded,
                                  color: Colors.redAccent,
                                  size: 40,
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                "Liberar Mesas?",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2D3250),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Deseja remover a reserva de $userName?",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                  actions: isClearing
                      ? [] // Esconde os botões durante o loading
                      : [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text(
                                      "CANCELAR",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // AGORA SIM: Notifica o StatefulBuilder para reconstruir com loading
                                      setModalState(() => isClearing = true);

                                      final provider =
                                          Provider.of<TableProvider>(
                                            context,
                                            listen: false,
                                          );

                                      // Garantimos que o loading apareça por pelo menos 1 segundo
                                      await Future.wait([
                                        provider.clearReservation(userName),
                                        Future.delayed(
                                          const Duration(
                                            seconds: 2,
                                            milliseconds: 50,
                                          ),
                                        ),
                                      ]);

                                      if (context.mounted) {
                                        Navigator.pop(context); // Fecha diálogo
                                        Navigator.pop(
                                          context,
                                        ); // Volta tela principal

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Reserva de $userName liberada!",
                                            ),
                                            backgroundColor: Colors.redAccent,
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.all(15),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      "LIBERAR",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildInfoTile({
    required String label,
    required String value,
    required IconData icon,
    Widget? trailing, // Novo parâmetro opcional
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
          Expanded(
            // Adicionado Expanded para não dar overflow com o ícone
            child: Column(
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
          ),
          if (trailing != null) trailing, // Mostra o ícone do Zap se existir
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

Future<void> _launchWhatsApp(String phone, String name, bool isPaid) async {
  try {
    // Limpa o número e garante que não tenha zero no início do DDD
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.startsWith('0')) {
      cleanPhone = cleanPhone.substring(1);
    }

    final String message = isPaid
        ? "Olá $name! Confirmamos seu pagamento para as mesas. Até lá!"
        : "Olá $name, sua reserva está pendente. Por favor, confirme o pagamento para garantir suas mesas. Não perca essa chance!";

    final Uri url = Uri.parse(
      "https://wa.me/55$cleanPhone?text=${Uri.encodeComponent(message)}",
    );

    // Verifica se pode abrir antes de tentar
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Caso não consiga abrir o link wa.me, tenta o formato direto api.whatsapp
      final Uri fallbackUrl = Uri.parse(
        "whatsapp://send?phone=55$cleanPhone&text=${Uri.encodeComponent(message)}",
      );
      await launchUrl(fallbackUrl);
    }
  } catch (e) {
    debugPrint("Erro ao abrir WhatsApp: $e");
  }
}

void _showFullScreenImage(BuildContext context, String path) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero, // Faz o dialog ocupar a tela toda
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Área clicável fora da imagem para fechar
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(color: Colors.black87),
          ),
          // A Imagem
          InteractiveViewer(
            // Permite Pinch-to-Zoom (zoom com os dedos)
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.file(File(path), fit: BoxFit.contain),
          ),
          // Botão de fechar no topo
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    ),
  );
}
