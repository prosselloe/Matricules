
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'dart:developer' as developer;

class DgtService {
  static const String _dgtBaseUrl = 'https://sede.dgt.gob.es';

  Future<String?> getEnvironmentalStickerUrl(String plate) async {
    // URL final de la pàgina de la DGT.
    final requestUrl = Uri.parse('$_dgtBaseUrl/es/vehiculos/informacion-de-vehiculos/distintivo-ambiental/index.html?matricula=$plate');

    try {
      final response = await http.get(requestUrl);

      if (response.statusCode == 200) {
        final document = html_parser.parse(response.body);
        final img = document.querySelector('img[src*="/distintivo-ambiental/images/"]');
        
        if (img != null && img.attributes['src'] != null) {
          // Construïm i retornem la URL completa de la imatge del distintiu.
          return '$_dgtBaseUrl${img.attributes['src']}';
        }
      } else {
        developer.log(
          'Error en la petició a la DGT. Codi: ${response.statusCode}',
          name: 'dgt_service',
          error: response.body,
          level: 900,
        );
      }
    } catch (e, s) {
      developer.log(
        'Excepció en intentar obtenir el distintiu ambiental.',
        name: 'dgt_service',
        error: e,
        stackTrace: s,
        level: 1000,
      );
    }
    
    // Si alguna cosa falla, retornem null.
    return null;
  }
}
