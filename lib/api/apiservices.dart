import 'package:dashapi/model/datamodel.dart';
import 'package:dashapi/model/loginmodel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class APIService {
  Future<LoginResponseModel> login(LoginRequestModel requestModel) async {
    String url = "https://api-dasher.doordash.com/v2/auth/token/";

    final response = await http.post(url, body: requestModel.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      return LoginResponseModel.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to load data!');
    }
  }

  Future<DataResponseModel> data(LoginRequestModel requestModelData) async {
    String url = "https://api-dasher.doordash.com/v1/dasher/me/dashes";

    final response = await http.post(url, body: requestModelData.toJson());
    if (response.statusCode == 200 || response.statusCode == 400) {
      return DataResponseModel.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to load data!');
    }
  }
}
