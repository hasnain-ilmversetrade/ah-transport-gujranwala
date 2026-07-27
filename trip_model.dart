import 'expense_model.dart';

class Trip {
  final int? id;
  final String tripNumber;
  final DateTime date;
  final int vehicleId;
  final int driverId;
  final int customerId;
  final String loadingPoint;
  final String unloadingPoint;
  final String goodsType;
  final double weight;
  final double freightAmount;
  final double advancePayment;
  final String status; // Active / Completed / Cancelled
  final String? notes;

  // Not stored directly on trips table; loaded via join
  final List<TripExpense> expenses;

  Trip({
    this.id,
    required this.tripNumber,
    required this.date,
    required this.vehicleId,
    required this.driverId,
    required this.customerId,
    required this.loadingPoint,
    required this.unloadingPoint,
    required this.goodsType,
    this.weight = 0,
    required this.freightAmount,
    this.advancePayment = 0,
    this.status = 'Active',
    this.notes,
    this.expenses = const [],
  });

  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);
  double get profit => freightAmount - totalExpenses;
  double get remainingPayment => freightAmount - advancePayment;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_number': tripNumber,
      'date': date.toIso8601String(),
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'customer_id': customerId,
      'loading_point': loadingPoint,
      'unloading_point': unloadingPoint,
      'goods_type': goodsType,
      'weight': weight,
      'freight_amount': freightAmount,
      'advance_payment': advancePayment,
      'status': status,
      'notes': notes,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map, {List<TripExpense> expenses = const []}) {
    return Trip(
      id: map['id'] as int?,
      tripNumber: map['trip_number'] as String,
      date: DateTime.parse(map['date']),
      vehicleId: map['vehicle_id'] as int,
      driverId: map['driver_id'] as int,
      customerId: map['customer_id'] as int,
      loadingPoint: map['loading_point'] as String,
      unloadingPoint: map['unloading_point'] as String,
      goodsType: map['goods_type'] as String,
      weight: (map['weight'] as num?)?.toDouble() ?? 0,
      freightAmount: (map['freight_amount'] as num?)?.toDouble() ?? 0,
      advancePayment: (map['advance_payment'] as num?)?.toDouble() ?? 0,
      status: map['status'] as String? ?? 'Active',
      notes: map['notes'] as String?,
      expenses: expenses,
    );
  }
}
