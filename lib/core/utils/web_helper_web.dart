import 'dart:html' as html;

void downloadFileWeb(Uint8List bytes, String fileName) {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
    ..click();
  html.Url.revokeObjectUrl(url);
}
