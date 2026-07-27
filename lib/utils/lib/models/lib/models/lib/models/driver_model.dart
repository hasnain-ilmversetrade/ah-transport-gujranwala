class Driver {
  final int? id;
  final String name;
  final String phone;
  final String? licenseNumber;
  final DateTime? licenseExpiry;
  final String? address;
  final String salaryType; // Daily/Weekly/Monthly
  final double salaryAmount;
  final bool isActive;

  Driver({
    this.id,
    required this.name,
    required this.phone,
    this.licenseNumber,
    this.licenseExpiry,
    this.address,
    this.salaryType = 'Monthly',
    this.salaryAmount = 0,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry?.toIso8601String(),
      'address': address,
      'salary_type': salaryType,
      'salary_amount': salaryAmount,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory Driver.fromMap(Map<String, dynamic> map) {
    return Driver(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      licenseNumber: map['license_number'] as String?,
      licenseExpiry: map['license_expiry'] != null ? DateTime.parse(map['license_expiry']) : null,
      address: map['address'] as String?,
      salaryType: map['salary_type'] as String? ?? 'Monthly',
      salaryAmount: (map['salary_amount'] as num?)?.toDouble() ?? 0,
      isActive: (map['is_active'] as int? ?? 1) == 1,
    );
  }
}
