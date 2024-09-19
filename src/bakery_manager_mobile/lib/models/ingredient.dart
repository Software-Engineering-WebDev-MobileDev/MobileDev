class Ingredient {
  final String name;
  final double quantity;
  final String unit;

  Ingredient({required this.name, required this.quantity, required this.unit});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['Name'] ?? '',
      quantity: json['Quantity'] ?? 0,
      unit: json['Unit'] ?? '',
    );
  }
}