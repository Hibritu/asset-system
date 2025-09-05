import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/api.dart';
import '../config.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/material_model.dart';
import '../providers/auth_provider.dart';
import 'package:asset/edit_material_screen.dart';
import 'package:intl/intl.dart';

class FetchDataScreen extends StatefulWidget {
  const FetchDataScreen({super.key});

  @override
  State<FetchDataScreen> createState() => _FetchDataScreenState();
}

class _FetchDataScreenState extends State<FetchDataScreen> {
  late Future<List<MaterialModel>> _materialsFuture;
  final dateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _materialsFuture = Api.getMaterials();
  }

  void _refreshData() {
    setState(() {
      _materialsFuture = Api.getMaterials();
    });
  }

  void _deleteMaterial(String id, String token) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this material?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await Api.deleteMaterial(id, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Material deleted successfully.' : 'Failed to delete material.')),
      );
      if (success) _refreshData();
    }
  }

  void _editMaterial(BuildContext context, MaterialModel item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditMaterialScreen(material: item)),
    ).then((_) => _refreshData());
  }

  void _createRentalRequest(String materialId, String token) async {
  final quantityController = TextEditingController();
  final notesController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String durationText = '';

  // Use the parent Scaffold context for SnackBars and navigation after closing the dialog
  final parentContext = context;

  await showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Create Lending Request'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              startDate = picked;
                            });
                          }
                        },
                        child: Text(
                          startDate != null
                              ? 'From: ${DateFormat('yyyy-MM-dd').format(startDate!)}'
                              : 'Pick Start Date',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: startDate ?? DateTime(2023),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              endDate = picked;
                              if (startDate != null) {
                                final difference = endDate!.difference(startDate!);
                                final years = (difference.inDays / 365).floor();
                                final months = ((difference.inDays % 365) / 30).floor();
                                final days = difference.inDays - (years * 365 + months * 30);
                                durationText =
                                    '$years years $months months $days days';
                              }
                            });
                          }
                        },
                        child: Text(
                          endDate != null
                              ? 'To: ${DateFormat('yyyy-MM-dd').format(endDate!)}'
                              : 'Pick End Date',
                        ),
                      ),
                    ),
                  ],
                ),
                if (durationText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('📆 Duration: $durationText'),
                  ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final quantityText = quantityController.text.trim();
                final notes = notesController.text.trim();

                if (quantityText.isEmpty || int.tryParse(quantityText) == null || int.parse(quantityText) <= 0) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid quantity.')),
                  );
                  return;
                }

                if (startDate == null || endDate == null || startDate!.isAfter(endDate!)) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    const SnackBar(content: Text('Please select a valid date range.')),
                  );
                  return;
                }

                // Close the dialog using the parent context to avoid using a disposed dialog context
                Navigator.pop(parentContext);
                final quantity = int.parse(quantityText);

                // Backend expects rentalDuration as total number of days (integer)
                final totalDays = endDate!.difference(startDate!).inDays;
                final success = await Api.createRentalRequest(
                  materialId: materialId,
                  quantity: quantity,
                  rentalDuration: totalDays.toString(),
                  notes: notes,
                  token: token,
                );

                // Show the SnackBar on the parent ScaffoldMessenger (not the dialog context)
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Lending Request submitted.'
                        : 'Failed to submit Lending Request.'),
                  ),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      appBar: AppBar(title: const Text('Materials')),
      body: FutureBuilder<List<MaterialModel>>(
        future: _materialsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final materials = snapshot.data ?? [];

          // ✅ Sort by createdAt descending (newest first)
          materials.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (materials.isEmpty) {
            return const Center(child: Text("No materials found."));
          }

          return ListView.builder(
            itemCount: materials.length,
            itemBuilder: (context, index) {
              final item = materials[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("📦 Type: ${item.type}"),
                            Text("📍 Location: ${item.location}"),
                            Text("📝 Description: ${item.description}"),
                            Text("🕒 Posted: ${timeago.format(item.createdAt)}",
                                style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text("🔑 QR: ", style: TextStyle(fontWeight: FontWeight.w500)),
                                Expanded(
                                  child: SelectableText(item.qrDataString,
                                      style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  tooltip: 'Copy QR Data',
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: item.qrDataString));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("QR code copied!")),
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text("🔢 Quantity: ", style: TextStyle(fontWeight: FontWeight.w500)),
                                Text(item.quantity.toString(),
                                    style: const TextStyle(fontSize: 16, color: Colors.teal)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  onPressed: () => _editMaterial(context, item),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.delete, size: 18),
                                  label: const Text('Delete'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  onPressed: () => _deleteMaterial(item.id, token!),
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.shopping_cart, size: 18),
                                  label: const Text('Lend Request'),
                                  onPressed: () => _createRentalRequest(item.id, token!),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
