

import 'dart:convert';
import 'dart:io';
import 'package:aspire/View/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:oktoast/oktoast.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:fluttertoast/fluttertoast.dart';
import '../../root/root.dart';

class EditProfileController {

  Future<void> Profile_Details({
    required Function(void Function()) setState,
    required void Function(String?) updateFname,
    required void Function(String?) updateLname,
    required void Function(String?) updateDob,
    required void Function(String?) updateAge,
    required void Function(String?) updateSex,
    required void Function(String?) updateHeight,
    required void Function(String?) updateWeight,
    required void Function(String?) updateMobile,
    required void Function(String?) updateEmail,
    required void Function(String?) updateProfileImage,
    required void Function(bool) setLoading,
    required TextEditingController fnamecontroller,
    required TextEditingController lnamecontroller,
    required TextEditingController monthController,
    required TextEditingController dayController,
    required TextEditingController yearController,
    required TextEditingController heightController,
    required TextEditingController weightController,
    required TextEditingController mobnumController,
    required TextEditingController mailController,
    required void Function(int) updateGroupValue,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String Url = "$root/get_user_profile";
    var user_id = prefs.getString('user_id') ?? "";
    final Map<String, dynamic> userData = {
      'user_id': user_id
    };
    try {
      final response = await http.post(
        Uri.parse(Url),
        body: userData,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "SUCCESS") {
          print(response.body);
          setState(() {
            String? fname = jsonResponse['first_name'];
            String? lname = jsonResponse['last_name'];
            String? dob = jsonResponse['dob'];
            String? age = jsonResponse['age'];
            String? sex = jsonResponse['sex'];
            String? height = jsonResponse['height'];
            String? weight = jsonResponse['weight'];
            String? mobile_no = jsonResponse['mobile_no'];
            String? email = jsonResponse['email'];
            String? profile_image = jsonResponse['pofile_image'];

            updateFname(fname);
            updateLname(lname);
            updateDob(dob);
            updateAge(age);
            updateSex(sex);
            updateHeight(height);
            updateWeight(weight);
            updateMobile(mobile_no);
            updateEmail(email);
            updateProfileImage(profile_image);
            setLoading(false);

            fnamecontroller.text = fname ?? " ";
            lnamecontroller.text = lname ?? " ";

            if (dob != null && dob.isNotEmpty) {
              List<String> dateParts = dob.split(' ');
              if (dateParts.length == 3) {
                monthController.text = dateParts[0];
                dayController.text = dateParts[1].replaceAll(',', '');
                yearController.text = dateParts[2];
              } else {
                monthController.text = '';
                dayController.text = '';
                yearController.text = '';
              }
            } else {
              monthController.text = '';
              dayController.text = '';
              yearController.text = '';
            }

            int groupValue = 0;
            if (sex == "Female") groupValue = 2;
            else if (sex == "Male") groupValue = 1;
            else if (sex == "Others") groupValue = 3;
            updateGroupValue(groupValue);

            heightController.text = height ?? " ";
            weightController.text = weight ?? " ";
            mobnumController.text = mobile_no ?? " ";
            mailController.text = email ?? " ";
          });
        } else {
          throw Exception('Failed to load Profile');
        }
      }
    } catch (e) {
      print('Error fetching Profile: $e');
    }
  }

  //editdata API
  Future<void> editTheData(
      BuildContext context, {
        required TextEditingController fnamecontroller,
        required TextEditingController lnamecontroller,
        required TextEditingController monthController,
        required TextEditingController dayController,
        required TextEditingController yearController,
        required int? groupValue,
        required TextEditingController heightController,
        required TextEditingController weightController,
        required TextEditingController mobnumController,
        required TextEditingController mailController,
        required File? shopImage,
        required void Function(String) showToast,
      }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? "";

    print("User ID: $user_id");
    print("First Name: ${fnamecontroller.text}");
    print("Last Name: ${lnamecontroller.text}");
    print("DOB: ${monthController.text} ${dayController.text}, ${yearController.text}");
    print("Sex: ${groupValue == 1 ? "Male" : groupValue == 2 ? "Female" : groupValue == 3 ? "Others" : "null"}");
    print("Height: ${heightController.text}");
    print("Weight: ${weightController.text}");
    print("Mobile Number: ${mobnumController.text}");
    print("Email: ${mailController.text}");

    File? imageFile;
    if (shopImage != null) {
      imageFile = File(shopImage.path);
    }

    String formattedDob = '${monthController.text} ${dayController.text}, ${yearController.text}';

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$root/edit_profile'),
      );

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_image',
            imageFile.path,
            filename: 'image.jpg',
          ),
        );
      }

      request.fields['user_id'] = user_id;
      request.fields['first_name'] = fnamecontroller.text;
      request.fields['last_name'] = lnamecontroller.text;
      request.fields['dob'] = formattedDob;
      request.fields['sex'] = groupValue == 1 ? "Male" : groupValue == 2 ? "Female" : groupValue == 3 ? "Others" : "null";
      request.fields['height'] = heightController.text;
      request.fields['weight'] = weightController.text;
      request.fields['mobile_no'] = mobnumController.text;
      request.fields['email'] = mailController.text;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          print('Response data: $data');

          if (data['status'] == 'SUCCESS') {
            debugPrint('Profile updated successfully: $data');
            showToast('Profile Updated Successfully');
            Get.to(() => Profile());
          } else {
            print('API response status: ${data['status']}');
            showToast('Failed to update profile. Please try again.');
          }
        } catch (jsonError) {
          print('JSON decoding error: $jsonError');
          showToast('Error processing server response.');
        }
      } else {
        print('Non-200 status code: ${response.statusCode}');
        showToast('Failed to update profile. Server error.');
      }
    } catch (e) {
      print('Failed to edit the data. Error: $e');
      showToast('Failed to connect. Please try again later.');
    }
  }


}

void showCustomToast(String msg) {
  showToast(
    msg,
    duration: Duration(seconds: 2),
    position: kIsWeb ? ToastPosition.top : ToastPosition.bottom,
    backgroundColor: Colors.black,
    radius: 8.0,
    textPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
    textStyle: TextStyle(
      fontSize: 16.0,
      color: Colors.white,
    ),
    textAlign: TextAlign.center,
    animationCurve: kIsWeb ? Curves.easeInOut : Curves.easeIn,
    animationDuration: const Duration(milliseconds: 400),
    animationBuilder: kIsWeb ? _slideFromRight : null,
  );
}

Widget _slideFromRight(
    BuildContext context,
    Widget child,
    AnimationController controller,
    double percent,
    ) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset(1.2, 0.0), // start from right off-screen
      end: Offset(0.0, 0.0),   // slide to original position
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    )),
    child: child,
  );
}


// showToast(String msg) {
//   Fluttertoast.showToast(
//     msg: msg,
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.BOTTOM,
//     timeInSecForIosWeb: 1,
//     backgroundColor: Colors.black,
//     textColor: Colors.white,
//     fontSize: 16.0,
//   );
// }



