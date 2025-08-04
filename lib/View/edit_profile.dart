
import 'dart:io';
import 'dart:ui';
import 'package:azpire_new/Controller/editprofile_controller.dart';
import 'package:azpire_new/View/edit_emai.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/utils/app_color.dart';
import 'package:azpire_new/utils/appimages.dart';
import 'package:azpire_new/utils/apptextstyle.dart';
import 'package:easy_radio/easy_radio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/apptext.dart';
import 'edit phone number.dart';
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb


class EditProfile extends StatefulWidget {
  @override
  State<EditProfile> createState() => _EditProfileState();
}
class _EditProfileState extends State<EditProfile> {
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
  bool isLoading_1 = false;
  String selectedDate = "Select Date";
  TextEditingController fnamecontroller = TextEditingController();
  TextEditingController lnamecontroller = TextEditingController();
  TextEditingController monthController = TextEditingController();
  TextEditingController dayController = TextEditingController();
  TextEditingController yearController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController mobnumController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  int? _groupValue = 0;
  File? shopImage;

  final EditProfileController _profilecontroller = EditProfileController();

  @override
  void initState() {
    super.initState();
    Profile_Details();
  }

  Future<void> Profile_Details() async {
    await _profilecontroller.Profile_Details(
      setState: setState,
      updateFname: (val) => fname = val,
      updateLname: (val) => lname = val,
      updateDob: (val) => dob = val,
      updateAge: (val) => age = val,
      updateSex: (val) => sex = val,
      updateHeight: (val) => height = val,
      updateWeight: (val) => weight = val,
      updateMobile: (val) => mobile_no = val,
      updateEmail: (val) => email = val,
      updateProfileImage: (val) => profile_image = val,
      setLoading: (val) => isLoading = val,
      fnamecontroller: fnamecontroller,
      lnamecontroller: lnamecontroller,
      monthController: monthController,
      dayController: dayController,
      yearController: yearController,
      heightController: heightController,
      weightController: weightController,
      mobnumController: mobnumController,
      mailController: mailController,
      updateGroupValue: (val) => _groupValue = val,
    );
  }

