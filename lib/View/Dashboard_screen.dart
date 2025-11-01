
import 'dart:async';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:azpire_new/Controller/dashboard_controller.dart';
import 'package:azpire_new/Controller/notifications_controller.dart';
import 'package:azpire_new/View/AdminScreen.dart';
import 'package:azpire_new/View/Dialy_steps.dart';
import 'package:azpire_new/View/Heart_rate.dart';
import 'package:azpire_new/View/Sleep_chart.dart';
import 'package:azpire_new/View/blood_oxygenpressure.dart';
import 'package:azpire_new/View/blood_pressure.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/View/weight.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/CustomBottomNavBar.dart';
import 'package:azpire_new/widgets/charts/dashboard_blood_pressure.dart';
import 'package:azpire_new/widgets/charts/dashboard_daily_steps.dart';
import 'package:azpire_new/widgets/charts/dashboard_heart_rate.dart';
import 'package:azpire_new/widgets/charts/dashboard_sleep.dart';
import 'package:azpire_new/widgets/charts/dashboard_bloodoxygen.dart';
import 'package:azpire_new/widgets/charts/dashboard_weight_chart.dart';
import 'package:azpire_new/widgets/shimmer_effects.dart';
import 'package:azpire_new/widgets/text_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer
import '../menu/NavMneu.dart';
import '../utils/apptext.dart';
import '../widgets/custom_card.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required String deviceID});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final settings = AdminSettings();
  List<Map<String, dynamic>> minuteDataList = [];
  final _advancedDrawerController = AdvancedDrawerController();
  final NotificationsController _notifycontroller = NotificationsController();
  final DashboardController _dashboardcontroller = DashboardController();
  String t1 = "";
  String t2 = "";
  String datetime = "";
  String heartRate = "";
  String spo2 = "";
  String steps = "";
  int weight = 0;
  String sleep = "";
  String bps = "";
  var profilephoto ;
  String bpd = "";
  String sys = "";
  String Dia = "";
  String weekdate = "";
  bool isLoggedIn = false;
  var user_id;
  var name;
  var mobile_no;
  var email;
  var pofileimage;
  var noti_count;
  String? deepPercentage;
  String? lightPercentage;
  String? middlePercentage;
  String formattedDateTime = " ";
  bool isLoading = true;
  List title = ["Blood Pressure", "Heart Rate", "Avg Daily Steps", "Sleep", "Weight"];
  String notificationMessage = "Waiting for data...";
  Map<String, dynamic>? dailyData;
  Timer? _syncTimer;
  /// Controller to handle bottom nav bar and also handles initial page
  final NotchBottomBarController _controller = NotchBottomBarController(index: 0);
  Map<String, dynamic>? _dailyData;
  bool _hasNavigated = false;
  bool _hasLoadedOnce = false;
  
  


 // bool shouldSync = false;

  @override
  void initState() {
    super.initState();
    loadDashboardData();
    checkSession();
    loaddata();
    _loadNotificationCount();
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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadDashboardData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    print("user_id:$user_id");
    final data = await _dashboardcontroller.fetchDashboardload(user_id);
    if (data != null) {

      DateTime originalDateTime = DateFormat('yyyy-MM-dd hh:mm:ss a').parse(data['collection_date']);
      String formattedDateTime = DateFormat('MMMM d, yyyy, HH:mm').format(originalDateTime);

      // Initialize defaults
      String deep = '';
      String middle = '';
      String light = '';

      // Extract sleep_list
      List<dynamic> rawSleepList = data['sleep_list'] ?? [];

      for (var item in rawSleepList) {
        switch (item['sleep_value']) {
          case 4:
            deep = item['percentage'];
            break;
          case 3:
            middle = item['percentage'];
            break;
          case 2:
            light = item['percentage'];
            break;
        }
      }

      if (mounted)
      setState(() {
        profilephoto = data['profile_image'].toString();
        bps = data['blood_pressure_systolic'].toString();
        bpd = data['blood_pressure_diastolic'].toString();
        heartRate = data['heart_rate'].toString();
        steps = data['daily_steps'].toString();
        //weight = data['weight'].toString();
        weight = data['weight'] ?? 0; // weight as int
        sleep = data['sleep'].toString();
        datetime = formattedDateTime;
        weekdate = data['week_range'].toString();
        deepPercentage = deep;
        middlePercentage = middle;
        lightPercentage = light;
      });
    }
  }


  Future<void> _loadNotificationCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final count = await _notifycontroller.getNotificationCount(user_id);
    if (mounted) {
      setState(() {
        noti_count = count;
      });
    }
  }

  Future<void> checkSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
    print("isLoggedIn$isLoggedIn");
  }

  Future<void> loaddata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      user_id = prefs.getString('user_id');
      name = prefs.getString('name');
      mobile_no = prefs.getString('mobile_no');
      email = prefs.getString('email');
      pofileimage = prefs.getString('pofile');
      isLoading = false;
    });

    if (prefs.getString("name") != null) {
      await prefs.setString("username", prefs.getString("name")!);
    }

  }




  ExitAppDialog(){}
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
       ExitAppDialog();
       return true;
      },
      child: Container(
        width: kIsWeb ? 250 : MediaQuery.of(context).size.width * 0.7,
        child: AdvancedDrawer(
          controller: _advancedDrawerController,
          backdropColor: Colors.grey.shade100,
          drawer: NavMenu(name: name, email : email, profile:profilephoto, noti_count: noti_count, ),
          child: Scaffold(
            backgroundColor: AppColors.White,
            appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: AppColors.White,
                title: isLoading
                    ? ShimmerLoadingItem()
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Get.to(()=>Profile());
                      },
                      child:profilephoto !=null ? CircleAvatar(
                        backgroundImage: NetworkImage(profilephoto),
                        radius: 20,
                      ):CircleAvatar(
                        backgroundImage: AssetImage(Appimages.profilelogo),
                        radius: 20,
                      ),
                    ),
                    SizedBox(width: 20),
                    TextTitle1(
                      title: "Hi, ${name.toString().capitalizeFirst}",
                      color: Colors.black,
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        _advancedDrawerController.showDrawer();
                      },
                      icon: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
        ),
            body: isLoading
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView(
                physics: BouncingScrollPhysics(),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 24,
                        width: 100,
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  for (int i = 0; i < 4; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Daily Dashboard: $weekdate',
                        style: Apptextstyle.s18wbcB,
                      ),
                    ],
                    //padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    //child:
                  ),
                ),
                Expanded(
                  child: ListView(
                    physics: BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          ValueListenableBuilder<bool>(
                            valueListenable: settings.showBloodPressure,
                            builder: (context, show, _) {
                              return show
                                  ? CustomCard1(
                                title: AppText.bp,
                                t1: bps,
                                t2: '$bpd',
                                Bps: AppText.SYS,
                                Bpd: AppText.DIA,
                                bpunit: AppText.bp_unit,
                                t2fontsize: 24,
                                datetime: AppText.avg_bp,
                                chart: BloodPressureChart(),
                                press: () {
                                  Get.to(()=>BloodPressureChartPage(name: name, email : email, profile:profilephoto, noti_count: noti_count,));
                                },
                                color1: AppColors.color1,
                                color2: AppColors.color2,
                              )
                                  : SizedBox.shrink();
                            },
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: settings.showHeartRate,
                            builder: (context, show, _) {
                              return show
                                  ? CustomCard(
                                title: AppText.HR,
                                t1: heartRate,
                                t2: AppText.HR_unit,
                                t2fontsize: 15,
                                datetime: AppText.avg_hr,
                                chart: HeartRateChartPage(),
                                press: () {
                                  Get.to(()=>HeartRateChart(name: name, email : email,profile:profilephoto, noti_count: noti_count,));
                                },
                                color: Color(0xFFe13b4a), heading: 'heart',
                              )
                                  : SizedBox.shrink();
                            },
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: settings.showSteps,
                            builder: (context, show, _) {
                              return show
                                  ? CustomCard(
                                title: AppText.dailysteps,
                                t1: NumberFormat.decimalPattern('en_US').format(int.tryParse(steps) ?? 0),
                                t2: AppText.D_Steps,
                                t2fontsize: 15,
                                datetime:  AppText.avg_steps,
                                chart: StepsChart(),
                                press: () {
                                  Get.to(()=>StepsChartPage(name: name, email : email,profile:profilephoto, noti_count: noti_count));
                                },
                                color: Color(0xFF9C53C7), heading: 'steps',
                              )
                                  : SizedBox.shrink();
                            },
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: settings.showSleep,
                            builder: (context, show, _) {
                              return show
                                  ? CustomCardsleep(
                                title: AppText.dailysleep,
                                t1: sleep,
                                t2: "",
                                t2fontsize: 15,
                                datetime: AppText.avg_sleep,
                                chart: SleepChart(),
                                press: () {
                                  Get.to(()=>SleepChartPage(name: name, email : email,profile:profilephoto, noti_count: noti_count));
                                },
                                color: AppColors.color3,
                                deepPercentage: _formatPercentage(deepPercentage),
                                middlePercentage: _formatPercentage(middlePercentage),
                                lightPercentage: _formatPercentage(lightPercentage),

                              )
                                  : SizedBox.shrink();
                            },
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: settings.showSpo2,
                            builder: (context, show, _) {
                              return show
                                  ? CustomCardspo2(
                                title: AppText.blood_oxygen,
                                t1: "96%",
                                t2: "",
                                t2fontsize: 15,
                                datetime: AppText.avg,
                                chart: BloodOxygenChartPage(),
                                press: () {
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => BloodoxygenPressureChartPage()));
                                  Get.to(()=>BloodoxygenPressureChartPage(name: name, email : email,profile:profilephoto, noti_count: noti_count));
                                },
                                color: AppColors.color4,
                              )
                                  : SizedBox.shrink();
                            },
                          ),
                          CustomCard(
                            title: AppText.weight,
                            t1: weight.toString(),
                            t2: AppText.pounds,
                            t2fontsize: 15,
                            datetime: AppText.avg,
                            chart: WeightChartPage(),
                            press: () {
                              Get.to(()=>WeightChart(name: name, email : email,profile:profilephoto, noti_count: noti_count));
                            },
                            color: Color(0xffF5B849), heading: 'weight',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            //bottomNavigationBar: CustomBottomNavBar(controller: _controller),
            bottomNavigationBar: (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
                ? CustomBottomNavBar(controller: _controller)
                : null,
          ),
        ),
      ),
    );
  }
}
