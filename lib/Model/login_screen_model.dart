
class LoginModel {
  final String status;
  final LoginData data;

  LoginModel({required this.status, required this.data});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'],
      data: LoginData.fromJson(json['data']),
    );
  }
}

class LoginData {
  final String mobileOtp;
  final String user;
  final String mobileNo;

  LoginData({
    required this.mobileOtp,
    required this.user,
    required this.mobileNo,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      mobileOtp: json['mobile_otp'].toString(),
      user: json['user'].toString(),
      mobileNo: json['mobile_no'].toString(),
    );
  }
}
