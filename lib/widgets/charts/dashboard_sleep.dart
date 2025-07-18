import 'dart:convert';
import 'package:azpire_new/Controller/sleep_controller.dart';
import 'package:azpire_new/Model/sleep_model.dart';
import 'package:azpire_new/View/Sleep_chart.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:http/http.dart' as http;

import '../../root/root.dart';




class SleepChart extends StatefulWidget {
  @override
  State<SleepChart> createState() => _SleepChartState();
}

class _SleepChartState extends State<SleepChart> {

  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  final SleepController _sleepcontroller = Get.put(SleepController());
  bool _isLoading = false;
  String formattedTime = "";
  List<SleepBarData> _daySleepBars = [];
  List<SleepBarData> _weekSleepBars = [];
  DateTime? selectedDate;
  List<SleepDataChart1> _sleepsData = [];
  double yAxisMax = 0;
  String? deepPercentage;
  String? lightPercentage;
  String? remPercentage;
  String? totalPercentage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Week_Chart();
  }



  Color _getColor(int value) {
    switch (value) {
      //case 1: return Color(0xFFffd000); // Awake
      case 2: return Color(0xFFa4bce7); // Light
      case 3: return Color(0xFFb5e78c);
      case 4: return Color(0xFFef989e);
      case 5: return Color(0xFFef989e);
      default: return Color(0xFFef989e); // Unknown or filler
    }
  }

  String? _formatPercentage(dynamic value) {
    if (value is String) {
      final stripped = value.replaceAll('%', '');
      final parsed = double.tryParse(stripped);
      return parsed != null ? '${parsed.toStringAsFixed(1)}%' : null;
    } else if (value is num) {
      return '${value.toDouble().toStringAsFixed(1)}%';
    }
    return null;
  }




  Future<void> Week_Chart() async {



    setState(() => _isLoading = true);

    try {
      final result = await _sleepcontroller.Week_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
        type: 'weekly',
      );

      // final String? recentRaw = result['recent_datetime'];
      // final String formattedDate = recentRaw != null
      //     ? formatDateTime(recentRaw)
      //     : result['mainDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      setState(() {
        _weekSleepBars = result['chartData'];
        _sleepsData = result['summaryData'];
        yAxisMax = (result['y_axis_max'] as num).toDouble();
        deepPercentage = _formatPercentage(result['recent_deep_percent']);
        lightPercentage = _formatPercentage(result['recent_light_percent']);
        remPercentage = _formatPercentage(result['recent_rem_percent']);
        //totalsleep = result['recent_total'];
        totalPercentage = result['recent_total_percent'];

        //mainDate = formattedDate;

        final recentSleepList = result['sleep_sessions'];
        if (recentSleepList != null && recentSleepList is List && recentSleepList.isNotEmpty) {
          for (var item in recentSleepList) {
            final int state = item['sleep_value'];
            final String time = item['datetime'];

            String stateLabel;
            switch (state) {
              case 1:
                stateLabel = 'Awake';
                break;
              case 2:
                stateLabel = 'Light Sleep';
                break;
              case 3:
                stateLabel = 'Deep Sleep';
                break;
              case 4:
                stateLabel = 'REM Sleep';
                break;
              case 5:
                stateLabel = 'Middle Sleep';
                break;
              default:
                stateLabel = 'Unknown';
            }

            print("Sleep State: $stateLabel, Time: $time");
          }

        }


      });

      print("✅ Weekly Sleep Chart Data Loaded");
    } catch (e) {
      print('❌ Error loading weekly sleep chart: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? _buildShimmerEffect()
            : Column(
          children: [
            /// Chart takes available space
            Expanded(
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  canShowMarker: false, // Hides the marker dot
                ),
                onTooltipRender: (TooltipArgs args) {
                  final dayLabel = args.dataPoints![args.pointIndex!.toInt()].x;
                  final summary = _sleepsData.firstWhere(
                        (e) => e.day_name == dayLabel,
                    orElse: () => SleepDataChart1(
                      day_name: '',
                      totalLight: '0h 0m',
                      totalDeep: '0h 0m',
                      totalMiddle: '0h 0m',
                      total_sleep: '0h 0m',
                      light2: 0,
                      week_names: '',
                      awake_s: 0,
                      lightSleep_s: 0,
                      deepSleep_s: 0,
                      remSleep_s: 0,
                      awake_s1: 0,
                      lightSleep_s1: 0,
                      remSleep_s1: 0,
                      time_s: DateTime.now(),
                      month_name: '',
                      years: '',
                    ),
                  );

                  args.text =
                  'Deep : ${summary.totalDeep}\n'
                      'Middle : ${summary.totalMiddle}\n'
                      'Light : ${summary.totalLight}';
                },
                plotAreaBorderWidth: 0.0,
                plotAreaBorderColor: AppColors.greyshaded100,
                backgroundColor: Colors.white,
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  majorTickLines: MajorTickLines(width: 0),
                  axisLine: const AxisLine(width: 1, color: AppColors.Grey),
                  title: AxisTitle(text: ''),
                  labelStyle: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                  minorGridLines: const MinorGridLines(width: 0),
                  majorTickLines: MajorTickLines(width: 0),
                  minimum: 0,
                  maximum: yAxisMax,
                  interval: 1,
                  labelStyle: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                  title: const AxisTitle(
                    text: '',
                    textStyle: TextStyle(color: AppColors.contentColorBlack),
                  ),
                ),
                series: <CartesianSeries>[
                  RangeColumnSeries<SleepBarData, String>(
                    dataSource: _weekSleepBars,
                    xValueMapper: (SleepBarData data, _) => data.label,
                    lowValueMapper: (SleepBarData data, _) => data.startHour,
                    highValueMapper: (SleepBarData data, _) => data.endHour,
                    pointColorMapper: (SleepBarData data, _) => _getColor(data.value),
                    name: 'Sleep',
                  ),
                ],
              ),
            ),

          ]
        ),
      ),
    );
  }




  Widget _buildLegendItem(Color color, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade500),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(width: 15, height: 10, color: color),
            SizedBox(width: 5),
            Text(label, style: Apptextstyle.s12wbcb),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendvalues(Color color, Color Color1,String label) {
    return Container(
      decoration: BoxDecoration(
        color:  color,
        border: Border.all(
          color: Color1, // Border color for Deep Sleep
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
            label,
          overflow: TextOverflow.ellipsis,
          style:Apptextstyle.s10wbcB
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
}








