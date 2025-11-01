// Stub implementation for unsupported platforms
Future<void> saveFile(List<int> bytes, String filename) async {
  throw UnsupportedError('File saving is not supported on this platform');
}
