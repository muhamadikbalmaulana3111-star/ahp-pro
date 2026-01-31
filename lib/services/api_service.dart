import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ahp_model.dart';

class ApiService {
  // URL GitHub Gist yang berisi config.json
  // GANTI dengan URL Raw Gist Anda!
  static const String gistRawUrl = 'https://gist.githubusercontent.com/muhamadikbalmaulana3111-star/0810838a56b7dffa83e2cb38c1ec17bd/raw/54a7bc07e88e95be8c56008ee182fc2e74783b50/config.json';
  
  String? _cachedApiUrl;

  /// Fetch base URL dari GitHub Gist
  Future<String> fetchBaseUrl() async {
    try {
      print('📡 Fetching config from Gist...');
      final response = await http.get(
        Uri.parse(gistRawUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final config = json.decode(response.body);
        _cachedApiUrl = config['base_url'];
        print('✅ Config loaded: $_cachedApiUrl');
        return _cachedApiUrl!;
      } else {
        throw Exception('Gagal mengambil config: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching config: $e');
      
      // Fallback ke cached URL jika ada
      if (_cachedApiUrl != null) {
        print('⚠️ Using cached URL: $_cachedApiUrl');
        return _cachedApiUrl!;
      }
      
      rethrow;
    }
  }

  /// Kirim request ke Python API untuk kalkulasi AHP
  Future<AHPResult> calculateAHP(AHPRequest request) async {
    try {
      // Step 1: Get base URL from Gist
      final baseUrl = await fetchBaseUrl();
      final apiUrl = '$baseUrl/api/calculate';

      print('🚀 Sending AHP request to: $apiUrl');
      
      // Step 2: Send POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      ).timeout(const Duration(seconds: 30));

      print('📥 Response status: ${response.statusCode}');
      
      // Step 3: Parse response
      final responseData = json.decode(response.body);
      final result = AHPResult.fromJson(responseData);
      
      if (result.isSuccess) {
        print('✅ AHP calculation successful');
      } else {
        print('⚠️ AHP calculation returned error: ${result.message}');
      }
      
      return result;
      
    } catch (e) {
      print('❌ Error in calculateAHP: $e');
      return AHPResult(
        status: 'error',
        message: 'Terjadi kesalahan: ${e.toString()}',
      );
    }
  }

  /// Health check endpoint
  Future<bool> checkHealth() async {
    try {
      final baseUrl = await fetchBaseUrl();
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  /// Clear cached URL (untuk debugging)
  void clearCache() {
    _cachedApiUrl = null;
  }
}
