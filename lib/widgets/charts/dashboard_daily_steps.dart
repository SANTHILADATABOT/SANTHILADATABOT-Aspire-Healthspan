
import 'dart:convert';
import 'package:azpire_new/Controller/steps_controller.dart';
import 'package:azpire_new/Model/steps_model.dart';
import 'package:azpire_new/utils/app_color.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:azpire_new/root/root.dart';

class StepsChart extends StatefulWidget {
  @override
  _StepsChartState createState() => _StepsChartState();
}

class _StepsChartState extends State<StepsChart> {
  List<StepsData> _stepsData = [];
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  bool _isLoading = false;
  final StepsController _stepscontroller = Get.put(StepsController());
  DateTime? selectedDate;
  String? mainDate;
  int? _tappedIndex;
  int? _tappedSteps;

  @override
  void initState() {
    super.initState();
    Week_Chart(); // Fetch data on init
  }

  Future<void> Week_Chart() async {
    setState(() => _isLoading = true);
    try {
      final result = await _stepscontroller.Week_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      );

      setState(() {
        mainDate = result['mainDate'];
        //stespsvalue = result['recent_step'];
        //milesValue = result['miles'];
        //calValue = result['calories'];
        _stepsData = result['chartData'];
      });
    } catch (e) {
      print('Error loading weekly steps: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    int maxSteps = _stepsData.isNotEmpty
        ? _stepsData.map((data) => data.dailySteps).reduce((a, b) => a > b ? a : b)
        : 0;

    double maxinterval = ((maxSteps + 50 ) ~/ 50) * 50;

    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildShimmerEffect() // Show shimmer effect while loading
          : buildChartWeeklyWidget(
        context: context,
        size: size,
        data: _stepsData,
        xValueMapper: (d) => d.day,
        maxInterval: maxinterval,
        onPointTap: (details) {
          setState(() {
            _tappedIndex = details.pointIndex;
            _tappedSteps = details.dataPoints![details.pointIndex!].y as int;
          });
        },
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

  Widget buildChartWeeklyWidget({
    required BuildContext context,
    required Size size,
    required List<StepsData> data,
    required double maxInterval,
    required Function(ChartPointDetails) onPointTap,
    required Function(dynamic d) xValueMapper,
  }) {
    return SfCartesianChart(
      //tooltipBehavior: TooltipBehavior(enable: true),
      tooltipBehavior: TooltipBehavior(enable: true),
      //margin: const EdgeInsets.only(left: 10),
      plotAreaBorderWidth: 0,
      backgroundColor: AppColors.White,
     // title: ChartTitle(text: title),
      primaryXAxis: CategoryAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        majorTickLines: const MajorTickLines(size: 0),
        axisLine: const AxisLine(width: 1, color: Colors.grey),
        majorGridLines: const MajorGridLines(width: 0),
        //title: AxisTitle(text: 'Days'),
        labelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black
        ),
      ),
      primaryYAxis: NumericAxis(
        // title: const AxisTitle(
        //   text: 'Steps',
        //   //textStyle: TextStyle(color: AppColors.contentColorBlack),
        // ),
        minimum: 0,
        maximum: maxInterval,
        interval: maxInterval / 10,
        majorTickLines: const MajorTickLines(width: 0),
        labelStyle: const TextStyle(   fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black),
        majorGridLines: const MajorGridLines(width: 0),
        numberFormat: NumberFormat.decimalPattern('en_US'),

      ),
      series: <CartesianSeries>[
        ColumnSeries<StepsData, String>(
          name: 'Steps',
          dataSource: data,
          xValueMapper: (data, _) => data.day,
          yValueMapper: (StepsData d, _) => d.dailySteps,
          color: AppColors.steps_graph,
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          onPointTap: onPointTap,
        )
      ],
    );
  }
}
