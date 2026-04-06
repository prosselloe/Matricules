import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import 'package:matricules/models/autonomy.dart';
import 'package:matricules/models/matricula_model.dart';
import 'package:matricules/models/state_plate_data.dart';
import 'package:matricules/services/matricula_service.dart';

enum SortType { none, byName, byYear, byUnits }

class ModelProvider with ChangeNotifier {
  final MatriculaService _matriculaService = MatriculaService();
  List<MatriculaModel> _models = [];
  List<Autonomy> _autonomies = [];
  StatePlateData? _statePlateData;
  List<MatriculaModel> _filteredModels = [];
  bool _isLoading = false;
  SortType _sortType = SortType.byName;
  String? _selectedAutonomy;
  String? _selectedProvince;

  List<MatriculaModel> get models => _filteredModels;
  List<MatriculaModel> get allModels => _models;
  List<Autonomy> get autonomies => _autonomies;
  bool get isLoading => _isLoading;
  SortType get sortType => _sortType;
  String? get selectedAutonomy => _selectedAutonomy;
  String? get selectedProvince => _selectedProvince;

  ModelProvider() {
    fetchData();
  }

  Future<void> fetchModels() => fetchData();

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    await initializeDateFormatting('ca', null);
    _models = await _matriculaService.getModels();
    _autonomies = await _matriculaService.getAutonomies();
    _statePlateData = await _matriculaService.getStatePlateData();
    _filteredModels = _models;
    sort(_sortType, notify: false);

