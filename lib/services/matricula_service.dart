import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:matricules/models/autonomy.dart';
import 'package:matricules/models/matricula_model.dart';
import 'package:matricules/models/state_plate_data.dart';

class MatriculaService {
  Future<List<MatriculaModel>> getModels() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final modelPaths = manifestMap.keys.where((String key) =>
        key.startsWith('assets/data/') &&
        key.endsWith('.json') &&
        key.contains('db_') &&
        !key.contains('db_national.json'));

    List<MatriculaModel> models = [];
    for (var path in modelPaths) {
      final jsonString = await rootBundle.loadString(path);
      final List<dynamic> jsonList = json.decode(jsonString);
      models.addAll(
          jsonList.map((json) => MatriculaModel.fromJson(json)).toList());
    }
    return models;
  }

  Future<List<Autonomy>> getAutonomies() async {
    final jsonString =
        await rootBundle.loadString('assets/data/autonomies.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Autonomy.fromJson(json)).toList();
  }

  Future<StatePlateData> getStatePlateData() async {
    final jsonString =
        await rootBundle.loadString('assets/data/state_plate_data.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return StatePlateData.fromJson(jsonMap);
  }
}
