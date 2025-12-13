import 'package:motivegold/utils/util.dart';
import 'package:flutter/foundation.dart';

// Environment configuration
// Automatically detects environment:
// 1. In debug mode (flutter run) → Uses DEV
// 2. With --dart-define=ENV=UAT → Uses UAT
// 3. With --dart-define=ENV=PRO or release build → Uses PRO
//
// Examples:
// flutter run → DEV (localhost)
// flutter build web --dart-define=ENV=UAT → UAT
// flutter build web --dart-define=ENV=PRO → PRO (production)
var env = _getEnvironment();

ENV _getEnvironment() {
  // Check if explicitly set via dart-define
  const envString = String.fromEnvironment('ENV', defaultValue: '');

  if (envString == 'DEV') {
    return ENV.DEV;
  } else if (envString == 'UAT') {
    return ENV.UAT;
  } else if (envString == 'PRO') {
    return ENV.PRO;
  }

  // Auto-detect: debug mode = UAT (for testing), release mode = PRO
  if (kDebugMode) {
    return ENV.UAT; // Changed from DEV to UAT for easier testing
  } else {
    return ENV.PRO; // flutter build web, flutter build apk, etc.
  }
}
