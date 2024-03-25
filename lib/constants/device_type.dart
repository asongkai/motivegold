import 'package:flutter/widgets.dart';

enum DeviceType { Phone, Tablet }

String getDeviceType() {
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
  return data.size.shortestSide < 550 ? 'phone' : 'tablet';
}