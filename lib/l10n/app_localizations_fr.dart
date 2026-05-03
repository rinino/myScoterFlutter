// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'My Scooter';

  @override
  String get myScooters => 'Mes Scooters';

  @override
  String get noScooterFound => 'Aucun scooter trouvé.';

  @override
  String get addScooterPrompt => 'Appuyez sur \"+\" pour en ajouter un !';

  @override
  String get delete => 'SUPPRIMER';

  @override
  String get cancel => 'ANNULER';

  @override
  String get save => 'ENREGISTRER';

  @override
  String get deleteScooterTitle => 'Supprimer le Scooter';

  @override
  String deleteScooterContent(String modello) {
    return 'Êtes-vous sûr de vouloir supprimer le scooter $modello ?\nCette action supprimera également tous les pleins.';
  }

  @override
  String get brand => 'Marque';

  @override
  String get model => 'Modèle';

  @override
  String get displacement => 'Cylindrée';

  @override
  String get mixer => 'Mélangeur';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get refuelings => 'PLEINS';

  @override
  String get noDataPresent => 'Aucune donnée présente';

  @override
  String get sharePhoto => 'Partager la photo';

  @override
  String get saveToGallery => 'Sauvegarder dans la galerie';

  @override
  String get scooterUpdated => 'Scooter mis à jour !';

  @override
  String get refuelingSaved => 'Plein enregistré !';

  @override
  String get addScooter => 'Ajouter un Scooter';

  @override
  String get editScooter => 'Modifier le Scooter';

  @override
  String get licensePlate => 'Plaque d\'immatriculation';

  @override
  String get year => 'Année';

  @override
  String get tankCapacity => 'Capacité du réservoir (L)';

  @override
  String get selectImage => 'Sélectionner une image';

  @override
  String get camera => 'Appareil photo';

  @override
  String get gallery => 'Galerie';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get missingFields => 'Veuillez remplir tous les champs obligatoires';

  @override
  String get insertBrand => 'Entrez la marque';

  @override
  String get insertModel => 'Entrez le modèle';

  @override
  String get refuelingDetails => 'Détails du Plein';

  @override
  String get date => 'Date';

  @override
  String get currentKm => 'Km Actuels';

  @override
  String get gasLiters => 'Litres d\'essence';

  @override
  String get oilLiters => 'Litres d\'huile';

  @override
  String get none => 'Aucun';

  @override
  String get oilPercentage => 'Pourcentage d\'huile';

  @override
  String get kmTraveled => 'Km Parcourus';

  @override
  String get averageConsumption => 'Consommation Moyenne';

  @override
  String get averageConsumptionCalcTitle => 'Calcul de la Consommation Moyenne';

  @override
  String get averageConsumptionCalcDesc =>
      'La consommation moyenne est calculée en divisant les kilomètres parcourus depuis le dernier plein par les litres d\'essence de ce plein. On suppose que le plein complet est fait à chaque fois.';

  @override
  String get addRefueling => 'Ajouter un Plein';

  @override
  String get editRefueling => 'Modifier le Plein';

  @override
  String get selectDate => 'Sélectionner une Date';

  @override
  String get dateTime => 'Date et Heure';

  @override
  String get oilAdded => 'Huile ajoutée ?';

  @override
  String get saveRefueling => 'Enregistrer le Plein';

  @override
  String get deleteRecordTitle => 'Supprimer';

  @override
  String get deleteRecordContent =>
      'Voulez-vous supprimer cet enregistrement ?';

  @override
  String get generalInfo => 'INFORMATIONS GÉNÉRALES';

  @override
  String get details => 'DÉTAILS';

  @override
  String get autoMixer => 'Mélangeur Automatique';

  @override
  String get autoMixerDesc =>
      'Activer si le scooter gère l\'huile de manière autonome';

  @override
  String get requiredField => 'Champ obligatoire';

  @override
  String get insertNumber => 'Veuillez entrer un nombre valide';

  @override
  String get invalidLicensePlate => 'Format de plaque non valide';

  @override
  String get invalidYear => 'Année non valide';

  @override
  String get impostazioni => 'Paramètres';

  @override
  String get aspetto => 'Apparence';

  @override
  String get lingua => 'Langue';

  @override
  String get informazioni => 'Informations';

  @override
  String get versione => 'Version';

  @override
  String get termini_condizioni => 'Termes et Conditions';

  @override
  String get fatto => 'Terminé';

  @override
  String get legale => 'Légal';

  @override
  String get maggiori_info => 'Plus d\'informations';

  @override
  String get leggi_sito => 'Lire sur le site';

  @override
  String get info_text =>
      'Pour connaître les détails sur la gestion des données et les conditions d\'utilisation, visitez notre site officiel.';

  @override
  String get info_dati =>
      'L\'application ne collecte pas de données personnelles sur des serveurs externes. Tout est sauvegardé localement.';

  @override
  String get sistema => 'Système';

  @override
  String get chiaro => 'Clair';

  @override
  String get scuro => 'Sombre';

  @override
  String get errorSharing => 'Erreur lors du partage';

  @override
  String get errorSaving => 'Erreur lors de l\'enregistrement';

  @override
  String get errorLoadingRefuelings => 'Erreur lors du chargement des pleins';

  @override
  String get errorDeleting => 'Erreur lors de la suppression';

  @override
  String get recordDeleted => 'Enregistrement supprimé avec succès';

  @override
  String get permissionDenied => 'Permission refusée';

  @override
  String get imageSaved => 'Image sauvegardée dans la galerie !';

  @override
  String get errorUpdating => 'Erreur lors de la mise à jour';

  @override
  String get scooterAdded => 'Scooter ajouté avec succès !';

  @override
  String get scooterDeleted => 'Scooter supprimé';

  @override
  String get licensePlateShort => 'Plaque';

  @override
  String shareText(String scooter) {
    return 'Regardez mon $scooter !';
  }

  @override
  String get shareSubject => 'Photo du Scooter';

  @override
  String get refuelingData => 'Données des Pleins';

  @override
  String get dateAndKm => 'DATE ET KILOMÈTRES';

  @override
  String get fuelAndMix => 'CARBURANT ET MÉLANGE';

  @override
  String get calculatedLabel => '(Calculé)';

  @override
  String get errorInitialData =>
      'Erreur lors du chargement des données initiales.';

  @override
  String mustBeGreaterThan(String km) {
    return 'Doit être > au précédent ($km km)';
  }

  @override
  String get cantOpenBrowser => 'Impossible d\'ouvrir le navigateur';

  @override
  String get dati => 'DONNÉES';

  @override
  String get backupRestoreTitle => 'Sauvegarde et Restauration';

  @override
  String get backupSection => 'EXPORTER LA SAUVEGARDE';

  @override
  String get backupDesc =>
      'Enregistrez une copie sécurisée de vos données. Vous pouvez la sauvegarder sur Google Drive, iCloud, l\'envoyer par e-mail ou la conserver sur votre téléphone.';

  @override
  String get createBackupBtn => 'Créer la Sauvegarde';

  @override
  String get restoreSection => 'RESTAURER LA SAUVEGARDE';

  @override
  String get restoreDesc =>
      'ATTENTION : La restauration écrasera toutes les données actuelles de l\'application. Cette opération est irréversible.';

  @override
  String get restoreBtn => 'Choisir le fichier de sauvegarde';

  @override
  String get restoreSuccess => 'Données restaurées avec succès !';

  @override
  String get errorBackup => 'Erreur lors de la sauvegarde';

  @override
  String get errorRestore =>
      'Erreur lors de la restauration ou fichier non valide';

  @override
  String get costoLabel => 'Coût';

  @override
  String get noteLabel => 'Notes';

  @override
  String get placeholderNote => 'Ajouter des notes (ex. nom de la station)';

  @override
  String get posizioneGPSLabel => 'Position GPS';

  @override
  String get aggiungiPosizione => 'Ajouter la position';

  @override
  String get posizioneSalvata => 'Position enregistrée';

  @override
  String get selezionaSullaMappa => 'Sélectionner sur la carte';

  @override
  String get confermaPosizione => 'Confirmer la position';

  @override
  String get erroreCostoNonValido => 'Veuillez entrer un coût valide';

  @override
  String get apriInGoogleMaps => 'Ouvrir dans Google Maps';

  @override
  String get apriInWaze => 'Ouvrir dans Waze';

  @override
  String get distributorePin => 'Station-service';

  @override
  String get registroManutenzione => 'Carnet d\'Entretien';

  @override
  String get nessunaManutenzione => 'Aucun entretien enregistré.';

  @override
  String get aggiungiIntervento => 'Ajouter une Intervention';

  @override
  String get nuovoIntervento => 'Nouvelle Intervention';

  @override
  String get dettagliIntervento => 'Détails de l\'Intervention';

  @override
  String get modificaIntervento => 'Modifier l\'Intervention';

  @override
  String get titoloIntervento => 'Titre (ex. Changement de bougie)';

  @override
  String get dataIntervento => 'Date';

  @override
  String get categoria => 'Catégorie';

  @override
  String get specificaAltro => 'Spécifier la catégorie';

  @override
  String get costoOpzionale => 'Coût (Optionnel)';

  @override
  String get noteDettagli => 'Notes / Détails';

  @override
  String get fotoRicevuta => 'Photo / Reçu';

  @override
  String get selezionaFoto => 'Sélectionner une image';

  @override
  String get rimuoviFoto => 'Supprimer la photo';

  @override
  String get datiMancanti => 'Données manquantes';

  @override
  String get erroreDatiMessaggio =>
      'Veuillez entrer un titre et des kilomètres valides pour continuer.';

  @override
  String get infoPrincipali => 'Informations Principales';

  @override
  String get dettagliAggiuntivi => 'Détails Supplémentaires';

  @override
  String get notePlaceholder => 'Ajouter des notes sur l\'intervention...';

  @override
  String get cat_motore => 'Moteur';

  @override
  String get cat_accensione => 'Allumage / Électrique';

  @override
  String get cat_alimentazione => 'Alimentation';

  @override
  String get cat_olio_cambio => 'Huile de Transmission';

  @override
  String get cat_trasmissione => 'Transmission / Câbles';

  @override
  String get cat_freni_gomme => 'Freins / Pneus';

  @override
  String get cat_carrozzeria => 'Carrosserie / Châssis';

  @override
  String get cat_altro => 'Autre';

  @override
  String get confirmTitle => 'Confirmer';

  @override
  String get confirmDeleteMaintenance =>
      'Êtes-vous sûr de vouloir supprimer cette intervention ?';

  @override
  String get maintenanceSaved => 'Intervention enregistrée !';

  @override
  String get maintenanceDeleted => 'Intervention supprimée';

  @override
  String get backupShareSubject => 'Sauvegarde MyScooter';

  @override
  String get backupShareText => 'Sauvegarde MyScooter (Données + Photos)';

  @override
  String get documentiScadenze => 'Documents et Échéances';

  @override
  String get nessunDocumento => 'Aucun document enregistré';

  @override
  String get scadeIl => 'Expire le :';

  @override
  String get scaduto => 'Expiré !';

  @override
  String get inScadenza => 'Bientôt expiré';

  @override
  String get senzaScadenza => 'Sans échéance';

  @override
  String get tipoDocumento => 'Type de Document';

  @override
  String get haScadenza => 'A-t-il une date d\'expiration ?';

  @override
  String get dataScadenza => 'Date d\'Expiration';

  @override
  String get docLibretto => 'Carte Grise';

  @override
  String get docAssicurazione => 'Assurance';

  @override
  String get docRevisione => 'Contrôle Technique';

  @override
  String get docBollo => 'Taxe de Circulation';

  @override
  String get docCertificato => 'Certificat Historique';

  @override
  String get docPatente => 'Permis de Conduire';

  @override
  String get documentSaved => 'Document enregistré !';

  @override
  String get documentDeleted => 'Document supprimé';

  @override
  String get aggiungi => 'Ajouter';

  @override
  String get esportaPDF => 'Exporter le Rapport PDF';

  @override
  String get reportDi => 'Rapport de';

  @override
  String get totaleManutenzioni => 'Total Entretien :';

  @override
  String get totaleRifornimenti => 'Total Pleins :';

  @override
  String get litriConsumati => 'Litres Consommés';

  @override
  String get costoTotaleGestione => 'Coût Total de Gestion';

  @override
  String get generatoDa => 'Généré par myScooter';

  @override
  String get pag => 'Page';

  @override
  String get onboardingTitle1 => 'Votre Garage Virtuel';

  @override
  String get onboardingDesc1 =>
      'Gérez toutes vos Vespas et scooters dans une seule application, toujours à portée de main.';

  @override
  String get onboardingTitle2 => 'Suivez vos Pleins';

  @override
  String get onboardingDesc2 =>
      'Enregistrez les pleins et suivez la consommation. Calculez automatiquement les litres, les coûts et les moyennes.';

  @override
  String get onboardingTitle3 => 'Vos Documents';

  @override
  String get onboardingDesc3 =>
      'Sauvegardez la carte grise, l\'assurance et d\'autres documents. Recevez des notifications automatiques avant l\'échéance !';

  @override
  String get salta => 'Passer';

  @override
  String get avanti => 'Suivant';

  @override
  String get inizia => 'Commencer';

  @override
  String get profiloTitle => 'Profil';

  @override
  String get utenteOspite => 'Utilisateur Invité';

  @override
  String get datiLocali =>
      'Vos données sont sauvegardées uniquement sur cet appareil.';

  @override
  String get avvisoSovrascrittura =>
      'Attention : Se connecter avec un compte Cloud existant remplacera vos données locales.';

  @override
  String get accediGoogle => 'Se connecter avec Google';

  @override
  String get accediApple => 'Se connecter avec Apple';

  @override
  String get esci => 'Se déconnecter';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get themeLabel => 'Thème de l\'App';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get accediEmail => 'Se connecter par Email';

  @override
  String get registrati => 'S\'inscrire';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get confermaPassword => 'Confirmer le mot de passe';

  @override
  String get mailVerificaInviata =>
      'Nous vous avons envoyé un e-mail de vérification. Consultez votre boîte de réception.';

  @override
  String get mailNonVerificata =>
      'E-mail non vérifié. Cliquez ici pour renvoyer le lien.';

  @override
  String get modificaProfilo => 'Modifier le Profil';

  @override
  String get nomeLabel => 'Prénom';

  @override
  String get cognomeLabel => 'Nom';

  @override
  String get selezionaFotoProfilo => 'Choisir une photo de profil';

  @override
  String get attenzioneSovrascritturaTitolo =>
      'Avertissement sur les Données Locales';

  @override
  String get attenzioneSovrascritturaMessaggio =>
      'Vous êtes sur le point de vous connecter à un compte Cloud. S\'il contient déjà des données, celles enregistrées sur cet appareil (Utilisateur Invité) seront ÉCRASÉES et définitivement perdues. Voulez-vous continuer ?';

  @override
  String get procedi => 'Procéder';

  @override
  String get annulla => 'Annuler';

  @override
  String get loginSuccess => 'Connexion réussie';

  @override
  String get loginError => 'Échec ou annulation de la connexion';

  @override
  String get cloudUser => 'Utilisateur Cloud';

  @override
  String get logoutSuccess => 'Déconnexion réussie';

  @override
  String get emailValida => 'Entrez un e-mail valide';

  @override
  String get passwordCorta => 'Minimum 6 caractères';

  @override
  String get passwordNonCoincidono => 'Les mots de passe ne correspondent pas';

  @override
  String get nonHaiAccount => 'Pas de compte ? S\'inscrire';

  @override
  String get haiGiaAccount => 'Déjà un compte ? Se connecter';

  @override
  String get profiloAggiornato => 'Profil mis à jour avec succès !';

  @override
  String get erroreSalvataggio => 'Erreur lors de l\'enregistrement';

  @override
  String get languageLabel => 'Langue';

  @override
  String get eliminaAccount => 'Elimina Account';

  @override
  String get eliminaAccountConferma =>
      'Sei sicuro di voler eliminare definitivamente il tuo account? Questa operazione cancellerà tutti i tuoi dati e le tue foto dal Cloud.';

  @override
  String get eliminaDefinitivamente => 'Elimina Definitivamente';

  @override
  String get accountEliminato => 'Account eliminato con successo';

  @override
  String get erroreRiautenticazione =>
      'Per sicurezza, devi fare prima il logout, accedere di nuovo e poi eliminare l\'account.';

  @override
  String get funzioneInArrivo =>
      'Funzione in arrivo nei prossimi aggiornamenti';

  @override
  String get notificaScadenza15Titolo => 'Échéance proche';

  @override
  String notificaScadenza15Corpo(String documento) {
    return 'Le document $documento expirera dans 15 jours.';
  }

  @override
  String get notificaScadenza3Titolo => 'Échéance imminente !';

  @override
  String notificaScadenza3Corpo(String documento) {
    return 'Attention : le document $documento expirera dans 3 jours.';
  }

  @override
  String get notificaScadenza0Titolo => 'Document Expiré';

  @override
  String notificaScadenza0Corpo(String documento) {
    return 'Le document $documento expire aujourd\'hui.';
  }
}
