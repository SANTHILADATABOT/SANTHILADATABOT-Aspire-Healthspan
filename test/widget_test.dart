// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:http/http.dart' as http;
//
// class BloodPressureChartPage extends StatefulWidget {
//   @override
//   State<BloodPressureChartPage> createState() => _BloodPressureChartPageState();
// }
//
// class _BloodPressureChartPageState extends State<BloodPressureChartPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<BloodPressureData> bloodPressureData = [];
//
//   Future<void> Week_Chart() async {
//     final String url = "https://app.aspirehealthspan.ai/aspire_api/blood_pressure";
//
//     final Map<String, dynamic> userdata = {
//       'user_id': '102',
//       'filter': 'week'
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: userdata,
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         print('Response: $jsonResponse');
//
//         if (jsonResponse['status'] == "SUCCESS" && jsonResponse['week_chart_bp'] != null) {
//           // Mapping day indices to day names
//           const List<String> daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
//
//           // Parsing the data
//           List<BloodPressureData> fetchedData = (jsonResponse['week_chart_bp'] as List).map<BloodPressureData>((data) {
//             final DateTime dateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(data['datetime']);
//             final int dayIndex = dateTime.weekday; // 1=Monday, 7=Sunday
//
//             // Adjust for Sunday to be the first day
//             final String weekDay = daysOfWeek[(dayIndex % 7)];
//
//             return BloodPressureData(
//               week: weekDay, // Use the week day name
//               systolic: (data['bp_systolic_chart'] as num).toDouble(), // Convert to double
//               diastolic: (data['bp_diastolic_chart'] as num).toDouble(), // Convert to double
//             );
//           }).toList();
//
//           setState(() {
//             bloodPressureData = fetchedData;
//           });
//         } else {
//           print('Failed: ${jsonResponse['message']}');
//           throw Exception('Failed to load weekly chart');
//         }
//       } else {
//         print('Failed to load weekly chart. Status code: ${response.statusCode}');
//         throw Exception('Failed to load weekly chart');
//       }
//     } catch (e) {
//       print('Error fetching weekly chart: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     Week_Chart();
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: SfCartesianChart(
//         backgroundColor: Colors.white,
//         primaryXAxis: CategoryAxis(
//           title: AxisTitle(text: 'Days of the Week'),
//         ),
//         series: <CartesianSeries>[
//           SplineRangeAreaSeries<BloodPressureData, String>(
//             dataSource: bloodPressureData,
//             xValueMapper: (BloodPressureData data, _) => data.week,
//             lowValueMapper: (BloodPressureData data, _) => data.lowSystolic,
//             highValueMapper: (BloodPressureData data, _) => data.highSystolic,
//             name: 'Systolic Range',
//             gradient: LinearGradient(
//               colors: <Color>[Colors.blue.withOpacity(0.4), Colors.green.withOpacity(0.4)],
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//             ),
//           ),
//           SplineRangeAreaSeries<BloodPressureData, String>(
//             dataSource: bloodPressureData,
//             xValueMapper: (BloodPressureData data, _) => data.week,
//             lowValueMapper: (BloodPressureData data, _) => data.lowDiastolic,
//             highValueMapper: (BloodPressureData data, _) => data.highDiastolic,
//             name: 'Diastolic Range',
//             gradient: LinearGradient(
//               colors: <Color>[Colors.red.withOpacity(0.4), Colors.orange.withOpacity(0.4)],
//               begin: Alignment.bottomCenter,
//               end: Alignment.topCenter,
//             ),
//           ),
//           LineSeries<BloodPressureData, String>(
//             dataSource: bloodPressureData,
//             xValueMapper: (BloodPressureData data, _) => data.week,
//             yValueMapper: (BloodPressureData data, _) =>
//             (data.lowSystolic + data.highSystolic) / 2,
//             name: 'Average Systolic',
//             color: Colors.blue,
//             width: 2,
//           ),
//           LineSeries<BloodPressureData, String>(
//             dataSource: bloodPressureData,
//             xValueMapper: (BloodPressureData data, _) => data.week,
//             yValueMapper: (BloodPressureData data, _) =>
//             (data.lowDiastolic + data.highDiastolic) / 2,
//             name: 'Average Diastolic',
//             color: Colors.red,
//             width: 2,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class BloodPressureData {
//   final String week; // Day of the week representation
//   final double systolic; // Average systolic blood pressure
//   final double diastolic; // Average diastolic blood pressure
//
//   BloodPressureData({
//     required this.week,
//     required this.systolic,
//     required this.diastolic,
//   });
//
//   double get lowSystolic => systolic - 10;  // Example logic for low systolic
//   double get highSystolic => systolic + 10; // Example logic for high systolic
//   double get lowDiastolic => diastolic - 10;  // Example logic for low diastolic
//   double get highDiastolic => diastolic + 10; // Example logic for high diastolic
// }
//
//

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:http/http.dart' as http;
//
// class BloodPressureChartPage extends StatefulWidget {
//   @override
//   State<BloodPressureChartPage> createState() => _BloodPressureChartPageState();
// }
//
// class _BloodPressureChartPageState extends State<BloodPressureChartPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<BloodPressureData> bloodPressureData = [];
//   final List<String> daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
//
//   Future<void> Week_Chart() async {
//     final String url = "https://app.aspirehealthspan.ai/aspire_api/blood_pressure";
//
//     final Map<String, dynamic> userdata = {
//       'user_id': '102',
//       'filter': 'week'
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: userdata,
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         print('Response: $jsonResponse');
//
//         if (jsonResponse['status'] == "SUCCESS" && jsonResponse['week_chart_bp'] != null) {
//           // Parsing the data
//           List<BloodPressureData> fetchedData = (jsonResponse['week_chart_bp'] as List).map<BloodPressureData>((data) {
//             final DateTime dateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(data['datetime']);
//             final int dayIndex = dateTime.weekday; // 1=Monday, 7=Sunday
//
//             // Adjust for Sunday to be the first day
//             final String weekDay = daysOfWeek[(dayIndex % 7)];
//
//             return BloodPressureData(
//               week: weekDay,
//               systolic: (data['bp_systolic_chart'] as num).toDouble(),
//               diastolic: (data['bp_diastolic_chart'] as num).toDouble(),
//             );
//           }).toList();
//
//           // Create a complete list of BloodPressureData for all days of the week
//           List<BloodPressureData> completeData = daysOfWeek.map((day) {
//             // Find the data for the current day
//             final dataForDay = fetchedData.firstWhere(
//                   (data) => data.week == day,
//               orElse: () => BloodPressureData(week: day, systolic: 0, diastolic: 0), // Default value if no data
//             );
//             return dataForDay;
//           }).toList();
//
//           setState(() {
//             bloodPressureData = completeData;
//           });
//         } else {
//           print('Failed: ${jsonResponse['message']}');
//           throw Exception('Failed to load weekly chart');
//         }
//       } else {
//         print('Failed to load weekly chart. Status code: ${response.statusCode}');
//         throw Exception('Failed to load weekly chart');
//       }
//     } catch (e) {
//       print('Error fetching weekly chart: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     Week_Chart();
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SfCartesianChart(
//         backgroundColor: Colors.white,
//         primaryXAxis: CategoryAxis(
//           title: AxisTitle(text: 'Days of the Week'),
//           // Set the labels to show all days of the week
//           labelPlacement: LabelPlacement.onTicks,
//         ),
//         series: <CartesianSeries>[
//           LineSeries<BloodPressureData, String>(
//             name: 'Systolic',
//             dataSource: bloodPressureData,
//             xValueMapper: (BloodPressureData data, _) => data.week,
//             yValueMapper: (BloodPressureData data, _) => data.systolic,
//             // markerSettings: MarkerSettings(isVisible: true),
//           ),
//           LineSeries<BloodPressureData, String>(
//             name: 'Diastolic',
//             dataSource: bloodPressureData,
//             xValueMapper: (BloodPressureData data, _) => data.week,
//             yValueMapper: (BloodPressureData data, _) => data.diastolic,
//             // markerSettings: MarkerSettings(isVisible: true),
//           ),
//         ],
//         tooltipBehavior: TooltipBehavior(enable: true),
//       ),
//     );
//   }
// }
//
// class BloodPressureData {
//   final String week; // Day of the week representation
//   final double systolic; // Average systolic blood pressure
//   final double diastolic; // Average diastolic blood pressure
//
//   BloodPressureData({
//     required this.week,
//     required this.systolic,
//     required this.diastolic,
//   });
//
//   double get lowSystolic => systolic - 10;
//   double get highSystolic => systolic + 10;
//   double get lowDiastolic => diastolic - 10;
//   double get highDiastolic => diastolic + 10;
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:http/http.dart' as http;
//
// class BloodPressureChartPage extends StatefulWidget {
//   @override
//   State<BloodPressureChartPage> createState() => _BloodPressureChartPageState();
// }
//
// class _BloodPressureChartPageState extends State<BloodPressureChartPage>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<BloodPressureData> bloodPressureData = [];
//   final List<String> daysOfWeek = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
//
//   List<BloodPressureData> chartData = [
//     BloodPressureData('Su', 120, 80),  // Sunday
//     BloodPressureData('Mo', 125, 85),   // Monday
//     BloodPressureData('Tu', 118, 78),   // Tuesday
//     BloodPressureData('We', 130, 88),   // Wednesday
//     BloodPressureData('Th', 124, 82),  // Thursday
//     BloodPressureData('Fr', 126, 84),   // Friday
//     BloodPressureData('Sa', 122, 80),  // Saturday
//   ];
//   Future<void> Week_Chart() async {
//     final String url = "https://app.aspirehealthspan.ai/aspire_api/blood_pressure";
//
//     final Map<String, dynamic> userdata = {
//       'user_id': '102',
//       'filter': 'week'
//     };
//
//     try {
//       final response = await http.post(
//         Uri.parse(url),
//         body: userdata,
//       );
//
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> jsonResponse = json.decode(response.body);
//         print('Response: $jsonResponse');
//
//         if (jsonResponse['status'] == "SUCCESS" && jsonResponse['week_chart_bp'] != null) {
//           print(response.body);
//         } else {
//           print('Failed: ${jsonResponse['message']}');
//           throw Exception('Failed to load weekly chart');
//         }
//       } else {
//         print('Failed to load weekly chart. Status code: ${response.statusCode}');
//         throw Exception('Failed to load weekly chart');
//       }
//     } catch (e) {
//       print('Error fetching weekly chart: $e');
//     }
//   }
//
//   @override
//   void initState() {
//     Week_Chart();
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SfCartesianChart(
//         plotAreaBorderWidth: 1.0,
//         plotAreaBorderColor: Colors.grey.shade100,
//         backgroundColor: Colors.white,
//         primaryXAxis: CategoryAxis(
//           majorGridLines: const MajorGridLines(width: 0), // Remove major grid lines
//           // minorGridLines: const MinorGridLines(width: 0), // Remove minor grid lines
//         ),
//         primaryYAxis: NumericAxis(
//           // borderWidth: 1,
//           isVisible: false,
//           majorGridLines: const MajorGridLines(width: 0), // Remove major grid lines
//           minorGridLines: const MinorGridLines(width: 0), // Remove minor grid lines
//         ),
//         series: <CartesianSeries>[
//           SplineSeries<BloodPressureData, String>(
//             name: 'Systolic',
//             dataSource: chartData,
//             xValueMapper: (BloodPressureData data, _) => data.day,
//             yValueMapper: (BloodPressureData data, _) => data.systolic,
//             color: Colors.red,
//             // markerSettings: MarkerSettings(isVisible: true),
//           ),
//           SplineSeries<BloodPressureData, String>(
//             name: 'Diastolic',
//             dataSource: chartData,
//             xValueMapper: (BloodPressureData data, _) => data.day,
//             yValueMapper: (BloodPressureData data, _) => data.diastolic,
//             color: Colors.blue,
//             // markerSettings: MarkerSettings(isVisible: true),
//           ),
//           SplineRangeAreaSeries<BloodPressureData, String>(
//             name: 'Systolic Range',
//             dataSource: chartData,
//             xValueMapper: (BloodPressureData data, _) => data.day,
//             lowValueMapper: (BloodPressureData data, _) => data.systolic - 10,
//             highValueMapper: (BloodPressureData data, _) => data.systolic + 10,
//             color: Colors.red.withOpacity(0.2),
//           ),
//           SplineRangeAreaSeries<BloodPressureData, String>(
//             name: 'Diastolic Range',
//             dataSource: chartData,
//             xValueMapper: (BloodPressureData data, _) => data.day,
//             lowValueMapper: (BloodPressureData data, _) => data.diastolic - 10,
//             highValueMapper: (BloodPressureData data, _) => data.diastolic + 10,
//             color: Colors.blue.withOpacity(0.2),
//           ),
//         ],
//       )
//
//     );
//   }
// }
//
// class BloodPressureData {
//   BloodPressureData(this.day, this.systolic, this.diastolic);
//
//   final String day;
//   final double systolic;
//   final double diastolic;
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

class BloodPressureChartPage extends StatefulWidget {
  @override
  State<BloodPressureChartPage> createState() => _BloodPressureChartPageState();
}

class _BloodPressureChartPageState extends State<BloodPressureChartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BloodPressureData> chartData = [];
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

  Future<void> Week_Chart() async {
    final String url = "https://app.aspirehealthspan.ai/aspire_api/blood_pressure";

    final Map<String, dynamic> userdata = {
      'user_id': '102',
      'filter': 'week'
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: userdata,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('Response: $jsonResponse');

        if (jsonResponse['status'] == "SUCCESS" && jsonResponse['week_chart_bp'] != null) {
          List<dynamic> weekChartBP = jsonResponse['week_chart_bp'];
          List<BloodPressureData> loadedChartData = List.generate(
            7,
                (index) => BloodPressureData(daysOfWeek[index], 0.0, 0.0),
          );

          for (var item in weekChartBP) {
            String dayName = item['day_name'];
            double systolic = item['bp_systolic_chart'].toDouble();
            double diastolic = item['bp_diastolic_chart'].toDouble();

            // Find the index of the day and update the corresponding chart data
            int index = daysOfWeek.indexOf(_getAbbreviatedDay(dayName));
            if (index != -1) {
              loadedChartData[index] = BloodPressureData(daysOfWeek[index], systolic, diastolic);
            }
          }

          setState(() {
            chartData = loadedChartData;
          });
        } else {
          print('Failed: ${jsonResponse['message']}');
          throw Exception('Failed to load weekly chart');
        }
      } else {
        print('Failed to load weekly chart. Status code: ${response.statusCode}');
        throw Exception('Failed to load weekly chart');
      }
    } catch (e) {
      print('Error fetching weekly chart: $e');
    }
  }

  String _getAbbreviatedDay(String dayName) {
    switch (dayName) {
      case 'Sunday':
        return 'Su';
      case 'Monday':
        return 'Mo';
      case 'Tuesday':
        return 'Tu';
      case 'Wednesday':
        return 'We';
      case 'Thursday':
        return 'Th';
      case 'Friday':
        return 'Fr';
      case 'Saturday':
        return 'Sa';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Week_Chart(); // Fetch data on init
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SfCartesianChart(
        plotAreaBorderWidth: 1.0,
        plotAreaBorderColor: Colors.grey.shade100,
        backgroundColor: Colors.white,
        primaryXAxis: CategoryAxis(
          majorGridLines: const MajorGridLines(width: 0), // Remove major grid lines
        ),
        primaryYAxis: NumericAxis(
          isVisible: false,
          majorGridLines: const MajorGridLines(width: 0), // Remove major grid lines
          minorGridLines: const MinorGridLines(width: 0), // Remove minor grid lines
        ),
        series: <CartesianSeries>[
          SplineSeries<BloodPressureData, String>(
            name: 'Systolic',
            dataSource: chartData,
            xValueMapper: (BloodPressureData data, _) => data.day,
            yValueMapper: (BloodPressureData data, _) => data.systolic,
            color: Colors.red,
          ),
          SplineSeries<BloodPressureData, String>(
            name: 'Diastolic',
            dataSource: chartData,
            xValueMapper: (BloodPressureData data, _) => data.day,
            yValueMapper: (BloodPressureData data, _) => data.diastolic,
            color: Colors.blue,
          ),
          SplineRangeAreaSeries<BloodPressureData, String>(
            name: 'Systolic Range',
            dataSource: chartData,
            xValueMapper: (BloodPressureData data, _) => data.day,
            lowValueMapper: (BloodPressureData data, _) => data.systolic - 10,
            highValueMapper: (BloodPressureData data, _) => data.systolic + 10,
            color: Colors.red.withOpacity(0.2),
          ),
          SplineRangeAreaSeries<BloodPressureData, String>(
            name: 'Diastolic Range',
            dataSource: chartData,
            xValueMapper: (BloodPressureData data, _) => data.day,
            lowValueMapper: (BloodPressureData data, _) => data.diastolic - 10,
            highValueMapper: (BloodPressureData data, _) => data.diastolic + 10,
            color: Colors.blue.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}

class BloodPressureData {
  BloodPressureData(this.day, this.systolic, this.diastolic);

  final String day;
  final double systolic;
  final double diastolic;
}


