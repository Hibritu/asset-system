import 'dart:convert';
import 'dart:io';
import 'package:asset/models/rentals_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/material_model.dart';
import '../config.dart'; // make sure path is correct

class Api {
  static const baseUrl = "http://localhost:5007/api/";
  
  static get decoded => null;
  
 
  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> createMaterial(Map materialData, String token) async {
    try {
      var url = Uri.parse("${baseUrl}materials");
      final response = await http.post(
        url,
        body: jsonEncode(materialData),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Material created successfully!");
      } else {
        print("Server error: ${response.body}");
      }
    } catch (e) {
      print("Error creating material: $e");
    }
  }

   
  static Future<List<MaterialModel>> getMaterials() async {
  try {
    final url = Uri.parse("${baseUrl}materials");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> materialsJson = jsonDecode(response.body); // ✅ FIXED

      return materialsJson
          .map((item) => MaterialModel.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load materials");
    }
  } catch (e) {
    print("Error fetching materials: $e");
    return [];
  }
}

static Future<bool> deleteMaterial(String id, String token) async {
  try {
    final url = Uri.parse("${baseUrl}materials/$id");
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      print("Failed to delete: ${response.body}");
      return false;
    }
  } catch (e) {
    print("Error deleting material: $e");
    return false;
  }
}

static Future<void> updateMaterial(String id, String token,Map<String, dynamic> updatedData) async {
  final url = Uri.parse("${baseUrl}materials/$id");

  final response = await http.put(
    url,
    body: jsonEncode(updatedData),
    headers: {
      'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update material: ${response.body}');
  }
}
Future<List<Rental>> fetchRentals(String token) async {
  final response = await http.get(
    Uri.parse('${baseUrl}rentals'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    try {
      final body = jsonDecode(response.body);
      final rentalsJson = (body is List)
          ? body
          : (body['data'] is List ? body['data'] as List : <dynamic>[]);
      return rentalsJson.map((json) => Rental.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing rentals: $e');
      throw Exception('Failed to parse rental data');
    }
  } else {
    throw Exception('Failed to load rentals');
  }
}





 
static Future<bool> deleteRental(String id, String token) async {
  final response = await http.delete(
    Uri.parse('${baseUrl}rentals/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  return response.statusCode == 200;
}

static Future<bool> createRentalRequest({
  required String materialId,
  required String rentalDuration,
 required int quantity,

 
  required String notes,
  required String token,
}) async {
  final response = await http.post(
    Uri.parse('${baseUrl}rentals'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'materialId': materialId,
      'rentalDuration': rentalDuration,
       'quantity': quantity,
      'notes': notes,
    }),
  );
  if (response.statusCode == 201) {
    return true;
  } else {
    debugPrint('Create rental failed: ${response.statusCode} ${response.body}');
    return false;
  }
}

static Future<void> updateRental(String id, String token, Map<String, dynamic> updatedData) async {
  final response = await http.put(
    Uri.parse('${baseUrl}rentals/$id'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: json.encode(updatedData),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to update rental');
  }
}
// Inside Api class
static Future<bool> approveRental(String rentalId, String token) async {
  final response = await http.patch(
    Uri.parse('${baseUrl}rentals/$rentalId/approve'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    debugPrint("Approve error: ${response.body}");
    return false;
  }
}
static Future<String?> uploadImage(File imageFile, String token) async {
  final uri = Uri.parse('${AppConfig.baseUrl}/api/upload-image');
  print("Uploading image to: $uri");

  var request = http.MultipartRequest('POST', uri)
    ..headers['Authorization'] = 'Bearer $token'
    ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await http.Response.fromStream(response);
    final data = jsonDecode(responseData.body);
    print('Upload successful. Image URL: ${data['imageUrl']}'); // ✅ Log here
    return data['imageUrl'];
  } else {
    print('Image upload failed: ${response.statusCode}');
    return null;
  }
}


static Future<List<Rental>> getRentals(String token) async {
  final response = await http.get(
    Uri.parse('${baseUrl}rentals'),
    headers: {'Authorization': 'Bearer $token'},
  );

  debugPrint("📨 Raw rental response: ${response.body}");

  if (response.statusCode == 200) {
    final jsonData = json.decode(response.body);
    return (jsonData['data'] as List).map((r) => Rental.fromJson(r)).toList();
  } else {
    throw Exception('Failed to load lendings');
  }
}




}
