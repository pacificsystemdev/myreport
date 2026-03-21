import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://app.pacific.com.kh/devreport/api';

  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Login failed');
  }

  Future<Map<String, dynamic>> submitReport(
    Map<String, dynamic> data,
    String token,
    int userId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({...data, 'userId': userId, 'token': token}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Submit failed');
  }

  Future<Map<String, dynamic>> updateReport(
    int reportId,
    Map<String, dynamic> data,
    String token,
    int userId,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reports.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        ...data,
        'reportId': reportId,
        'userId': userId,
        'token': token,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Update failed');
  }

  Future<Map<String, dynamic>> getReports(
    int userId,
    String token, {
    int? year,
    int? month,
  }) async {
    final queryParams = <String, String>{
      'userId': userId.toString(),
      'token': token,
    };
    if (year != null) queryParams['year'] = year.toString();
    if (month != null) queryParams['month'] = month.toString();
    final uri = Uri.parse(
      '$baseUrl/reports.php',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Fetch reports failed');
  }
}
