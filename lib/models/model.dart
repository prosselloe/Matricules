class Model {
  final int id;
  final String name;
  final String description;
  final int year;
  final String productionYears;
  final String imageUrl;

  Model({
    required this.id,
    required this.name,
    required this.description,
    required this.year,
    required this.productionYears,
    required this.imageUrl,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    String productionYears = json['productionYears'] ?? 'N/A';
    int year = 0;
    if (productionYears.isNotEmpty && productionYears != 'N/A') {
      year = int.tryParse(productionYears.split('-').first) ?? 0;
    }

    return Model(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      year: year,
      productionYears: productionYears,
      imageUrl: json['imageUrl'],
    );
  }
}
