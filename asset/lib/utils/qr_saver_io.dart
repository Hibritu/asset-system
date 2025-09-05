import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// IO implementation: saves a base64 PNG to application documents directory
/// and returns the file path.
Future<String> saveBase64Png(String base64Data, String filename) async {
  final bytes = base64Decode(base64Data);
  final directory = await getApplicationDocumentsDirectory();
  await directory.create(recursive: true);
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
  return file.path;
}
