import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class FinancialService {
  static Future<void> generateFinancialReport(
    BuildContext context,
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "Relatorio Financeiro",
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(dateStr),
                ],
              ),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),

              // Info do Evento
              pw.Text(
                "Evento: ${event.name}",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                "Preco por Mesa: ${currencyFormatter.format(event.tablePrice)}",
              ),
              pw.SizedBox(height: 30),

              // Tabela de Dados
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF0F1A44),
                ),
                data: <List<String>>[
                  <String>['Descricao', 'Valor'],
                  <String>['Recebido (Pago)', currencyFormatter.format(pago)],
                  <String>[
                    'Pendente (Reservado)',
                    currencyFormatter.format(pendente),
                  ],
                  <String>[
                    'Total Potencial',
                    currencyFormatter.format(pago + pendente),
                  ],
                  <String>['Maximo do Evento', currencyFormatter.format(total)],
                ],
              ),

              pw.SizedBox(height: 40),
              pw.Center(
                child: pw.Text(
                  "Gerado automaticamente pelo Sistema de Mesas",
                  style: const pw.TextStyle(color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Exibe o preview do PDF para o usuário
    // No seu método _generatePdf
    try {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'Relatorio_${event.name}.pdf',
      );
    } catch (e) {
      debugPrint("Erro ao gerar PDF: $e");
      // Opcional: Mostrar um SnackBar de erro para o usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao abrir visualização de PDF: $e")),
      );
    }
  }
}
// Método para gerar e abrir o PDF