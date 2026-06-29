
class StepsData {
  final String day;
  final int steps;
  final String monthName;
  final int dailySteps;
  final double miles;
  final String year;
  final double caloriesBurned;
  final DateTime date;
  final int totalSteps;
  final int targetsteps;
  final String labelHour; // 👈 add this

  StepsData({
    required this.day,
    required this.steps,
    required this.monthName,
    required this.dailySteps,
    required this.miles,
    required this.caloriesBurned,
    required this.date,
    required this.year,
    required this.totalSteps,
    required this.targetsteps,
    required this.labelHour,
  });
}