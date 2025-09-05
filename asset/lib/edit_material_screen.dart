import 'package:flutter/material.dart';
import '../models/material_model.dart';
import '../services/api.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class EditMaterialScreen extends StatefulWidget {
  final MaterialModel material;

  const EditMaterialScreen({super.key, required this.material});

  @override
  State<EditMaterialScreen> createState() => _EditMaterialScreenState();
}

class _EditMaterialScreenState extends State<EditMaterialScreen> {
  late TextEditingController nameController;
  late TextEditingController typeController;
  late TextEditingController quantityController;
  late TextEditingController locationController;
  late TextEditingController descriptionController;
 

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.material.name);
    typeController = TextEditingController(text: widget.material.type);
    quantityController = TextEditingController(text: widget.material.quantity.toString());
    locationController = TextEditingController(text: widget.material.location);
    descriptionController = TextEditingController(text: widget.material.description);
   
  }

  @override
  void dispose() {
    nameController.dispose();
    typeController.dispose();
    quantityController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateMaterial() async {
  final updatedMaterial = {
    "name": nameController.text,
    "type": typeController.text,
    "quantity": quantityController.text,
    "location": locationController.text,
    "description": descriptionController.text,
    
  };

  final token = Provider.of<AuthProvider>(context, listen: false).token;

  try {
    await Api.updateMaterial(widget.material.id, token!, updatedMaterial);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Material updated successfully")),
    );
    Navigator.pop(context);
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error updating material: $e")),
    );
  }
}

  Widget _buildImagePreview(String url) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      height: 150,
      decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${widget.material.name}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
             TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Type')),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location')),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateMaterial,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