    _isLoading = false;
    notifyListeners();
  }

  List<Autonomy> getAvailableAutonomies() {
    return List<Autonomy>.from(_autonomies);
  }

  void filterByAutonomy(String? autonomy) {
    _selectedAutonomy = autonomy;
    _selectedProvince = null;
    search('');
  }

  void filterByProvince(String? province) {
    _selectedProvince = province;
    _selectedAutonomy = null;
    search('');
  }

  List<MatriculaModel> getModelsByIds(List<String> ids) {
    return _models.where((model) => ids.contains(model.id.toString())).toList();
  }

  Map<String, dynamic> searchByNationalPlate(String plateInput) {
    final normalizedInput = plateInput.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    final regex = RegExp(r'^(\d{4})([A-Z]{3})$');
    final match = regex.firstMatch(normalizedInput);

    if (match == null) {
      return {'error': 'Format de matrícula invàlid. Ha de ser 1234ABC.'};
    }

    final letters = match.group(2)!;
    if (_statePlateData == null) {
      return {'error': 'Les dades de matrícules estatals no s\'han carregat.'};
    }

    final plateValue = _getNationalPlateValue(letters);

    final sortedYears = List<LastLetter>.from(_statePlateData!.lastLetters)
      ..sort((a, b) => a.year.compareTo(b.year));

    const monthOrder = {
      'Ene': 1, 'Feb': 2, 'Mar': 3, 'Abr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Ago': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dic': 12
    };

    int? previousCombinationValue;

    for (var yearData in sortedYears) {
      final months = yearData.months.entries.toList()
        ..sort((a, b) => monthOrder[a.key]!.compareTo(monthOrder[b.key]!));

      for (var monthEntry in months) {
        final combination = monthEntry.value;
        if (combination == 'N/A') continue;

        final combinationValue = _getNationalPlateValue(combination);

        if (plateValue <= combinationValue) {
          final monthName = monthEntry.key;
          final year = yearData.year;
          final month = monthOrder[monthName]!;

          final fromValue = previousCombinationValue ?? _getNationalPlateValue('BBB');
          final toValue = combinationValue;

          final startDate = DateTime(year, month, 1);
          final daysInMonth = DateTime(year, month + 1, 0).day;
          final totalPlatesInRange = toValue - fromValue;
          final plateOffset = plateValue - fromValue;

          String estimatedDateStr;
          if (totalPlatesInRange > 0) {
            final estimatedDayOffset = (plateOffset / totalPlatesInRange) * daysInMonth;
            final estimatedDate = startDate.add(Duration(days: estimatedDayOffset.round()));
            estimatedDateStr = "Aprox. ${intl.DateFormat('d MMMM yyyy', 'ca').format(estimatedDate)}";
          } else {
            estimatedDateStr = "Aprox. ${intl.DateFormat('d MMMM yyyy', 'ca').format(startDate)}";
          }
          final provincialEquivalents = _getProvincialEquivalents(year);

          return {
            'Data de matriculació': estimatedDateStr,
            'Sistema': 'Estatal (2000-Actualitat)',
            'Matrícules provincials (any $year)': provincialEquivalents,
          };
        }
        previousCombinationValue = combinationValue;
      }
    }

    return {'error': 'La matrícula és posterior a les dades disponibles.'};
  }

  List<Map<String, String>> _getProvincialEquivalents(int year) {
    if (_statePlateData == null) {
      return [];
    }

    final provincialEquivalents = <Map<String, String>>[];

    for (var registration in _statePlateData!.provincialRegistrations) {
      if (registration.registrations.containsKey(year.toString())) {
        provincialEquivalents.add({
          'province': registration.province,
          'plate': registration.registrations[year.toString()].toString(),
          'flagUrl': registration.flagUrl,
        });
      }
    }

    provincialEquivalents.sort((a, b) => a['province']!.compareTo(b['province']!));
    return provincialEquivalents;
  }

  int _getNationalPlateValue(String letters) {
    const alphabet = "BCDFGHJKLMNPRSTVWXYZ";
    int value = 0;
    value += alphabet.indexOf(letters[2]);
    value += alphabet.indexOf(letters[1]) * alphabet.length;
    value += alphabet.indexOf(letters[0]) * alphabet.length * alphabet.length;
    return value;
  }

  Map<String, dynamic> searchByProvincialPlate(String plateInput) {
    final normalizedInput = plateInput.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    final regex = RegExp(r'^([A-Z]{1,3})([0-9A-Z]+)$');
    final match = regex.firstMatch(normalizedInput);

    if (match == null) {
        return {'error': 'Format de matrícula invàlid. Ex: B-123456, M-1234-AB'};
    }

    final acronym = match.group(1)!;
    final platePart = match.group(2)!;

    final isInputNumeric = int.tryParse(platePart) != null;
    if (!isInputNumeric) {
      final alphanumericRegex = RegExp(r'^(\d{4})([A-Z]{1,2})$');
      final alphanumericMatch = alphanumericRegex.firstMatch(platePart);
      if (alphanumericMatch == null) {
        return {'error': 'Format alfanumèric invàlid. Ha de ser NNNNA o NNNNAB.'};
      }

      final letters = alphanumericMatch.group(2)!;
      if (letters.length == 1) {
        if (['A', 'E', 'I', 'O', 'U', 'Ñ', 'Q', 'R'].contains(letters)) {
          return {'error': 'Les lletres A, E, I, O, U, Ñ, Q i R no estan permeses en matrícules d\'una sola lletra.'};
        }
      } else { // 2 letters
        final firstLetter = letters[0];
        final secondLetter = letters[1];
        if (['Ñ', 'Q', 'R'].contains(firstLetter)) {
          return {'error': 'La primera lletra no pot ser Ñ, Q, o R.'};
        }
        if (['A', 'E', 'I', 'O', 'Ñ', 'Q', 'R'].contains(secondLetter)) {
          return {'error': 'La segona lletra no pot ser A, E, I, O, Ñ, Q, o R.'};
        }
        if (letters == 'WC') {
          return {'error': 'La combinació de lletres "WC" no està permesa.'};
        }
      }
    }

    MatriculaModel? foundModel;
    for (var model in _models) {
        final acronyms = model.acronym.split(' / ').map((a) => a.trim().toUpperCase());
        if (acronyms.contains(acronym)) {
            foundModel = model;
            break;
        }
    }

    if (foundModel == null) {
        return {'error': 'Acrònim de província "$acronym" no trobat.'};
    }

    num maxNumericValue = 0;
    final numericRanges = foundModel.plateNumbers.where((range) => int.tryParse(range.plateFrom ?? '') != null);
    final lastNumericRange = numericRanges.isEmpty ? null : numericRanges.last;
    
    if (lastNumericRange != null && lastNumericRange.plateTo != null) {
        maxNumericValue = int.parse(lastNumericRange.plateTo!);
    }

    final plateRanges = foundModel.plateNumbers;
    int min = 0;
    int max = plateRanges.length - 1;
    final plateValue = _getComparableValue(platePart, maxNumericValue);

    while (min <= max) {
        int mid = min + ((max - min) >> 1);
        final version = plateRanges[mid];
        final plateFrom = version.plateFrom;
        final plateTo = version.plateTo;

        if (plateFrom == null || plateTo == null) {
            max = mid -1;
            continue;
        }

        final fromValue = _getComparableValue(plateFrom, maxNumericValue);
        final toValue = _getComparableValue(plateTo, maxNumericValue);

        if (plateValue >= fromValue && plateValue <= toValue) {
            return _createPlateSearchResult(foundModel, version, plateValue.toDouble(), fromValue.toDouble(), toValue.toDouble());
        }

        if (plateValue < fromValue) {
            max = mid - 1;
        } else {
            min = mid + 1;
        }
    }

    return {'error': 'Matrícula no trobada en els rangs per a ${foundModel.name}.'};
}

