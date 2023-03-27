import 'dart:convert';
// import 'package:flutter/material.dart';
import 'package:simple_azaan/http_request.dart';
import 'package:http/http.dart' as http;

class AlAdhanApi {
  HttpRequest web = HttpRequest();

  AlAdhanApi({
    this.city,
    this.state,
    this.country = "United States",
    this.method = "2",
  });
  final city;
  final state;
  final country;
  final method;

  static const String apiUrl = 'http://api.aladhan.com/v1/';

  static const timingsByCity = 'timingsByCity?';

  _get(url, params) async {
    var headers = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };

    return _responseJson(await web.getRequest(url + params, headers));
  }

  _responseJson(http.Response response) {
    // print(response.statusCode);

    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body.toString());
      default:
        throw Exception('Error ${response.statusCode}:\n${response.body}');
    }
  }

  getPrayerTimeToday() async {
    var params =
        'city=$city&state=$state&country=$country&method=$method&iso8601=true';
    return await _get(apiUrl + timingsByCity, params);
  }
}
