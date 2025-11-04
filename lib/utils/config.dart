import 'package:motivegold/utils/util.dart';

// Environment configuration
// Change this value to switch environments:
// - ENV.DEV: Development (localhost)
// - ENV.UAT: UAT/Staging
// - ENV.PRO: Production
var env = const String.fromEnvironment('ENV', defaultValue: 'PRO') == 'DEV'
    ? ENV.DEV
    : const String.fromEnvironment('ENV') == 'UAT'
    ? ENV.UAT
    : ENV.PRO;
