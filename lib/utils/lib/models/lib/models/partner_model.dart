class Partner {
  final int? id;
  final String name;
  final String phone;
  final String? cnic;
  final String? address;
  final double defaultSharePercent;

  Partner({
    this.id,
    required this.name,
    required this.phone,
    this.cnic,
    this.address,
    this.defaultSharePercent = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'cnic': cnic,
      'address': address,
      'default_share_percent': defaultSharePercent,
    };
  }

  factory Partner.fromMap(Map<String, dynamic> map) {
    return Partner(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      cnic: map['cnic'] as String?,
      address: map['address'] as String?,
      defaultSharePercent: (map['default_share_percent'] as num?)?.toDouble() ?? 0,
    );
  }
}
