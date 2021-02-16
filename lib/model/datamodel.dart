class DataResponseModel {
  final String token;
  final String error;

  DataResponseModel({this.token, this.error});

  factory DataResponseModel.fromJson(Map<String, dynamic> json) {
    return DataResponseModel(
      token: json["token"] != null ? json["token"] : "",
      error: json["error"] != null ? json["error"] : "",
    );
  }
}

class DataRequestModel {
  String email;
  String password;

  DataRequestModel({
    this.email,
    this.password,
  });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'Authorization': email.trim(),
      'password': password.trim(),
    };

    return map;
  }
}
