bool isNetworkURL(String url) {
    return url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('ftp://') ||
        url.startsWith('www.');
  }


  String generateRandomId() {
    // You can use a more robust UUID implementation if needed.
    // Here, just randomizing from current timestamp + a random int.
    final millis = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch.remainder(100000);
    return '$millis$random';
  }