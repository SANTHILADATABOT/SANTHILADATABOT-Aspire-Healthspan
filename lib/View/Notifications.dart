import 'dart:convert';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:azpire_new/View/Dashboard_screen.dart';
import 'package:azpire_new/View/profile.dart';
import 'package:azpire_new/root/root.dart';
import 'package:azpire_new/widgets/CustomBottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class Notifications_Screen extends StatefulWidget {
  Notifications_Screen({super.key});

  @override
  State<Notifications_Screen> createState() => _Notifications_ScreenState();
}

class _Notifications_ScreenState extends State<Notifications_Screen> {
  List<Map<String, String>> notificationsList = [];
bool is_loading = false;
  String? _registeredDevice;
  final NotchBottomBarController _controller = NotchBottomBarController(index: 1);
  @override
  void initState() {
    super.initState();
    notifications();
  }

  Future<void> notifications() async {
    setState(() {
      is_loading = true;
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var user_id = prefs.getString('user_id') ?? '102';
    final String Url = "$root/get_notification";

    final Map<String, dynamic> userData = {
      'user_id': "102",
    };
    try {
      final response = await http.post(
        Uri.parse(Url),
        body: userData,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == "SUCCESS") {
          notificationsList.clear(); // Clear the list before adding new data
          for (var data in jsonResponse['final_message']) {
            // Parse the date and format it
            String formattedDate = _formatDate(data["date"]);
            notificationsList.add({
              "date": formattedDate,
              "category": data["category"],
              "message": data["message"],
            });
          }
          setState(() {
            is_loading = false;
          });
        } else {
          setState(() {
            is_loading = false;
          });
          throw Exception('Failed to load notifications');
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy hh:mm a').format(parsedDate);
    } catch (e) {
      print('Error formatting date: $e');
      return dateString; // Return the original date string if parsing fails
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.to(() => DashboardScreen(deviceID:_registeredDevice!));
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFffffff),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Notifications',
            style: TextStyle(
              color: Color(0xFF365c7f),
              fontSize: 17,
            ),
          ),
          backgroundColor: Color(0xFFffffff),
          leading: IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              Get.to(() => DashboardScreen(deviceID: _registeredDevice ?? ''));
            },
          ),
        ),
        body:
        notificationsList.isEmpty
            // ? Center(child: Text("No Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18),))
            // :
        // is_loading == false ?
              ? _buildShimmerEffect() :
        notificationsList.isEmpty ? Center(child: Text("No Notifications", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold,fontSize: 18),)):
      ListView.builder(
          itemCount: notificationsList.length,
          itemBuilder: (context, index) {
            return Card(
              color: Colors.white,
              elevation: 4,
              margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      notificationsList[index]['category']!,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF365c7f),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      notificationsList[index]['message']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 5),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        notificationsList[index]['date']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: CustomBottomNavBar(controller: _controller)
      ),
    );
  }
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(

      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 5, // Adjust this count as necessary
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
}
