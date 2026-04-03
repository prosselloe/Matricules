class Autonomy {
  final int id;
  final String name;
  final String flag;
  final String flagUrl;
  final double latitude;
  final double longitude;

  Autonomy({
    required this.id,
    required this.name,
    required this.flag,
    required this.flagUrl,
    required this.latitude,
    required this.longitude,
  });

  factory Autonomy.fromJson(Map<String, dynamic> json) {
    return Autonomy(
      id: json['id'],
      name: json['name'],
      flag: json['flag'],
      flagUrl: json['flagUrl'],
      latitude: json['coordinates']['latitude'],
      longitude: json['coordinates']['longitude'],
    );
  }
}
