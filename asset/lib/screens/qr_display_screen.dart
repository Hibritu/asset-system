import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:asset/utils/qr_saver.dart';

class QRDisplayScreen extends StatefulWidget {
  const QRDisplayScreen({super.key});

  @override
  State<QRDisplayScreen> createState() => _QRDisplayScreenState();
}

class _QRDisplayScreenState extends State<QRDisplayScreen> {
  final TextEditingController _qrInputController = TextEditingController();
  String? qrCodeBase64;
  bool isLoading = false;
  String errorMessage = '';
  bool hasNetworkError = false;

  // Normalize base64 by stripping any data URL header and whitespace/newlines
  String _normalizedBase64(String data) {
    final part = data.contains(',') ? data.split(',').last : data;
    return part.replaceAll(RegExp(r"\s+"), '');
  }

  Future<void> fetchQRCode(String qrDataString) async {
    if (qrDataString.isEmpty) return;

    setState(() {
      isLoading = true;
      qrCodeBase64 = null;
      errorMessage = '';
      hasNetworkError = false;
    });

    try {
      final url = Uri.parse('http://localhost:5007/api/materials/qr/$qrDataString');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['qrCodeData'] != null) {
          setState(() {
            qrCodeBase64 = data['qrCodeData'];
          });
        } else {
          throw Exception('QR code data not found in response');
        }
      } else {
        throw Exception('Server responded with status code: ${response.statusCode}');
      }
    } on SocketException {
      setState(() {
        errorMessage = 'Network error. Please check your connection.';
        hasNetworkError = true;
      });
    } on http.ClientException {
      setState(() {
        errorMessage = 'Could not connect to the server.';
        hasNetworkError = true;
      });
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timed out. Please try again.';
        hasNetworkError = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _retryFetch() async {
    if (_qrInputController.text.isNotEmpty) {
      await fetchQRCode(_qrInputController.text.trim());
    }
  }

  void copyBase64() {
    if (qrCodeBase64 != null) {
      Clipboard.setData(ClipboardData(text: qrCodeBase64!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR base64 copied to clipboard')),
      );
    }
  }

  Future<void> saveQRCodeToFile() async {
    if (qrCodeBase64 == null) return;

    try {
      final filename = 'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
      final savedPath = await saveBase64Png(_normalizedBase64(qrCodeBase64!), filename);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(kIsWeb
              ? 'QR code downloaded as $filename'
              : 'QR code saved to $savedPath'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              // Optional: implement open logic for non-web platforms using a file opener package
            },
          ),
        ),
      );
    } on FormatException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid QR image data: ${e.message}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.toString()}')),
      );
    }
  }

  Future<void> shareQRCode() async {
    if (qrCodeBase64 == null) return;

    try {
      final filename = 'qr_${DateTime.now().millisecondsSinceEpoch}.png';
      if (kIsWeb) {
        // On web, trigger a download instead of using share APIs
        await saveBase64Png(_normalizedBase64(qrCodeBase64!), filename);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QR downloaded as $filename')),
        );
      } else {
        final bytes = base64Decode(_normalizedBase64(qrCodeBase64!));
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/$filename';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: 'Scan this QR Code to view the asset',
          subject: 'QR Code',
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing QR: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _qrInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Viewer"),
        actions: [
          if (qrCodeBase64 != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryFetch,
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _qrInputController,
              decoration: InputDecoration(
                labelText: 'Enter QR Code String',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => fetchQRCode(_qrInputController.text.trim()),
                ),
              ),
              onSubmitted: (value) => fetchQRCode(value.trim()),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (qrCodeBase64 != null) ...[
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(_normalizedBase64(qrCodeBase64!)),
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, size: 50, color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: copyBase64,
                            icon: const Icon(Icons.copy, size: 18),
                            label: const Text("Copy Base64"),
                          ),
                          FilledButton.icon(
                            onPressed: saveQRCodeToFile,
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text("Save"),
                          ),
                          FilledButton.icon(
                            onPressed: shareQRCode,
                            icon: const Icon(Icons.share, size: 18),
                            label: const Text("Share"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (errorMessage.isNotEmpty)
              Column(
                children: [
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: hasNetworkError ? Colors.orange : Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasNetworkError)
                    TextButton(
                      onPressed: _retryFetch,
                      child: const Text('Retry'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}