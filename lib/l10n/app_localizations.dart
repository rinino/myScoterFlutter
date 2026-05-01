import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In it, this message translates to:
  /// **'My Scooter'**
  String get appTitle;

  /// No description provided for @myScooters.
  ///
  /// In it, this message translates to:
  /// **'I Miei Scooter'**
  String get myScooters;

  /// No description provided for @noScooterFound.
  ///
  /// In it, this message translates to:
  /// **'Nessuno scooter trovato.'**
  String get noScooterFound;

  /// No description provided for @addScooterPrompt.
  ///
  /// In it, this message translates to:
  /// **'Premi \"+\" per aggiungerne uno!'**
  String get addScooterPrompt;

  /// No description provided for @delete.
  ///
  /// In it, this message translates to:
  /// **'ELIMINA'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In it, this message translates to:
  /// **'ANNULLA'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In it, this message translates to:
  /// **'SALVA'**
  String get save;

  /// No description provided for @deleteScooterTitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina Scooter'**
  String get deleteScooterTitle;

  /// No description provided for @deleteScooterContent.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare lo scooter {modello}?\nQuesta azione cancellerà anche tutti i rifornimenti.'**
  String deleteScooterContent(String modello);

  /// No description provided for @brand.
  ///
  /// In it, this message translates to:
  /// **'Marca'**
  String get brand;

  /// No description provided for @model.
  ///
  /// In it, this message translates to:
  /// **'Modello'**
  String get model;

  /// No description provided for @displacement.
  ///
  /// In it, this message translates to:
  /// **'Cilindrata'**
  String get displacement;

  /// No description provided for @mixer.
  ///
  /// In it, this message translates to:
  /// **'Miscelatore'**
  String get mixer;

  /// No description provided for @yes.
  ///
  /// In it, this message translates to:
  /// **'Sì'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In it, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @refuelings.
  ///
  /// In it, this message translates to:
  /// **'RIFORNIMENTI'**
  String get refuelings;

  /// No description provided for @noDataPresent.
  ///
  /// In it, this message translates to:
  /// **'Nessun dato presente'**
  String get noDataPresent;

  /// No description provided for @sharePhoto.
  ///
  /// In it, this message translates to:
  /// **'Condividi foto'**
  String get sharePhoto;

  /// No description provided for @saveToGallery.
  ///
  /// In it, this message translates to:
  /// **'Salva in galleria'**
  String get saveToGallery;

  /// No description provided for @scooterUpdated.
  ///
  /// In it, this message translates to:
  /// **'Scooter aggiornato!'**
  String get scooterUpdated;

  /// No description provided for @refuelingSaved.
  ///
  /// In it, this message translates to:
  /// **'Rifornimento salvato!'**
  String get refuelingSaved;

  /// No description provided for @addScooter.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi Scooter'**
  String get addScooter;

  /// No description provided for @editScooter.
  ///
  /// In it, this message translates to:
  /// **'Modifica Scooter'**
  String get editScooter;

  /// No description provided for @licensePlate.
  ///
  /// In it, this message translates to:
  /// **'Targa'**
  String get licensePlate;

  /// No description provided for @year.
  ///
  /// In it, this message translates to:
  /// **'Anno'**
  String get year;

  /// No description provided for @tankCapacity.
  ///
  /// In it, this message translates to:
  /// **'Capacità Serbatoio (L)'**
  String get tankCapacity;

  /// No description provided for @selectImage.
  ///
  /// In it, this message translates to:
  /// **'Seleziona Immagine'**
  String get selectImage;

  /// No description provided for @camera.
  ///
  /// In it, this message translates to:
  /// **'Fotocamera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In it, this message translates to:
  /// **'Galleria'**
  String get gallery;

  /// No description provided for @removePhoto.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi Foto'**
  String get removePhoto;

  /// No description provided for @missingFields.
  ///
  /// In it, this message translates to:
  /// **'Compila tutti i campi obbligatori'**
  String get missingFields;

  /// No description provided for @insertBrand.
  ///
  /// In it, this message translates to:
  /// **'Inserisci la marca'**
  String get insertBrand;

  /// No description provided for @insertModel.
  ///
  /// In it, this message translates to:
  /// **'Inserisci il modello'**
  String get insertModel;

  /// No description provided for @refuelingDetails.
  ///
  /// In it, this message translates to:
  /// **'Dettagli Rifornimento'**
  String get refuelingDetails;

  /// No description provided for @date.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get date;

  /// No description provided for @currentKm.
  ///
  /// In it, this message translates to:
  /// **'Km Attuali'**
  String get currentKm;

  /// No description provided for @gasLiters.
  ///
  /// In it, this message translates to:
  /// **'Litri Benzina'**
  String get gasLiters;

  /// No description provided for @oilLiters.
  ///
  /// In it, this message translates to:
  /// **'Litri Olio'**
  String get oilLiters;

  /// No description provided for @none.
  ///
  /// In it, this message translates to:
  /// **'Nessuno'**
  String get none;

  /// No description provided for @oilPercentage.
  ///
  /// In it, this message translates to:
  /// **'Percentuale Olio'**
  String get oilPercentage;

  /// No description provided for @kmTraveled.
  ///
  /// In it, this message translates to:
  /// **'Km Percorsi'**
  String get kmTraveled;

  /// No description provided for @averageConsumption.
  ///
  /// In it, this message translates to:
  /// **'Media Consumo'**
  String get averageConsumption;

  /// No description provided for @averageConsumptionCalcTitle.
  ///
  /// In it, this message translates to:
  /// **'Calcolo Consumo Medio'**
  String get averageConsumptionCalcTitle;

  /// No description provided for @averageConsumptionCalcDesc.
  ///
  /// In it, this message translates to:
  /// **'Il consumo medio viene calcolato dividendo i chilometri percorsi dall\'ultimo rifornimento per i litri di benzina inseriti in questo rifornimento. Si assume che ad ogni rifornimento venga fatto il pieno.'**
  String get averageConsumptionCalcDesc;

  /// No description provided for @addRefueling.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi Rifornimento'**
  String get addRefueling;

  /// No description provided for @editRefueling.
  ///
  /// In it, this message translates to:
  /// **'Modifica Rifornimento'**
  String get editRefueling;

  /// No description provided for @selectDate.
  ///
  /// In it, this message translates to:
  /// **'Seleziona Data'**
  String get selectDate;

  /// No description provided for @dateTime.
  ///
  /// In it, this message translates to:
  /// **'Data e Ora'**
  String get dateTime;

  /// No description provided for @oilAdded.
  ///
  /// In it, this message translates to:
  /// **'Olio aggiunto?'**
  String get oilAdded;

  /// No description provided for @saveRefueling.
  ///
  /// In it, this message translates to:
  /// **'Salva Rifornimento'**
  String get saveRefueling;

  /// No description provided for @deleteRecordTitle.
  ///
  /// In it, this message translates to:
  /// **'Elimina'**
  String get deleteRecordTitle;

  /// No description provided for @deleteRecordContent.
  ///
  /// In it, this message translates to:
  /// **'Vuoi eliminare questo record?'**
  String get deleteRecordContent;

  /// No description provided for @generalInfo.
  ///
  /// In it, this message translates to:
  /// **'INFORMAZIONI GENERALI'**
  String get generalInfo;

  /// No description provided for @details.
  ///
  /// In it, this message translates to:
  /// **'DETTAGLI'**
  String get details;

  /// No description provided for @autoMixer.
  ///
  /// In it, this message translates to:
  /// **'Miscelatore Automatico'**
  String get autoMixer;

  /// No description provided for @autoMixerDesc.
  ///
  /// In it, this message translates to:
  /// **'Attiva se lo scooter gestisce l\'olio da solo'**
  String get autoMixerDesc;

  /// No description provided for @requiredField.
  ///
  /// In it, this message translates to:
  /// **'Campo obbligatorio'**
  String get requiredField;

  /// No description provided for @insertNumber.
  ///
  /// In it, this message translates to:
  /// **'Inserire un numero'**
  String get insertNumber;

  /// No description provided for @invalidLicensePlate.
  ///
  /// In it, this message translates to:
  /// **'Formato targa non valido'**
  String get invalidLicensePlate;

  /// No description provided for @invalidYear.
  ///
  /// In it, this message translates to:
  /// **'Anno non valido (es. compreso tra 1900 e oggi)'**
  String get invalidYear;

  /// No description provided for @impostazioni.
  ///
  /// In it, this message translates to:
  /// **'Impostazioni'**
  String get impostazioni;

  /// No description provided for @aspetto.
  ///
  /// In it, this message translates to:
  /// **'Aspetto'**
  String get aspetto;

  /// No description provided for @lingua.
  ///
  /// In it, this message translates to:
  /// **'Lingua'**
  String get lingua;

  /// No description provided for @informazioni.
  ///
  /// In it, this message translates to:
  /// **'Informazioni'**
  String get informazioni;

  /// No description provided for @versione.
  ///
  /// In it, this message translates to:
  /// **'Versione'**
  String get versione;

  /// No description provided for @termini_condizioni.
  ///
  /// In it, this message translates to:
  /// **'Termini e Condizioni'**
  String get termini_condizioni;

  /// No description provided for @fatto.
  ///
  /// In it, this message translates to:
  /// **'Fatto'**
  String get fatto;

  /// No description provided for @legale.
  ///
  /// In it, this message translates to:
  /// **'Legale'**
  String get legale;

  /// No description provided for @maggiori_info.
  ///
  /// In it, this message translates to:
  /// **'Maggiori Informazioni'**
  String get maggiori_info;

  /// No description provided for @leggi_sito.
  ///
  /// In it, this message translates to:
  /// **'Leggi sul sito'**
  String get leggi_sito;

  /// No description provided for @info_text.
  ///
  /// In it, this message translates to:
  /// **'Per conoscere i dettagli sulla gestione dei dati e i termini d\'uso, visita il nostro sito ufficiale.'**
  String get info_text;

  /// No description provided for @info_dati.
  ///
  /// In it, this message translates to:
  /// **'L\'app non raccoglie dati personali su server esterni. Tutto viene salvato localmente.'**
  String get info_dati;

  /// No description provided for @sistema.
  ///
  /// In it, this message translates to:
  /// **'Sistema'**
  String get sistema;

  /// No description provided for @chiaro.
  ///
  /// In it, this message translates to:
  /// **'Chiaro'**
  String get chiaro;

  /// No description provided for @scuro.
  ///
  /// In it, this message translates to:
  /// **'Scuro'**
  String get scuro;

  /// No description provided for @errorSharing.
  ///
  /// In it, this message translates to:
  /// **'Errore durante la condivisione'**
  String get errorSharing;

  /// No description provided for @errorSaving.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il salvataggio'**
  String get errorSaving;

  /// No description provided for @errorLoadingRefuelings.
  ///
  /// In it, this message translates to:
  /// **'Errore nel caricamento dei rifornimenti'**
  String get errorLoadingRefuelings;

  /// No description provided for @errorDeleting.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'eliminazione'**
  String get errorDeleting;

  /// No description provided for @recordDeleted.
  ///
  /// In it, this message translates to:
  /// **'Record eliminato con successo'**
  String get recordDeleted;

  /// No description provided for @permissionDenied.
  ///
  /// In it, this message translates to:
  /// **'Permesso negato'**
  String get permissionDenied;

  /// No description provided for @imageSaved.
  ///
  /// In it, this message translates to:
  /// **'Immagine salvata nella galleria!'**
  String get imageSaved;

  /// No description provided for @errorUpdating.
  ///
  /// In it, this message translates to:
  /// **'Errore durante l\'aggiornamento'**
  String get errorUpdating;

  /// No description provided for @scooterAdded.
  ///
  /// In it, this message translates to:
  /// **'Scooter aggiunto con successo!'**
  String get scooterAdded;

  /// No description provided for @scooterDeleted.
  ///
  /// In it, this message translates to:
  /// **'Scooter eliminato'**
  String get scooterDeleted;

  /// No description provided for @licensePlateShort.
  ///
  /// In it, this message translates to:
  /// **'Targa'**
  String get licensePlateShort;

  /// No description provided for @shareText.
  ///
  /// In it, this message translates to:
  /// **'Guarda il mio {scooter}!'**
  String shareText(String scooter);

  /// No description provided for @shareSubject.
  ///
  /// In it, this message translates to:
  /// **'Foto Scooter'**
  String get shareSubject;

  /// No description provided for @refuelingData.
  ///
  /// In it, this message translates to:
  /// **'Dati rifornimenti'**
  String get refuelingData;

  /// No description provided for @dateAndKm.
  ///
  /// In it, this message translates to:
  /// **'DATA E CHILOMETRI'**
  String get dateAndKm;

  /// No description provided for @fuelAndMix.
  ///
  /// In it, this message translates to:
  /// **'CARBURANTE E MISCELA'**
  String get fuelAndMix;

  /// No description provided for @calculatedLabel.
  ///
  /// In it, this message translates to:
  /// **'(Calcolato)'**
  String get calculatedLabel;

  /// No description provided for @errorInitialData.
  ///
  /// In it, this message translates to:
  /// **'Errore nel caricamento dei dati iniziali.'**
  String get errorInitialData;

  /// No description provided for @mustBeGreaterThan.
  ///
  /// In it, this message translates to:
  /// **'Deve essere > del precedente ({km} km)'**
  String mustBeGreaterThan(String km);

  /// No description provided for @cantOpenBrowser.
  ///
  /// In it, this message translates to:
  /// **'Impossibile aprire il browser'**
  String get cantOpenBrowser;

  /// No description provided for @dati.
  ///
  /// In it, this message translates to:
  /// **'DATI'**
  String get dati;

  /// No description provided for @backupRestoreTitle.
  ///
  /// In it, this message translates to:
  /// **'Backup e Ripristino'**
  String get backupRestoreTitle;

  /// No description provided for @backupSection.
  ///
  /// In it, this message translates to:
  /// **'ESPORTA BACKUP'**
  String get backupSection;

  /// No description provided for @backupDesc.
  ///
  /// In it, this message translates to:
  /// **'Salva una copia sicura dei tuoi dati. Puoi salvare il file su Google Drive, iCloud, inviartelo per email o tenerlo sul telefono.'**
  String get backupDesc;

  /// No description provided for @createBackupBtn.
  ///
  /// In it, this message translates to:
  /// **'Crea Backup'**
  String get createBackupBtn;

  /// No description provided for @restoreSection.
  ///
  /// In it, this message translates to:
  /// **'RIPRISTINA BACKUP'**
  String get restoreSection;

  /// No description provided for @restoreDesc.
  ///
  /// In it, this message translates to:
  /// **'ATTENZIONE: Il ripristino sovrascriverà tutti i dati attuali presenti nell\'app con quelli del backup. L\'operazione non è reversibile.'**
  String get restoreDesc;

  /// No description provided for @restoreBtn.
  ///
  /// In it, this message translates to:
  /// **'Scegli file di backup'**
  String get restoreBtn;

  /// No description provided for @restoreSuccess.
  ///
  /// In it, this message translates to:
  /// **'Dati ripristinati con successo!'**
  String get restoreSuccess;

  /// No description provided for @errorBackup.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il backup'**
  String get errorBackup;

  /// No description provided for @errorRestore.
  ///
  /// In it, this message translates to:
  /// **'Errore durante il ripristino o file non valido'**
  String get errorRestore;

  /// No description provided for @costoLabel.
  ///
  /// In it, this message translates to:
  /// **'Costo'**
  String get costoLabel;

  /// No description provided for @noteLabel.
  ///
  /// In it, this message translates to:
  /// **'Note'**
  String get noteLabel;

  /// No description provided for @placeholderNote.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi note (es. nome distributore)'**
  String get placeholderNote;

  /// No description provided for @posizioneGPSLabel.
  ///
  /// In it, this message translates to:
  /// **'Posizione GPS'**
  String get posizioneGPSLabel;

  /// No description provided for @aggiungiPosizione.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi posizione'**
  String get aggiungiPosizione;

  /// No description provided for @posizioneSalvata.
  ///
  /// In it, this message translates to:
  /// **'Posizione salvata'**
  String get posizioneSalvata;

  /// No description provided for @selezionaSullaMappa.
  ///
  /// In it, this message translates to:
  /// **'Seleziona sulla mappa'**
  String get selezionaSullaMappa;

  /// No description provided for @confermaPosizione.
  ///
  /// In it, this message translates to:
  /// **'Conferma posizione'**
  String get confermaPosizione;

  /// No description provided for @erroreCostoNonValido.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un costo valido'**
  String get erroreCostoNonValido;

  /// No description provided for @apriInGoogleMaps.
  ///
  /// In it, this message translates to:
  /// **'Apri in Google Maps'**
  String get apriInGoogleMaps;

  /// No description provided for @apriInWaze.
  ///
  /// In it, this message translates to:
  /// **'Apri in Waze'**
  String get apriInWaze;

  /// No description provided for @distributorePin.
  ///
  /// In it, this message translates to:
  /// **'Distributore'**
  String get distributorePin;

  /// No description provided for @registroManutenzione.
  ///
  /// In it, this message translates to:
  /// **'Registro Manutenzione'**
  String get registroManutenzione;

  /// No description provided for @nessunaManutenzione.
  ///
  /// In it, this message translates to:
  /// **'Nessuna manutenzione registrata.'**
  String get nessunaManutenzione;

  /// No description provided for @aggiungiIntervento.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi Intervento'**
  String get aggiungiIntervento;

  /// No description provided for @nuovoIntervento.
  ///
  /// In it, this message translates to:
  /// **'Nuovo Intervento'**
  String get nuovoIntervento;

  /// No description provided for @dettagliIntervento.
  ///
  /// In it, this message translates to:
  /// **'Dettagli Intervento'**
  String get dettagliIntervento;

  /// No description provided for @modificaIntervento.
  ///
  /// In it, this message translates to:
  /// **'Modifica Intervento'**
  String get modificaIntervento;

  /// No description provided for @titoloIntervento.
  ///
  /// In it, this message translates to:
  /// **'Titolo (es. Sostituzione candela)'**
  String get titoloIntervento;

  /// No description provided for @dataIntervento.
  ///
  /// In it, this message translates to:
  /// **'Data'**
  String get dataIntervento;

  /// No description provided for @categoria.
  ///
  /// In it, this message translates to:
  /// **'Categoria'**
  String get categoria;

  /// No description provided for @specificaAltro.
  ///
  /// In it, this message translates to:
  /// **'Specifica categoria'**
  String get specificaAltro;

  /// No description provided for @costoOpzionale.
  ///
  /// In it, this message translates to:
  /// **'Costo (Opzionale)'**
  String get costoOpzionale;

  /// No description provided for @noteDettagli.
  ///
  /// In it, this message translates to:
  /// **'Note / Dettagli'**
  String get noteDettagli;

  /// No description provided for @fotoRicevuta.
  ///
  /// In it, this message translates to:
  /// **'Foto / Ricevuta'**
  String get fotoRicevuta;

  /// No description provided for @selezionaFoto.
  ///
  /// In it, this message translates to:
  /// **'Seleziona un\'immagine'**
  String get selezionaFoto;

  /// No description provided for @rimuoviFoto.
  ///
  /// In it, this message translates to:
  /// **'Rimuovi foto'**
  String get rimuoviFoto;

  /// No description provided for @datiMancanti.
  ///
  /// In it, this message translates to:
  /// **'Dati mancanti'**
  String get datiMancanti;

  /// No description provided for @erroreDatiMessaggio.
  ///
  /// In it, this message translates to:
  /// **'Inserisci un titolo e i chilometri validi per continuare.'**
  String get erroreDatiMessaggio;

  /// No description provided for @infoPrincipali.
  ///
  /// In it, this message translates to:
  /// **'Informazioni Principali'**
  String get infoPrincipali;

  /// No description provided for @dettagliAggiuntivi.
  ///
  /// In it, this message translates to:
  /// **'Dettagli Aggiuntivi'**
  String get dettagliAggiuntivi;

  /// No description provided for @notePlaceholder.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi note sull\'intervento...'**
  String get notePlaceholder;

  /// No description provided for @cat_motore.
  ///
  /// In it, this message translates to:
  /// **'Motore'**
  String get cat_motore;

  /// No description provided for @cat_accensione.
  ///
  /// In it, this message translates to:
  /// **'Accensione / Elettrica'**
  String get cat_accensione;

  /// No description provided for @cat_alimentazione.
  ///
  /// In it, this message translates to:
  /// **'Alimentazione'**
  String get cat_alimentazione;

  /// No description provided for @cat_olio_cambio.
  ///
  /// In it, this message translates to:
  /// **'Olio Cambio'**
  String get cat_olio_cambio;

  /// No description provided for @cat_trasmissione.
  ///
  /// In it, this message translates to:
  /// **'Trasmissione / Cavi'**
  String get cat_trasmissione;

  /// No description provided for @cat_freni_gomme.
  ///
  /// In it, this message translates to:
  /// **'Freni / Gomme'**
  String get cat_freni_gomme;

  /// No description provided for @cat_carrozzeria.
  ///
  /// In it, this message translates to:
  /// **'Carrozzeria / Telaio'**
  String get cat_carrozzeria;

  /// No description provided for @cat_altro.
  ///
  /// In it, this message translates to:
  /// **'Altro'**
  String get cat_altro;

  /// No description provided for @confirmTitle.
  ///
  /// In it, this message translates to:
  /// **'Conferma'**
  String get confirmTitle;

  /// No description provided for @confirmDeleteMaintenance.
  ///
  /// In it, this message translates to:
  /// **'Sei sicuro di voler eliminare questo intervento?'**
  String get confirmDeleteMaintenance;

  /// No description provided for @maintenanceSaved.
  ///
  /// In it, this message translates to:
  /// **'Intervento salvato!'**
  String get maintenanceSaved;

  /// No description provided for @maintenanceDeleted.
  ///
  /// In it, this message translates to:
  /// **'Intervento eliminato'**
  String get maintenanceDeleted;

  /// No description provided for @backupShareSubject.
  ///
  /// In it, this message translates to:
  /// **'Backup MyScooter'**
  String get backupShareSubject;

  /// No description provided for @backupShareText.
  ///
  /// In it, this message translates to:
  /// **'Backup MyScooter (Dati + Foto)'**
  String get backupShareText;

  /// No description provided for @documentiScadenze.
  ///
  /// In it, this message translates to:
  /// **'Documenti e Scadenze'**
  String get documentiScadenze;

  /// No description provided for @nessunDocumento.
  ///
  /// In it, this message translates to:
  /// **'Nessun documento salvato'**
  String get nessunDocumento;

  /// No description provided for @scadeIl.
  ///
  /// In it, this message translates to:
  /// **'Scadenza:'**
  String get scadeIl;

  /// No description provided for @scaduto.
  ///
  /// In it, this message translates to:
  /// **'Scaduto!'**
  String get scaduto;

  /// No description provided for @inScadenza.
  ///
  /// In it, this message translates to:
  /// **'In scadenza'**
  String get inScadenza;

  /// No description provided for @senzaScadenza.
  ///
  /// In it, this message translates to:
  /// **'Nessuna scadenza'**
  String get senzaScadenza;

  /// No description provided for @tipoDocumento.
  ///
  /// In it, this message translates to:
  /// **'Tipo di Documento'**
  String get tipoDocumento;

  /// No description provided for @haScadenza.
  ///
  /// In it, this message translates to:
  /// **'Ha una data di scadenza?'**
  String get haScadenza;

  /// No description provided for @dataScadenza.
  ///
  /// In it, this message translates to:
  /// **'Data di Scadenza'**
  String get dataScadenza;

  /// No description provided for @docLibretto.
  ///
  /// In it, this message translates to:
  /// **'Libretto'**
  String get docLibretto;

  /// No description provided for @docAssicurazione.
  ///
  /// In it, this message translates to:
  /// **'Assicurazione'**
  String get docAssicurazione;

  /// No description provided for @docRevisione.
  ///
  /// In it, this message translates to:
  /// **'Revisione'**
  String get docRevisione;

  /// No description provided for @docBollo.
  ///
  /// In it, this message translates to:
  /// **'Bollo'**
  String get docBollo;

  /// No description provided for @docCertificato.
  ///
  /// In it, this message translates to:
  /// **'Certificato Storico'**
  String get docCertificato;

  /// No description provided for @docPatente.
  ///
  /// In it, this message translates to:
  /// **'Patente'**
  String get docPatente;

  /// No description provided for @documentSaved.
  ///
  /// In it, this message translates to:
  /// **'Documento salvato!'**
  String get documentSaved;

  /// No description provided for @documentDeleted.
  ///
  /// In it, this message translates to:
  /// **'Documento eliminato'**
  String get documentDeleted;

  /// No description provided for @aggiungi.
  ///
  /// In it, this message translates to:
  /// **'Aggiungi'**
  String get aggiungi;

  /// No description provided for @esportaPDF.
  ///
  /// In it, this message translates to:
  /// **'Esporta Report PDF'**
  String get esportaPDF;

  /// No description provided for @reportDi.
  ///
  /// In it, this message translates to:
  /// **'Report di'**
  String get reportDi;

  /// No description provided for @totaleManutenzioni.
  ///
  /// In it, this message translates to:
  /// **'Totale Manutenzioni:'**
  String get totaleManutenzioni;

  /// No description provided for @totaleRifornimenti.
  ///
  /// In it, this message translates to:
  /// **'Totale Rifornimenti:'**
  String get totaleRifornimenti;

  /// No description provided for @litriConsumati.
  ///
  /// In it, this message translates to:
  /// **'Litri Consumati'**
  String get litriConsumati;

  /// No description provided for @costoTotaleGestione.
  ///
  /// In it, this message translates to:
  /// **'Costo Totale Gestione'**
  String get costoTotaleGestione;

  /// No description provided for @generatoDa.
  ///
  /// In it, this message translates to:
  /// **'Generato da myScooter'**
  String get generatoDa;

  /// No description provided for @pag.
  ///
  /// In it, this message translates to:
  /// **'Pag.'**
  String get pag;

  /// No description provided for @onboardingTitle1.
  ///
  /// In it, this message translates to:
  /// **'Il tuo Garage Virtuale'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In it, this message translates to:
  /// **'Gestisci tutte le tue Vespe e i tuoi scooter in un\'unica app, sempre a portata di mano.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In it, this message translates to:
  /// **'Tieni traccia dei Rifornimenti'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In it, this message translates to:
  /// **'Registra i pieni e monitora i consumi. Calcola automaticamente litri, costi e medie.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In it, this message translates to:
  /// **'Il tuo Portadocumenti'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In it, this message translates to:
  /// **'Salva libretto, assicurazione e altri documenti. Ricevi notifiche automatiche prima delle scadenze!'**
  String get onboardingDesc3;

  /// No description provided for @salta.
  ///
  /// In it, this message translates to:
  /// **'Salta'**
  String get salta;

  /// No description provided for @avanti.
  ///
  /// In it, this message translates to:
  /// **'Avanti'**
  String get avanti;

  /// No description provided for @inizia.
  ///
  /// In it, this message translates to:
  /// **'Inizia'**
  String get inizia;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
