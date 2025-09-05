import 'package:flutter/material.dart';
import '../models/rentals_model.dart';
import '../services/api.dart';

class RentalProvider extends ChangeNotifier {
  List<Rental> _rentals = [];

  List<Rental> get rentals => _rentals;

  int get pendingCount => _rentals.where((r) => r.status == 'pending').length;

  Future<void> fetchRentals(String token) async {
    try {
      _rentals = await Api.getRentals(token); // ✅ Now valid
      notifyListeners();
    } catch (e) {
      print("Failed to fetch rentals: $e");
    }
  }

  void clearNotifications() {
  _rentals.removeWhere((r) => r.status == 'pending');
  notifyListeners();
}

}
