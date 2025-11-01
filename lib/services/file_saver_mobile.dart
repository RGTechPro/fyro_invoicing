import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> saveFile(List<int> bytes, String filename) async {
  try {
    // Get the downloads directory
    final directory = await getDownloadsDirectory() ??
        await getApplicationDocumentsDirectory();

    final path = '${directory.path}/$filename';
    final file = File(path);
    await file.writeAsBytes(bytes);

    print('File saved to: $path');
  } catch (e) {
    print('Error saving file: $e');
    rethrow;
  }
}
