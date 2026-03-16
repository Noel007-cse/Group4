import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spacebook/models/space_frame_model.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  static String? _token;
  static Map<String, dynamic>? currentUser;

  // ── Favorites ──
  static final List<SpaceFrameModel> favorites = [];

  static void toggleFavorite(SpaceFrameModel space) {
    if (favorites.any((s) => s.id == space.id)) {
      favorites.removeWhere((s) => s.id == space.id);
    } else {
      favorites.add(space);
    }
  }

  static bool isFavorite(int spaceId) {
    return favorites.any((s) => s.id == spaceId);
  }

  static void setToken(String token) => _token = token;

  static Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  static bool get isOwner => currentUser?['account_type'] == 'seller';

  // ── Auth ──
  static Future<Map<String, dynamic>> register(
    String name, String email, String password,
    {String accountType = 'buyer'}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'account_type': accountType,
      }),
    );
    final data = jsonDecode(res.body);
    if (data['token'] != null) {
      setToken(data['token']);
      currentUser = data['user'];
    }
    return data;
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body);
    if (data['token'] != null) {
      setToken(data['token']);
      currentUser = data['user'];
    }
    return data;
  }

  static void logout() {
    _token = null;
    currentUser = null;
    favorites.clear();
  }

  static Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/change-password'),
      headers: _authHeaders,
      body: jsonEncode({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateProfile(String name) async{
    final res = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: _authHeaders,
      body: jsonEncode({
        'name':name,
      }),
    );

    final data = jsonDecode(res.body);

    if(res.statusCode==200){
      currentUser=data['user'];
    }
    return data;
  }

  // ── Cloudinary Upload ──
  static Future<String> uploadImageToCloudinary(
      List<int> imageBytes, String fileName) async {
    const cloudName = 'drgun1vll';
    const uploadPreset = 'spacebook';

    final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: fileName,
      ));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final data = jsonDecode(responseBody);

    if (data['secure_url'] != null) {
      return data['secure_url'] as String;
    }
    throw Exception('Cloudinary upload failed: ${data['error']?['message']}');
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

  static Future<List<dynamic>> getRecommend() async {
    final url = '$baseUrl/recom';
    final res = await http.get(
      Uri.parse(url),
      headers: _authHeaders
      );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load spaces');
  }

  static Future<List<dynamic>> getMySpaces() async {
    final res = await http.get(
      Uri.parse('$baseUrl/spaces/mine'),
      headers: _authHeaders,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load my spaces');
  }

  static Future<Map<String, dynamic>> createSpace({
    required String title,
    required String category,
    required String area,
    required String description,
    required int pricePerHr,
    required bool hasSeats,
    String imageUrl = '',
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/spaces'),
      headers: _authHeaders,
      body: jsonEncode({
        'title': title,
        'category': category,
        'area': area,
        'description': description,
        'price_per_hr': pricePerHr,
        'has_seats': hasSeats,
        'image_url': imageUrl,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteSpace(int spaceId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/spaces/$spaceId'),
      headers: _authHeaders,
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateSpacePrice(
      int spaceId, int newPrice) async {
    final res = await http.put(
      Uri.parse('$baseUrl/spaces/$spaceId'),
      headers: _authHeaders,
      body: jsonEncode({'price_per_hr': newPrice}),
    );
    return jsonDecode(res.body);
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

  // ← NEW: get all bookings made on owner's spaces
  static Future<List<dynamic>> getBookingsForMySpaces() async {
    final res = await http.get(
      Uri.parse('$baseUrl/bookings/for-my-spaces'),
      headers: _authHeaders,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load bookings for spaces');
  }
}