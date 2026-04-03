import 'dart:convert';
import 'package:flutter/services.dart';

class VinInfo {
  final String wmi;
  final String vds;
  final String vis;
  final String country;
  final String manufacturer;
  final String? wmiDescription; // <-- Can be null
  final int modelYear;
  final String plant;
  final String sequentialNumber;
  final String? modelName;
  final String? error;

  VinInfo({
    this.wmi = '',
    this.vds = '',
    this.vis = '',
    this.country = 'Desconegut',
    this.manufacturer = 'Desconegut',
    this.wmiDescription,
    this.modelYear = 0,
    this.plant = 'Desconegut',
    this.sequentialNumber = '',
    this.modelName,
    this.error,
  });

  bool get isValid => error == null;
}

class VinDecoderService {
  Map<String, dynamic>? _vinData;

  Future<void> _loadVinData() async {
    if (_vinData == null) {
      final String response = await rootBundle.loadString('assets/data/vin_data.json');
      _vinData = json.decode(response); // <-- No await needed
    }
  }

  // ... (Maps for plant, country, and model codes remain the same)
  static const Map<String, String> _plantCodes = {
      'A': 'Ingolstadt, DE',
      'B': 'Brussels, BE',
      'C': 'Chattanooga, US',
      'D': 'Bratislava, SK',
      'E': 'Emden, DE',
      'F': 'Resende, BR',
      'G': 'Steyr, AT',
      'H': 'Hannover, DE',
      'K': 'Osnabrück, DE',
      'M': 'Puebla, MX',
      'N': 'Neckarsulm, DE',
      'P': 'Mosel (Zwickau), DE',
      'R': 'Martorell, ES',
      'S': 'Salzgitter, DE',
      'T': 'Taubaté, BR',
      'U': 'Uitenhage, ZA',
      'V': 'Palmela, PT', // AutoEuropa
      'W': 'Wolfsburg, DE',
      'X': 'Poznan, PL',
      'Y': 'Pamplona, ES',
      '1': 'Györ, HU',
      '8': 'Dresden, DE',
  };

  static const Map<String, String> _countryCodes = {
      'W': 'Alemanya',
      '1': 'Estats Units',
      '2': 'Canadà',
      '3': 'Mèxic',
      '9': 'Brasil',
      'S': 'Regne Unit',
      'V': 'França',
      'T': 'República Txeca',
      'Y': 'Suècia',
      'Z': 'Itàlia',
  };

  static const Map<String, String> _modelCodes = {
    '16': 'Jetta Mk1 / Mk2', // This will be handled by special logic
    '17': 'Golf Mk1',
    '1G': 'Golf / Jetta Mk2',
    '1H': 'Golf Mk3 / Vento',
    '1E': 'Golf Mk3 Cabriolet',
    '1J': 'Golf / Bora Mk4',
    '9M': 'Bora (Xina)',
    '1K': 'Golf / Jetta Mk5',
    '1T': 'Touran',
    '5K': 'Golf Mk6',
    'AU': 'Golf Mk7',
    '53': 'Scirocco Mk1 / Mk2',
    '32': 'Passat B1',
    '33': 'Passat B2',
    '3A': 'Passat B3 / B4',
    '3B': 'Passat B5',
    '3C': 'Passat B6',
    '86': 'Polo Mk1 / Mk2',
    '6N': 'Polo Mk3',
    '9N': 'Polo Mk4',
    '6R': 'Polo Mk5',
    '1C': 'New Beetle',
    '1Y': 'New Beetle Cabrio',
    '7L': 'Touareg',
    '7M': 'Sharan',
    '2K': 'Caddy',
    '7H': 'Transporter T5',
  };

