
import 'dart:ui';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/Controller/profile_controller.dart';
import 'package:azpire_new/View/edit_profile.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:azpire_new/widgets/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/apptext.dart';

class Profile extends StatefulWidget {

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  var fname;
  var lname;
  var dob;
  var age;
  var sex;
  var height;
  var weight;
  var mobile_no;
  var email;
  var profile_image;
  bool isLoading = true;
  final NotchBottomBarController _controller = NotchBottomBarController(index: 2);
  ProfileController _profilecontroller = ProfileController();
  String? _registeredDevice;
  @override
  void initState() {
    super.initState();
    Profile_Details();
  }

  Future<void> Profile_Details() async {
    await _profilecontroller.Profile_Details((jsonResponse) {
      setState(() {
        fname = jsonResponse['first_name'];
        lname = jsonResponse['last_name'];
        dob = jsonResponse['dob'];
        age = jsonResponse['age'] == "0" ? " " :  jsonResponse['age'];
        sex = jsonResponse['sex'] == "null" ? " " : jsonResponse['sex'];
        height = jsonResponse['height'];
        weight = jsonResponse['weight'];
        mobile_no = jsonResponse['mobile_no'];
        email = jsonResponse['email'];
        profile_image = jsonResponse['pofile_image'];
        print("profile_image$profile_image");
        isLoading = false;
      });
    });
  }


  showdialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          Center(
            child:profile_image == null || profile_image == " " || profile_image == "None" ?
            CircleAvatar(
              backgroundImage: AssetImage(Appimages.profilelogo),
              radius: 100,
            ) :
            CircleAvatar(
              backgroundImage: NetworkImage(profile_image),
              radius: 100,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        Get.to(() => DashboardScreen(deviceID: _registeredDevice!));
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFffffff),
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppText.profile,
                style: Apptextstyle.s17wbcapp_b
              ),
              TextButton(
                onPressed: () { Get.to(() => EditProfile()); }, child: Text( 'Edit',
                style: TextStyle(
                  color: Color(0xFF0D37CD),
                  fontSize: 17,
                ),),
              ),
            ],
          ),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.to(() => DashboardScreen(deviceID:_registeredDevice ?? ''));

            },
          ),
        ),
        body: isLoading ? buildShimmer() : buildProfileDetails(context),
          bottomNavigationBar: CustomBottomNavBar(controller: _controller)
      ),
    );
  }

  Widget buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.white,
              ),
            ),
            Container(
              height: 450,
              width: double.infinity,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Container(
                          height: 20,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 20,
                          color: Colors.white,
                        ),
                        Divider(),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileDetails(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  showdialog(context);
                },
                child:
                profile_image == null || profile_image == " " || profile_image == "None"?
                CircleAvatar(
                  backgroundImage: AssetImage(Appimages.profilelogo),
                  radius: 55,
                ) :
                CircleAvatar(
                  backgroundImage: NetworkImage(profile_image),
                  radius: 55,
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
            decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffbae9f7), Color(0xffbcf5e6)],
          ),
        ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    profilelist(AppText.FName, fname),
                    profilelist(AppText.LName, lname),
                    profilelist(AppText.DOB, dob),
                    profilelist(AppText.age, age),
                    profilelist(AppText.sex, sex),
                    profilelist(AppText.height, height),
                    profilelist(AppText.weightkg, weight),
                    profilelist(AppText.mobno, mobile_no),
                    profilelist(AppText.email, email),
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget profilelist(String title, String? value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
              ),
              Container(
                width: 180,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    value ?? '',
                    style: TextStyle(fontWeight: FontWeight.w400,fontSize: 15,color: Colors.grey.shade700,),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider()
      ],
    );
  }
}
