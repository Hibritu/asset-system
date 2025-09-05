import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api.dart';
//import '../models/rentals_model.dart';

class ApproveRentalButton extends StatefulWidget {
  final String rentalId;
  final String currentStatus; // ✅ pass current rental status
  final VoidCallback onApproved;

  const ApproveRentalButton({
    super.key,
    required this.rentalId,
    required this.currentStatus,
    required this.onApproved,
  });

  @override
  State<ApproveRentalButton> createState() => _ApproveRentalButtonState();
}

class _ApproveRentalButtonState extends State<ApproveRentalButton> {
  bool isLoading = false;

  Future<void> _approveRental() async {
    if (widget.currentStatus.toLowerCase() == 'approved') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This rental is already approved'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final success = await Api.approveRental(widget.rentalId, token);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Rental approved successfully' : 'Failed to approve rental'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    setState(() => isLoading = false);

    if (success) {
      widget.onApproved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: isLoading ? null : _approveRental,
      icon: isLoading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(Icons.check, size: 18),
      label: Text(isLoading ? 'Approving...' : 'Approve'),
    );
  }
}
