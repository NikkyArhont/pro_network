import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pro_network/config/api_keys.dart';

class PlacesService {
  static const String _baseUrl = 'https://places.googleapis.com/v1/places:autocomplete';

  /// Запрашивает подсказки адресов по введенному тексту
  Future<List<String>> fetchSuggestions(String input) async {
    if (input.trim().isEmpty) return [];

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': ApiKeys.googlePlacesApiKey,
        },
        body: jsonEncode({
          'input': input,
          'languageCode': 'ru',
          'regionCode': 'RU',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['suggestions'] as List<dynamic>?;

        if (suggestions == null) return [];

        return suggestions.map((s) {
          final prediction = s['placePrediction'];
          if (prediction != null && prediction['text'] != null) {
            return prediction['text']['text'].toString();
          }
          return '';
        }).where((s) => s.isNotEmpty).toList();
      } else {
        print('Error from Google Places API: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception fetching places: $e');
      return [];
    }
  }
}
