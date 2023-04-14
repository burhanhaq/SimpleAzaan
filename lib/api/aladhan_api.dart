import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:simple_azaan/service/http_request.dart';
import 'package:http/http.dart' as http;

class AlAdhanApi {
  HttpRequest web = HttpRequest();

  AlAdhanApi({
    this.city,
    this.state,
    this.country = "United States",
    this.method = "2",
  });
  final String? city;
  final String? state;
  final String? country;
  final String? method;

  static const String apiUrl = 'http://api.aladhan.com/v1';

  static const timingsByCity = '/timingsByCity';

  _get(url, params) async {
    var headers = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
    };

    return _responseJson(await web.getRequest(url + params, headers));
  }

  _responseJson(http.Response response) {
    // print(response.body);

    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body.toString());
      default:
        throw Exception('Error ${response.statusCode}:\n${response.body}');
    }
  }

  getParams() {
    var params = "";
    params += 'iso8601=true';
    params += city == null ? '' : '&city=$city';
    params += state == null ? '' : '&state=$state';
    params += country == null ? '' : '&country=$country';
    params += method == null ? '' : '&method=$method';

    return params;
  }

  _getPrayerTimeOnDate(DateTime date) async {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    String formattedDateInUrl = "/$formattedDate";
    return await _get("$apiUrl$timingsByCity$formattedDateInUrl?", getParams());
  }

  getPrayerTimeToday() async {
    return await _getPrayerTimeOnDate(DateTime.now());
  }

  getPrayerTimeForDate(DateTime date) async {
    return await _getPrayerTimeOnDate(date);
  }
}
