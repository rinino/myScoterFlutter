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
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true,
    );
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> scheduleDocumentNotifications(Documento documento, AppLocalizations l10n) async {
    final scadenza = documento.dataScadenza;
    final docId = documento.id;

    if (scadenza == null || docId == null) return;

    await cancelNotifications(docId);

    final nomeDoc = documento.tipo == TipoDocumento.altro
        ? (documento.tipoCustom ?? 'Documento')
        : documento.tipo.getLocalizedName(l10n);

    // Usa le traduzioni di sistema passando il nome del documento
    await _schedule(docId, 15, scadenza, l10n.notificaScadenza15Titolo, l10n.notificaScadenza15Corpo(nomeDoc));
    await _schedule(docId, 3, scadenza, l10n.notificaScadenza3Titolo, l10n.notificaScadenza3Corpo(nomeDoc));
    await _schedule(docId, 0, scadenza, l10n.notificaScadenza0Titolo, l10n.notificaScadenza0Corpo(nomeDoc));
  }

  Future<void> _schedule(String docId, int daysBefore, DateTime targetDate, String title, String body) async {
    final notificationDate = targetDate.subtract(Duration(days: daysBefore));
    var scheduledDate = DateTime(notificationDate.year, notificationDate.month, notificationDate.day, 9, 0, 0);

    if (scheduledDate.isBefore(DateTime.now())) return;

    final int notificationId = docId.hashCode + daysBefore;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'documenti_scadenze', 'Scadenze Documenti',
      channelDescription: 'Notifiche per le scadenze dei documenti dello scooter',
      importance: Importance.max, priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId, title: title, body: body,
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotifications(String docId) async {
    await flutterLocalNotificationsPlugin.cancel(id: docId.hashCode + 15);
    await flutterLocalNotificationsPlugin.cancel(id: docId.hashCode + 3);
    await flutterLocalNotificationsPlugin.cancel(id: docId.hashCode + 0);
  }
}