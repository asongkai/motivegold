import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:motivegold/model/gold_data.dart';
import 'package:motivegold/model/response.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/util.dart';

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

  static Future<Response>? get(String url) {
    try {
      return http.get(Uri.parse(Constants.BACKEND_URL + url), headers: headers).then((response) {
        // print(response.body);
        if (response.statusCode == 200) {
          return Response.fromJson(jsonDecode(response.body));
        } else {
          return Response(status: 'failed', message: response.body, data: null);
        }
      });
    } catch (e) {
      motivePrint(e.toString());
    }
    return null;
  }


  static Future<Response>? post(String url, dynamic data) {
    try {
      motivePrint(Constants.BACKEND_URL + url);
      return http.post(Uri.parse(Constants.BACKEND_URL + url), headers: headers, body: data).then((response) {
        // motivePrint(response.body);
        if (response.statusCode == 200) {
          // print(response.body);
          return Response.fromJson(jsonDecode(response.body));
        } else {
          return Response(data: response.body, status: "failed");
        }
      });
    } catch (e) {
      motivePrint(url + e.toString());
    }
    return null;
  }

  static Future<Response>? put(String url, dynamic id, dynamic data) {
    try {
      return http.put(Uri.parse('${Constants.BACKEND_URL}$url/$id'), headers: headers, body: data).then((response) {
        // print(response.body);
        if (response.statusCode == 200) {
          // print(response.body);
          return Response.fromJson(jsonDecode(response.body));
        } else {
          return Response(status: 'failed', message: response.body, data: null);
        }
      });
    } catch (e) {
      print(url + e.toString());
    }
    return null;
  }

  static Future<Response>? delete(String url, dynamic data, {Map<String, dynamic>? queryParams}) {
    try {
      // Build URI with query parameters
      String baseUrl = '${Constants.BACKEND_URL}$url/$data';
      Uri uri;

      if (queryParams != null && queryParams.isNotEmpty) {
        // Convert all query param values to strings and filter out nulls
        Map<String, String> stringParams = {};
        queryParams.forEach((key, value) {
          if (value != null) {
            stringParams[key] = value.toString();
          }
        });
        uri = Uri.parse(baseUrl).replace(queryParameters: stringParams);
      } else {
        uri = Uri.parse(baseUrl);
      }

      return http.delete(uri, headers: headers).then((response) {
        // print(response.body);
        if (response.statusCode == 200) {
          // print(response.body);
          return Response.fromJson(jsonDecode(response.body));
        } else {
          return Response(status: 'failed', message: response.body, data: null);
        }
      });
    } catch (e) {
      motivePrint(url + e.toString());
    }
    return null;
  }

  Future<GoldDataModel?> getGoldPrice(BuildContext context) async {
    // print(headers);
    if (await Utils.checkConnection()) {
      return http.get(
        Uri.parse('${Constants.BACKEND_URL}/price'),
        headers: headers,
      ).then((http.Response response) {
        final String res = response.body;
        final int statusCode = response.statusCode;
        // print(res);
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

  // Customer Reference Data API Methods

  /// Get all nationalities
  static Future<Response>? getNationalities() {
    return post('/nationality/all', jsonEncode({})); // Fixed: removed /api/ prefix
  }

  /// Get all occupations
  static Future<Response>? getOccupations() {
    return post('/occupation/all', jsonEncode({}));
  }

  /// Get occupations by category
  static Future<Response>? getOccupationsByCategory(String category) {
    return post('/occupation/byCategory', jsonEncode({'data': category}));
  }

  /// Get all title names
  static Future<Response>? getTitleNames() {
    return post('/titlename/all', jsonEncode({}));
  }

  /// Get title names by nationality
  static Future<Response>? getTitleNamesByNationality(String nationality) {
    return post('/titlename/byNationality', jsonEncode({'data': nationality}));
  }

  /// Get all card types
  static Future<Response>? getCardTypes() {
    return post('/cardtype/all', jsonEncode({}));
  }
}
