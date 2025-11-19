
import 'dart:convert';
import 'package:azpire_new/Controller/weight_controller.dart';
import 'package:azpire_new/Model/weight_model.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

import '../../root/root.dart';

class WeightChartPage extends StatefulWidget {
  @override
  State<WeightChartPage> createState() => _WeightChartPageState();
}

class _WeightChartPageState extends State<WeightChartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<WeightChartData> weekChart = [];
  final WeightController _weightcontroller = Get.put(WeightController());
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  bool _isLoading = false;
  List<WeightChartData> chartData = [];
  int? weightrate;// Variable to store the systolic value
  var bmi1;
  String? mainDate;
  DateTime? selectedDate;



  Future<void> Week_Chart() async {

    setState(() {
      _isLoading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    try {
      final result = await _weightcontroller.Week_Chart(
        user_id,
        DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      );

      final List<WeightChartData> data = result['chartData'];
      final String mainDateString = result['mainDate'];
      final int weekWeight = int.tryParse(result['weight'].toString()) ?? 0;
      final String bmi = result['bmi'].toString();

      String formattedDate = '';
      try {
        DateTime parsedMainDateTime = DateTime.parse(mainDateString);
        formattedDate = DateFormat('MMM dd, yyyy').format(parsedMainDateTime);
      } catch (e) {
        print('Error parsing main date: $e');
        formattedDate = mainDateString;
      }

      setState(() {
        chartData = data;
        mainDate = formattedDate;
        weightrate = weekWeight;
        bmi1 = bmi;
      });
    } catch (e) {
      print('Error fetching weight chart: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }








  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Week_Chart();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildShimmerEffect()
          : Column(
        children: [
          Expanded(
            child: _buildChart(
              title: '',
              seriesName: "Weight(lbs)",
              dataSource: chartData,
              xMapper: (data, _) => data.day,
              yMapper: (data, _) => data.weightrate.toDouble(),
              color: Color(0xffF5B849),
            ),
          ),
        ],
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
              color: Colors.white,
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
  Widget _buildChart({
    required String title,
    required String seriesName,
    required List<WeightChartData> dataSource,
    required String Function(WeightChartData, int) xMapper,
    required double Function(WeightChartData, int) yMapper,

    required Color color,
    double maxY = 240,
    double minY = 30,
    double interval = 30,
  }) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
          enable: true,
          textStyle: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold
          )
      ),
      //tooltipBehavior: TooltipBehavior(enable: true),
      title: ChartTitle(
        alignment: ChartAlignment.near,
        text: title,
        textStyle: Apptextstyle.swn14cothers,
      ),
      plotAreaBorderWidth: 0.0,
      plotAreaBorderColor: Colors.grey.shade100,
      backgroundColor: Colors.white,
      primaryXAxis: CategoryAxis(
        majorTickLines: MajorTickLines(width: 0),
        majorGridLines: const MajorGridLines(width: 0),
        labelPlacement: LabelPlacement.onTicks,
        interval: 1,
        maximumLabels: 7,
        labelIntersectAction: AxisLabelIntersectAction.none,
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        title: AxisTitle(
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
        maximum: maxY,
        minimum: minY,
        interval: interval,
        title: AxisTitle(
          text: '',
          textStyle: TextStyle(color: Colors.black),
        ),
        labelStyle: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.black
        ),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        majorTickLines: MajorTickLines(width: 0),
      ),
      series: <CartesianSeries>[
        SplineSeries<WeightChartData, String>(
          name: seriesName,
          dataSource: dataSource,
          xValueMapper: xMapper,
          yValueMapper: yMapper,
          color: color,
          markerSettings: MarkerSettings(
              isVisible: true,
              //color: color,
              height: 12,width: 12
          ),
        ),
      ],

    );
  }

}