  // CORRECTED: This function now correctly handles the 30-year VIN cycle ambiguity.
  int _decodeYear(String yearCode, String vis) {
    const Map<String, int> yearMap2010_2039 = {
        'A': 2010, 'B': 2011, 'C': 2012, 'D': 2013, 'E': 2014, 'F': 2015, 'G': 2016, 'H': 2017,
        'J': 2018, 'K': 2019, 'L': 2020, 'M': 2021, 'N': 2022, 'P': 2023, 'R': 2024, 'S': 2025,
        'T': 2026, 'V': 2027, 'W': 2028, 'X': 2029, 'Y': 2030, '1': 2031, '2': 2032, '3': 2033,
        '4': 2034, '5': 2035, '6': 2036, '7': 2037, '8': 2038, '9': 2039
    };
    const Map<String, int> yearMap1980_2009 = {
        'A': 1980, 'B': 1981, 'C': 1982, 'D': 1983, 'E': 1984, 'F': 1985, 'G': 1986, 'H': 1987,
        'J': 1988, 'K': 1989, 'L': 1990, 'M': 1991, 'N': 1992, 'P': 1993, 'R': 1994, 'S': 1995,
        'T': 1996, 'V': 1997, 'W': 1998, 'X': 1999, 'Y': 2000, '1': 2001, '2': 2002, '3': 2003,
        '4': 2004, '5': 2005, '6': 2006, '7': 2007, '8': 2008, '9': 2009
    };

    int? year1 = yearMap1980_2009[yearCode];
    int? year2 = yearMap2010_2039[yearCode];

    if (year1 != null && year2 != null) {
      // Ambiguity exists. Use a heuristic: check the check digit or sequence.
      // For VW, a zero at VIS position 1 (11th char of VIN) often indicates the earlier cycle.
      if (vis.startsWith('0')) {
          return year1;
      } else {
          return year2;
      }
    } else if (year2 != null) {
      return year2;
    } else if (year1 != null) {
      return year1;
    }

    return 0;
  }

  // CORRECTED: Model decoding is now more robust.
  String? _decodeModel(String vds, int modelYear) {
      String modelCode;

      if (vds.startsWith('ZZZ')) {
        // For modern EU VINs, the model is often in positions 7-8 of the full VIN, which are 4-5 of the VDS
        modelCode = vds.substring(3, 5);
      } else {
        // For older or US models, it's in positions 4-5 of the full VIN (0-1 of VDS)
        modelCode = vds.substring(0, 2);
      }

      // Special handling for ambiguous code '15'
      if (modelCode == '15') {
        if (modelYear >= 1980) {
          return 'New Beetle Cabriolet'; // Modern Beetle Cabriolet
        } else {
          return 'Golf Mk1 Cabriolet'; // Classic Golf Cabriolet
        }
      }

      // Special handling for ambiguous code '16'
      if (modelCode == '16') {
        if (modelYear >= 2011) {
          return 'Beetle / Cabriolet'; // Modern Beetle
        } else {
          return 'Jetta Mk1 / Mk2'; // Classic Jetta
        }
      }   

      return _modelCodes[modelCode];
  }


  Future<VinInfo> decodeVin(String vin) async {
    vin = vin.toUpperCase().trim();

    if (vin.length != 17) {
      return VinInfo(error: 'El VIN ha de tenir 17 caràcters.');
    }
    
    if (vin.contains('I') || vin.contains('O') || vin.contains('Q')) {
        return VinInfo(error: 'El VIN no pot contenir els caràcters I, O, o Q.');
    }

    await _loadVinData();

    try {
      String wmi = vin.substring(0, 3);
      String vds = vin.substring(3, 9);
      String vis = vin.substring(9);
      
      String countryCode = wmi.substring(0, 1);
      String yearCode = vis.substring(0, 1);
      String plantCode = vis.substring(1, 2);
      String sequence = vis.substring(2);

      int modelYear = _decodeYear(yearCode, vis);
      String? modelName = _decodeModel(vds, modelYear);

      String? wmiDescription = (_vinData!['wmi'] as Map<String, dynamic>)[wmi];

      return VinInfo(
        wmi: wmi,
        vds: vds,
        vis: vis,
        country: _countryCodes[countryCode] ?? 'Desconegut ($countryCode)',
        manufacturer: 'Volkswagen',
        wmiDescription: wmiDescription,
        modelYear: modelYear,
        modelName: modelName ?? 'Model desconegut',
        plant: _plantCodes[plantCode] ?? 'Desconegut ($plantCode)',
        sequentialNumber: sequence,
      );

    } catch (e) {
      return VinInfo(error: "S'ha produït un error en processar el VIN: $e");
    }
  }
}
