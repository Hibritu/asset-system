import 'dart:convert';
import 'dart:html' as html;

/// Web implementation: triggers a browser download of a base64 PNG
/// and returns a pseudo path (the filename).
Future<String> saveBase64Png(String base64Data, String filename) async {
  final bytes = base64Decode(base64Data);
  final blob = html.Blob([bytes], 'image/png');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
  return filename;
}
