// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Scooter';

  @override
  String get myScooters => 'My Scooters';

  @override
  String get noScooterFound => 'No scooters found.';

  @override
  String get addScooterPrompt => 'Press \"+\" to add one!';

  @override
  String get delete => 'DELETE';

  @override
  String get cancel => 'CANCEL';

  @override
  String get save => 'SAVE';

  @override
  String get deleteScooterTitle => 'Delete Scooter';

  @override
  String deleteScooterContent(String modello) {
    return 'Are you sure you want to delete the scooter $modello?\nThis action will also delete all its refuelings.';
  }

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get displacement => 'Displacement';

  @override
  String get mixer => 'Oil Mixer';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get refuelings => 'REFUELINGS';

  @override
  String get noDataPresent => 'No data present';

  @override
  String get sharePhoto => 'Share photo';

  @override
  String get saveToGallery => 'Save to gallery';

  @override
  String get scooterUpdated => 'Scooter updated!';

  @override
  String get refuelingSaved => 'Refueling saved!';

  @override
  String get addScooter => 'Add Scooter';

  @override
  String get editScooter => 'Edit Scooter';

  @override
  String get licensePlate => 'License Plate';

  @override
  String get year => 'Year';

  @override
  String get tankCapacity => 'Tank Capacity (L)';

  @override
  String get selectImage => 'Select Image';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get removePhoto => 'Remove Photo';

  @override
  String get missingFields => 'Please fill in all required fields';

  @override
  String get insertBrand => 'Enter brand';

  @override
  String get insertModel => 'Enter model';

  @override
  String get refuelingDetails => 'Refueling Details';

  @override
  String get date => 'Date';

  @override
  String get currentKm => 'Current Km';

  @override
  String get gasLiters => 'Gas Liters';

  @override
  String get oilLiters => 'Oil Liters';

  @override
  String get none => 'None';

  @override
  String get oilPercentage => 'Oil Percentage';

  @override
  String get kmTraveled => 'Km Traveled';

  @override
  String get averageConsumption => 'Average Consumption';

  @override
  String get averageConsumptionCalcTitle => 'Average Consumption Calculation';

  @override
  String get averageConsumptionCalcDesc =>
      'The average consumption is calculated by dividing the kilometers traveled since the last refueling by the liters of gas inserted in this refueling. It is assumed that the tank is filled up at each refueling.';

  @override
  String get addRefueling => 'Add Refueling';

  @override
  String get editRefueling => 'Edit Refueling';

  @override
  String get selectDate => 'Select Date';

  @override
  String get dateTime => 'Date and Time';

  @override
  String get oilAdded => 'Oil added?';

  @override
  String get saveRefueling => 'Save Refueling';

  @override
  String get deleteRecordTitle => 'Delete';

  @override
  String get deleteRecordContent => 'Do you want to delete this record?';

  @override
  String get generalInfo => 'GENERAL INFORMATION';

  @override
  String get details => 'DETAILS';

  @override
  String get autoMixer => 'Automatic Oil Mixer';

  @override
  String get autoMixerDesc => 'Enable if the scooter mixes oil automatically';

  @override
  String get requiredField => 'Required field';

  @override
  String get insertNumber => 'Please enter a valid number';

  @override
  String get invalidLicensePlate => 'Invalid license plate format';

  @override
  String get invalidYear => 'Invalid year (between 1900 and today)';

  @override
  String get impostazioni => 'Settings';

  @override
  String get aspetto => 'Appearance';

  @override
  String get lingua => 'Language';

  @override
  String get informazioni => 'Information';

  @override
  String get versione => 'Version';

  @override
  String get termini_condizioni => 'Terms and Conditions';

  @override
  String get fatto => 'Done';

  @override
  String get legale => 'Legal';

  @override
  String get maggiori_info => 'More Information';

  @override
  String get leggi_sito => 'Read on website';

  @override
  String get info_text =>
      'To know the details about data management and terms of use, visit our official website.';

  @override
  String get info_dati =>
      'The app does not collect personal data on external servers. Everything is saved locally.';

  @override
  String get sistema => 'System';

  @override
  String get chiaro => 'Light';

  @override
  String get scuro => 'Dark';

  @override
  String get errorSharing => 'Error while sharing';

  @override
  String get errorSaving => 'Error while saving';

  @override
  String get errorLoadingRefuelings => 'Error loading refuelings';

  @override
  String get errorDeleting => 'Error while deleting';

  @override
  String get recordDeleted => 'Record successfully deleted';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get imageSaved => 'Image saved to gallery!';

  @override
  String get errorUpdating => 'Error while updating';

  @override
  String get scooterAdded => 'Scooter added successfully!';

  @override
  String get scooterDeleted => 'Scooter deleted';

  @override
  String get licensePlateShort => 'Plate';

  @override
  String shareText(String scooter) {
    return 'Check out my $scooter!';
  }

  @override
  String get shareSubject => 'Scooter Photo';

  @override
  String get refuelingData => 'Refueling Data';

  @override
  String get dateAndKm => 'DATE AND KILOMETERS';

  @override
  String get fuelAndMix => 'FUEL AND MIX';

  @override
  String get calculatedLabel => '(Calculated)';

  @override
  String get errorInitialData => 'Error loading initial data.';

  @override
  String mustBeGreaterThan(String km) {
    return 'Must be > than previous ($km km)';
  }

  @override
  String get cantOpenBrowser => 'Cannot open browser';

  @override
  String get dati => 'DATA';

  @override
  String get backupRestoreTitle => 'Backup and Restore';

  @override
  String get backupSection => 'EXPORT BACKUP';

  @override
  String get backupDesc =>
      'Save a secure copy of your data. You can save the file to Google Drive, iCloud, email it to yourself, or keep it on your phone.';

  @override
  String get createBackupBtn => 'Create Backup';

  @override
  String get restoreSection => 'RESTORE BACKUP';

  @override
  String get restoreDesc =>
      'WARNING: Restoring will overwrite all current app data with the backup data. This operation cannot be undone.';

  @override
  String get restoreBtn => 'Choose backup file';

  @override
  String get restoreSuccess => 'Data successfully restored!';

  @override
  String get errorBackup => 'Error during backup';

  @override
  String get errorRestore => 'Error during restore or invalid file';

  @override
  String get costoLabel => 'Cost';

  @override
  String get noteLabel => 'Notes';

  @override
  String get placeholderNote => 'Add notes (e.g., station name)';

  @override
  String get posizioneGPSLabel => 'GPS Location';

  @override
  String get aggiungiPosizione => 'Add location';

  @override
  String get posizioneSalvata => 'Location saved';

  @override
  String get selezionaSullaMappa => 'Select on map';

  @override
  String get confermaPosizione => 'Confirm location';

  @override
  String get erroreCostoNonValido => 'Please enter a valid cost';

  @override
  String get apriInGoogleMaps => 'Open in Google Maps';

  @override
  String get apriInWaze => 'Open in Waze';

  @override
  String get distributorePin => 'Gas Station';

  @override
  String get registroManutenzione => 'Maintenance Log';

  @override
  String get nessunaManutenzione => 'No maintenance recorded.';

  @override
  String get aggiungiIntervento => 'Add Service';

  @override
  String get nuovoIntervento => 'New Service';

  @override
  String get dettagliIntervento => 'Service Details';

  @override
  String get modificaIntervento => 'Edit Service';

  @override
  String get titoloIntervento => 'Title (e.g. Spark plug replacement)';

  @override
  String get dataIntervento => 'Date';

  @override
  String get categoria => 'Category';

  @override
  String get specificaAltro => 'Specify category';

  @override
  String get costoOpzionale => 'Cost (Optional)';

  @override
  String get noteDettagli => 'Notes / Details';

  @override
  String get fotoRicevuta => 'Photo / Receipt';

  @override
  String get selezionaFoto => 'Select an image';

  @override
  String get rimuoviFoto => 'Remove photo';

  @override
  String get datiMancanti => 'Missing data';

  @override
  String get erroreDatiMessaggio =>
      'Please enter a valid title and mileage to continue.';

  @override
  String get infoPrincipali => 'Main Information';

  @override
  String get dettagliAggiuntivi => 'Additional Details';

  @override
  String get notePlaceholder => 'Add notes about the service...';

  @override
  String get cat_motore => 'Engine';

  @override
  String get cat_accensione => 'Ignition / Electrical';

  @override
  String get cat_alimentazione => 'Fuel System';

  @override
  String get cat_olio_cambio => 'Gear Oil';

  @override
  String get cat_trasmissione => 'Transmission / Cables';

  @override
  String get cat_freni_gomme => 'Brakes / Tires';

  @override
  String get cat_carrozzeria => 'Body / Frame';

  @override
  String get cat_altro => 'Other';

  @override
  String get confirmTitle => 'Confirm';

  @override
  String get confirmDeleteMaintenance =>
      'Are you sure you want to delete this service?';

  @override
  String get maintenanceSaved => 'Service saved!';

  @override
  String get maintenanceDeleted => 'Service deleted';

  @override
  String get backupShareSubject => 'MyScooter Backup';

  @override
  String get backupShareText => 'MyScooter Backup (Data + Photos)';

  @override
  String get documentiScadenze => 'Documents & Deadlines';

  @override
  String get nessunDocumento => 'No document saved';

  @override
  String get scadeIl => 'Expiry:';

  @override
  String get scaduto => 'Expired!';

  @override
  String get inScadenza => 'Expiring soon';

  @override
  String get senzaScadenza => 'No expiry date';

  @override
  String get tipoDocumento => 'Document Type';

  @override
  String get haScadenza => 'Does it have an expiry date?';

  @override
  String get dataScadenza => 'Expiry Date';

  @override
  String get docLibretto => 'Registration';

  @override
  String get docAssicurazione => 'Insurance';

  @override
  String get docRevisione => 'Inspection';

  @override
  String get docBollo => 'Road Tax';

  @override
  String get docCertificato => 'Historical Certificate';

  @override
  String get docPatente => 'Driver\'s License';

  @override
  String get documentSaved => 'Document saved!';

  @override
  String get documentDeleted => 'Document deleted';

  @override
  String get aggiungi => 'Add';

  @override
  String get esportaPDF => 'Export PDF Report';

  @override
  String get reportDi => 'Report for';

  @override
  String get totaleManutenzioni => 'Total Maintenance:';

  @override
  String get totaleRifornimenti => 'Total Refuelings:';

  @override
  String get litriConsumati => 'Liters Consumed';

  @override
  String get costoTotaleGestione => 'Total Management Cost';

  @override
  String get generatoDa => 'Generated by myScooter';

  @override
  String get pag => 'Page';

  @override
  String get onboardingTitle1 => 'Your Virtual Garage';

  @override
  String get onboardingDesc1 =>
      'Manage all your Vespas and scooters in a single app, always at hand.';

  @override
  String get onboardingTitle2 => 'Track Refuelings';

  @override
  String get onboardingDesc2 =>
      'Record fill-ups and monitor fuel consumption. Automatically calculate liters, costs, and averages.';

  @override
  String get onboardingTitle3 => 'Your Wallet';

  @override
  String get onboardingDesc3 =>
      'Save registration, insurance and other documents. Receive automatic notifications before deadlines!';

  @override
  String get salta => 'Skip';

  @override
  String get avanti => 'Next';

  @override
  String get inizia => 'Get Started';

  @override
  String get profiloTitle => 'Profile';

  @override
  String get utenteOspite => 'Guest User';

  @override
  String get datiLocali => 'Your data is saved only on this device.';

  @override
  String get avvisoSovrascrittura =>
      'Warning: Logging in with an existing Cloud account will replace your local data with the data saved on the Cloud.';

  @override
  String get accediGoogle => 'Sign in with Google';

  @override
  String get accediApple => 'Sign in with Apple';

  @override
  String get esci => 'Sign Out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get themeLabel => 'App Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get accediEmail => 'Sign in with Email';

  @override
  String get registrati => 'Sign Up';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confermaPassword => 'Confirm Password';

  @override
  String get mailVerificaInviata =>
      'We\'ve sent you a verification email. Please check your inbox.';

  @override
  String get mailNonVerificata =>
      'Email not verified yet. Click here to resend the link.';

  @override
  String get modificaProfilo => 'Edit Profile';

  @override
  String get nomeLabel => 'First Name';

  @override
  String get cognomeLabel => 'Last Name';

  @override
  String get selezionaFotoProfilo => 'Choose a profile picture';

  @override
  String get attenzioneSovrascritturaTitolo => 'Local Data Warning';

  @override
  String get attenzioneSovrascritturaMessaggio =>
      'You are about to sign in to a Cloud account. If this account already contains data, the data currently saved on this device (Guest User) will be OVERWRITTEN and permanently lost. Do you wish to proceed?';

  @override
  String get procedi => 'Proceed';

  @override
  String get annulla => 'Cancel';

  @override
  String get loginSuccess => 'Login successful';

  @override
  String get loginError => 'Login failed or cancelled';

  @override
  String get cloudUser => 'Cloud User';

  @override
  String get logoutSuccess => 'Logged out successfully';

  @override
  String get emailValida => 'Enter a valid email';

  @override
  String get passwordCorta => 'Minimum 6 characters';

  @override
  String get passwordNonCoincidono => 'Passwords do not match';

  @override
  String get nonHaiAccount => 'Don\'t have an account? Sign up';

  @override
  String get haiGiaAccount => 'Already have an account? Sign in';

  @override
  String get profiloAggiornato => 'Profile updated successfully!';

  @override
  String get erroreSalvataggio => 'Error saving profile';

  @override
  String get languageLabel => 'Language';

  @override
  String get eliminaAccount => 'Delete Account';

  @override
  String get eliminaAccountConferma =>
      'Are you sure you want to permanently delete your account? This operation will delete all your data and photos from the Cloud.';

  @override
  String get eliminaDefinitivamente => 'Permanently Delete';

  @override
  String get accountEliminato => 'Account successfully deleted';

  @override
  String get erroreRiautenticazione =>
      'For security reasons, you must log out first, log in again, and then delete your account.';

  @override
  String get funzioneInArrivo => 'Feature coming in future updates';

  @override
  String get notificaScadenza15Titolo => 'Deadline approaching';

  @override
  String notificaScadenza15Corpo(String documento) {
    return 'The document $documento will expire in 15 days.';
  }

  @override
  String get notificaScadenza3Titolo => 'Expiring Soon!';

  @override
  String notificaScadenza3Corpo(String documento) {
    return 'Warning: the document $documento will expire in 3 days.';
  }

  @override
  String get notificaScadenza0Titolo => 'Document Expired';

  @override
  String notificaScadenza0Corpo(String documento) {
    return 'The document $documento expires today.';
  }
}
