import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../models/vehicle_model.dart';
import '../models/partner_model.dart';
import '../models/driver_model.dart';
import '../models/customer_model.dart';
import '../models/trip_model.dart';
import '../models/expense_model.dart';
import '../utils/helpers.dart';

class AppStateProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Theme & language
  ThemeMode themeMode = ThemeMode.light;
  String language = 'en'; // 'en' or 'ur'

  // Data caches
  List<Vehicle> vehicles = [];
  List<Partner> partners = [];
  List<Driver> drivers = [];
  List<Customer> customers = [];
  List<Trip> trips = [];

  bool isLoading = false;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? 'light';
    themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    language = prefs.getString('language') ?? 'en';
    await refreshAll();
  }

  Future<void> toggleTheme() async {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
  }

  Future<void> refreshAll() async {
    isLoading = true;
    notifyListeners();
    vehicles = await _db.getVehicles();
    partners = await _db.getPartners();
    drivers = await _db.getDrivers();
    customers = await _db.getCustomers();
    trips = await _db.getTrips();
    isLoading = false;
    notifyListeners();
  }

  // ---- Vehicles ----
  Future<void> addVehicle(Vehicle v) async {
    await _db.insertVehicle(v);
    vehicles = await _db.getVehicles();
    notifyListeners();
  }

  Future<void> updateVehicle(Vehicle v) async {
    await _db.updateVehicle(v);
    vehicles = await _db.getVehicles();
    notifyListeners();
  }

  Future<void> deleteVehicle(int id) async {
    await _db.deleteVehicle(id);
    vehicles = await _db.getVehicles();
    notifyListeners();
  }

  // ---- Partners ----
  Future<void> addPartner(Partner p) async {
    await _db.insertPartner(p);
    partners = await _db.getPartners();
    notifyListeners();
  }

  // ---- Drivers ----
  Future<void> addDriver(Driver d) async {
    await _db.insertDriver(d);
    drivers = await _db.getDrivers();
    notifyListeners();
  }

  Future<void> updateDriver(Driver d) async {
    await _db.updateDriver(d);
    drivers = await _db.getDrivers();
    notifyListeners();
  }

  Future<void> deleteDriver(int id) async {
    await _db.deleteDriver(id);
    drivers = await _db.getDrivers();
    notifyListeners();
  }

  // ---- Customers ----
  Future<void> addCustomer(Customer c) async {
    await _db.insertCustomer(c);
    customers = await _db.getCustomers();
    notifyListeners();
  }

  Future<void> updateCustomer(Customer c) async {
    await _db.updateCustomer(c);
    customers = await _db.getCustomers();
    notifyListeners();
  }

  Future<void> deleteCustomer(int id) async {
    await _db.deleteCustomer(id);
    customers = await _db.getCustomers();
    notifyListeners();
  }

  // ---- Trips ----
  Future<void> addTrip(Trip t, List<TripExpense> expenses) async {
    final id = await _db.insertTrip(t);
    for (final e in expenses) {
      await _db.insertTripExpense(TripExpense(
        tripId: id,
        category: e.category,
        amount: e.amount,
        description: e.description,
      ));
    }
    trips = await _db.getTrips();
    notifyListeners();
  }

  Future<void> deleteTrip(int id) async {
    await _db.deleteTrip(id);
    trips = await _db.getTrips();
    notifyListeners();
  }

  Future<String> nextTripNumber() async {
    final seq = await _db.getNextTripSeq();
    return Helpers.generateTripNumber(seq);
  }

  Future<Map<String, double>> summary({DateTime? from, DateTime? to}) {
    return _db.getSummary(from: from, to: to);
  }

  Vehicle? vehicleById(int id) {
    try {
      return vehicles.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }

  Driver? driverById(int id) {
    try {
      return drivers.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Customer? customerById(int id) {
    try {
      return customers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
