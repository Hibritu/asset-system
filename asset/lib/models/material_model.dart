class MaterialModel {
  final String id;
  final String name;
  final String type;
  final int quantity;
  final String location;
   final String  qrDataString;
   final DateTime createdAt;
  final String description;

  MaterialModel({
    required this.id,
    required this.name,
    required this.type,
    required this.quantity,
    required this.location,
    required this.qrDataString,
    required this.createdAt,
    required this.description,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      quantity: json['quantity'] is int ? json['quantity'] : int.tryParse(json['quantity'].toString()) ?? 0,
      location: json['location'] ?? '',
      qrDataString: json['qrDataString'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      description: json['description'] ?? '',
    );
  }

  
}
