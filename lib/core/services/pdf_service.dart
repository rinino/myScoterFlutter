import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';

class PdfService {
  static Future<void> generateAndShareReport({
    required Scooter scooter,
    required List<Rifornimento> rifornimenti,
    required List<Manutenzione> manutenzioni,
    required String currencySymbol,
    required AppLocalizations l10n,
    required String localeCode,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy', localeCode);

    // Calcoli totali
    final double totaleRifornimenti = rifornimenti.fold(0.0, (sum, item) => sum + (item.costo ?? 0.0));
    final double totaleManutenzioni = manutenzioni.fold(0.0, (sum, item) => sum + (item.costo ?? 0.0));
    final double costoTotale = totaleRifornimenti + totaleManutenzioni;
    final double litriTotali = rifornimenti.fold(0.0, (sum, item) => sum + item.litriBenzina);

    // Generazione Impaginazione
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            // FIX: rimosso const e usato .only()
            margin: pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              '${l10n.generatoDa} - ${dateFormat.format(DateTime.now())} - ${l10n.pag} ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            // Titolo
            pw.Header(
              level: 0,
              child: pw.Text(
                '${l10n.reportDi} ${scooter.marca} ${scooter.modello}',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
            ),
            pw.SizedBox(height: 10),

            // Box Info Scooter
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(l10n.licensePlate, scooter.targa),
                  _buildInfoRow(l10n.displacement, '${scooter.cilindrata} cc'),
                  _buildInfoRow(l10n.year, scooter.anno.toString()),
                  _buildInfoRow(l10n.mixer, scooter.miscelatore ? l10n.yes : l10n.no),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Tabella Manutenzioni
            if (manutenzioni.isNotEmpty) ...[
              pw.Text(l10n.registroManutenzione, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
              pw.SizedBox(height: 10),
              _buildManutenzioniTable(manutenzioni, currencySymbol, l10n, dateFormat),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text('${l10n.totaleManutenzioni} ${totaleManutenzioni.toStringAsFixed(2)} $currencySymbol', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
            ],

            // Tabella Rifornimenti
            if (rifornimenti.isNotEmpty) ...[
              pw.Text(l10n.refuelings, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
              pw.SizedBox(height: 10),
              _buildRifornimentiTable(rifornimenti, currencySymbol, l10n, dateFormat),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text('${l10n.totaleRifornimenti} ${totaleRifornimenti.toStringAsFixed(2)} $currencySymbol', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
            ],

            // Riepilogo Finale Globale
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('${l10n.litriConsumati}: ${litriTotali.toStringAsFixed(2)} L', style: const pw.TextStyle(fontSize: 14)),
                  pw.Divider(color: PdfColors.grey400),
                  pw.Text('${l10n.costoTotaleGestione}: ${costoTotale.toStringAsFixed(2)} $currencySymbol',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Innesca la Share Sheet nativa passando il file PDF generato
    final targaPulita = scooter.targa.replaceAll(' ', '');
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'Report_$targaPulita.pdf',
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text('$label: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildManutenzioniTable(List<Manutenzione> list, String currency, AppLocalizations l10n, DateFormat df) {
    return pw.TableHelper.fromTextArray(
      headers: [l10n.date, l10n.currentKm, l10n.details, l10n.costoLabel],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellAlignment: pw.Alignment.centerLeft,
      data: list.map((m) {
        final catName = m.categoria == CategoriaManutenzione.altro ? (m.categoriaCustom ?? l10n.cat_altro) : m.categoria.nameKey;
        final costoStr = m.costo != null ? '${m.costo!.toStringAsFixed(2)} $currency' : '-';
        return [df.format(m.data), '${m.km.toStringAsFixed(0)}', '${m.titolo} ($catName)', costoStr];
      }).toList(),
    );
  }

  static pw.Widget _buildRifornimentiTable(List<Rifornimento> list, String currency, AppLocalizations l10n, DateFormat df) {
    return pw.TableHelper.fromTextArray(
      headers: [l10n.date, l10n.currentKm, l10n.gasLiters, l10n.costoLabel],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellAlignment: pw.Alignment.centerLeft,
      data: list.map((r) {
        final costoStr = r.costo != null ? '${r.costo!.toStringAsFixed(2)} $currency' : '-';
        // FIX: Cambiato r.dateTime in r.dataRifornimento
        return [df.format(r.dataRifornimento), '${r.kmAttuali.toStringAsFixed(0)}', '${r.litriBenzina.toStringAsFixed(2)} L', costoStr];
      }).toList(),
    );
  }
}