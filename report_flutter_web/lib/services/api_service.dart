import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'http://localhost/workActivityReport/myreport/api';

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    bool rememberMe = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
        'rememberMe': rememberMe,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    }

    throw Exception('Login failed');
  }

  // ================= SUBMIT REPORT =================
  Future<Map<String, dynamic>> submitReport(
    Map<String, dynamic> data,
    String token,
    int userId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reports.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ✅ FIXED
      },
      body: json.encode({...data, 'userId': userId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Submit failed');
  }

  // ================= UPDATE REPORT =================
  Future<Map<String, dynamic>> updateReport(
    int reportId,
    Map<String, dynamic> data,
    String token,
    int userId,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/reports.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ✅ FIXED
      },
      body: json.encode({...data, 'reportId': reportId, 'userId': userId}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Update failed');
  }

  // ================= GET REPORTS =================
  Future<Map<String, dynamic>> getReports(
    int userId,
    String token, {
    int? year,
    int? month,
  }) async {
    final queryParams = <String, String>{
      'userId': userId.toString(),
      if (year != null) 'year': year.toString(),
      if (month != null) 'month': month.toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/reports.php',
    ).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token', // ✅ FIXED
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Fetch reports failed');
  }

  // ================= REFRESH TOKEN =================
  Future<Map<String, dynamic>> refreshToken(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/refresh.php'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ✅ FIXED
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Token refresh failed');
  }
}
