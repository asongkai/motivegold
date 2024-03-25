import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motivegold/model/gold_data.dart';
import 'package:motivegold/model/response.dart';
import '../utils/constants.dart';
import '../utils/util.dart';

String makeAuth() {
  String username = 'root';
  String password = 't00r';
  return
      'Basic ${base64.encode(utf8.encode('$username:$password'))}';
}

class ApiServices {
  static Map<String, String> headers = {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
    'authorization': makeAuth()
  };

  static Future<dynamic>? get(String url) {
    // TODO: implement post
    try {
      return http.get(Uri.parse(Constants.BACKEND_URL + url), headers: headers).then((response) {
        print(response.body);
        if (response.statusCode == 200) {
          return response.body;
        } else {
          throw Future.error('error${response.body}');
        }
      });
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  static Future<Response>? post(String url, dynamic data) {
    try {
      return http.post(Uri.parse(Constants.BACKEND_URL + url), headers: headers, body: data).then((response) {
        // print(response.body);
        if (response.statusCode == 200) {
          // print(response.body);
          return Response.fromJson(jsonDecode(response.body));
        } else {
          throw Future.error('error${response.body}');
        }
      });
    } catch (e) {
      print(url + e.toString());
    }
    return null;
  }

  Future<GoldDataModel?> getGoldPrice(BuildContext context) async {
    print(headers);
    if (await Utils.checkConnection()) {
      return http.post(
        Uri.parse('${Constants.BACKEND_URL}/gold/price'),
        headers: headers,
      ).then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;
        print(res);
        if (statusCode < 200 || statusCode > 400) {
          Exception("Error while fetching data");
          return null;
        } else {
          final parsed = json.decode(res)['data'];
          return GoldDataModel.fromJson(parsed);
        }
      });
    } else {
      Utils.showAlert(context, "Flutter", "Internet is not connected.", () {
        Navigator.pop(context);
      }, true);
      return null;
    }
  }
}
