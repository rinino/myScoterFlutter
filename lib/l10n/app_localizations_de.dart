// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'My Scooter';

  @override
  String get myScooters => 'Meine Roller';

  @override
  String get noScooterFound => 'Kein Roller gefunden.';

  @override
  String get addScooterPrompt => 'Drücke \"+\", um einen hinzuzufügen!';

  @override
  String get delete => 'LÖSCHEN';

  @override
  String get cancel => 'ABBRECHEN';

  @override
  String get save => 'SPEICHERN';

  @override
  String get deleteScooterTitle => 'Roller Löschen';

  @override
  String deleteScooterContent(String modello) {
    return 'Bist du sicher, dass du den Roller $modello löschen möchtest?\nDiese Aktion löscht auch alle Betankungen.';
  }

  @override
  String get brand => 'Marke';

  @override
  String get model => 'Modell';

  @override
  String get displacement => 'Hubraum';

  @override
  String get mixer => 'Mischer';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get refuelings => 'TANKFUNGEN';

  @override
  String get noDataPresent => 'Keine Daten vorhanden';

  @override
  String get sharePhoto => 'Foto teilen';

  @override
  String get saveToGallery => 'In der Galerie speichern';

  @override
  String get scooterUpdated => 'Roller aktualisiert!';

  @override
  String get refuelingSaved => 'Betankung gespeichert!';

  @override
  String get addScooter => 'Roller hinzufügen';

  @override
  String get editScooter => 'Roller bearbeiten';

  @override
  String get licensePlate => 'Kennzeichen';

  @override
  String get year => 'Jahr';

  @override
  String get tankCapacity => 'Tankinhalt (L)';

  @override
  String get selectImage => 'Bild auswählen';

  @override
  String get camera => 'Kamera';

  @override
  String get gallery => 'Galerie';

  @override
  String get removePhoto => 'Foto entfernen';

  @override
  String get missingFields => 'Bitte alle Pflichtfelder ausfüllen';

  @override
  String get insertBrand => 'Marke eingeben';

  @override
  String get insertModel => 'Modell eingeben';

  @override
  String get refuelingDetails => 'Details zur Betankung';

  @override
  String get date => 'Datum';

  @override
  String get currentKm => 'Aktuelle Km';

  @override
  String get gasLiters => 'Liter Benzin';

  @override
  String get oilLiters => 'Liter Öl';

  @override
  String get none => 'Keins';

  @override
  String get oilPercentage => 'Ölanteil';

  @override
  String get kmTraveled => 'Gefahrene Km';

  @override
  String get averageConsumption => 'Durchschnittsverbrauch';

  @override
  String get averageConsumptionCalcTitle =>
      'Berechnung des Durchschnittsverbrauchs';

  @override
  String get averageConsumptionCalcDesc =>
      'Der Durchschnittsverbrauch wird berechnet, indem die seit der letzten Betankung gefahrenen Kilometer durch die bei dieser Betankung eingefüllten Liter Benzin geteilt werden. Es wird davon ausgegangen, dass jedes Mal vollgetankt wird.';

  @override
  String get addRefueling => 'Betankung hinzufügen';

  @override
  String get editRefueling => 'Betankung bearbeiten';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get dateTime => 'Datum und Uhrzeit';

  @override
  String get oilAdded => 'Öl hinzugefügt?';

  @override
  String get saveRefueling => 'Betankung speichern';

  @override
  String get deleteRecordTitle => 'Löschen';

  @override
  String get deleteRecordContent => 'Möchtest du diesen Eintrag löschen?';

  @override
  String get generalInfo => 'ALLGEMEINE INFORMATIONEN';

  @override
  String get details => 'DETAILS';

  @override
  String get autoMixer => 'Automatischer Mischer';

  @override
  String get autoMixerDesc =>
      'Aktivieren, falls der Roller das Öl selbst mischt';

  @override
  String get requiredField => 'Pflichtfeld';

  @override
  String get insertNumber => 'Bitte gültige Zahl eingeben';

  @override
  String get invalidLicensePlate => 'Ungültiges Kennzeichenformat';

  @override
  String get invalidYear => 'Ungültiges Jahr';

  @override
  String get impostazioni => 'Einstellungen';

  @override
  String get aspetto => 'Erscheinungsbild';

  @override
  String get lingua => 'Sprache';

  @override
  String get informazioni => 'Informationen';

  @override
  String get versione => 'Version';

  @override
  String get termini_condizioni => 'Allgemeine Geschäftsbedingungen';

  @override
  String get fatto => 'Fertig';

  @override
  String get legale => 'Rechtliches';

  @override
  String get maggiori_info => 'Weitere Informationen';

  @override
  String get leggi_sito => 'Auf der Website lesen';

  @override
  String get info_text =>
      'Details zur Datenverwaltung und den Nutzungsbedingungen findest du auf unserer offiziellen Website.';

  @override
  String get info_dati =>
      'Die App sammelt keine personenbezogenen Daten auf externen Servern. Alles wird lokal gespeichert.';

  @override
  String get sistema => 'System';

  @override
  String get chiaro => 'Hell';

  @override
  String get scuro => 'Dunkel';

  @override
  String get errorSharing => 'Fehler beim Teilen';

  @override
  String get errorSaving => 'Fehler beim Speichern';

  @override
  String get errorLoadingRefuelings => 'Fehler beim Laden der Betankungen';

  @override
  String get errorDeleting => 'Fehler beim Löschen';

  @override
  String get recordDeleted => 'Eintrag erfolgreich gelöscht';

  @override
  String get permissionDenied => 'Berechtigung verweigert';

  @override
  String get imageSaved => 'Bild in der Galerie gespeichert!';

  @override
  String get errorUpdating => 'Fehler beim Aktualisieren';

  @override
  String get scooterAdded => 'Roller erfolgreich hinzugefügt!';

  @override
  String get scooterDeleted => 'Roller gelöscht';

  @override
  String get licensePlateShort => 'Kennz.';

  @override
  String shareText(String scooter) {
    return 'Schau dir meinen $scooter an!';
  }

  @override
  String get shareSubject => 'Roller-Foto';

  @override
  String get refuelingData => 'Betankungsdaten';

  @override
  String get dateAndKm => 'DATUM UND KILOMETER';

  @override
  String get fuelAndMix => 'KRAFTSTOFF UND GEMISCH';

  @override
  String get calculatedLabel => '(Berechnet)';

  @override
  String get errorInitialData => 'Fehler beim Laden der Anfangsdaten.';

  @override
  String mustBeGreaterThan(String km) {
    return 'Muss > als vorheriger sein ($km km)';
  }

  @override
  String get cantOpenBrowser => 'Browser kann nicht geöffnet werden';

  @override
  String get dati => 'DATEN';

  @override
  String get backupRestoreTitle => 'Sicherung & Wiederherstellung';

  @override
  String get backupSection => 'BACKUP EXPORTIEREN';

  @override
  String get backupDesc =>
      'Speichere eine sichere Kopie deiner Daten. Du kannst sie auf Google Drive, iCloud, per E-Mail speichern oder auf dem Telefon behalten.';

  @override
  String get createBackupBtn => 'Backup erstellen';

  @override
  String get restoreSection => 'BACKUP WIEDERHERSTELLEN';

  @override
  String get restoreDesc =>
      'ACHTUNG: Die Wiederherstellung überschreibt alle aktuellen App-Daten. Dieser Vorgang kann nicht rückgängig gemacht werden.';

  @override
  String get restoreBtn => 'Backup-Datei auswählen';

  @override
  String get restoreSuccess => 'Daten erfolgreich wiederhergestellt!';

  @override
  String get errorBackup => 'Fehler bei der Sicherung';

  @override
  String get errorRestore =>
      'Fehler bei der Wiederherstellung oder ungültige Datei';

  @override
  String get costoLabel => 'Kosten';

  @override
  String get noteLabel => 'Notizen';

  @override
  String get placeholderNote => 'Notizen hinzufügen (z.B. Tankstellenname)';

  @override
  String get posizioneGPSLabel => 'GPS-Standort';

  @override
  String get aggiungiPosizione => 'Standort hinzufügen';

  @override
  String get posizioneSalvata => 'Standort gespeichert';

  @override
  String get selezionaSullaMappa => 'Auf der Karte auswählen';

  @override
  String get confermaPosizione => 'Standort bestätigen';

  @override
  String get erroreCostoNonValido => 'Bitte gültige Kosten eingeben';

  @override
  String get apriInGoogleMaps => 'In Google Maps öffnen';

  @override
  String get apriInWaze => 'In Waze öffnen';

  @override
  String get distributorePin => 'Tankstelle';

  @override
  String get registroManutenzione => 'Wartungsbuch';

  @override
  String get nessunaManutenzione => 'Keine Wartung aufgezeichnet.';

  @override
  String get aggiungiIntervento => 'Wartung hinzufügen';

  @override
  String get nuovoIntervento => 'Neue Wartung';

  @override
  String get dettagliIntervento => 'Wartungsdetails';

  @override
  String get modificaIntervento => 'Wartung bearbeiten';

  @override
  String get titoloIntervento => 'Titel (z.B. Zündkerze wechseln)';

  @override
  String get dataIntervento => 'Datum';

  @override
  String get categoria => 'Kategorie';

  @override
  String get specificaAltro => 'Kategorie spezifizieren';

  @override
  String get costoOpzionale => 'Kosten (Optional)';

  @override
  String get noteDettagli => 'Notizen / Details';

  @override
  String get fotoRicevuta => 'Foto / Quittung';

  @override
  String get selezionaFoto => 'Bild auswählen';

  @override
  String get rimuoviFoto => 'Foto entfernen';

  @override
  String get datiMancanti => 'Fehlende Daten';

  @override
  String get erroreDatiMessaggio =>
      'Bitte einen Titel und gültige Kilometer eingeben, um fortzufahren.';

  @override
  String get infoPrincipali => 'Hauptinformationen';

  @override
  String get dettagliAggiuntivi => 'Zusätzliche Details';

  @override
  String get notePlaceholder => 'Notizen zur Wartung hinzufügen...';

  @override
  String get cat_motore => 'Motor';

  @override
  String get cat_accensione => 'Zündung / Elektrik';

  @override
  String get cat_alimentazione => 'Kraftstoffsystem';

  @override
  String get cat_olio_cambio => 'Getriebeöl';

  @override
  String get cat_trasmissione => 'Getriebe / Züge';

  @override
  String get cat_freni_gomme => 'Bremsen / Reifen';

  @override
  String get cat_carrozzeria => 'Karosserie / Rahmen';

  @override
  String get cat_altro => 'Sonstiges';

  @override
  String get confirmTitle => 'Bestätigen';

  @override
  String get confirmDeleteMaintenance =>
      'Möchtest du diese Wartung wirklich löschen?';

  @override
  String get maintenanceSaved => 'Wartung gespeichert!';

  @override
  String get maintenanceDeleted => 'Wartung gelöscht';

  @override
  String get backupShareSubject => 'MyScooter Backup';

  @override
  String get backupShareText => 'MyScooter Backup (Daten + Fotos)';

  @override
  String get documentiScadenze => 'Dokumente & Fristen';

  @override
  String get nessunDocumento => 'Kein Dokument gespeichert';

  @override
  String get scadeIl => 'Ablauf:';

  @override
  String get scaduto => 'Abgelaufen!';

  @override
  String get inScadenza => 'Läuft bald ab';

  @override
  String get senzaScadenza => 'Kein Ablaufdatum';

  @override
  String get tipoDocumento => 'Dokumenttyp';

  @override
  String get haScadenza => 'Gibt es ein Ablaufdatum?';

  @override
  String get dataScadenza => 'Ablaufdatum';

  @override
  String get docLibretto => 'Zulassungsbescheinigung';

  @override
  String get docAssicurazione => 'Versicherung';

  @override
  String get docRevisione => 'HU (TÜV)';

  @override
  String get docBollo => 'Kfz-Steuer';

  @override
  String get docCertificato => 'Historisches Zertifikat';

  @override
  String get docPatente => 'Führerschein';

  @override
  String get documentSaved => 'Dokument gespeichert!';

  @override
  String get documentDeleted => 'Dokument gelöscht';

  @override
  String get aggiungi => 'Hinzufügen';

  @override
  String get esportaPDF => 'PDF-Bericht exportieren';

  @override
  String get reportDi => 'Bericht von';

  @override
  String get totaleManutenzioni => 'Gesamte Wartungen:';

  @override
  String get totaleRifornimenti => 'Gesamte Betankungen:';

  @override
  String get litriConsumati => 'Verbrauchte Liter';

  @override
  String get costoTotaleGestione => 'Gesamte Verwaltungskosten';

  @override
  String get generatoDa => 'Generiert von myScooter';

  @override
  String get pag => 'Seite';

  @override
  String get onboardingTitle1 => 'Deine Virtuelle Garage';

  @override
  String get onboardingDesc1 =>
      'Verwalte alle deine Vespas und Roller in einer einzigen App, immer griffbereit.';

  @override
  String get onboardingTitle2 => 'Behalte Tankungen im Blick';

  @override
  String get onboardingDesc2 =>
      'Zeichne Betankungen auf und überwache den Verbrauch. Liter, Kosten und Durchschnittswerte werden automatisch berechnet.';

  @override
  String get onboardingTitle3 => 'Deine Dokumentenmappe';

  @override
  String get onboardingDesc3 =>
      'Speichere Zulassung, Versicherung und weitere Dokumente. Erhalte automatische Benachrichtigungen vor Ablauf der Fristen!';

  @override
  String get salta => 'Überspringen';

  @override
  String get avanti => 'Weiter';

  @override
  String get inizia => 'Starten';

  @override
  String get profiloTitle => 'Profil';

  @override
  String get utenteOspite => 'Gastbenutzer';

  @override
  String get datiLocali =>
      'Deine Daten werden nur auf diesem Gerät gespeichert.';

  @override
  String get avvisoSovrascrittura =>
      'Achtung: Die Anmeldung mit einem Cloud-Konto ersetzt deine lokalen Daten.';

  @override
  String get accediGoogle => 'Mit Google anmelden';

  @override
  String get accediApple => 'Mit Apple anmelden';

  @override
  String get esci => 'Abmelden';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get themeLabel => 'App-Design';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get accediEmail => 'Mit E-Mail anmelden';

  @override
  String get registrati => 'Registrieren';

  @override
  String get emailLabel => 'E-Mail';

  @override
  String get passwordLabel => 'Passwort';

  @override
  String get confermaPassword => 'Passwort bestätigen';

  @override
  String get mailVerificaInviata =>
      'Wir haben dir eine Bestätigungs-E-Mail gesendet. Bitte prüfe deinen Posteingang.';

  @override
  String get mailNonVerificata =>
      'E-Mail noch nicht bestätigt. Hier klicken, um den Link erneut zu senden.';

  @override
  String get modificaProfilo => 'Profil bearbeiten';

  @override
  String get nomeLabel => 'Vorname';

  @override
  String get cognomeLabel => 'Nachname';

  @override
  String get selezionaFotoProfilo => 'Wähle ein Profilbild';

  @override
  String get attenzioneSovrascritturaTitolo => 'Warnung zu lokalen Daten';

  @override
  String get attenzioneSovrascritturaMessaggio =>
      'Du meldest dich bei einem Cloud-Konto an. Falls dieses Konto bereits Daten enthält, werden die auf diesem Gerät (Gastbenutzer) gespeicherten Daten ÜBERSCHRIEBEN und gehen dauerhaft verloren. Fortfahren?';

  @override
  String get procedi => 'Fortfahren';

  @override
  String get annulla => 'Abbrechen';

  @override
  String get loginSuccess => 'Erfolgreich angemeldet';

  @override
  String get loginError => 'Anmeldung fehlgeschlagen oder abgebrochen';

  @override
  String get cloudUser => 'Cloud-Benutzer';

  @override
  String get logoutSuccess => 'Erfolgreich abgemeldet';

  @override
  String get emailValida => 'Gültige E-Mail eingeben';

  @override
  String get passwordCorta => 'Mindestens 6 Zeichen';

  @override
  String get passwordNonCoincidono => 'Passwörter stimmen nicht überein';

  @override
  String get nonHaiAccount => 'Kein Konto? Registrieren';

  @override
  String get haiGiaAccount => 'Bereits ein Konto? Anmelden';

  @override
  String get profiloAggiornato => 'Profil erfolgreich aktualisiert!';

  @override
  String get erroreSalvataggio => 'Fehler beim Speichern';

  @override
  String get languageLabel => 'Sprache';
}
