import 'package:flutter/material.dart';
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
    tz.initializeTimeZones();

    // Inizializzazione ESCLUSIVA per Android
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);

    // Richiesta permessi notifiche per Android 13+
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Richiesta permessi allarmi esatti (necessari per i solleciti programmati)
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // 1. NOTIFICA ISTANTANEA (All'apertura dello scooter)
  Future<void> showInstantNotificationForExpiredDocs(List<Documento> documentiScaduti, AppLocalizations l10n) async {
    if (documentiScaduti.isEmpty) return;

    final count = documentiScaduti.length;
    final String title = count == 1
        ? "Attenzione: Documento Scaduto!"
        : "Attenzione: $count Documenti Scaduti!";

    String body = "";
    if (count == 1) {
      final doc = documentiScaduti.first;
      final nome = doc.tipo == TipoDocumento.altro ? (doc.tipoCustom ?? 'Documento') : doc.tipo.getLocalizedName(l10n);
      body = "Il documento $nome risulta scaduto. Aggiornalo il prima possibile.";
    } else {
      body = "Hai $count documenti con la data di scadenza passata. Apri l'app per controllare.";
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'documenti_scadenze', 'Scadenze Documenti',
      channelDescription: 'Avvisi per i documenti dello scooter scaduti',
      importance: Importance.max, priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    // FIX: Ripristinati i parametri nominati richiesti dal plugin
    await flutterLocalNotificationsPlugin.show(
      id: 999,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  // 2. SOLLECITI IN BACKGROUND A TELEFONO BLOCCATO (3, 7 e 14 giorni)
  Future<void> scheduleFutureReminders(List<Documento> documentiScaduti, AppLocalizations l10n) async {
    // Prima di tutto puliamo i vecchi promemoria per non accavallarli
    await cancelAllReminders();

    if (documentiScaduti.isEmpty) return;

    final count = documentiScaduti.length;
    final String title = "Promemoria Scadenze";
    final String body = count == 1
        ? "Ricordati di rinnovare il documento scaduto per il tuo scooter."
        : "Hai $count documenti scaduti che richiedono la tua attenzione.";

    // Scheduliamo gli avvisi alle ore 10:00 tra 3, 7 e 14 giorni a partire da ORA
    await _scheduleReminder(1003, 3, title, body);
    await _scheduleReminder(1007, 7, title, body);
    await _scheduleReminder(1014, 14, title, body);
  }

  Future<void> _scheduleReminder(int id, int daysFromNow, String title, String body) async {
    try {
      final now = DateTime.now();
      final scheduledDate = DateTime(now.year, now.month, now.day, 10, 0, 0).add(Duration(days: daysFromNow));

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'documenti_promemoria', 'Promemoria Documenti',
        channelDescription: 'Solleciti ricorrenti per documenti scaduti',
        importance: Importance.defaultImportance, priority: Priority.defaultPriority,
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      // FIX: Ripristinati i parametri nominati e rimosso quello deprecato
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint("ADR: Impossibile programmare sollecito: $e");
    }
  }

  Future<void> cancelAllReminders() async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id: 1003);
      await flutterLocalNotificationsPlugin.cancel(id: 1007);
      await flutterLocalNotificationsPlugin.cancel(id: 1014);
    } catch (_) {}
  }

  // 3. NOTIFICHE PREVENTIVE (Quando crei un documento valido per il futuro)
  Future<void> scheduleDocumentNotifications(Documento documento, AppLocalizations l10n) async {
    try {
      final scadenza = documento.dataScadenza;
      final docId = documento.id;
      if (scadenza == null || docId == null) return;

      await cancelNotifications(docId);

      final nomeDoc = documento.tipo == TipoDocumento.altro
          ? (documento.tipoCustom ?? 'Documento')
          : documento.tipo.getLocalizedName(l10n);

      await _schedulePreventive(docId, 15, scadenza, l10n.notificaScadenza15Titolo, l10n.notificaScadenza15Corpo(nomeDoc));
      await _schedulePreventive(docId, 3, scadenza, l10n.notificaScadenza3Titolo, l10n.notificaScadenza3Corpo(nomeDoc));
      await _schedulePreventive(docId, 0, scadenza, l10n.notificaScadenza0Titolo, l10n.notificaScadenza0Corpo(nomeDoc));
    } catch (e) {
      debugPrint("ADR: Errore nello schedule preventivo: $e");
    }
  }

  Future<void> _schedulePreventive(String docId, int daysBefore, DateTime targetDate, String title, String body) async {
    try {
      final notificationDate = targetDate.subtract(Duration(days: daysBefore));
      final scheduledDate = DateTime(notificationDate.year, notificationDate.month, notificationDate.day, 9, 0, 0);
      final now = DateTime.now();

      // Se la data è già passata, non la scheduliamo qui (ci pensa l'istantanea!)
      if (scheduledDate.isBefore(now)) return;

      final int notificationId = docId.hashCode.abs() + daysBefore;

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'documenti_scadenze', 'Scadenze Documenti',
        channelDescription: 'Notifiche per le scadenze dei documenti',
        importance: Importance.max, priority: Priority.high,
      );
      const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

      // FIX: Ripristinati i parametri nominati e rimosso quello deprecato
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: notificationId,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}
  }

  Future<void> cancelNotifications(String docId) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id: docId.hashCode.abs() + 15);
      await flutterLocalNotificationsPlugin.cancel(id: docId.hashCode.abs() + 3);
      await flutterLocalNotificationsPlugin.cancel(id: docId.hashCode.abs() + 0);
    } catch (_) {}
  }
}