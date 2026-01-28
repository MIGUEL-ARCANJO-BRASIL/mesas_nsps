import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw; // RESOLVE: 'pw.Document'
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart'; // RESOLVE: 'DateFormat' e 'NumberFormat'

class FinancialService {
  // 1. Método privado para criar o documento (reutilização)
  static Future<pw.Document> _buildPdfDocument(
    dynamic event,
    double pago,
    double pendente,
    double total,
  ) async {
    final pdf = pw.Document();
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());

    // Cores do seu Dashboard para manter a identidade visual
    const primaryDark = PdfColor.fromInt(0xFF0F1A44);
    const accentBlue = PdfColor.fromInt(0xFF7077A1);
    const successGreen = PdfColor.fromInt(0xFF2E7D32);
    const warningOrange = PdfColor.fromInt(0xFFE65100);
    const bgLight = PdfColor.fromInt(0xFFF6F6F9);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- CABEÇALHO MODERNO ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "RELATÓRIO FINANCEIRO",
                        style: pw.TextStyle(
                          fontSize: 26,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                      pw.Text(
                        "Evento: ${event.name.toUpperCase()}",
                        style: pw.TextStyle(fontSize: 14, color: accentBlue),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        "Gerado em:",
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey,
                        ),
                      ),
                      pw.Text(
                        dateStr,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: primaryDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 30),

              // --- CARDS DE RESUMO (GRID) ---
              pw.Row(
                children: [
                  _buildPdfCard(
                    "RECEBIDO",
                    currencyFormatter.format(pago),
                    successGreen,
                  ),
                  pw.SizedBox(width: 15),
                  _buildPdfCard(
                    "PENDENTE",
                    currencyFormatter.format(pendente),
                    warningOrange,
                  ),
                  pw.SizedBox(width: 15),
                  _buildPdfCard(
                    "POTENCIAL",
                    currencyFormatter.format(pago + pendente),
                    primaryDark,
                  ),
                ],
              ),

              pw.SizedBox(height: 40),

              // --- SEÇÃO DE DETALHAMENTO ---
              pw.Text(
                "Detalhamento Geral",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryDark,
                ),
              ),
              pw.SizedBox(height: 15),

              pw.TableHelper.fromTextArray(
                border: null,
                headerAlignment: pw.Alignment.centerLeft,
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: const pw.BoxDecoration(
                  color: primaryDark,
                  borderRadius: pw.BorderRadius.vertical(
                    top: pw.Radius.circular(6),
                  ),
                ),
                headerHeight: 35,
                cellHeight: 35,
                headerStyle: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                ),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
                  ),
                ),
                oddRowDecoration: const pw.BoxDecoration(color: bgLight),
                data: <List<String>>[
                  ['Descrição do Item', 'Valor'],
                  [
                    'Total Arrecadado (Confirmado)',
                    currencyFormatter.format(pago),
                  ],
                  [
                    'Total em Reservas (A receber)',
                    currencyFormatter.format(pendente),
                  ],
                  [
                    'Capacidade Máxima do Evento',
                    currencyFormatter.format(total),
                  ],
                ],
              ),

              pw.Spacer(),

              // --- RODAPÉ ---
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Sistema de Gestão de Mesas",
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey,
                    ),
                  ),
                  pw.Text(
                    "Página 1 de 1",
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  // Widget auxiliar para criar os cards coloridos dentro do PDF
  static pw.Widget _buildPdfCard(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. AÇÃO: IMPRIMIR / VISUALIZAR
  static Future<void> printReport(
    dynamic event,
    double pago,
    double pendente,
    double total,
  ) async {
    final pdf = await _buildPdfDocument(event, pago, pendente, total);
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Relatorio_${event.name}.pdf',
    );
  }

  // 3. AÇÃO: BAIXAR / SALVAR NO CELULAR
  static Future<void> downloadReport(
    BuildContext context,
    dynamic event,
    double pago,
    double pendente,
    double total,
  ) async {
    try {
      final pdf = await _buildPdfDocument(event, pago, pendente, total);
      final bytes = await pdf.save();

      // 1. DEFINIR O CAMINHO (Downloads ou Pasta Externa)
      Directory? directory;
      if (Platform.isAndroid) {
        // Tenta pegar a pasta de Downloads do Android
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      final String timestamp = DateFormat(
        'dd-MM-yyyy_HH-mm',
      ).format(DateTime.now());
      final String fileName =
          'Relatorio_${event.name.replaceAll(' ', '_')}_$timestamp.pdf';
      final File file = File('${directory!.path}/$fileName');

      // 2. SALVAR NO DISPOSITIVO
      await file.writeAsBytes(bytes);

      debugPrint("Arquivo salvo fisicamente em: ${file.path}");

      // 3. COMPARTILHAR O ARQUIVO SALVO
      // Usamos o caminho do arquivo que acabamos de criar
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Relatório Financeiro: ${event.name}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Salvo em Downloads: $fileName"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint("Erro ao salvar/compartilhar: $e");
      // Se der erro de permissão na pasta de Download, tentamos o método seguro
      _fallbackSaveAndShare(context, event, pago, pendente, total);
    }
  }

  // Método de segurança caso o Android bloqueie a pasta /Download diretamente
  static Future<void> _fallbackSaveAndShare(
    context,
    event,
    pago,
    pendente,
    total,
  ) async {
    final pdf = await _buildPdfDocument(event, pago, pendente, total);
    final bytes = await pdf.save();
    final directory = await getExternalStorageDirectory();
    final file = File('${directory!.path}/relatorio_financeiro.pdf');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
  }
}
