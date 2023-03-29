import 'package:http/http.dart' as http;

class HttpRequest {
  postRequest(url, body, headers) async {
    http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return response;
  }

  getRequest(url, headers) async {
    http.Response response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    return response;
  }

  deleteRequest(url, headers) async {
    http.Response response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    return response;
  }
}
