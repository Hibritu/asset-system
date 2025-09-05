import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:zxing2/qrcode.dart';
import 'package:image/image.dart' as img;
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter/foundation.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String? decryptedText;
  bool isLoading = false;

  // AES-128-CBC Decryption
  String decryptQR(String encryptedBase64Text) {
    try {
      final key = encrypt.Key.fromUtf8('MySecureKey12345'); // 16-char key
      final iv = encrypt.IV.fromBase64(base64Encode(Uint8List(16))); // All-zero IV
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: 'PKCS7'),
      );
      return encrypter.decrypt64(encryptedBase64Text, iv: iv);
    } catch (e) {
      return '❌ Decryption failed: ${e.toString()}';
    }
  }

  Future<void> pickAndScanImage() async {
    setState(() {
      isLoading = true;
      decryptedText = null;
    });

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );
    if (result == null || result.files.single.path == null) {
      setState(() => isLoading = false);
      return;
    }

    Uint8List? bytes;
    if (kIsWeb) {
      bytes = result.files.single.bytes;
      if (bytes == null) {
        setState(() {
          decryptedText = '❌ No image data available.';
          isLoading = false;
        });
        return;
      }
    } else {
      final filePath = result.files.single.path!;
      bytes = await File(filePath).readAsBytes();
    }
    final image = img.decodeImage(bytes);

    if (image == null) {
      setState(() {
        decryptedText = '❌ Could not decode image.';
        isLoading = false;
      });
      return;
    }

    final argbData = Int32List.fromList(
      image.getBytes(order: img.ChannelOrder.rgba).buffer.asInt32List(),
    );

    final luminanceSource =
        RGBLuminanceSource(image.width, image.height, argbData);
    final bitmap = BinaryBitmap(HybridBinarizer(luminanceSource));
    final reader = QRCodeReader();

    try {
      final scanResult = reader.decode(bitmap);
      final decrypted = decryptQR(scanResult.text);
      setState(() {
        decryptedText = decrypted;
      });
    } catch (e) {
      setState(() => decryptedText = '❌ QR decode failed: ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> startLiveScan() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LiveQRScanner()),
    );
    if (result != null && result is String) {
      final decrypted = decryptQR(result);
      setState(() {
        decryptedText = decrypted;
      });
    }
  }

  Widget _buildDecryptedContent() {
    if (decryptedText != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.greenAccent),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                decryptedText!,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              tooltip: 'Copy Text',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: decryptedText!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Copied to clipboard")),
                );
              },
            )
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure QR Scanner")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: pickAndScanImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Scan from Image'),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: startLiveScan,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Live QR Scan'),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  _buildDecryptedContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔹 Live QR Scanner Screen
class LiveQRScanner extends StatelessWidget {
  const LiveQRScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live QR Scanner')),
      body: MobileScanner(
        onDetect: (BarcodeCapture capture) {
          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            Navigator.pop(context, barcodes.first.rawValue);
          }
        },
      ),
    );
  }
}
