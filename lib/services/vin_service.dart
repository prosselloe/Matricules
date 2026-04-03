import 'dart:convert';
import 'package:flutter/services.dart';

class VinDecodedResult {
  final String modelName;
  final int modelYear;

  VinDecodedResult({required this.modelName, required this.modelYear});
}

class VinService {
  static Map<String, dynamic>? _vinData;

  static Future<void> init() async {
    final String response = await rootBundle.loadString('assets/data/state_plate_data.json');
    _vinData = await json.decode(response);
  }

  static VinDecodedResult? decodeVin(String vin) {
    if (_vinData == null || vin.length != 17) {
      return null;
    }

    final modelCode = vin.substring(6, 8);
    final yearCode = vin[9];

    final modelData = _vinData!['model_vds'][modelCode];
    if (modelData == null) return null;

    final possibleYears = _getPossibleYears(yearCode);
    if (possibleYears.isEmpty) return null;

    String? modelName;
    int? finalYear;

    if (modelData.containsKey('disambiguation')) {
        for (var option in modelData['disambiguation']) {
            final int cycle = option['cycle'];
            for (int year in possibleYears) {
                if (_getCycleForYear(year) == cycle) {
                    modelName = option['name'];
                    finalYear = year;
                    break;
                }
            }
            if (finalYear != null) break;
        }
    } else {
        final int cycle = modelData['cycle'];
        modelName = modelData['name'];
        for (int year in possibleYears) {
            if (_getCycleForYear(year) == cycle) {
                finalYear = year;
                break;
            }
        }
    }

    if (modelName != null && finalYear != null) {
        return VinDecodedResult(modelName: modelName, modelYear: finalYear);
    }

    return null;
  }

  static List<int> _getPossibleYears(String code) {
    const Map<String, int> yearMap1 = {
      'A': 1980, 'B': 1981, 'C': 1982, 'D': 1983, 'E': 1984, 'F': 1985, 'G': 1986, 'H': 1987,
      'J': 1988, 'K': 1989, 'L': 1990, 'M': 1991, 'N': 1992, 'P': 1993, 'R': 1994, 'S': 1995,
      'T': 1996, 'V': 1997, 'W': 1998, 'X': 1999, 'Y': 2000, '1': 2001, '2': 2002, '3': 2003,
      '4': 2004, '5': 2005, '6': 2006, '7': 2007, '8': 2008, '9': 2009
    };
    const Map<String, int> yearMap2 = {
      'A': 2010, 'B': 2011, 'C': 2012, 'D': 2013, 'E': 2014, 'F': 2015, 'G': 2016, 'H': 2017,
      'J': 2018, 'K': 2019, 'L': 2020, 'M': 2021, 'N': 2022, 'P': 2023, 'R': 2024, 'S': 2025,
      'T': 2026, 'V': 2027, 'W': 2028, 'X': 2029, 'Y': 2030, '1': 2031, '2': 2032, '3': 2033,
      '4': 2034, '5': 2035, '6': 2036, '7': 2037, '8': 2038, '9': 2039
    };

    List<int> years = [];
    if (yearMap1.containsKey(code)) years.add(yearMap1[code]!);
    if (yearMap2.containsKey(code)) years.add(yearMap2[code]!);
    return years;
  }

  static int _getCycleForYear(int year) {
    if (year >= 1980 && year <= 2009) return 1; // Cycle 1: Classic
    if (year >= 2010 && year <= 2039) return 2; // Cycle 2: Modern
    return 0; // Should not happen
  }

  static String? decodeWmi(String wmi) {
    return _vinData?['wmi'][wmi];
  }

  static String? getPlantFromCode(String code, int? modelYear) {
    if (_vinData == null) return null;
    
    // Handle specific plant logic based on year
    if (modelYear != null) {
      if (code == 'V') {
        return modelYear <= 1994 ? 'Westmoreland, USA (up to 1994)' : 'Palmela, Portugal (from 1994)';
      }
      if (code == 'T') {
        return modelYear <= 1994 ? 'Sarajevo, Yugoslavia (up to 1994)' : 'Taubaté, Brazil';
      }
    }
    
    return _vinData!['plant_codes'][code];
  }
}
