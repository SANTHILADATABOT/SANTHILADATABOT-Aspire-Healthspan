
import 'package:azpire_new/Controller/bloodpressure_controller.dart';
import 'package:azpire_new/Model/bloodpressure_model.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../root/root.dart';

class BloodPressureChart extends StatefulWidget {
  @override
  State<BloodPressureChart> createState() => _BloodPressureChartState();
}

class _BloodPressureChartState extends State<BloodPressureChart>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BloodPressureData> chartData = [];
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  bool _isLoading = false;

  //bool isLoading = false;
  final BloodPressureController _bloodpressurecontroller = Get.put(BloodPressureController());
  DateTime? selectedDate;
  String? mainDate;
  double? diastolic_sd_low;
  double? systolic_sd_high;
  double? systolic_sd_low;
  double? diastolic_sd_high;
  int? target_sys, target_dys;


  Future<void> Week_Chart() async {
    setState(() => _isLoading = true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _bloodpressurecontroller.Week_Chart(
          user_id,
          DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now())
      );

      setState(() {
        chartData = result['chartData'];
        // systolicValue = result['weekBpSystolic'];
        // diastolicValue = result['weekBpDiastolic'];
        target_sys = result['targetSystolic'];
        target_dys = result['targetDiastolic'];
        mainDate = result['mainDate'];
        diastolic_sd_low = result['diastolic_sd_low'];
        systolic_sd_high = result['systolic_sd_high'];
        systolic_sd_low = result['systolic_sd_low'];
        diastolic_sd_high = result['diastolic_sd_high'];
      });
    } catch (e) {
      print('Error loading weekly Bp data: $e');
    } finally {
      setState(() => _isLoading = false);
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
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildShimmerEffect() :
      buildWeeklyBloodPressureChart(
        chartData: chartData,
        targetSystolic: target_sys ?? 120,
        targetDiastolic: target_dys ?? 80,
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 1, // Adjust this count as necessary
        itemBuilder: (context, index) {
          return Container(
            height: 200,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFFffffff),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget buildWeeklyBloodPressureChart({
    required List<BloodPressureData> chartData,
    required int targetSystolic,
    required int targetDiastolic,

  }) {
    final screenSize = MediaQuery.of(context).size;
    final double portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;

    print("$systolic_sd_low....$systolic_sd_high");
    return Container(
      width: double.infinity,
      height: portraitHeight * 0.30,
      child: SfCartesianChart(
        plotAreaBorderWidth: 0.0,
        backgroundColor: Color(0xFFffffff),
        tooltipBehavior: TooltipBehavior(
            enable: true,
            textStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold
            )
        ),
        primaryXAxis: CategoryAxis(
          title: const AxisTitle(
            text: '',
            textStyle: TextStyle(color: AppColors.contentColorBlack),
          ),
         labelPlacement: LabelPlacement.onTicks,
          interval: 1,
          maximumLabels: 7,
          labelIntersectAction: AxisLabelIntersectAction.none,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          //plotOffset: 1,
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        primaryYAxis: NumericAxis(
          majorGridLines:  MajorGridLines(width: 0),
          minorGridLines:  MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          minimum: 60,
          maximum: 200,
          interval: 20,
          // title: AxisTitle(text: 'mmHg',textStyle: TextStyle(color: AppColors.White)),
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
            // plotBands: <PlotBand>[
            //   PlotBand(
            //     isVisible: true,
            //     start: targetSystolic.toDouble(),
            //     end: targetSystolic.toDouble(),
            //     borderWidth: 2,
            //     textStyle: TextStyle(color: Colors.green),
            //    // color: Colors.green,
            //     borderColor: Colors.green,
            //     text: '',
            //     horizontalTextAlignment: TextAnchor.end,
            //   ),
            //   PlotBand(
            //     isVisible: true,
            //     start: targetDiastolic.toDouble(),
            //     end: targetDiastolic.toDouble(),
            //     borderWidth: 2,
            //     text: '',
            //     color: Colors.green,
            //     borderColor: Colors.green,
            //     horizontalTextAlignment: TextAnchor.end,
            //   ),
            // ]
        ),
        series: <CartesianSeries>[
          SplineRangeAreaSeries<BloodPressureData, String>(
            //dataSource: chartData.where((d) => d.date.isBefore(DateTime.now().add(Duration(days: 0)))).toList(),
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            highValueMapper: (data, _) => systolic_sd_high,
            lowValueMapper: (data, _) => systolic_sd_low,
            color: Color(0xFFd9d9ff).withOpacity(0.6),
            name: '',
            enableTooltip: false,
          ),
          SplineRangeAreaSeries<BloodPressureData, String>(
            // dataSource: chartData.where((d) => d.date.isBefore(DateTime.now().add(Duration(days: 0)))).toList(),
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            highValueMapper: (data, _) => diastolic_sd_high,
            lowValueMapper: (data, _) => diastolic_sd_low,
            color: Color(0xFFfddcc9).withOpacity(0.6),
            name: '',
            enableTooltip: false,
          ),
          // Target Lines
          LineSeries<BloodPressureData, String>(
            name: 'Target Systolic',
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            yValueMapper: (data, _) => targetSystolic,
            color: Colors.green,
            width: 2,
            enableTooltip: false,
            markerSettings: MarkerSettings(
                isVisible: false
            ),
          ),

          LineSeries<BloodPressureData, String>(
            name: 'Target Diastolic',
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            yValueMapper: (data, _) => targetDiastolic,
            color: Colors.green,
            // dashArray: [5, 5],
            width: 2,
            enableTooltip: false,
            markerSettings: MarkerSettings(
                isVisible: false
            ),
          ),
          // Systolic Line
          SplineSeries<BloodPressureData, String>(
            name: 'Systolic',
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            yValueMapper: (data, _) => data.systolic == 0 ? null: data.systolic,
            color: Color(0xFF5454ff),
            markerSettings: const MarkerSettings(
                isVisible: true,
                height: 12,width: 12
            ),
          ),
          // Diastolic Line
          SplineSeries<BloodPressureData, String>(
            name: 'Diastolic',
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            yValueMapper: (data, _) => data.diastolic == 0 ? null : data.diastolic,
            color: Color(0xFFf6803d),
            markerSettings: const MarkerSettings(
                isVisible: true,
                height: 12,width: 12
            ),
          ),

        ],
      ),
    );
  }

}
