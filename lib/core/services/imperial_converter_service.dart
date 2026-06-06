class ImperialConverterService {
  // Costanti di conversione esatte
  static const double _litersPerGallon = 3.78541;
  static const double _kilometersPerMile = 1.60934;

  /// Converte i Galloni (US) in Litri
  static double gallonsToLiters(double gallons) {
    return gallons * _litersPerGallon;
  }

  /// Converte le Miglia in Chilometri
  static double milesToKilometers(double miles) {
    return miles * _kilometersPerMile;
  }
}