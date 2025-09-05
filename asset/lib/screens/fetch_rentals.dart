import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/rentals_model.dart';
import '../screens/edit_rental_screen.dart';
import '../services/api.dart';
import '../widgets/approve_rental_button.dart';
//import '../config.dart';

class FetchRentalScreen extends StatefulWidget {
  const FetchRentalScreen({super.key});

  @override
  State<FetchRentalScreen> createState() => _FetchRentalScreenState();
}

class _FetchRentalScreenState extends State<FetchRentalScreen> {
  List<Rental> rentals = [];
  bool isLoading = true;
  final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    fetchRentals();
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await fetchRentals();
  }

  Future<void> _deleteRental(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this rental?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await Api.deleteRental(id, token);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Lendly deleted')));
        _refreshData();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Failed to delete Lendly')));
      }
    }
  }

  Future<void> _editRental(BuildContext context, Rental rental) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditRentalScreen(rental: rental),
      ),
    );
    await _refreshData();
  }

  Future<void> fetchRentals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final rentalsData = await Api.getRentals(token);

      // Safely sort (newest first)
      rentalsData.sort((a, b) {
        if (a.requestDate == null || b.requestDate == null) return 0;
        return b.requestDate!.compareTo(a.requestDate!);
      });

      setState(() {
        rentals = rentalsData;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching rentals: $e');
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No Lendly requests found: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asset Lending Requests")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                itemCount: rentals.length,
                itemBuilder: (context, index) {
                  final rental = rentals[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📦 Material name: ${rental.materialName}',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text('👤 Requested by: ${rental.userName}'),

                         Text(
                                  '📥 Requested: ${rental.requestDate != null ? timeago.format(rental.requestDate!.toLocal()) : 'N/A'}',
                                     style: const TextStyle(color: Colors.grey),
                               ),

                          
                          Text('📅 Start: ${rental.startDate != null ? dateFormatter.format(rental.startDate!.toLocal()) : 'N/A'}'),
                          Text('📅 End: ${rental.endDate != null ? dateFormatter.format(rental.endDate!.toLocal()) : 'N/A'}'),
                          Text('📝 Status: ${rental.status}',
                              style: TextStyle(
                                  color: rental.status == 'approved'
                                      ? Colors.green
                                      : Colors.orange)),
                        
                            Text('🗒 Notes: ${rental.notes!}'),
                          const SizedBox(height: 12),
                                          Row(
  children: [
    const Text('🔢 Quantity: '),
    Text(
      rental.quantity.toString(),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: int.tryParse(rental.quantity.toString()) != null &&
                int.parse(rental.quantity.toString()) > 5
            ? Colors.red
            : Colors.teal,
      ),
    ),
  ],
),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _editRental(context, rental),
                                icon: const Icon(Icons.edit, size: 18),
                                label: const Text('Edit'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color.fromARGB(255, 16, 13, 211),
                                  side: const BorderSide(color: Colors.blue),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _deleteRental(rental.id),
                                icon: const Icon(Icons.delete, size: 18),
                                label: const Text('Delete'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                              ),
                              ApproveRentalButton(
                                rentalId: rental.id,
                                currentStatus: rental.status,
                                onApproved: _refreshData,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