num _getComparableValue(String plate, num alphanumericOffset) {
    final isNumeric = int.tryParse(plate) != null;
    if (isNumeric) {
        return int.parse(plate);
    } else {
        return _getAlphanumericValue(plate, alphanumericOffset);
    }
}

int _getAlphanumericValue(String plate, num offset) {
    final regex = RegExp(r'^(\d*)?([A-Z]{1,2})$');
    final match = regex.firstMatch(plate.toUpperCase());

    if (match == null) {
      return -1;
    }

    final numberPartStr = match.group(1);
    final numberPart = (numberPartStr == null || numberPartStr.isEmpty) ? 0 : int.parse(numberPartStr);
    final letterPart = match.group(2)!;

    int letterValue = 0;
    const String alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    if (letterPart.length == 1) {
        letterValue = alphabet.indexOf(letterPart[0]);
    } else if (letterPart.length == 2) {
        final first = alphabet.indexOf(letterPart[0]);
        final second = alphabet.indexOf(letterPart[1]);
        if (first == -1 || second == -1) return -1;

        const letterOffset = alphabet.length;
        letterValue = letterOffset + (first * alphabet.length) + second;
    }

    if (letterValue == -1) return -1;

    return offset.toInt() + (letterValue * 10000) + numberPart;
}

  Map<String, dynamic> _createPlateSearchResult(
      MatriculaModel model, PlateNumber version, num plateValue, num fromValue, num toValue) {
    Map<String, dynamic> result = {
      'id': model.id,
      'Província': model.name,
      'Any de la matrícula': version.plateYear,
      'Sistema': int.tryParse(version.plateFrom!) != null ? 'Numèric' : 'Alfanumèric',
      'Rang': '${version.plateFrom} - ${version.plateTo}',
      'flagUrl': model.flagUrl
    };

    try {
      final startDate = DateTime.parse(version.dateFrom);
      final endDate = DateTime.parse(version.dateTo);
      final totalPlatesInRange = toValue - fromValue;
      final plateOffset = plateValue - fromValue;

      if (totalPlatesInRange > 0) {
        final registrationDurationInDays = endDate.difference(startDate).inDays;
        final estimatedDayOffset = (plateOffset / totalPlatesInRange) * registrationDurationInDays;
        final estimatedDate = startDate.add(Duration(days: estimatedDayOffset.round()));
        result['Data de matriculació'] = "Aprox. ${intl.DateFormat('d MMMM yyyy', 'ca').format(estimatedDate)}";
      } else {
        result['Data de matriculació'] = "Aprox. ${intl.DateFormat('d MMMM yyyy', 'ca').format(startDate)}";
      }
    } catch (e) {
      result['Data de matriculació'] = 'Error en calcular la data.';
    }

    return result;
  }

  void search(String query) {
    List<MatriculaModel> tempModels = List.from(_models);

    if (_selectedAutonomy != null && _selectedAutonomy!.isNotEmpty) {
      tempModels = tempModels.where((model) {
        return model.autonomy.contains(_selectedAutonomy!);
      }).toList();
    }
    
    if (_selectedProvince != null && _selectedProvince!.isNotEmpty) {
      tempModels = tempModels.where((model) {
        return model.name == _selectedProvince!;
      }).toList();
    }

    if (query.isNotEmpty) {
      final lowerCaseQuery = query.toLowerCase();

      tempModels = tempModels.where((model) {
        return model.name.toLowerCase().contains(lowerCaseQuery) ||
            model.acronym.toLowerCase().contains(lowerCaseQuery) ||
            model.capital.toLowerCase().contains(lowerCaseQuery);
      }).toList();
    }

    _filteredModels = tempModels;
    sort(_sortType, notify: false);
    notifyListeners();
  }

  void sort(SortType type, {bool notify = true}) {
    _sortType = type;
    switch (type) {
      case SortType.byName:
        _filteredModels.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortType.byYear:
        _filteredModels.sort((a, b) {
          final dateAString = a.plateNumbers.isNotEmpty ? a.plateNumbers.first.dateFrom : null;
          final dateBString = b.plateNumbers.isNotEmpty ? b.plateNumbers.first.dateFrom : null;

          if (dateAString == null && dateBString == null) return 0;
          if (dateAString == null) return -1;
          if (dateBString == null) return 1;

          try {
            final dateA = DateTime.parse(dateAString);
            final dateB = DateTime.parse(dateBString);
            return dateA.compareTo(dateB);
          } catch (e) {
            return 0;
          }
        });
        break;
      case SortType.byUnits:
        _filteredModels.sort((a, b) {
          return b.unitsPlates.compareTo(a.unitsPlates);
        });
        break;
      case SortType.none:
        _filteredModels.sort((a, b) => a.id.compareTo(b.id));
        break;
    }
    if (notify) {
      notifyListeners();
    }
  }
}
