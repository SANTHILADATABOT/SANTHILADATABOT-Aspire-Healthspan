
class HeartRateData {
  final String day;
  final String Years;
  final String months;
  final DateTime date;
  final int heartrate;
  final int targetheartrate;
  final double sd_high;
  final double sd_low;



  HeartRateData({
    required this.day,
    required this.Years,
    required this.months,
    required this.date,
    required this.heartrate,
    required this.targetheartrate,
    required this.sd_low,
    required this.sd_high
  });
}