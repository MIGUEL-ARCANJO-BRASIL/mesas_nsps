import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mesasnsps/model/provider/table_provider.dart';
import 'package:mesasnsps/model/table.dart';
import 'package:mesasnsps/screens/main/table_map_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;

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
    final provider = Provider.of<TableProvider>(context);

    // 2. Filtre as mesas atualizadas pelo userName que veio no construtor
    // Isso garante que se o telefone ou status mudar, este 'build' rodará de novo.
    final currentTables = provider.tables
        .where((t) => t.userName == userName)
        .toList();

    // 3. Caso a reserva tenha sido apagada ou o nome mudado, evite erro de lista vazia
    if (currentTables.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Reserva não encontrada")),
      );
    }

    final firstTable = currentTables.first;
    final bool isPaid = currentTables.any(
      (t) => t.status == TableStatusEnum.paid,
    );
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
          "Detalhes",
          style: TextStyle(color: primaryDark, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: primaryDark),
            onPressed: () {
              final provider = Provider.of<TableProvider>(
                context,
                listen: false,
              );
              provider.prepareForEdit(tables.map((t) => t.number).toList());
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TableMapScreen()),
              );
            },
          ),
        ],
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
                            icon: Image.asset(
                              'assets/images/whatsapp.png',
                              width:
                                  20, // Mantendo o tamanho proporcional ao seu antigo size: 28
                              height: 20,
                              // Caso queira garantir que a cor não mude, não use o color aqui.
                              // Imagens .png já vêm com suas cores originais.
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
                    _buildImageTile(
                      label: "COMPROVANTE ANEXADO",
                      imagePath: firstTable.receiptPath!,
                      icon: Icons.receipt_long_rounded,
                      onTap: () => _showFullScreenImage(
                        context,
                        firstTable.receiptPath!,
                      ),
                      trailing: isPaid
                          ? IconButton(
                              icon: Icon(
                                Icons.share_rounded,
                                color: primaryDark,
                                size: 22,
                              ),
                              onPressed: () {
                                final eventProvider =
                                    Provider.of<TableProvider>(
                                      context,
                                      listen: false,
                                    );
                                final event = eventProvider.selectedEvent;

                                if (event != null) {
                                  _generateAndShareReceipt(
                                    name: userName,
                                    tables: tables,
                                    eventName: event.name,
                                    eventDate: DateFormat('dd/MM/yyyy').format(
                                      event.date,
                                    ), // Formata a data se for DateTime
                                  );
                                }
                              },
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),
                  ] else if (isPaid && !isPix) ...[
                    _buildInfoTile(
                      label: "COMPROVANTE ANEXADO",
                      value: "Gerar recibo em dinheiro",
                      icon: Icons.receipt_long_rounded,
                      trailing: IconButton(
                        icon: Icon(
                          Icons.share_rounded,
                          color: primaryDark,
                          size: 22,
                        ),
                        onPressed: () {
                          final eventProvider = Provider.of<TableProvider>(
                            context,
                            listen: false,
                          );
                          final event = eventProvider.selectedEvent;

                          if (event != null) {
                            _generateAndShareReceipt(
                              name: userName,
                              tables: tables,
                              eventName: event.name,
                              eventDate: DateFormat('dd/MM/yyyy').format(
                                event.date,
                              ), // Formata a data se for DateTime
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 32),
                  TextButton.icon(
                    onPressed: () => showLiberateDialog(context, userName),
                    icon: const Icon(
                      Icons.no_meeting_room_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    label: const Text(
                      "LIBERAR ESTAS MESAS",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODO PRINCIPAL DE GERAÇÃO DE RECIBO ---
  // --- MÉTODO PRINCIPAL DE GERAÇÃO DE RECIBO ATUALIZADO ---
  Future<void> _generateAndShareReceipt({
    required String name,
    required List<TableModel> tables,
    required String eventName, // Novo campo
    required String eventDate, // Novo campo
  }) async {
    final pdf = pw.Document();
    final dateGenerationStr = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.now());
    final tablesStr = tables.map((t) => t.number).join(', ');
    final firstTable = tables.first;

    final bool isPix = firstTable.paymentMethod == "Pix";
    final totalValue = tables.length * firstTable.price;

    const primaryColor = PdfColor.fromInt(0xFF2D3250);
    const accentColor = PdfColor.fromInt(0xFF7077A1);
    const successColor = PdfColor.fromInt(0xFF2E7D32);

    pw.MemoryImage? proofImage;
    if (isPix && firstTable.receiptPath != null) {
      try {
        final file = File(firstTable.receiptPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          proofImage = pw.MemoryImage(bytes);
        }
      } catch (e) {
        debugPrint("Erro ao carregar imagem local para o PDF: $e");
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a6,
        margin: const pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return [
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: accentColor, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              ),
              padding: const pw.EdgeInsets.all(15),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            "RECIBO",
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          pw.Text(
                            isPix
                                ? "Pagamento via PIX"
                                : "Pagamento em Espécie",
                            style: const pw.TextStyle(
                              fontSize: 9,
                              color: accentColor,
                            ),
                          ),
                        ],
                      ),
                      _buildPdfStatusBadge(successColor),
                    ],
                  ),
                  pw.SizedBox(height: 8),

                  // --- INFORMAÇÕES DO EVENTO ---
                  pw.Center(
                    child: pw.Text(
                      eventName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  pw.Center(
                    child: pw.Text(
                      "Data do Evento: $eventDate",
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 8),
                  pw.Divider(thickness: 0.5, color: accentColor),
                  pw.SizedBox(height: 8),

                  // --- DADOS DO CLIENTE ---
                  _buildPdfRow("Cliente", name.toUpperCase(), primaryColor),
                  _buildPdfRow("Mesas", tablesStr, primaryColor),
                  _buildPdfRow("Emitido em", dateGenerationStr, primaryColor),

                  pw.SizedBox(height: 15),

                  // --- SEÇÃO DO COMPROVANTE ---
                  if (isPix && proofImage != null) ...[
                    pw.Center(
                      child: pw.Text(
                        "COMPROVANTE ANEXO",
                        style: pw.TextStyle(
                          fontSize: 8,
                          color: accentColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Container(
                      alignment: pw.Alignment.center,
                      height: 140,
                      width: double.infinity,
                      child: pw.Image(proofImage, fit: pw.BoxFit.contain),
                    ),
                    pw.SizedBox(height: 10),
                  ],

                  // --- TOTAL ---
                  pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFFF6F6F9),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "TOTAL",
                          style: pw.TextStyle(
                            fontSize: 12,
                            fontWeight: pw.FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        pw.Text(
                          "R\$ ${totalValue.toStringAsFixed(2)}",
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Center(
                    child: pw.Text(
                      "Sistema de Gestão de Mesas",
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    await Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: 'Recibo_${name.replaceAll(' ', '_')}.pdf',
          mimeType: 'application/pdf',
        ),
      ],
      text:
          '✅ *Pagamento Confirmado!*\n\n'
          'Olá, $name! Segue o seu recibo para o evento *$eventName*.\n'
          'Mesas: $tablesStr\n'
          'Data do Evento: $eventDate\n\n'
          'Muito obrigado pela preferência! 😊',
    );
  }

  pw.Widget _buildPdfRow(String label, String value, PdfColor valueColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStatusBadge(PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        "PAGO",
        style: pw.TextStyle(
          color: PdfColors.white,
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
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
                                      await provider.clearReservation(userName);
                                      await Future.delayed(
                                        const Duration(seconds: 2),
                                      );

                                      if (context.mounted) {
                                        // 1. Fecha o Diálogo
                                        Navigator.of(
                                          context,
                                          rootNavigator: true,
                                        ).pop();

                                        // 2. Volta para a tela anterior (Home/Mapa)
                                        // Se você usou pushAndRemoveUntil, o pop aqui levará para a route.isFirst
                                        Navigator.of(context).pop();

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

  Widget _buildImageTile({
    required String label,
    required String imagePath,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: accentBlue.withOpacity(0.7),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onTap,
            child: Hero(
              tag: 'receipt_image',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.file(
                  File(imagePath),
                  width: double.infinity,
                  height: 200, // Altura levemente menor para caber no card
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: Colors.grey[100],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
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