  // Future<void> Profile_Details() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //  // var user_id = prefs.getString('user_id');
  //   final String Url = "$root/get_user_profile";
  //   final Map<String, dynamic> userData = {
  //     'user_id': '102'
  //   };
  //   try {
  //     final response = await http.post(
  //       Uri.parse(Url),
  //       body: userData,
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       if (jsonResponse['status'] == "SUCCESS") {
  //         print(response.body);
  //         setState(() {
  //           fname = jsonResponse['first_name'];
  //           lname = jsonResponse['last_name'];
  //           dob = jsonResponse['dob'];
  //           age = jsonResponse['age'];
  //           sex = jsonResponse['sex'];
  //           height = jsonResponse['height'];
  //           weight = jsonResponse['weight'];
  //           mobile_no = jsonResponse['mobile_no'];
  //           email = jsonResponse['email'];
  //           profile_image = jsonResponse['pofile_image'];
  //           isLoading = false;
  //           fnamecontroller.text = fname ?? " ";
  //           lnamecontroller.text = lname ?? " ";
  //           List<String> dateParts = dob.split(' ');
  //           if (dob != null && dob.isNotEmpty) {
  //             List<String> dateParts = dob.split(' ');
  //             if (dateParts.length == 3) {
  //               monthController.text = dateParts[0];
  //               dayController.text = dateParts[1].replaceAll(',', '');
  //               yearController.text = dateParts[2];
  //             } else {
  //               monthController.text = '';
  //               dayController.text = '';
  //               yearController.text = '';
  //             }
  //           } else {
  //             monthController.text = '';
  //             dayController.text = '';
  //             yearController.text = '';
  //           }
  //
  //           sex == "Female" ? _groupValue = 2 : sex == "Male"
  //               ? _groupValue = 1
  //               : sex == "Others" ? _groupValue = 3 : _groupValue = 0;
  //           heightController.text = height ?? " ";
  //           weightController.text = weight ?? " ";
  //           mobnumController.text = mobile_no ?? " ";
  //           mailController.text = email ?? " ";
  //         });
  //       } else {
  //         throw Exception('Failed to load Profile');
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching Profile: $e');
  //   }
  // }

  @override
  void dispose() {
    fnamecontroller.dispose();
    lnamecontroller.dispose();
    monthController.dispose();
    dayController.dispose();
    yearController.dispose();
    heightController.dispose();
    weightController.dispose();
    mobnumController.dispose();
    mailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return WillPopScope(
      onWillPop: () async {
        Get.to(() => Profile());
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFffffff),
        appBar: AppBar(
          title: Text(
              AppText.editprofile,
              style: Apptextstyle.s18wbap
          ),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Get.to(() => Profile());
            },
          ),
        ),
        body: isLoading ? buildShimmer() : buildProfileDetails(context),
      ),
    );
  }

  Widget buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
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
    );
  }

  void _showRoundedDatePicker() async {
    DateTime? newDateTime = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: Colors.pink, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor: Colors.white,
            // background color of the dialog
            textTheme: TextTheme(
              bodyMedium: TextStyle(color: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (newDateTime != null) {
      setState(() {
        monthController.text = DateFormat('MMM').format(newDateTime);
        dayController.text = DateFormat('dd').format(newDateTime);
        yearController.text = DateFormat('yyyy').format(newDateTime);
      });
    }
  }

  Future<void> show_dialogue() async {
    var cameraStatus = await Permission.camera.status;
    var photoStatus = await Permission.photos.status;

    // Request permission if denied
    if (cameraStatus.isDenied || photoStatus.isDenied) {
      await [Permission.camera, Permission.photos].request();
    }

    // Check for permanently denied permissions
    if (cameraStatus.isPermanentlyDenied || photoStatus.isPermanentlyDenied) {
      openAppSettings();
      return;
    }

    // Check if permissions are granted
    if (await Permission.camera.isGranted &&
        await Permission.photos.isGranted) {
      showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
              title: Text(
                AppText.choosewith,
                style: Apptextstyle.s16wbcB
              ),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        await _handleImageSelectiongallery();
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Color(0xff275176),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Center(
                          child: Text(
                            AppText.gallery,
                            style: Apptextstyle.s16wbcW
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        await _handleImageSelectioncamera();
                        Navigator.of(context, rootNavigator: true).pop();
                      },
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                          color: Color(0xff275176),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Center(
                          child: Text(
                            AppText.camera,
                            style: Apptextstyle.s16wbcW
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    }
  }

  _handleImageSelectiongallery() async {
    var result;
    print('photo-------');
    result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );
    setState(() {
      shopImage = result != null ? File(result.path) : null;
    });
  }

  _handleImageSelectioncamera() async {
    var result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.camera, // Make sure this is set to camera
    );
    setState(() {
      shopImage = result != null ? File(result.path) : null;
    });
  }

  Widget buildProfileDetails(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: InkWell(
                onTap: () {
                  show_dialogue();
                },
                child: Stack(
                  children: [
                    profile_image == null || profile_image == " " ||
                        profile_image == "None"
                        ? CircleAvatar(
                      backgroundImage: shopImage == null ? AssetImage(
                          Appimages.profilelogo) : FileImage(
                          shopImage!) as ImageProvider,
                      radius: 60,
                    )
                        :
                    CircleAvatar(
                      backgroundImage: shopImage == null ? NetworkImage(
                          profile_image) : FileImage(
                          shopImage!) as ImageProvider,
                      radius: 60,
                    ),
                    Positioned(
                      top: 90,
                      left: 85,
                      child: Icon(Icons.linked_camera_sharp, size: 18,
                          color: Color(0xFF5F6368)),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: fnamecontroller,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "First Name",
                      focusColor: Color(0xFF275176),
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: lnamecontroller,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Last Name",
                      focusColor: Color(0xFF275176),
                      hintStyle: TextStyle(
                          color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(AppText.bday),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          onTap: () {
                            _showRoundedDatePicker();
                          },
                          controller: monthController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Month",
                            focusColor: Color(0xFF275176),
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          onTap: () {
                            _showRoundedDatePicker();
                          },
                          controller: dayController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Day",
                            focusColor: Color(0xFF275176),
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: TextFormField(
                          onTap: () {
                            _showRoundedDatePicker();
                          },
                          controller: yearController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Year",
                            focusColor: Color(0xFF275176),
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Text(AppText.Esex),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          EasyRadio<int>(
                            value: 1,
                            groupValue: _groupValue,
                            onChanged: (value) {
                              setState(() {
                                _groupValue = value;
                              });
                            },
                          ),
                          SizedBox(width: 10,),
                          Text(AppText.Emale, style: TextStyle(fontSize: 16,
                              color: _groupValue == 1
                                  ? Color(0xFF365c7f)
                                  : Colors.grey.shade400),)
                        ],
                      ),
                      Row(
                        children: [
                          EasyRadio<int>(
                            value: 2,
                            groupValue: _groupValue,
                            onChanged: (value) {
                              setState(() {
                                _groupValue = value;
                              });
                            },
                          ),
                          SizedBox(width: 10,),
                          Text(AppText.Efemale, style: TextStyle(fontSize: 16,
                              color: _groupValue == 2
                                  ? Color(0xFF365c7f)
                                  : Colors.grey.shade400))
                        ],
                      ),
                      Row(
                        children: [
                          EasyRadio<int>(
                            value: 3,
                            groupValue: _groupValue,
                            onChanged: (value) {
                              setState(() {
                                _groupValue = value;
                              });
                            },
                          ),
                          SizedBox(width: 10,),
                          Text(AppText.Eothers, style: TextStyle(fontSize: 16,
                              color: _groupValue == 3
                                  ? Color(0xFF365c7f)
                                  : Colors.grey.shade400))
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.3,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: heightController,
                          decoration: InputDecoration(
                            hintText: "Height (ft/in)",
                            focusColor: Color(0xFF275176),
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      ),
                      SizedBox(width: 30),
                      Container(
                        width: size.width * 0.3,
                        child: TextFormField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "weight (lbs)",
                            focusColor: Color(0xFF275176),
                            hintStyle: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          readOnly: true,
                          controller: mobnumController,
                          keyboardType: TextInputType.phone,

                          decoration: InputDecoration(

                              hintText: "Mobile Number",
                              // focusColor: Color(0xFF275176),
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 14),
                              suffixIcon: IconButton(onPressed: () async{
                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                var user_id = prefs.getString('user_id') ?? "";
                                Get.to(() =>
                                    edit_phone_number(
                                        mobnum: mobnumController.text,
                                        user_id: user_id));
                              },
                                icon: Icon(Icons.edit),
                                color: Colors.grey.shade400,)
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        // height: 50,
                        // width: size.width*0.6,
                        child: TextFormField(
                          readOnly: true,
                          controller: mailController,
                          keyboardType: TextInputType.emailAddress,
                          maxLines: 2,
                          minLines: 1,
                          decoration: InputDecoration(
                              hintText: "E-mail ID",
                              focusColor: Color(0xFF275176),
                              hintStyle: TextStyle(
                                  color: Colors.grey.shade500, fontSize: 14),
                              suffixIcon: IconButton(onPressed: () async{
                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                var user_id = prefs.getString('user_id') ?? "";
                                Get.to(() =>
                                    edit_email(email_id: mailController.text,
                                        user_id: user_id));
                              },
                                icon: Icon(Icons.edit),
                                color: Colors.grey.shade400,)
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: InkWell(
                      onTap: () {
                        validate();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                            gradient: AppColors.button
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(30, 8, 30, 8),
                          child: Text(
                            AppText.Ebtn,
                            style: Apptextstyle.s20wbcW
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  validate() {
    if (monthController.text.isEmpty)
      showToast("Kindly Select Date");
    else
      editTheData(context);
  }

  // Future<void> editTheData(BuildContext context) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   var user_id = prefs.getString('user_id') ?? ""; // Replace with actual user_id
  //
  //   // Display the form data in debug logs
  //   print("User ID: $user_id");
  //   print("First Name: ${fnamecontroller.text}");
  //   print("Last Name: ${lnamecontroller.text}");
  //   print("DOB: ${monthController.text} ${dayController.text}, ${yearController.text}");
  //   print("Sex: ${_groupValue == 1 ? "Male" : _groupValue == 2 ? "Female" : _groupValue == 3 ? "Others" : "null"}");
  //   print("Height: ${heightController.text}");
  //   print("Weight: ${weightController.text}");
  //   print("Mobile Number: ${mobnumController.text}");
  //   print("Email: ${mailController.text}");
  //
  //   File? imageFile;
  //   if (shopImage != null) {
  //     imageFile = File(shopImage!.path);
  //   }
  //   String formattedDob = '${monthController.text} ${dayController.text}, ${yearController.text}';
  //
  //   try {
  //     var request = http.MultipartRequest(
  //       'POST',
  //       Uri.parse('$root/edit_profile'),
  //     );
  //
  //     if (imageFile != null) {
  //       request.files.add(
  //         await http.MultipartFile.fromPath(
  //           'profile_image',
  //           imageFile.path,
  //           filename: 'image.jpg',
  //         ),
  //       );
  //     }
  //
  //     // Add request fields
  //     request.fields['user_id'] = user_id;
  //     request.fields['first_name'] = fnamecontroller.text;
  //     request.fields['last_name'] = lnamecontroller.text;
  //     request.fields['dob'] = formattedDob;
  //     request.fields['sex'] = _groupValue == 1 ? "Male" : _groupValue == 2 ? "Female" : _groupValue == 3 ? "Others" : "null";
  //     request.fields['height'] = heightController.text;
  //     request.fields['weight'] = weightController.text;
  //     request.fields['mobile_no'] = mobnumController.text;
  //     request.fields['email'] = mailController.text;
  //
  //     final streamedResponse = await request.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //
  //     // Check the response code
  //     print('Response status code: ${response.statusCode}');
  //     if (response.statusCode == 200) {
  //       try {
  //         final data = json.decode(response.body);
  //         print('Response data: $data');
  //
  //         if (data['status'] == 'SUCCESS') {
  //           debugPrint('Profile updated successfully: $data');
  //           showToast('Profile Updated Successfully');
  //           Get.to(() => Profile());
  //         } else {
  //           // Handle other statuses returned by the API
  //           print('API response status: ${data['status']}');
  //           showToast('Failed to update profile. Please try again.');
  //         }
  //       } catch (jsonError) {
  //         print('JSON decoding error: $jsonError');
  //         showToast('Error processing server response.');
  //       }
  //     } else {
  //       print('Non-200 status code: ${response.statusCode}');
  //       showToast('Failed to update profile. Server error.');
  //     }
  //   } catch (e) {
  //     print('Failed to edit the data. Error: $e');
  //     showToast('Failed to connect. Please try again later.');
  //   }
  // }

  Future<void> editTheData(BuildContext context) async {
    _profilecontroller.editTheData(
      context,
      fnamecontroller: fnamecontroller,
      lnamecontroller: lnamecontroller,
      monthController: monthController,
      dayController: dayController,
      yearController: yearController,
      groupValue: _groupValue,
      heightController: heightController,
      weightController: weightController,
      mobnumController: mobnumController,
      mailController: mailController,
      shopImage: shopImage,
      showToast: showToast,
    );
  }

}
