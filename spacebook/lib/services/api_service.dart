import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static String? _token;

  static void setToken(String token) => _token = token;

  static Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ── Auth ──
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (data['token'] != null) setToken(data['token']);
    return data;
  }

  // ── Spaces ──
  static Future<List<dynamic>> getSpaces({String? category}) async {
    final url = category != null
        ? '$baseUrl/spaces?category=${Uri.encodeComponent(category)}'
        : '$baseUrl/spaces';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load spaces');
  }

  // ── Bookings ──
  static Future<Map<String, dynamic>> createBooking({
    required int spaceId,
    required String bookingDate,
    required String timeSlot,
    required int totalPrice,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: _authHeaders,
      body: jsonEncode({
        'space_id': spaceId,
        'booking_date': bookingDate,
        'time_slot': timeSlot,
        'total_price': totalPrice,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<List<dynamic>> getMyBookings() async {
    final res = await http.get(
      Uri.parse('$baseUrl/bookings/mine'),
      headers: _authHeaders,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load bookings');
  }
}