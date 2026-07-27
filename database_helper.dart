import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle_model.dart';
import '../models/partner_model.dart';
import '../models/driver_model.dart';
import '../models/customer_model.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../utils/constants.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE partners(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        cnic TEXT,
        address TEXT,
        default_share_percent REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE vehicles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_number TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        model TEXT,
        ownership_type TEXT NOT NULL,
        partner_id INTEGER,
        partner_share_percent REAL DEFAULT 0,
        purchase_date TEXT,
        insurance_expiry TEXT,
        token_expiry TEXT,
        fitness_expiry TEXT,
        notes TEXT,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (partner_id) REFERENCES partners (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE drivers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        license_number TEXT,
        license_expiry TEXT,
        address TEXT,
        salary_type TEXT DEFAULT 'Monthly',
        salary_amount REAL DEFAULT 0,
        is_active INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        cnic_ntn TEXT,
        address TEXT,
        credit_limit REAL DEFAULT 0,
        outstanding_balance REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE trips(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_number TEXT NOT NULL,
        date TEXT NOT NULL,
        vehicle_id INTEGER NOT NULL,
        driver_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        loading_point TEXT,
        unloading_point TEXT,
        goods_type TEXT,
        weight REAL DEFAULT 0,
        freight_amount REAL DEFAULT 0,
        advance_payment REAL DEFAULT 0,
        status TEXT DEFAULT 'Active',
        notes TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id),
        FOREIGN KEY (driver_id) REFERENCES drivers (id),
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE trip_expenses(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        trip_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        amount REAL DEFAULT 0,
        description TEXT,
        FOREIGN KEY (trip_id) REFERENCES trips (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        cost REAL DEFAULT 0,
        notes TEXT,
        FOREIGN KEY (vehicle_id) REFERENCES vehicles (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        amount REAL DEFAULT 0,
        date TEXT NOT NULL,
        description TEXT,
        receipt_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_trips_date ON trips(date)');
    await db.execute('CREATE INDEX idx_trips_vehicle ON trips(vehicle_id)');
    await db.execute('CREATE INDEX idx_expenses_trip ON trip_expenses(trip_id)');
  }

  // ---------------- VEHICLES ----------------
  Future<int> insertVehicle(Vehicle v) async {
    final db = await database;
    return db.insert('vehicles', v.toMap()..remove('id'));
  }

  Future<int> updateVehicle(Vehicle v) async {
    final db = await database;
    return db.update('vehicles', v.toMap(), where: 'id = ?', whereArgs: [v.id]);
  }

  Future<int> deleteVehicle(int id) async {
    final db = await database;
    return db.delete('vehicles', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Vehicle>> getVehicles({String? query}) async {
    final db = await database;
    final maps = await db.query(
      'vehicles',
      where: query != null && query.isNotEmpty ? 'vehicle_number LIKE ? OR type LIKE ?' : null,
      whereArgs: query != null && query.isNotEmpty ? ['%$query%', '%$query%'] : null,
      orderBy: 'id DESC',
    );
    return maps.map((m) => Vehicle.fromMap(m)).toList();
  }

  // ---------------- PARTNERS ----------------
  Future<int> insertPartner(Partner p) async {
    final db = await database;
    return db.insert('partners', p.toMap()..remove('id'));
  }

  Future<int> updatePartner(Partner p) async {
    final db = await database;
    return db.update('partners', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  Future<int> deletePartner(int id) async {
    final db = await database;
    return db.delete('partners', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Partner>> getPartners() async {
    final db = await database;
    final maps = await db.query('partners', orderBy: 'name ASC');
    return maps.map((m) => Partner.fromMap(m)).toList();
  }

  // ---------------- DRIVERS ----------------
  Future<int> insertDriver(Driver d) async {
    final db = await database;
    return db.insert('drivers', d.toMap()..remove('id'));
  }

  Future<int> updateDriver(Driver d) async {
    final db = await database;
    return db.update('drivers', d.toMap(), where: 'id = ?', whereArgs: [d.id]);
  }

  Future<int> deleteDriver(int id) async {
    final db = await database;
    return db.delete('drivers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Driver>> getDrivers({String? query}) async {
    final db = await database;
    final maps = await db.query(
      'drivers',
      where: query != null && query.isNotEmpty ? 'name LIKE ? OR phone LIKE ?' : null,
      whereArgs: query != null && query.isNotEmpty ? ['%$query%', '%$query%'] : null,
      orderBy: 'name ASC',
    );
    return maps.map((m) => Driver.fromMap(m)).toList();
  }

  // ---------------- CUSTOMERS ----------------
  Future<int> insertCustomer(Customer c) async {
    final db = await database;
    return db.insert('customers', c.toMap()..remove('id'));
  }

  Future<int> updateCustomer(Customer c) async {
    final db = await database;
    return db.update('customers', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  Future<int> deleteCustomer(int id) async {
    final db = await database;
    return db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Customer>> getCustomers({String? query}) async {
    final db = await database;
    final maps = await db.query(
      'customers',
      where: query != null && query.isNotEmpty ? 'name LIKE ? OR phone LIKE ?' : null,
      whereArgs: query != null && query.isNotEmpty ? ['%$query%', '%$query%'] : null,
      orderBy: 'name ASC',
    );
    return maps.map((m) => Customer.fromMap(m)).toList();
  }

  // ---------------- TRIPS ----------------
  Future<int> insertTrip(Trip t) async {
    final db = await database;
    return db.insert('trips', t.toMap()..remove('id'));
  }

  Future<int> updateTrip(Trip t) async {
    final db = await database;
    return db.update('trips', t.toMap(), where: 'id = ?', whereArgs: [t.id]);
  }

  Future<int> deleteTrip(int id) async {
    final db = await database;
    await db.delete('trip_expenses', where: 'trip_id = ?', whereArgs: [id]);
    return db.delete('trips', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Trip>> getTrips({
    DateTime? from,
    DateTime? to,
    int? vehicleId,
    int? driverId,
    int? customerId,
    String? status,
  }) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];

    if (from != null) {
      conditions.add('date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('date <= ?');
      args.add(to.toIso8601String());
    }
    if (vehicleId != null) {
      conditions.add('vehicle_id = ?');
      args.add(vehicleId);
    }
    if (driverId != null) {
      conditions.add('driver_id = ?');
      args.add(driverId);
    }
    if (customerId != null) {
      conditions.add('customer_id = ?');
      args.add(customerId);
    }
    if (status != null) {
      conditions.add('status = ?');
      args.add(status);
    }

    final maps = await db.query(
      'trips',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: conditions.isEmpty ? null : args,
      orderBy: 'date DESC',
    );

    final trips = <Trip>[];
    for (final m in maps) {
      final expenses = await getTripExpenses(m['id'] as int);
      trips.add(Trip.fromMap(m, expenses: expenses));
    }
    return trips;
  }

  Future<int> getNextTripSeq() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM trips');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ---------------- TRIP EXPENSES ----------------
  Future<int> insertTripExpense(TripExpense e) async {
    final db = await database;
    return db.insert('trip_expenses', e.toMap()..remove('id'));
  }

  Future<int> deleteTripExpensesForTrip(int tripId) async {
    final db = await database;
    return db.delete('trip_expenses', where: 'trip_id = ?', whereArgs: [tripId]);
  }

  Future<List<TripExpense>> getTripExpenses(int tripId) async {
    final db = await database;
    final maps = await db.query('trip_expenses', where: 'trip_id = ?', whereArgs: [tripId]);
    return maps.map((m) => TripExpense.fromMap(m)).toList();
  }

  // ---------------- TRANSACTIONS (standalone income/expense) ----------------
  Future<int> insertTransaction(Transaction t) async {
    final db = await database;
    return db.insert('transactions', t.toMap()..remove('id'));
  }

  Future<List<Transaction>> getTransactions({DateTime? from, DateTime? to}) async {
    final db = await database;
    final conditions = <String>[];
    final args = <dynamic>[];
    if (from != null) {
      conditions.add('date >= ?');
      args.add(from.toIso8601String());
    }
    if (to != null) {
      conditions.add('date <= ?');
      args.add(to.toIso8601String());
    }
    final maps = await db.query(
      'transactions',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: conditions.isEmpty ? null : args,
      orderBy: 'date DESC',
    );
    return maps.map((m) => Transaction.fromMap(m)).toList();
  }

  // ---------------- DASHBOARD AGGREGATES ----------------
  Future<Map<String, double>> getSummary({DateTime? from, DateTime? to}) async {
    final trips = await getTrips(from: from, to: to);
    double income = 0, expense = 0;
    for (final t in trips) {
      income += t.freightAmount;
      expense += t.totalExpenses;
    }
    final txns = await getTransactions(from: from, to: to);
    for (final tx in txns) {
      if (tx.type == 'income') {
        income += tx.amount;
      } else {
        expense += tx.amount;
      }
    }
    return {
      'trips': trips.length.toDouble(),
      'income': income,
      'expense': expense,
      'profit': income - expense,
    };
  }
}
