

import 'dart:convert';
import 'package:azpire_new/Controller/Heartrate_controller.dart';
import 'package:azpire_new/Model/Heartrate_model.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

import '../../root/root.dart';

class HeartRateChartPage extends StatefulWidget {
  @override
  State<HeartRateChartPage> createState() => _HeartRateChartPageState();
}

class _HeartRateChartPageState extends State<HeartRateChartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HeartRateData> chartData = [];
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  bool _isLoading = false;
  DateTime? selectedDate;
  int? target_HR;
  double? sd_low;
  double? sd_high;
  double? heartrate_sd_high;
  double? heartrate_sd_low;
  String? mainDate;
  final HeartRatecontroller _Heartratecontroller = Get.put(HeartRatecontroller());
  Future<void> Week_Chart() async {
    setState(() => _isLoading = true);
    try {
      final result = await _Heartratecontroller.Week_Chart(
          '102',
          DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now())
      );

      setState(() {
        chartData = result['chartData'];
        //HeartateValue = result['weekBpSystolic'];
        target_HR = result['target_heart_rate'];
        mainDate = result['mainDate'];
        heartrate_sd_high = result['heartrate_sd_high'];
        heartrate_sd_low = result['heartrate_sd_low'];
      });
    } catch (e) {
      print('Error loading weekly data: $e');
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
          ? _buildShimmerEffect() // Show shimmer effect while loading
          :  buildWeeklyHeartRateChart(
        chartData: chartData,
        targetHR: target_HR ?? 75,
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
              color:Color(0xFFffffff),
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
  Widget buildWeeklyHeartRateChart({
    required List<HeartRateData> chartData,
    required int targetHR,
  }) {
    final screenSize = MediaQuery.of(context).size;
    final double portraitHeight = screenSize.height > screenSize.width
        ? screenSize.height
        : screenSize.width;
    return Container(
      width: double.infinity,
      height: portraitHeight * 0.28,
      // padding: EdgeInsets.all(8),
      child: SfCartesianChart(
        plotAreaBorderWidth: 0.0,
        backgroundColor: Color(0xFFffffff),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: CategoryAxis(
         //labelPlacement: LabelPlacement.onTicks,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          majorTickLines: MajorTickLines(width: 0),
          majorGridLines: const MajorGridLines(width: 0),
          title: const AxisTitle(
            text: '',
            textStyle: TextStyle(color: AppColors.contentColorBlack),
          ),
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
        ),
        primaryYAxis: NumericAxis(
          maximum: 170,
          interval: 20,
          minimum: 40,
          labelStyle: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black
          ),
          //title: AxisTitle(text: 'BPM'),
          majorGridLines: const MajorGridLines(width: 0),
          minorGridLines: const MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(width: 0),
          plotBands: <PlotBand>[
            PlotBand(
              isVisible: true,
              start: targetHR.toDouble(),
              end: targetHR.toDouble(),
              borderWidth: 2,
              borderColor: Colors.green,
              text: '',
              textStyle: TextStyle(color: Colors.green),
              horizontalTextAlignment: TextAnchor.end,
            ),
            // Target line
            // PlotBand(
            //     isVisible: true,
            //     start: targetHR.toDouble(),
            //     end: targetHR.toDouble(),
            //     borderWidth: 2,
            //     borderColor: Color(0xff1B601EFF),
            //     text: '',
            //     textStyle: TextStyle(color: Color(0xff38B73DFF),)),
            // SD Band - only add if values are valid
            // if (heartrate_sd_high != null && heartrate_sd_low != null && heartrate_sd_high! > 0 && heartrate_sd_low! > 0)
            //   PlotBand(
            //     isVisible: true,
            //     start: heartrate_sd_low!,
            //     end: heartrate_sd_high!,
            //     color: Colors.red.withOpacity(0.2),
            //     text: '',
            //     textStyle: TextStyle(color: Colors.red),
            //   ),
          ],
        ),
        series: <CartesianSeries>[
          SplineRangeAreaSeries<HeartRateData, String>(
            //dataSource: chartData.where((d) => d.date.isBefore(DateTime.now().add(Duration(days: 0)))).toList(),
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            highValueMapper: (data, _) => heartrate_sd_high,
            lowValueMapper: (data, _) => heartrate_sd_low,
            color: Colors.red.withOpacity(0.2),
            name: '',
            enableTooltip: false,
          ),
          SplineSeries<HeartRateData, String>(
            name: 'Heart Rate',
            dataSource: chartData,
            xValueMapper: (data, _) => data.day,
            yValueMapper: (data, _) => data.heartrate == 0 ? null:data.heartrate,
            color: Colors.red,
            markerSettings: const MarkerSettings(
                isVisible: true,
                //color: Color(0xffFF0000),
                height: 12,width: 12
            ),
          ),
          // LineSeries<HeartRateData, String>(
          //   enableTooltip: false,
          //   name: 'Target',
          //   dataSource: chartData,
          //   xValueMapper: (data, _) => data.day,
          //   yValueMapper: (data, _) => targetHR,
          //   color: Colors.green,
          //   width: 2,
          //   markerSettings: MarkerSettings(
          //     isVisible: false
          //   ),
          // ),
        ],
      ),
    );
  }
}



