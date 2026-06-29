
import 'dart:convert';
import '../root/root.dart';
import 'package:http/http.dart' as http;

class NotificationsController {

   Future<String?> getNotificationCount(String userId) async {
     final String url = "$root/notification_count";
     final Map<String, dynamic> userData = {'user_id': userId};

     try {
       final response = await http.post(Uri.parse(url), body: userData);

       if (response.statusCode == 200) {
         final Map<String, dynamic> jsonResponse = json.decode(response.body);
         if (jsonResponse['status'] == "SUCCESS") {
           return jsonResponse['notification_count'].toString();
         }
       }
       return "0"; // Default value if request fails
     } catch (e) {
       print('Error fetching notification count: $e');
       return "0"; // Default value on error
     }
   }
 }