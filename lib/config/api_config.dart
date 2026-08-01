import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String keyBaseUrl = 'api_base_url';
  static const String keyApiKey = 'api_key';

  // Default values
  static const String defaultBaseUrl = 'http://localhost/api/v1/';
  static const String defaultApiKey = '';

  String baseUrl;
  String apiKey;

  ApiConfig({
    required this.baseUrl,
    required this.apiKey,
  });

  /// Loads configuration from SharedPreferences
  static Future<ApiConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString(keyBaseUrl) ?? defaultBaseUrl;
    final apiKey = prefs.getString(keyApiKey) ?? defaultApiKey;
    return ApiConfig(baseUrl: baseUrl, apiKey: apiKey);
  }

  /// Saves current configuration to SharedPreferences
  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyBaseUrl, baseUrl);
    await prefs.setString(keyApiKey, apiKey);
  }

  /// Returns authentication and JSON headers
  Map<String, String> get headers {
    return {
      'api-key': apiKey,
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Helper to clean and build full URLs
  Uri getUri(String path, [Map<String, dynamic>? queryParameters]) {
    // Ensure base URL ends with a slash and does not contain duplicate slashes
    var base = baseUrl.trim();
    if (!base.endsWith('/')) {
      base += '/';
    }

    var cleanPath = path.trim();
    if (cleanPath.startsWith('/')) {
      cleanPath = cleanPath.substring(1);
    }

    final fullUrlStr = '$base$cleanPath';
    final uri = Uri.parse(fullUrlStr);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      // Map query parameters converting all values to strings, removing nulls
      final stringParams = <String, String>{};
      queryParameters.forEach((key, value) {
        if (value != null) {
          stringParams[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: stringParams);
    }

    return uri;
  }
}
