import '../domain/models/user_constants.dart';

class CalorieCalculator {
  // MET values for different activities
  static const Map<String, double> cyclingMET = {
    'mountain': 8.5,  // Bicycling, mountain, general
    'commute': 6.8,   // Bicycling, commuting, self selected pace
    'stationary': 6.8 // Bicycling, stationary, general
  };
  
  // MET values for swimming strokes
  static const Map<String, double> swimmingMET = {
    'Breaststroke': 10.3,
    'Freestyle (Front Crawl)': 7.8,
    'Backstroke': 7.15,
    'Butterfly': 13.8
  };
  
  // Menghitung BMR (Basal Metabolic Rate)
  static double calculateBMR() {
    if (UserConstants.gender == 'Male') {
      return (10 * UserConstants.weight) + (6.25 * UserConstants.height) - (5 * UserConstants.age) + 5;
    } else {
      return (10 * UserConstants.weight) + (6.25 * UserConstants.height) - (5 * UserConstants.age) - 161;
    }
  }
  
  // Generic method to calculate calories based on MET
  static double calculateCaloriesWithMET({
    required double met,
    required Duration duration,
  }) {
    // Hitung BMR
    double bmr = calculateBMR();
    
    // Hitung kalori terbakar per menit
    double caloriesPerMinute = (bmr / 1440) * met;
    
    // Total kalori terbakar
    return caloriesPerMinute * duration.inMinutes;
  }
  
  // Validate common inputs
  static void validateInputs({
    required double distanceKm,
    required Duration duration,
  }) {
    if (distanceKm < 0) {
      throw ArgumentError('Distance cannot be negative');
    }
    if (duration.inSeconds <= 0) {
      throw ArgumentError('Duration must be greater than zero');
    }
  }
  
  // Fungsi untuk mendapatkan MET lari berdasarkan kecepatan
  static double getRunningMETBySpeed(double speedKmPerHour) {
    if (speedKmPerHour < 8.0) { 
      return 7.0;       // Jogging lambat
    } else if (speedKmPerHour < 8.5) { 
      return 8.5;       // 8-8.4 km/h
    } else if (speedKmPerHour < 9.0) { 
      return 9.0;       // 8.5-8.9 km/h
    } else if (speedKmPerHour < 10.0) { 
      return 9.3;       // 9-10 km/h
    } else if (speedKmPerHour < 11.0) { 
      return 10.5;      // 10-11 km/h
    } else if (speedKmPerHour < 12.0) { 
      return 11.0;      // 11-12 km/h
    } else if (speedKmPerHour < 14.0) { 
      return 12.5;      // 12-14 km/h
    } else if (speedKmPerHour < 16.0) { 
      return 14.8;      // 14-16 km/h
    } else if (speedKmPerHour < 17.5) { 
      return 16.8;      // 16-17.5 km/h
    } else { 
      return 18.5;      // > 17.5 km/h
    }
  }
  
  // Menghitung kalori dari aktivitas lari
  static double calculateRunningCalories({
    required double distanceKm,
    required Duration duration,
  }) {
    validateInputs(distanceKm: distanceKm, duration: duration);
    
    // Hitung kecepatan dalam km/jam
    double speedKmPerHour = (distanceKm / duration.inSeconds) * 3600;
    
    // Dapatkan MET berdasarkan kecepatan
    double runningMET = getRunningMETBySpeed(speedKmPerHour);
    
    return calculateCaloriesWithMET(met: runningMET, duration: duration);
  }
  
  // Fungsi untuk mendapatkan MET bersepeda berdasarkan kecepatan
  static double getCyclingMETBySpeed(double speedKmPerHour, String cyclingType) {
    // Jika tipe bersepeda spesifik, gunakan nilai MET tetap
    if (cyclingType == 'mountain') {
      return cyclingMET['mountain']!;
    }
    if (cyclingType == 'stationary') {
      return cyclingMET['stationary']!;
    }
    
    // Tentukan berdasarkan kecepatan
    if (speedKmPerHour < 16.0) {
      return 4.0;       // < 16 km/h
    } else if (speedKmPerHour < 19.0) {
      return 6.8;       // 16-19 km/h
    } else if (speedKmPerHour < 22.0) {
      return 8.0;       // 19-22 km/h
    } else if (speedKmPerHour < 25.0) {
      return 10.0;      // 22-25 km/h
    } else if (speedKmPerHour < 30.0) {
      return 12.0;      // 25-30 km/h
    } else {
      return 16.0;      // > 30 km/h
    }
  }
  
  // Menghitung kalori dari aktivitas bersepeda
  static double calculateCyclingCalories({
    required double distanceKm,
    required Duration duration,
    required String cyclingType,
  }) {
    validateInputs(distanceKm: distanceKm, duration: duration);
    
    // Hitung kecepatan dalam km/jam
    double speedKmPerHour = (distanceKm / duration.inSeconds) * 3600;
    
    // Dapatkan MET berdasarkan kecepatan dan tipe bersepeda
    double cyclingMET = getCyclingMETBySpeed(speedKmPerHour, cyclingType);
    
    return calculateCaloriesWithMET(met: cyclingMET, duration: duration);
  }

  // Fungsi untuk mendapatkan MET renang berdasarkan kecepatan dan gaya
  static double getSwimmingMETBySpeedAndStroke(double speedMetersPerMinute, String stroke) {
    // Gunakan nilai MET dasar berdasarkan gaya renang
    double baseMET = swimmingMET[stroke] ?? 7.8; // default ke freestyle jika tidak ditemukan
    
    // Faktor pengali berdasarkan kecepatan
    if (speedMetersPerMinute < 25) {
      return baseMET * 0.8; // Lambat
    } else if (speedMetersPerMinute < 50) {
      return baseMET; // Sedang
    } else {
      return baseMET * 1.2; // Cepat
    }
  }

  static double calculateSwimmingCalories({
    required int laps,
    required double poolLength,
    required String stroke,
    required Duration duration,
  }) {
    if (laps <= 0) {
      throw ArgumentError('Laps must be greater than zero');
    }
    if (poolLength <= 0) {
      throw ArgumentError('Pool length must be greater than zero');
    }
    if (duration.inSeconds <= 0) {
      throw ArgumentError('Duration must be greater than zero');
    }

    // Hitung jarak dalam meter
    double distanceMeters = laps * poolLength;
    
    // Hitung kecepatan dalam meter per menit
    double speedMetersPerMinute = distanceMeters / (duration.inSeconds / 60);
    
    // Dapatkan MET berdasarkan kecepatan dan gaya renang
    double swimmingMET = getSwimmingMETBySpeedAndStroke(speedMetersPerMinute, stroke);
    
    return calculateCaloriesWithMET(met: swimmingMET, duration: duration);
  }
}