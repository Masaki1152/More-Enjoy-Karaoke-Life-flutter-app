import 'dart:math';

String generateDeviceId() {
  final random = Random();
  return 'dev_${random.nextInt(9999999)}';
}