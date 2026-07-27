class Customer {
  final int? id;
  final String name;
  final String phone;
  final String? cnicNtn;
  final String? address;
  final double creditLimit;
  final double outstandingBalance;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.cnicNtn,
    this.address,
    this.creditLimit = 0,
    this.outstandingBalance = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'cnic_ntn': cnicNtn,
      'address': address,
      'credit_limit': creditLimit,
      'outstanding_balance': outstandingBalance,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      cnicNtn: map['cnic_ntn'] as String?,
      address: map['address'] as String?,
      creditLimit: (map['credit_limit'] as num?)?.toDouble() ?? 0,
      outstandingBalance: (map['outstanding_balance'] as num?)?.toDouble() ?? 0,
    );
  }
}
