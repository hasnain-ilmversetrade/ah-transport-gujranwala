class Vehicle {
  final int? id;
  final String vehicleNumber;
  final String type;
  final String model;
  final String ownershipType; // Owned / Partnership
  final int? partnerId;
  final double partnerSharePercent;
  final DateTime? purchaseDate;
  final DateTime? insuranceExpiry;
  final DateTime? tokenExpiry;
  final DateTime? fitnessExpiry;
  final String? notes;
  final bool isActive;

  Vehicle({
    this.id,
    required this.vehicleNumber,
    required this.type,
    required this.model,
    required this.ownershipType,
    this.partnerId,
    this.partnerSharePercent = 0,
    this.purchaseDate,
    this.insuranceExpiry,
    this.tokenExpiry,
    this.fitnessExpiry,
    this.notes,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_number': vehicleNumber,
      'type': type,
      'model': model,
      'ownership_type': ownershipType,
      'partner_id': partnerId,
      'partner_share_percent': partnerSharePercent,
      'purchase_date': purchaseDate?.toIso8601String(),
      'insurance_expiry': insuranceExpiry?.toIso8601String(),
      'token_expiry': tokenExpiry?.toIso8601String(),
      'fitness_expiry': fitnessExpiry?.toIso8601String(),
      'notes': notes,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      vehicleNumber: map['vehicle_number'] as String,
      type: map['type'] as String,
      model: map['model'] as String,
      ownershipType: map['ownership_type'] as String,
      partnerId: map['partner_id'] as int?,
      partnerSharePercent: (map['partner_share_percent'] as num?)?.toDouble() ?? 0,
      purchaseDate: map['purchase_date'] != null ? DateTime.parse(map['purchase_date']) : null,
      insuranceExpiry: map['insurance_expiry'] != null ? DateTime.parse(map['insurance_expiry']) : null,
      tokenExpiry: map['token_expiry'] != null ? DateTime.parse(map['token_expiry']) : null,
      fitnessExpiry: map['fitness_expiry'] != null ? DateTime.parse(map['fitness_expiry']) : null,
      notes: map['notes'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }

  Vehicle copyWith({
    int? id,
    String? vehicleNumber,
    String? type,
    String? model,
    String? ownershipType,
    int? partnerId,
    double? partnerSharePercent,
    DateTime? purchaseDate,
    DateTime? insuranceExpiry,
    DateTime? tokenExpiry,
    DateTime? fitnessExpiry,
    String? notes,
    bool? isActive,
  }) {
    return Vehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      type: type ?? this.type,
      model: model ?? this.model,
      ownershipType: ownershipType ?? this.ownershipType,
      partnerId: partnerId ?? this.partnerId,
      partnerSharePercent: partnerSharePercent ?? this.partnerSharePercent,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      fitnessExpiry: fitnessExpiry ?? this.fitnessExpiry,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }
}
