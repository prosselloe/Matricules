import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class PlateApiService {
  final String apiKey = '77c05b9c0cmsh38db7fa8a967ca8p1c891fjsn8983b3074102';
  final String apiHost = 'api-matriculas-espana.p.rapidapi.com';

  Future<Map<String, dynamic>?> fetchDetails(String plate) async {
    final finalPlate = plate.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
    final url = Uri.parse('https://$apiHost/es?plate=$finalPlate');

    debugPrint('[PlateApiService] Attempting to fetch details for plate: $finalPlate');

    try {
      final response = await http.get(url, headers: {
        'X-RapidAPI-Key': apiKey,
        'X-RapidAPI-Host': apiHost,
        'Content-Type': 'application/json',
      });

      debugPrint('[PlateApiService] API Response Status: ${response.statusCode}');
      debugPrint('[PlateApiService] API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // The API returns a JSON array, so we decode it into a List.
        final List<dynamic> results = json.decode(response.body);

        // If the list is not empty, we return the first result.
        if (results.isNotEmpty) {
          // The first element is the map of vehicle details.
          return results.first as Map<String, dynamic>;
        }
      }
    } catch (e, s) {
      debugPrint('[PlateApiService] API call or JSON processing failed with error: $e');
      debugPrint('[PlateApiService] Stack Trace: $s');
    }

    // Return null if anything fails.
    return null;
  }
}
