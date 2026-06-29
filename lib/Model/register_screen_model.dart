
import 'dart:convert';

class RegisterModel {
  final String username;
  final String email;
  final String mobileNumber;

  RegisterModel({
    required this.username,
    required this.email,
    required this.mobileNumber,
  });

  Map<String, String> toJson() {
    return {
      'username': username.trim(),
      'mobile_no': mobileNumber.trim(),
      'email': email.trim(),
    };
  }

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      username: json['username'],
      email: json['email'],
      mobileNumber: json['mobile_no'],
    );
  }
}

class RegisterResponse {
  final String status;
  final String? message;
  final dynamic data;

  RegisterResponse({
    required this.status,
    this.message,
    this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'],
    );
  }
}
