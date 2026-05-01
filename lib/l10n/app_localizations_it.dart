// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'My Scooter';

  @override
  String get myScooters => 'I Miei Scooter';

  @override
  String get noScooterFound => 'Nessuno scooter trovato.';

  @override
  String get addScooterPrompt => 'Premi \"+\" per aggiungerne uno!';

  @override
  String get delete => 'ELIMINA';

  @override
  String get cancel => 'ANNULLA';

  @override
  String get save => 'SALVA';

  @override
  String get deleteScooterTitle => 'Elimina Scooter';

  @override
  String deleteScooterContent(String modello) {
    return 'Sei sicuro di voler eliminare lo scooter $modello?\nQuesta azione cancellerà anche tutti i rifornimenti.';
  }

  @override
  String get brand => 'Marca';

  @override
  String get model => 'Modello';

  @override
  String get displacement => 'Cilindrata';

  @override
  String get mixer => 'Miscelatore';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get refuelings => 'RIFORNIMENTI';

  @override
  String get noDataPresent => 'Nessun dato presente';

  @override
  String get sharePhoto => 'Condividi foto';

  @override
  String get saveToGallery => 'Salva in galleria';

  @override
  String get scooterUpdated => 'Scooter aggiornato!';

  @override
  String get refuelingSaved => 'Rifornimento salvato!';

  @override
  String get addScooter => 'Aggiungi Scooter';

  @override
  String get editScooter => 'Modifica Scooter';

  @override
  String get licensePlate => 'Targa';

  @override
  String get year => 'Anno';

  @override
  String get tankCapacity => 'Capacità Serbatoio (L)';

  @override
  String get selectImage => 'Seleziona Immagine';

  @override
  String get camera => 'Fotocamera';

  @override
  String get gallery => 'Galleria';

  @override
  String get removePhoto => 'Rimuovi Foto';

  @override
  String get missingFields => 'Compila tutti i campi obbligatori';

  @override
  String get insertBrand => 'Inserisci la marca';

  @override
  String get insertModel => 'Inserisci il modello';

  @override
  String get refuelingDetails => 'Dettagli Rifornimento';

  @override
  String get date => 'Data';

  @override
  String get currentKm => 'Km Attuali';

  @override
  String get gasLiters => 'Litri Benzina';

  @override
  String get oilLiters => 'Litri Olio';

  @override
  String get none => 'Nessuno';

  @override
  String get oilPercentage => 'Percentuale Olio';

  @override
  String get kmTraveled => 'Km Percorsi';

  @override
  String get averageConsumption => 'Media Consumo';

  @override
  String get averageConsumptionCalcTitle => 'Calcolo Consumo Medio';

  @override
  String get averageConsumptionCalcDesc =>
      'Il consumo medio viene calcolato dividendo i chilometri percorsi dall\'ultimo rifornimento per i litri di benzina inseriti in questo rifornimento. Si assume che ad ogni rifornimento venga fatto il pieno.';

  @override
  String get addRefueling => 'Aggiungi Rifornimento';

  @override
  String get editRefueling => 'Modifica Rifornimento';

  @override
  String get selectDate => 'Seleziona Data';

  @override
  String get dateTime => 'Data e Ora';

  @override
  String get oilAdded => 'Olio aggiunto?';

  @override
  String get saveRefueling => 'Salva Rifornimento';

  @override
  String get deleteRecordTitle => 'Elimina';

  @override
  String get deleteRecordContent => 'Vuoi eliminare questo record?';

  @override
  String get generalInfo => 'INFORMAZIONI GENERALI';

  @override
  String get details => 'DETTAGLI';

  @override
  String get autoMixer => 'Miscelatore Automatico';

  @override
  String get autoMixerDesc => 'Attiva se lo scooter gestisce l\'olio da solo';

  @override
  String get requiredField => 'Campo obbligatorio';

  @override
  String get insertNumber => 'Inserire un numero';

  @override
  String get invalidLicensePlate => 'Formato targa non valido';

  @override
  String get invalidYear => 'Anno non valido (es. compreso tra 1900 e oggi)';

  @override
  String get impostazioni => 'Impostazioni';

  @override
  String get aspetto => 'Aspetto';

  @override
  String get lingua => 'Lingua';

  @override
  String get informazioni => 'Informazioni';

  @override
  String get versione => 'Versione';

  @override
  String get termini_condizioni => 'Termini e Condizioni';

  @override
  String get fatto => 'Fatto';

  @override
  String get legale => 'Legale';

  @override
  String get maggiori_info => 'Maggiori Informazioni';

  @override
  String get leggi_sito => 'Leggi sul sito';

  @override
  String get info_text =>
      'Per conoscere i dettagli sulla gestione dei dati e i termini d\'uso, visita il nostro sito ufficiale.';

  @override
  String get info_dati =>
      'L\'app non raccoglie dati personali su server esterni. Tutto viene salvato localmente.';

  @override
  String get sistema => 'Sistema';

  @override
  String get chiaro => 'Chiaro';

  @override
  String get scuro => 'Scuro';

  @override
  String get errorSharing => 'Errore durante la condivisione';

  @override
  String get errorSaving => 'Errore durante il salvataggio';

  @override
  String get errorLoadingRefuelings =>
      'Errore nel caricamento dei rifornimenti';

  @override
  String get errorDeleting => 'Errore durante l\'eliminazione';

  @override
  String get recordDeleted => 'Record eliminato con successo';

  @override
  String get permissionDenied => 'Permesso negato';

  @override
  String get imageSaved => 'Immagine salvata nella galleria!';

  @override
  String get errorUpdating => 'Errore durante l\'aggiornamento';

  @override
  String get scooterAdded => 'Scooter aggiunto con successo!';

  @override
  String get scooterDeleted => 'Scooter eliminato';

  @override
  String get licensePlateShort => 'Targa';

  @override
  String shareText(String scooter) {
    return 'Guarda il mio $scooter!';
  }

  @override
  String get shareSubject => 'Foto Scooter';

  @override
  String get refuelingData => 'Dati rifornimenti';

  @override
  String get dateAndKm => 'DATA E CHILOMETRI';

  @override
  String get fuelAndMix => 'CARBURANTE E MISCELA';

  @override
  String get calculatedLabel => '(Calcolato)';

  @override
  String get errorInitialData => 'Errore nel caricamento dei dati iniziali.';

  @override
  String mustBeGreaterThan(String km) {
    return 'Deve essere > del precedente ($km km)';
  }

  @override
  String get cantOpenBrowser => 'Impossibile aprire il browser';

  @override
  String get dati => 'DATI';

  @override
  String get backupRestoreTitle => 'Backup e Ripristino';

  @override
  String get backupSection => 'ESPORTA BACKUP';

  @override
  String get backupDesc =>
      'Salva una copia sicura dei tuoi dati. Puoi salvare il file su Google Drive, iCloud, inviartelo per email o tenerlo sul telefono.';

  @override
  String get createBackupBtn => 'Crea Backup';

  @override
  String get restoreSection => 'RIPRISTINA BACKUP';

  @override
  String get restoreDesc =>
      'ATTENZIONE: Il ripristino sovrascriverà tutti i dati attuali presenti nell\'app con quelli del backup. L\'operazione non è reversibile.';

  @override
  String get restoreBtn => 'Scegli file di backup';

  @override
  String get restoreSuccess => 'Dati ripristinati con successo!';

  @override
  String get errorBackup => 'Errore durante il backup';

  @override
  String get errorRestore => 'Errore durante il ripristino o file non valido';

  @override
  String get costoLabel => 'Costo';

  @override
  String get noteLabel => 'Note';

  @override
  String get placeholderNote => 'Aggiungi note (es. nome distributore)';

  @override
  String get posizioneGPSLabel => 'Posizione GPS';

  @override
  String get aggiungiPosizione => 'Aggiungi posizione';

  @override
  String get posizioneSalvata => 'Posizione salvata';

  @override
  String get selezionaSullaMappa => 'Seleziona sulla mappa';

  @override
  String get confermaPosizione => 'Conferma posizione';

  @override
  String get erroreCostoNonValido => 'Inserisci un costo valido';

  @override
  String get apriInGoogleMaps => 'Apri in Google Maps';

  @override
  String get apriInWaze => 'Apri in Waze';

  @override
  String get distributorePin => 'Distributore';

  @override
  String get registroManutenzione => 'Registro Manutenzione';

  @override
  String get nessunaManutenzione => 'Nessuna manutenzione registrata.';

  @override
  String get aggiungiIntervento => 'Aggiungi Intervento';

  @override
  String get nuovoIntervento => 'Nuovo Intervento';

  @override
  String get dettagliIntervento => 'Dettagli Intervento';

  @override
  String get modificaIntervento => 'Modifica Intervento';

  @override
  String get titoloIntervento => 'Titolo (es. Sostituzione candela)';

  @override
  String get dataIntervento => 'Data';

  @override
  String get categoria => 'Categoria';

  @override
  String get specificaAltro => 'Specifica categoria';

  @override
  String get costoOpzionale => 'Costo (Opzionale)';

  @override
  String get noteDettagli => 'Note / Dettagli';

  @override
  String get fotoRicevuta => 'Foto / Ricevuta';

  @override
  String get selezionaFoto => 'Seleziona un\'immagine';

  @override
  String get rimuoviFoto => 'Rimuovi foto';

  @override
  String get datiMancanti => 'Dati mancanti';

  @override
  String get erroreDatiMessaggio =>
      'Inserisci un titolo e i chilometri validi per continuare.';

  @override
  String get infoPrincipali => 'Informazioni Principali';

  @override
  String get dettagliAggiuntivi => 'Dettagli Aggiuntivi';

  @override
  String get notePlaceholder => 'Aggiungi note sull\'intervento...';

  @override
  String get cat_motore => 'Motore';

  @override
  String get cat_accensione => 'Accensione / Elettrica';

  @override
  String get cat_alimentazione => 'Alimentazione';

  @override
  String get cat_olio_cambio => 'Olio Cambio';

  @override
  String get cat_trasmissione => 'Trasmissione / Cavi';

  @override
  String get cat_freni_gomme => 'Freni / Gomme';

  @override
  String get cat_carrozzeria => 'Carrozzeria / Telaio';

  @override
  String get cat_altro => 'Altro';

  @override
  String get confirmTitle => 'Conferma';

  @override
  String get confirmDeleteMaintenance =>
      'Sei sicuro di voler eliminare questo intervento?';

  @override
  String get maintenanceSaved => 'Intervento salvato!';

  @override
  String get maintenanceDeleted => 'Intervento eliminato';

  @override
  String get backupShareSubject => 'Backup MyScooter';

  @override
  String get backupShareText => 'Backup MyScooter (Dati + Foto)';

  @override
  String get documentiScadenze => 'Documenti e Scadenze';

  @override
  String get nessunDocumento => 'Nessun documento salvato';

  @override
  String get scadeIl => 'Scadenza:';

  @override
  String get scaduto => 'Scaduto!';

  @override
  String get inScadenza => 'In scadenza';

  @override
  String get senzaScadenza => 'Nessuna scadenza';

  @override
  String get tipoDocumento => 'Tipo di Documento';

  @override
  String get haScadenza => 'Ha una data di scadenza?';

  @override
  String get dataScadenza => 'Data di Scadenza';

  @override
  String get docLibretto => 'Libretto';

  @override
  String get docAssicurazione => 'Assicurazione';

  @override
  String get docRevisione => 'Revisione';

  @override
  String get docBollo => 'Bollo';

  @override
  String get docCertificato => 'Certificato Storico';

  @override
  String get docPatente => 'Patente';

  @override
  String get documentSaved => 'Documento salvato!';

  @override
  String get documentDeleted => 'Documento eliminato';

  @override
  String get aggiungi => 'Aggiungi';

  @override
  String get esportaPDF => 'Esporta Report PDF';

  @override
  String get reportDi => 'Report di';

  @override
  String get totaleManutenzioni => 'Totale Manutenzioni:';

  @override
  String get totaleRifornimenti => 'Totale Rifornimenti:';

  @override
  String get litriConsumati => 'Litri Consumati';

  @override
  String get costoTotaleGestione => 'Costo Totale Gestione';

  @override
  String get generatoDa => 'Generato da myScooter';

  @override
  String get pag => 'Pag.';

  @override
  String get onboardingTitle1 => 'Il tuo Garage Virtuale';

  @override
  String get onboardingDesc1 =>
      'Gestisci tutte le tue Vespe e i tuoi scooter in un\'unica app, sempre a portata di mano.';

  @override
  String get onboardingTitle2 => 'Tieni traccia dei Rifornimenti';

  @override
  String get onboardingDesc2 =>
      'Registra i pieni e monitora i consumi. Calcola automaticamente litri, costi e medie.';

  @override
  String get onboardingTitle3 => 'Il tuo Portadocumenti';

  @override
  String get onboardingDesc3 =>
      'Salva libretto, assicurazione e altri documenti. Ricevi notifiche automatiche prima delle scadenze!';

  @override
  String get salta => 'Salta';

  @override
  String get avanti => 'Avanti';

  @override
  String get inizia => 'Inizia';
}
