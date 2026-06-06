import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:myscooter/l10n/app_localizations.dart';
import 'package:myscooter/features/scooter/model/scooter.dart';
import 'package:myscooter/features/rifornimento/models/rifornimento.dart';
import 'package:myscooter/features/manutenzione/models/manutenzione.dart';

// Classe payload per impacchettare in modo sicuro i dati per l'Isolate in background
class _PdfDataPayload {
  final Scooter scooter;
  final List<Map<String, dynamic>> manutenzioniVisualizzabili;
  final List<Rifornimento> rifornimenti;
  final String currencySymbol;
  final Map<String, String> translations;
  final String localeCode;

  _PdfDataPayload({
    required this.scooter,
    required this.manutenzioniVisualizzabili,
    required this.rifornimenti,
    required this.currencySymbol,
    required this.translations,
    required this.localeCode,
  });
}

class PdfService {
  /// Genera e condivide il report sfruttando le liste di dati GIA CARICATE IN MEMORIA locale (0 chiamate cloud)
  static Future<void> generateAndShareReport({
    required Scooter scooter,
    required List<Rifornimento> rifornimenti,
    required List<Manutenzione> manutenzioni,
    required String currencySymbol,
    required AppLocalizations l10n,
    required String localeCode,
  }) async {

    // 1. Traduzione chirurgica delle categorie sul thread principale tramite il file .arb
    final List<Map<String, dynamic>> manutenzioniVisualizzabili = manutenzioni.map((m) {
      String catName = l10n.cat_altro;

      if (m.categoria == CategoriaManutenzione.altro) {
        catName = m.categoriaCustom ?? l10n.cat_altro;
      } else {
        // Mappatura 1:1 esatta con le chiavi presenti nel tuo file JSON di localizzazione
        switch (m.categoria) {
          case CategoriaManutenzione.motore:
            catName = l10n.cat_motore;
            break;
          case CategoriaManutenzione.accensione:
            catName = l10n.cat_accensione;
            break;
          case CategoriaManutenzione.alimentazione:
            catName = l10n.cat_alimentazione;
            break;
          case CategoriaManutenzione.olioCambio:
            catName = l10n.cat_olio_cambio;
            break;
          case CategoriaManutenzione.trasmissione:
            catName = l10n.cat_trasmissione;
            break;
          case CategoriaManutenzione.freniGomme:
            catName = l10n.cat_freni_gomme;
            break;
          case CategoriaManutenzione.carrozzeria:
            catName = l10n.cat_carrozzeria;
            break;
          default:
            catName = l10n.cat_altro;
        }
      }

      return {
        'data': m.data,
        'km': m.km,
        'titolo': m.titolo,
        'categoriaTesto': catName,
        'costo': m.costo,
      };
    }).toList();

    // 2. Dizionario delle stringhe statiche necessarie al layout del PDF
    final translationsMap = {
      'generatoDa': l10n.generatoDa,
      'pag': l10n.pag,
      'reportDi': l10n.reportDi,
      'licensePlate': l10n.licensePlate,
      'displacement': l10n.displacement,
      'year': l10n.year,
      'mixer': l10n.mixer,
      'yes': l10n.yes,
      'no': l10n.no,
      'registroManutenzione': l10n.registroManutenzione,
      'totaleManutenzioni': l10n.totaleManutenzioni,
      'refuelings': l10n.refuelings,
      'totaleRifornimenti': l10n.totaleRifornimenti,
      'litriConsumati': l10n.litriConsumati,
      'costoTotaleGestione': l10n.costoTotaleGestione,
      'date': l10n.date,
      'currentKm': l10n.currentKm,
      'details': l10n.details,
      'costoLabel': l10n.costoLabel,
      'gasLiters': l10n.gasLiters,
    };

    final payload = _PdfDataPayload(
      scooter: scooter,
      manutenzioniVisualizzabili: manutenzioniVisualizzabili,
      rifornimenti: rifornimenti,
      currencySymbol: currencySymbol,
      translations: translationsMap,
      localeCode: localeCode,
    );

    // 3. Spostamento del rendering pesante nel background thread (Isolate) per evitare lag visivi
    final Uint8List pdfBytes = await compute(_generatePdfInBackground, payload);

    // 4. Apertura del foglio di condivisione nativo
    final targaPulita = scooter.targa.replaceAll(' ', '');
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Report_$targaPulita.pdf',
    );
  }

  // --- FUNZIONE PURA IN BACKGROUND (ISOLATE) ---
  static Future<Uint8List> _generatePdfInBackground(_PdfDataPayload data) async {
    // Inizializza la formattazione date specifica per il nuovo thread isolato
    await initializeDateFormatting(data.localeCode, null);

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy', data.localeCode);
    final t = data.translations;

    // Convertiamo il simbolo (€) nel codice ISO stringa (EUR) per azzerare i quadratini vuoti
    final String isoCurrency = _getIsoCode(data.currencySymbol);

    final double totaleRifornimenti = data.rifornimenti.fold(0.0, (sum, item) => sum + (item.costo ?? 0.0));
    final double totaleManutenzioni = data.manutenzioniVisualizzabili.fold(0.0, (sum, item) => sum + (item['costo'] ?? 0.0));

    final double costoTotale = totaleRifornimenti + totaleManutenzioni;
    final double litriTotali = data.rifornimenti.fold(0.0, (sum, item) => sum + item.litriBenzina);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              '${t['generatoDa']} - ${dateFormat.format(DateTime.now())} - ${t['pag']} ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                '${t['reportDi']} ${data.scooter.marca} ${data.scooter.modello}',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
              ),
            ),
            pw.SizedBox(height: 10),

            // Box Informazioni Generali Scooter
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
                  _buildInfoRow(t['licensePlate']!, data.scooter.targa),
                  _buildInfoRow(t['displacement']!, '${data.scooter.cilindrata} cc'),
                  _buildInfoRow(t['year']!, data.scooter.anno.toString()),
                  _buildInfoRow(t['mixer']!, data.scooter.miscelatore ? t['yes']! : t['no']!),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Tabella Registro Manutenzioni
            if (data.manutenzioniVisualizzabili.isNotEmpty) ...[
              pw.Text(t['registroManutenzione']!, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
              pw.SizedBox(height: 10),
              _buildManutenzioniTable(data.manutenzioniVisualizzabili, isoCurrency, t, dateFormat),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text('${t['totaleManutenzioni']} ${totaleManutenzioni.toStringAsFixed(2)} $isoCurrency', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
            ],

            // Tabella Registro Rifornimenti
            if (data.rifornimenti.isNotEmpty) ...[
              pw.Text(t['refuelings']!, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800)),
              pw.SizedBox(height: 10),
              _buildRifornimentiTable(data.rifornimenti, isoCurrency, t, dateFormat),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Text('${t['totaleRifornimenti']} ${totaleRifornimenti.toStringAsFixed(2)} $isoCurrency', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
            ],

            // Box Riepilogo Totale Costi di Gestione
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
                  pw.Text('${t['litriConsumati']}: ${litriTotali.toStringAsFixed(2)} L', style: const pw.TextStyle(fontSize: 14)),
                  pw.Divider(color: PdfColors.grey400),
                  pw.Text('${t['costoTotaleGestione']}: ${costoTotale.toStringAsFixed(2)} $isoCurrency',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // --- WIDGET HELPERS INTERNI ---
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

  static pw.Widget _buildManutenzioniTable(List<Map<String, dynamic>> list, String isoCurrency, Map<String, String> t, DateFormat df) {
    return pw.TableHelper.fromTextArray(
      headers: [t['date']!, t['currentKm']!, t['details']!, t['costoLabel']!],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellAlignment: pw.Alignment.centerLeft,
      data: list.map((m) {
        final DateTime dataMan = m['data'] as DateTime;
        final double kmMan = m['km'] as double;
        final String titoloMan = m['titolo'] as String;
        final String categoriaTesto = m['categoriaTesto'] as String;
        final double? costoMan = m['costo'] as double?;

        final costoStr = costoMan != null ? '${costoMan.toStringAsFixed(2)} $isoCurrency' : '-';
        return [df.format(dataMan), kmMan.toStringAsFixed(0), '$titoloMan ($categoriaTesto)', costoStr];
      }).toList(),
    );
  }

  static pw.Widget _buildRifornimentiTable(List<Rifornimento> list, String isoCurrency, Map<String, String> t, DateFormat df) {
    return pw.TableHelper.fromTextArray(
      headers: [t['date']!, t['currentKm']!, t['gasLiters']!, t['costoLabel']!],
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
      cellAlignment: pw.Alignment.centerLeft,
      data: list.map((r) {
        final costoStr = r.costo != null ? '${r.costo!.toStringAsFixed(2)} $isoCurrency' : '-';
        return [df.format(r.dataRifornimento), r.kmAttuali.toStringAsFixed(0), '${r.litriBenzina.toStringAsFixed(2)} L', costoStr];
      }).toList(),
    );
  }

  // Mappa i caratteri speciali grafici nei codici ISO standard testuali per bypassare i limiti di rendering dei font nativi
  static String _getIsoCode(String symbol) {
    switch (symbol) {
      case '€': return 'EUR';
      case '\$': return 'USD';
      case '£': return 'GBP';
      default: return symbol;
    }
  }
}