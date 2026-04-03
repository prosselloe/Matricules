import 'dart:convert';

StatePlateData statePlateDataFromJson(String str) =>
    StatePlateData.fromJson(json.decode(str));

String statePlateDataToJson(StatePlateData data) => json.encode(data.toJson());

class StatePlateData {
  final List<LastLetter> lastLetters;
  final List<ProvincialRegistration> provincialRegistrations;

  StatePlateData({
    required this.lastLetters,
    required this.provincialRegistrations,
  });

  factory StatePlateData.fromJson(Map<String, dynamic> json) => StatePlateData(
        lastLetters: List<LastLetter>.from(
            json["last_letters"].map((x) => LastLetter.fromJson(x))),
        provincialRegistrations: List<ProvincialRegistration>.from(
            json["provincial_registrations"]
                .map((x) => ProvincialRegistration.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "last_letters": List<dynamic>.from(lastLetters.map((x) => x.toJson())),
        "provincial_registrations":
            List<dynamic>.from(provincialRegistrations.map((x) => x.toJson())),
      };
}

class LastLetter {
  final int year;
  final Map<String, String> months;

  LastLetter({
    required this.year,
    required this.months,
  });

  factory LastLetter.fromJson(Map<String, dynamic> json) => LastLetter(
        year: json["year"],
        months: Map.from(json["months"])
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "year": year,
        "months":
            Map.from(months).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}

class ProvincialRegistration {
  final String province;
  final String flagUrl;
  final Map<String, int> registrations;
  final int total;

  ProvincialRegistration({
    required this.province,
    required this.flagUrl,
    required this.registrations,
    required this.total,
  });

  factory ProvincialRegistration.fromJson(Map<String, dynamic> json) =>
      ProvincialRegistration(
        province: json["province"] ?? '',
        flagUrl: json["flagUrl"] ?? '',
        registrations: Map.from(json["registrations"] ?? const {})
            .map((k, v) => MapEntry<String, int>(k, v as int)),
        total: json["total"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "province": province,
        "flag_url": flagUrl,
        "registrations":
            Map.from(registrations).map((k, v) => MapEntry<String, dynamic>(k, v)),
        "total": total,
      };
}
