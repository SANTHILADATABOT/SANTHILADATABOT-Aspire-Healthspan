// InkWell(
// onTap: () async {
// var datePicked = await DatePicker
//     .showSimpleDatePicker(
// context,
// initialDate: selectedDate ??
// DateTime.now(),
// firstDate: DateTime(1960),
// lastDate: DateTime.now(),
// dateFormat: "MMMM dd, yyyy",
// locale: DateTimePickerLocale.en_us,
// looping: false,
// );
//
// if (datePicked != null) {
// DateTime today = DateTime.now();
// DateTime selected = DateTime(
// datePicked.year, datePicked.month,
// datePicked.day);
// DateTime current = DateTime(
// today.year, today.month, today.day);
//
// setState(() {
// selectedDate = datePicked;
// mainDate =
// DateFormat('dd-MMMM-yyyy').format(
// datePicked);
// selectedPeriod = 'Day';
// currentTitle =
// 'Daily Blood Pressure Average';
// Reports = 'Day';
//
// });
// simulateLoading(Day_Chart);
//
// }
// },
// child: Container(
// decoration: BoxDecoration(
// color: Color(0xff275176),
// borderRadius: BorderRadius.all(
// Radius.circular(8)),
// ),
// padding: const EdgeInsets.symmetric(
// horizontal: 12, vertical: 8),
// child: Row(
// mainAxisSize: MainAxisSize.min,
// children: [
// Text(
// selectedDate != null
// ? DateFormat('MMMM dd, yyyy')
//     .format(selectedDate!)
//     : "Pick Date",
// style: TextStyle(
// color: Colors.white,
// fontWeight: FontWeight.bold,
// ),
// ),
// const SizedBox(width: 4),
// Icon(
// Icons.arrow_drop_down,
// color: Colors.white,
// ),
// ],
// ),
// ),
// ),


// Widget MultiYearlyBloodPressureChart({
//   required String title,
//   required List<BloodPressureData> chartData,
//   required int targetSystolic,
//   required int targetDiastolic,
//
// }) {
//   print("$systolic_sd_low....$systolic_sd_high");
//   return Container(
//     width: double.infinity,
//     height: MediaQuery
//         .of(context)
//         .size
//         .height * 0.40,
//     child: SfCartesianChart(
//       tooltipBehavior: TooltipBehavior(enable: true),
//       title: ChartTitle(text: title),
//       plotAreaBorderWidth: 0.0,
//       plotAreaBorderColor: AppColors.greyshaded100,
//       backgroundColor: AppColors.White,
//       primaryXAxis: CategoryAxis(
//         title: const AxisTitle(
//           text: 'Year',
//           textStyle: TextStyle(color: AppColors.contentColorBlack),
//         ),
//         minimum: fromYear! - 1,
//         maximum: toYear! + 1,
//         interval: 1,
//         labelPlacement: LabelPlacement.onTicks,
//         majorTickLines: MajorTickLines(width: 0),
//         majorGridLines: const MajorGridLines(width: 0),
//         labelStyle: TextStyle(
//             fontSize: 7,
//             fontWeight: FontWeight.bold
//         ),
//       ),
//       primaryYAxis: NumericAxis(
//         majorGridLines: const MajorGridLines(width: 0),
//         minorGridLines: const MinorGridLines(width: 0),
//         majorTickLines: MajorTickLines(width: 0),
//         minimum: 60,
//         maximum: 200,
//         interval: 20,
//         labelStyle: TextStyle(
//             fontSize: 7
//         ),
//         title: AxisTitle(text: 'mmHg'),
//       ),
//
//       series: <CartesianSeries>[
//         SplineRangeAreaSeries<BloodPressureData, String>(
//           //dataSource: chartData.where((data) => data.systolic > 0).toList(),
//           dataSource: chartData,
//           xValueMapper: (data, _) => data.Year,
//           highValueMapper: (data, _) => systolic_sd_high,
//           lowValueMapper: (data, _) => systolic_sd_low,
//           color: Color(0xFFd9d9ff).withOpacity(0.6),
//           name: '',
//           enableTooltip: false,
//           //initialIsVisible: true,
//         ),
//         SplineRangeAreaSeries<BloodPressureData, String>(
//           //dataSource: chartData.where((data) => data.diastolic > 0).toList(),
//           dataSource: chartData,
//           xValueMapper: (data, _) => data.Year,
//           highValueMapper: (data, _) => diastolic_sd_high,
//           lowValueMapper: (data, _) => diastolic_sd_low,
//           color: Color(0xFFfddcc9).withOpacity(0.6),
//           name: '',
//           enableTooltip: false,
//           // initialIsVisible: true,
//         ),
//         // Systolic Line
//         SplineSeries<BloodPressureData, String>(
//           name: 'Systolic',
//           dataSource: chartData,
//           xValueMapper: (data, _) => data.Year,
//           yValueMapper: (data, _) =>  data.systolic == 0 ? null : data.systolic,
//           color: Color(0xFF5454ff),
//           markerSettings: MarkerSettings(isVisible: true),
//         ),
//
//         // Diastolic Line
//         SplineSeries<BloodPressureData, String>(
//           name: 'Diastolic',
//           dataSource: chartData,
//           xValueMapper: (data, _) => data.Year,
//           yValueMapper: (data, _) =>   data.diastolic == 0 ? null : data.diastolic,
//           color: Color(0xFFf6803d),
//           markerSettings: MarkerSettings(isVisible: true),
//         ),
//
//         // Target Lines
//         LineSeries<BloodPressureData, String>(
//           name: 'Target Systolic',
//           dataSource: chartData,
//           xValueMapper: (data, _) => data.months,
//           yValueMapper: (data, _) => targetSystolic,
//           color: Colors.green,
//           // dashArray: [5, 5],
//           width: 2,
//         ),
//
//         LineSeries<BloodPressureData, String>(
//           name: 'Target Diastolic',
//           dataSource: chartData,
//           xValueMapper: (data, _) => data.months,
//           yValueMapper: (data, _) => targetDiastolic,
//           color: Colors.green,
//           // dashArray: [5, 5],
//           width: 2,
//         ),
//       ],
//     ),
//   );
// }