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
}
