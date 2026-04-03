import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:convert';
import 'package:matricules/models/matricula_model.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen> {
  String _readmeContent = 'Carregant...';

  @override
  void initState() {
    super.initState();
    _loadReadme();
  }

  Future<void> _loadReadme() async {
    try {
      final content = await rootBundle.loadString('README.md');
      final creditsStartIndex = content.indexOf('## Crèdits');
      if (!mounted) return;
      setState(() {
        if (creditsStartIndex != -1) {
            _readmeContent = content.substring(0, creditsStartIndex);
        } else {
            _readmeContent = content;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _readmeContent = 'Error al carregar la informació.';
      });
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (!mounted) return; 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No s\'ha pogut obrir $url')),
      );
    }
  }

  Future<void> _exportProvincesToCsv() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<MatriculaModel> allModels = [];
      final dbFiles = manifestMap.keys.where((String key) => key.startsWith('assets/data/db_')).toList();

      for (String dbFile in dbFiles) {
        final String modelsJsonString = await rootBundle.loadString(dbFile);
        final List<dynamic> modelsJson = json.decode(modelsJsonString);
        allModels.addAll(modelsJson.map((json) => MatriculaModel.fromJson(json)));
      }

      List<List<dynamic>> rows = [];
      rows.add(['ID', 'Name', 'Acronym', 'Capital', 'Autonomy', 'Region', 'Description', 'Flag URL', 'Units Plates']);
      for (var model in allModels) {
        rows.add([
          model.id,
          model.name,
          model.acronym,
          model.capital,
          model.autonomy,
          model.region,
          model.description,
          model.flagUrl,
          model.unitsPlates
        ].map((e) => e.toString()).toList());
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/provinces.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'Aquí teniu les dades de les províncies en format CSV.');

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en exportar les dades: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quant a l\'aplicació'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: _readmeContent,
              imageBuilder: (uri, title, alt) {
                if (uri.path.startsWith('assets/')) {
                  return Image.asset(uri.path);
                }
                return Image.network(uri.toString());
             },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _exportProvincesToCsv,
              icon: const Icon(Icons.download),
              label: const Text('Exporta Províncies a CSV'),
            ),
            const SizedBox(height: 24),
            Text(
              'Crèdits',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildCreditItem(
              context,
              'Wikipedia: Matrículas automovilísticas de España',
              'Sistema provincial numérico',
              'https://es.wikipedia.org/wiki/Matrículas_automovilísticas_de_España#Sistema_provincial_numérico',
            ),
            _buildCreditItem(
              context,
              'Wikipedia: Banderas de España',
              'Comunidades y ciudades autónomas',
              'https://es.wikipedia.org/wiki/Anexo:Banderas_de_Espa%C3%B1a#Comunidades_y_ciudades_aut%C3%B3nomas',
            ),
            _buildCreditItem(
              context,
              'Sistema de Matriculación Provincial Numérico',
              'Últimos números otorgados a 31 de Diciembre',
              'http://www.sme-matriculas.es/up1.html',
            ),
            _buildCreditItem(
              context,
              'La Maneta: Matriculas por Provincias y Años',
              'Últimos números otorgados a 31 de Diciembre',
              'https://www.lamaneta.org/matriculas/',
            ),
            _buildCreditItem(
              context,
              'Google Firebase Gemini',
              'Tecnologia d\'IA generativa',
              'https://firebase.google.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditItem(BuildContext context, String title, String subtitle, String url) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new),
        onTap: () => _launchURL(url),
      ),
    );
  }
}
