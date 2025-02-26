import 'package:flutter_test/flutter_test.dart';
import 'package:pockeat/weighting_input_page.dart';

void main() {
  group('Hitung Kalori Weightlifting', () {
    // [Success Case] Input normal dan wajar
    test('Success: Menghitung kalori dengan input normal', () {
      List<Exercise> exercises = [
        Exercise(
          name: 'Squats',
          bodyPart: 'Lower Body',
          sets: [
            ExerciseSet(weight: 50, reps: 10, duration: 0.5),
            ExerciseSet(weight: 60, reps: 8, duration: 0.5),
          ],
        ),
      ];

      // Default MET dan berat badan (sementara placeholder dulu)
      double MET = 3.15;
      double beratBadan = 75;

      // Hitung total durasi dari seluruh set
      double totalDurasi = exercises.fold(0.0, (sum, exercise) {
        return sum + exercise.sets.fold(0.0, (setSum, set) {
          return setSum + set.duration;
        });
      });

      // Durasi rata-rata per Exercise
      double durasiRataRata = totalDurasi / exercises.length;

      // Rumus: MET × beratBadan × durasi (rata-rata)
      double estimatedCalories = MET * beratBadan * durasiRataRata;

      // Ekspektasi untuk data di atas: 3.15 × 75 × 0.5 = 118.125
      expect(estimatedCalories, closeTo(118.125, 0.001));
    });

    // [Failed Case] Input dianggap tidak valid (misalnya, durasi negatif atau berat beban negatif)
    // Note:
    // - Jika menggunakan AI, diberikan saran agar expect hasil perhitungan 0 (atau default) jika input tidak valid
    // - Saya lebih memilih untuk throw exception jika input tidak valid
    test('Failed: Input tidak valid (durasi negatif)', () {
      List<Exercise> exercises = [
        Exercise(
          name: 'Bench Press',
          bodyPart: 'Upper Body',
          sets: [
            ExerciseSet(weight: 50, reps: 10, duration: -0.5), // Durasi negatif
          ],
        ),
      ];

      double MET = 3.15;
      double beratBadan = 75;

      expect(
        () {
          double totalDurasi = exercises.fold(0.0, (sum, exercise) {
            return sum + exercise.sets.fold(0.0, (setSum, set) {
              // Jika durasi negatif, anggap tidak valid dan
              if (set.duration < 0) {
                throw ArgumentError('Durasi tidak boleh negatif');
              }
              return setSum + set.duration;
            });
          });
          double durasiRataRata = totalDurasi / exercises.length;
          double estimatedCalories = MET * beratBadan * durasiRataRata;
          return estimatedCalories;
        },
        throwsA(isA<ArgumentError>()),
      );
    });

    // [Corner Case] total set = 0 atau volume = 0
    test('Corner Case: Tidak ada set (durasi total = 0)', () {
      List<Exercise> exercises = [
        Exercise(
          name: 'Lunges',
          bodyPart: 'Lower Body',
          sets: [], // Tidak ada set
        ),
      ];

      double MET = 3.15;
      double beratBadan = 75;

      // Total durasi seharusnya 0
      double totalDurasi = exercises.fold(0.0, (sum, exercise) {
        return sum + exercise.sets.fold(0.0, (setSum, set) {
          return setSum + set.duration;
        });
      });

      double durasiRataRata = totalDurasi / exercises.length;
      double estimatedCalories = MET * beratBadan * durasiRataRata;

      // Harusnya 0
      expect(estimatedCalories, equals(0));
    });
  });
}