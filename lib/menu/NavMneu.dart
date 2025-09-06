import 'dart:convert';
import 'package:azpire_new/View/AdminScreen.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/View/Dialy_steps.dart';
import 'package:azpire_new/View/Heart_rate.dart';
import 'package:azpire_new/View/Sleep_chart.dart';
import 'package:azpire_new/View/blood_oxygenpressure.dart';
import 'package:azpire_new/View/blood_pressure.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/View/weight.dart';
import 'package:azpire_new/View/Notifications.dart';
import 'package:azpire_new/View/login_Screen.dart';
import 'package:azpire_new/menu/goal_settings.dart';
import 'package:azpire_new/minutedata/minutedata.dart';
import 'package:azpire_new/View/bluetoothscreen.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptext.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:azpire_new/root/root.dart';

class NavMenu extends StatefulWidget {
  var name;

  var email, profile, noti_count;

   NavMenu({Key? key, required this.name, required this.email, required this.profile, required this.noti_count,}) : super(key: key);

  @override
  State<NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  static const platform = MethodChannel('cling_sdk');
  String notificationMessage = "Waiting for data...";
  bool is_loading = false;
  String? _registeredDevice;
  var name;
  var email;
  var pofileimage;
  var noti_count;
  @override
  void initState(){
    print("Hello");
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
      Container(
        height: kIsWeb ? 75 : MediaQuery.of(context).size.height*0.15,
        // width: MediaQuery.of(context).size.width < 600 ? 80 : 250,
      //  width: kIsWeb ? 300 : MediaQuery.of(context).size.width < 600 ? 80 : 250,
        width: kIsWeb ? 250 : MediaQuery.of(context).size.width*0.7,
        child: DrawerHeader(
          padding: EdgeInsets.zero,
        child: Column(
        //mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 25),
              child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
                //crossAxisAlignment: CrossAxisAlignment.start,// Center content horizontally
              children: [
                // App Logo or Icon
                Image.asset(
                  Appimages.applogo, // replace with your logo
                  height: 40,
                ), // Add some space between logo and text
                Text(
                  AppText.splashAppname,
                  style:Apptextstyle.s18wbco,
                  textAlign: TextAlign.center,
                ),
              ],
                      ),
            ),
          ),
        ],
            )
        ),
      ),
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                // ListTile(
                //   leading: Icon(Icons.person,color: Color(0xFF254a6c),size: 25,),
                //   title: Text('Admin',style: TextStyle(
                //       fontFamily: "Inter",
                //       color: Color(0xFF505970)
                //   ),),
                //   onTap: () {
                //     Navigator.push(context, MaterialPageRoute(builder: (context) => Adminscreen()));
                //
                //   },
                // ),
                ListTile(
                  leading: Icon(Icons.home,color: AppColors.C_others,size: 25,),
                  title: Text(AppText.dashboard_m,
                  style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    //Get.to(() => DashboardScreen(deviceID:_registeredDevice!));
                    Get.to(() => DashboardScreen(deviceID:''));
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings,color: AppColors.C_others,size: 25,),
                  title: Text(AppText.set_target,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TargetSetting()));
                  },
                ),
                // SizedBox(height: 10,),
                ListTile(
                  leading: Icon(Icons.bloodtype,color: AppColors.C_others,size: 25),
                  title: Text(AppText.BP_heading,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    Get.to(() => BloodPressureChartPage(name: widget.name, email : widget.email, profile:widget.profile, noti_count: noti_count,));
                  },
                ),
                // SizedBox(height: 10,),
                ListTile(
                  leading: Icon(Icons.heart_broken,color: AppColors.C_others,size: 25),
                  title: Text(AppText.hr_heading,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    Get.to(() => HeartRateChart(name: widget.name, email : widget.email,profile:widget.profile, noti_count: noti_count));

                  },
                ),
                // SizedBox(height: 10,),
                ListTile(
                  leading: Icon(Icons.show_chart,color: AppColors.C_others,size: 25),
                  title: Text(AppText.stepscount,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    Get.to(() => StepsChartPage(name: widget.name, email : widget.email,profile:widget.profile, noti_count: noti_count));

                  },
                ),
                // SizedBox(height: 10,),
                ListTile(
                  leading: Icon(Icons.nightlight_round,color: AppColors.C_others,size: 25),
                  title: Text(AppText.sleep,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    Get.to(() => SleepChartPage(name: widget.name, email : widget.email,profile:widget.profile, noti_count: noti_count));

                  },
                ),
                ListTile(
                  leading: Image.asset(
                    Appimages.o2_blood,
                    height: 25,
                    width: 25,
                    //color: Color(0xFF254a6c), // Optional: apply color overlay if needed
                  ),
                  title: Text(
                    AppText.spo2_heading,
                    style: Apptextstyle.s14wnco,
                    // style: TextStyle(
                    //   fontFamily: "Inter",
                    //   color: Color(0xFF505970),
                    // ),
                  ),
                  onTap: () {
                    Get.to(() => BloodoxygenPressureChartPage(name: widget.name, email : widget.email,profile:widget.profile, noti_count: noti_count));
                  },
                ),
                // SizedBox(height: 10,),
                ListTile(
                  leading: Icon(Icons.monitor_weight_outlined,color: AppColors.C_others,size: 25),
                  title: Text(AppText.weight_heading,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    Get.to(() => WeightChart(name: widget.name, email : widget.email,profile:widget.profile, noti_count: noti_count));

                  },
                ),
                // SizedBox(height: 10,),
                ListTile(
                  leading: Icon(Icons.notifications,color: AppColors.C_others,size: 25),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppText.notification_heading,
                        style: Apptextstyle.s14wnco,
                      //   style: TextStyle(
                      //     fontFamily: "Inter",
                      //     color: Color(0xFF505970)
                      // ),
                      ),
                      CircleAvatar(radius: 12,
                        backgroundColor: Color(0xFFFF472E),
                        child: Text(widget.noti_count.toString(),style: TextStyle(
                          fontFamily: "Inter",
                          color: Colors.white
                )),)
                    ],
                  ),
                  onTap: (){
                    Get.to(() => Notifications_Screen());

                  },
                ),

                ListTile(
                  leading: Icon(Icons.person_4,color: AppColors.C_others,size: 25),
                  title: Text(AppText.profile,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    Get.to(() => Profile());

                  },
                ),
                ListTile(
                  leading: Icon(Icons.bluetooth_connected,color: AppColors.C_others,size: 25,),
                  title: Text(AppText.unpaired_device,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){
                    //Get.to(() => Bluetoothscreen());
                    _deregisterDevice();
                  },
                ),
                // ListTile(
                //   leading: Icon(Icons.timer,color:Color(0xFF254a6c),size: 25),
                //   title: Text('MinuteData',style: TextStyle(
                //       fontFamily: "Inter",
                //       color: Color(0xFF505970)
                //   ),),
                //  onTap: (){
                //     Get.to(()=>MinuteData());
                //  },
                // ),
                ListTile(
                  leading: Icon(Icons.exit_to_app,color:AppColors.C_others,size: 25),
                  title: Text(AppText.logout,
                    style: Apptextstyle.s14wnco,
                  //   style: TextStyle(
                  //     fontFamily: "Inter",
                  //     color: Color(0xFF505970)
                  // ),
                  ),
                  onTap: (){logoutdialog();},
                ),
              ],
            ),
        ),
         Padding(
           padding: const EdgeInsets.all(20.0),
           child: SingleChildScrollView(
             child: Row(
               children: [
                 widget.profile == null || widget.profile == " " || widget.profile == "None"?
                 GestureDetector(
                   onTap: (){
                     Get.to(()=>Profile());
                   },
                   child: CircleAvatar(
                     backgroundImage: AssetImage(Appimages.profilelogo),
                     radius: 25,
                   ),
                 )
                 : CircleAvatar(
             backgroundImage: NetworkImage(widget.profile),
      radius: 20,
    ),
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Column(
                     mainAxisAlignment: MainAxisAlignment.start,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("${widget.name}",textAlign: TextAlign.left,style: TextStyle(fontFamily: "Inter",),
                       ),
                       Container(
                         width: MediaQuery.of(context).size.width * 0.4, // 40% of the screen width
                         child: Text(
                           "${widget.email}",
                           textAlign: TextAlign.left,
                           style: TextStyle(
                             fontFamily: "Inter",
                            // overflow: TextOverflow.ellipsis, // overflow enabled
                           ),
                         ),
                       )
                     ],
                   ),
                 )
               ],
             ),
           ),
         ),

          // User Profile section at the bottom
        ],
      ),
    );
  }
  Future<void> _deregisterDevice() async {
    setState(() {
      notificationMessage = "Deregistering device...";
    });

    try {
      await platform.invokeMethod('deregisterDevice'); // Call native iOS method
      setState(() {
        notificationMessage = "Device Deregistered Successfully!";
      });

      // Navigate back to pairing screen after deregistering
      Navigator.push(context, MaterialPageRoute(builder: (context) => BluetoothPair()));

    } on PlatformException catch (e) {
      setState(() {
        notificationMessage = "Failed to deregister device: ${e.message}";
      });
    }
  }
  logoutdialog(){
    showDialog(
      context: context,
      builder: (context) {
        String contentText = "Content of Dialog";
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              // title: Text("Title of Dialog"),
              // content: Text(contentText),
              actions: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 300, // Limits width for large screens (e.g., Web)
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.20, // Adjust for responsiveness
                    width: double.infinity, // Will follow maxWidth from BoxConstraints
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                            child: Center(
                              child: Text(
                                "Logout",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Do you want to Logout?",
                                    style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: is_loading
                                  ? const CircularProgressIndicator(color: Colors.red)
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      setState(() {
                                        is_loading = true;
                                      });
                                      logout_api();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.fromLTRB(20, 4, 20, 4),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Logout",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Icon(Icons.logout, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      Get.back();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 5),
                                              Icon(Icons.arrow_right_alt_sharp,
                                                  color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
  Future<void> logout_api() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";
    final String Url = "$root/logout";

    final Map<String, dynamic> userData = {
      'user_id': user_id
    };
    try {
      final response = await http.post(
        Uri.parse(Url),
        body: userData,
      );
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print("logout_api$jsonResponse");

      if (response.statusCode == 200) {

        if (jsonResponse['status'] == "SUCCESS") {
          print(response.body);
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.remove('isLoggedIn');
          Get.to(() => LoginScreen());
          setState(() {
            is_loading = false;
          });
        } else {
          setState(() {
            is_loading = false;
          });
          throw Exception('Failed to load Profile');
        }
      }
    } catch (e) {
      print('Error fetching Profile: $e');
    }
  }
}