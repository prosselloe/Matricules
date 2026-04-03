class MatriculaModel {
  final int id;
  final String name;
  final String acronym;
  final String autonomy;
  final String description;
  final String flagUrl;
  final bool isMissing;
  final String region;
  final String capital;
  final List<PlateNumber> plateNumbers;
  final List<int> relatedProvinces;
  final int unitsPlates;

  MatriculaModel({
    required this.id,
    required this.name,
    required this.acronym,
    required this.autonomy,
    required this.description,
    required this.flagUrl,
    this.isMissing = false,
    required this.region,
    required this.capital,
    this.plateNumbers = const [],
    this.relatedProvinces = const [],
    this.unitsPlates = 0,
  });

 factory MatriculaModel.fromJson(Map<String, dynamic> json) {
    var plateNumbersList = (json['plateNumbers'] as List?)
            ?.map((v) => PlateNumber.fromJson(v))
            .toList() ??
        [];

    // Sort the plateNumbers by dateFrom to enable binary search later
    plateNumbersList.sort((a, b) {
      try {
        final dateA = DateTime.parse(a.dateFrom);
        final dateB = DateTime.parse(b.dateFrom);
        return dateA.compareTo(dateB);
      } catch (e) {
        // Handle potential parsing errors if dates are not in correct format
        return 0;
      }
    });

    return MatriculaModel(
      id: json['id'],
      name: json['name'],
      acronym: json['acronym'],
      autonomy: json['autonomy'],
      description: json['description'],
      flagUrl: json['flagUrl'],
      isMissing: json['isMissing'] ?? false,
      region: json['region'],
      capital: json['capital'],
      plateNumbers: plateNumbersList,
      relatedProvinces: List<int>.from(json['relatedProvinces'] ?? []),
      unitsPlates: json['unitsPlates'] ?? 0,
    );
  }
}

class PlateNumber {
  final String plateYear;
  final String dateFrom;
  final String dateTo;
  final String? plateFrom;
  final String? plateTo;

  PlateNumber({
    required this.plateYear,
    required this.dateFrom,
    required this.dateTo,
    this.plateFrom,
    this.plateTo,
  });

  factory PlateNumber.fromJson(Map<String, dynamic> json) {
    return PlateNumber(
      plateYear: json['plateYear'],
      dateFrom: json['dateFrom'],
      dateTo: json['dateTo'],
      plateFrom: json['plateFrom'],
      plateTo: json['plateTo'],
    );
  }
}
