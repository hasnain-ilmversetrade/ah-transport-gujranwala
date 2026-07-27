class TripExpense {
  final int? id;
  final int tripId;
  final String category; // Fuel, Toll Tax, Loading/Unloading, Driver Salary, Food, Other
  final double amount;
  final String? description;

  TripExpense({
    this.id,
    required this.tripId,
    required this.category,
    required this.amount,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'category': category,
      'amount': amount,
      'description': description,
    };
  }

  factory TripExpense.fromMap(Map<String, dynamic> map) {
    return TripExpense(
      id: map['id'] as int?,
      tripId: map['trip_id'] as int,
      category: map['category'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      description: map['description'] as String?,
    );
  }
}

/// Standalone income/expense not linked to a trip
class Transaction {
  final int? id;
  final String type; // income / expense
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String? receiptPath;

  Transaction({
    this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    this.receiptPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'receipt_path': receiptPath,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as int?,
      type: map['type'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      date: DateTime.parse(map['date']),
      description: map['description'] as String?,
      receiptPath: map['receipt_path'] as String?,
    );
  }
}
