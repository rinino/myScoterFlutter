import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:myscooter/features/documenti/models/documento.dart';
import 'package:myscooter/l10n/app_localizations.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inizializza i fusi orari per poter programmare notifiche nel futuro
    tz.initializeTimeZones();

    // Configurazione per Android
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configurazione per iOS
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // FIX: Uso del parametro nominativo 'settings:'
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  // Equivalente della funzione scheduleDocumentNotifications di Swift
  Future<void> scheduleDocumentNotifications(Documento documento, AppLocalizations l10n) async {
    final scadenza = documento.dataScadenza;
    final docId = documento.id;

    if (scadenza == null || docId == null) return;

    // 1. Cancelliamo le notifiche precedenti per questo documento
    await cancelNotifications(docId);

    final nomeDoc = documento.tipo == TipoDocumento.altro
        ? (documento.tipoCustom ?? 'Documento')
        : documento.tipo.getLocalizedName(l10n);

    // 2. Programmiamo gli avvisi (15 gg, 3 gg, giorno stesso)
    await _schedule(docId, 15, scadenza, nomeDoc, "Scadenza in avvicinamento", "Il documento $nomeDoc scadrà tra 15 giorni.");
    await _schedule(docId, 3, scadenza, nomeDoc, "Scadenza Imminente!", "Attenzione: il documento $nomeDoc scadrà tra 3 giorni.");
    await _schedule(docId, 0, scadenza, nomeDoc, "Documento Scaduto", "Il documento $nomeDoc scade oggi.");
  }

  Future<void> _schedule(int docId, int daysBefore, DateTime targetDate, String docName, String title, String body) async {
    // Calcoliamo la data della notifica
    final notificationDate = targetDate.subtract(Duration(days: daysBefore));

    // Impostiamo l'ora alle 09:00 del mattino
    var scheduledDate = DateTime(
      notificationDate.year,
      notificationDate.month,
      notificationDate.day,
      9, 0, 0,
    );

    // Se la data calcolata è già passata, non la programmiamo
    if (scheduledDate.isBefore(DateTime.now())) return;

    // FIX: Creiamo un ID univoco matematico invece che testuale (evita l'errore del linter)
    final int notificationId = (docId * 100) + daysBefore;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'documenti_scadenze',
      'Scadenze Documenti',
      channelDescription: 'Notifiche per le scadenze dei documenti dello scooter',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // FIX: Uso esclusivo di parametri nominativi + rimozione di uiLocalNotificationDateInterpretation
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  // Cancella tutte le notifiche associate a un documento
  Future<void> cancelNotifications(int docId) async {
    // FIX: Uso del parametro nominativo 'id:' + calcolo matematico
    await flutterLocalNotificationsPlugin.cancel(id: (docId * 100) + 15);
    await flutterLocalNotificationsPlugin.cancel(id: (docId * 100) + 3);
    await flutterLocalNotificationsPlugin.cancel(id: (docId * 100) + 0);
  }
}