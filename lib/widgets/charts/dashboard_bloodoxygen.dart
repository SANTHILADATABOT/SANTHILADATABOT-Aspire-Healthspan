
import 'package:azpire_new/Controller/spo2_controller.dart';
import 'package:azpire_new/Model/spo2_model.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';




class BloodOxygenChartPage extends StatefulWidget {
  @override
  State<BloodOxygenChartPage> createState() => _BloodOxygenChartPageState();
}

class _BloodOxygenChartPageState extends State<BloodOxygenChartPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BloodOxygenData> chartData = [];
  final List<String> daysOfWeek = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
  bool _isLoading = false;
  final spo2Controller _spo2controller= Get.put(spo2Controller());
  String? mainDate; // Variable to store the fetched date
  DateTime? selectedDate;
  int? targetNormal;
  int? targetHigh;

  Future<void> Week_Chart() async {
    setState(() => _isLoading = true);
    try {
      final result = await _spo2controller.Week_Chart(
        userId: '102',
        date: DateFormat('yyyy-MM-dd').format(selectedDate ?? DateTime.now()),
      );

      // final String? recentRaw = result['recent_datetime']; // Note the correct key: recentDatetime
      // final String rawDate = (recentRaw != null && recentRaw.trim().isNotEmpty)
      //     ? recentRaw
      //     : result['mainDate'];
      //
      // final String formattedDate = formatDateTime(rawDate);


      setState(() {
        mainDate = result['mainDate'];;
        targetNormal = result['target_spo2_normal'];
        targetHigh = result['target_spo2_high'];
        //recentSpo2 = result['weekspo2'];
        chartData = result['chartData'];
      });
    } catch (e) {
      print('Error fetching SPO2 data: $e');
    }
    finally {
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
          : WeeklybuildBloodOxygenChart(
          context: context,
          chartData: chartData,
          targetspo2noraml: targetNormal?.toInt() ?? 91,
          targetspo2high: targetNormal?.toInt() ?? 95 // Your
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



  Widget WeeklybuildBloodOxygenChart({
    required BuildContext context,
    required List<BloodOxygenData> chartData,
    required int targetspo2noraml,
    required int targetspo2high,
  }) {
    return Column(
     children: [
       SizedBox(height: 20,),
       Expanded(
         child: Container(
           height: MediaQuery.of(context).size.height * 0.45,
           child: SfCartesianChart(
             //margin: const EdgeInsets.only(left: 10, right: 20),
             plotAreaBorderWidth: 0.0,
             backgroundColor: Color(0xFFffffff),
             tooltipBehavior: TooltipBehavior(enable: true),
             primaryXAxis: CategoryAxis(
               title: AxisTitle(text: ''),
               majorGridLines: const MajorGridLines(width: 0),
               majorTickLines: MajorTickLines(width: 0),
               labelStyle: const TextStyle(

                   fontSize: 9,
                   fontWeight: FontWeight.bold,
                   color: Colors.black// Ensures no spacing
               ),
             ),
             primaryYAxis: NumericAxis(
               labelStyle: const TextStyle(
                   fontSize: 9,
                   fontWeight: FontWeight.bold,
                   color: Colors.black// Ensures no spacing
               ),
               majorGridLines: const MajorGridLines(width: 0),
               majorTickLines: MajorTickLines(width: 0),
               minimum: 85,
               maximum: 104,
               interval: 5,
               plotBands: <PlotBand>[
                 PlotBand(isVisible: true, start: 95, end: 100, color: const Color(0xFFBFFABF)),
                 PlotBand(isVisible: true, start: 91, end: 95, color: const Color(0xFFFFF4CC)),
                 PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFF6CCCC)),
                 // PlotBand(isVisible: true, start: targetspo2noraml.toDouble(), end: targetspo2noraml.toDouble(), color: const Color(0xFFE6FFE6)),
                 // PlotBand(isVisible: true, start: targetspo2high.toDouble(), end: targetspo2high.toDouble(), color: const Color(0xFFFFF4CC)),
                 // PlotBand(isVisible: true, start: 0, end: 91, color: const Color(0xFFFFE6E6)),
               ],
             ),
             series: <CartesianSeries>[
               SplineSeries<BloodOxygenData, String>(
                 name: 'SpO₂',
                 dataSource: chartData,
                 xValueMapper: (BloodOxygenData data, _) => data.day,
                 yValueMapper: (data, _) => data.spo2,
                 color: const Color(0xffFF0000),
                 markerSettings: const MarkerSettings(
                     isVisible: true,
                     height: 12,width: 12
                 ),
                 // For better tooltips:
                 dataLabelSettings: DataLabelSettings(
                   isVisible: false,
                   labelAlignment: ChartDataLabelAlignment.auto,
                 ),
               ),
             ],
           ),
         ),
       ),

     ],



    );
  }




}

