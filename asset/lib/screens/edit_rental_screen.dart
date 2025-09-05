import 'package:flutter/material.dart';
import '../models/rentals_model.dart';
import '../services/api.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditRentalScreen extends StatefulWidget {
  final Rental rental;

  const EditRentalScreen({super.key, required this.rental});

  @override
  State<EditRentalScreen> createState() => _EditRentalScreenState();
}

class _EditRentalScreenState extends State<EditRentalScreen> {
  late TextEditingController startDateController;
  late TextEditingController endDateController;
  late TextEditingController quantityController;
 // late TextEditingController statusController;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();

    // Ensure DateTime fields are safely converted to string
    startDateController = TextEditingController(
        text: widget.rental.startDate?.toString() ?? '');
    endDateController = TextEditingController(
        text: widget.rental.endDate?.toString() ?? '');
    quantityController = TextEditingController(
        text: widget.rental.quantity?.toString() ?? '');
    //statusController = TextEditingController(text: widget.rental.status);
    notesController = TextEditingController(text: widget.rental.notes ?? '');
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    quantityController.dispose();
    //statusController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _updateRental() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final updatedRental = {
      "startDate": startDateController.text,
      "endDate": endDateController.text,
      "quantity": quantityController.text,
      //"status": statusController.text,
      "notes": notesController.text,
    };

    try {
      await Api.updateRental(widget.rental.id, token!, updatedRental);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lending updated successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating Lendy: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Lendy - ${widget.rental.materialName}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Material name: ${widget.rental.materialName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('User: ${widget.rental.userName}'),
            Text('Status: ${widget.rental.status}'),

            const SizedBox(height: 16),
            
            TextField(
              controller: startDateController,
              decoration: const InputDecoration(labelText: 'Start Date'),
            ),
            TextField(
              controller: endDateController,
              decoration: const InputDecoration(labelText: 'End Date'),
            ),
           TextField(
              controller: quantityController,
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateRental,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
