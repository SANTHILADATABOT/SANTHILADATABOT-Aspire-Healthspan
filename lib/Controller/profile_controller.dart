
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../root/root.dart';

class ProfileController {

  Future<void> Profile_Details(Function setStateCallback) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String Url = "$root/get_user_profile";

    final Map<String, dynamic> userData = {
      'user_id': '102'
    };

    try {
      final response = await http.post(
        Uri.parse(Url),
        body: userData,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "SUCCESS") {
          setStateCallback(jsonResponse);
        } else {
          throw Exception('Failed to load Profile');
        }
      }
    } catch (e) {
      print('Error fetching Profile: $e');
    }
  }
}
