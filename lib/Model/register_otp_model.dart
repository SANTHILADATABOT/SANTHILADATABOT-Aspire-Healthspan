//
// // lib/model/user_model.dart
//
// class UserModel {
//   final String userId;
//   final String name;
//   final String mobileNo;
//   final String email;
//   final String profile;
//
//   UserModel({
//     required this.userId,
//     required this.name,
//     required this.mobileNo,
//     required this.email,
//     required this.profile,
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) {
//     return UserModel(
//       userId: json['user_id'].toString(),
//       name: json['name'],
//       mobileNo: json['mobile_no'].toString(),
//       email: json['email'],
//       profile: json['pofile'] ?? '',
//     );
//   }
//
//   Map<String, String> toPrefs() {
//     return {
//       'user_id': userId,
//       'name': name,
//       'mobile_no': mobileNo,
//       'email': email,
//       'pofile': profile,
//     };
//   }
// }
