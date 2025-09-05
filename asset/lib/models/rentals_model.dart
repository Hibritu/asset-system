class Rental {
  final String id;
  final String status;
  final String quantity;
  final DateTime? requestDate;
  final DateTime? returnDate;
  final DateTime? startDate;
  final DateTime? endDate;
  
  final String? notes;

  final String materialId;
  final String materialName;

  final String userId;
  final String userName;

  Rental({
    required this.id,
    required this.status,
    this.requestDate,
    this.quantity = '1',
    
    this.returnDate,
    this.startDate,
    this.endDate,
    this.notes,
    required this.materialId,
    required this.materialName,
    required this.userId,
    required this.userName,
  });

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      quantity: json['quantity'] is int
          ? json['quantity'].toString()
          : (json['quantity'] ?? '1').toString(),
      
     requestDate: json['requestDate'] != null ? DateTime.parse(json['requestDate']) : null,

      returnDate: json['returnDate'] != null
          ? DateTime.tryParse(json['returnDate'])
          : null,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'])
          : null,
      notes: json['notes'] ?? '',

      materialId: json['materialId'] ?? '',
      materialName: json['materialName'] ?? '',
        userId: json['userId'] ?? '',
    userName: json['userName'] != null && json['userName'].toString().trim().isNotEmpty
        ? json['userName']
        : 'Unknown',
  );
     
    
  }
}
