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
}
