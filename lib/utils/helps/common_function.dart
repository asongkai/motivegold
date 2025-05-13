import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void motivePrint(Object? object) {
  if (kDebugMode) {
    print(object);
  }
}

Map<String, dynamic> readAndroidBuildData(AndroidDeviceInfo build) {
  return <String, dynamic>{
    'version.securityPatch': build.version.securityPatch,
    'version.sdkInt': build.version.sdkInt,
    'version.release': build.version.release,
    'version.previewSdkInt': build.version.previewSdkInt,
    'version.incremental': build.version.incremental,
    'version.codename': build.version.codename,
    'version.baseOS': build.version.baseOS,
    'board': build.board,
    'bootloader': build.bootloader,
    'brand': build.brand,
    'device': build.device,
    'display': build.display,
    'fingerprint': build.fingerprint,
    'hardware': build.hardware,
    'host': build.host,
    'id': build.id,
    'manufacturer': build.manufacturer,
    'model': build.model,
    'product': build.product,
    // 'supported32BitAbis': build.supported32BitAbis,
    // 'supported64BitAbis': build.supported64BitAbis,
    // 'supportedAbis': build.supportedAbis,
    'tags': build.tags,
    'type': build.type,
    'isPhysicalDevice': build.isPhysicalDevice,
    // 'systemFeatures': build.systemFeatures,
    'serialNumber': build.serialNumber
  };
}

Map<String, dynamic> readIosDeviceInfo(IosDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'systemName': data.systemName,
    'systemVersion': data.systemVersion,
    'model': data.model,
    'localizedModel': data.localizedModel,
    'identifierForVendor': data.identifierForVendor,
    'isPhysicalDevice': data.isPhysicalDevice,
    'utsname.sysname:': data.utsname.sysname,
    'utsname.nodename:': data.utsname.nodename,
    'utsname.release:': data.utsname.release,
    'utsname.version:': data.utsname.version,
    'utsname.machine:': data.utsname.machine,
  };
}

Map<String, dynamic> readLinuxDeviceInfo(LinuxDeviceInfo data) {
  return <String, dynamic>{
    'name': data.name,
    'version': data.version,
    'id': data.id,
    'idLike': data.idLike,
    'versionCodename': data.versionCodename,
    'versionId': data.versionId,
    'prettyName': data.prettyName,
    'buildId': data.buildId,
    'variant': data.variant,
    'variantId': data.variantId,
    'machineId': data.machineId,
  };
}

Map<String, dynamic> readWebBrowserInfo(WebBrowserInfo data) {
  return <String, dynamic>{
    'browserName': data.browserName.name,
    'appCodeName': data.appCodeName,
    'appName': data.appName,
    'appVersion': data.appVersion,
    'deviceMemory': data.deviceMemory,
    'language': data.language,
    'languages': data.languages,
    'platform': data.platform,
    'product': data.product,
    'productSub': data.productSub,
    'userAgent': data.userAgent,
    'vendor': data.vendor,
    'vendorSub': data.vendorSub,
    'hardwareConcurrency': data.hardwareConcurrency,
    'maxTouchPoints': data.maxTouchPoints,
  };
}

Map<String, dynamic> readMacOsDeviceInfo(MacOsDeviceInfo data) {
  return <String, dynamic>{
    'computerName': data.computerName,
    'hostName': data.hostName,
    'arch': data.arch,
    'model': data.model,
    'kernelVersion': data.kernelVersion,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'patchVersion': data.patchVersion,
    'osRelease': data.osRelease,
    'activeCPUs': data.activeCPUs,
    'memorySize': data.memorySize,
    'cpuFrequency': data.cpuFrequency,
    'systemGUID': data.systemGUID,
  };
}

Map<String, dynamic> readWindowsDeviceInfo(WindowsDeviceInfo data) {
  return <String, dynamic>{
    'numberOfCores': data.numberOfCores,
    'computerName': data.computerName,
    'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
    'userName': data.userName,
    'majorVersion': data.majorVersion,
    'minorVersion': data.minorVersion,
    'buildNumber': data.buildNumber,
    'platformId': data.platformId,
    'csdVersion': data.csdVersion,
    'servicePackMajor': data.servicePackMajor,
    'servicePackMinor': data.servicePackMinor,
    'suitMask': data.suitMask,
    'productType': data.productType,
    'reserved': data.reserved,
    'buildLab': data.buildLab,
    'buildLabEx': data.buildLabEx,
    'digitalProductId': data.digitalProductId,
    'displayVersion': data.displayVersion,
    'editionId': data.editionId,
    'installDate': data.installDate,
    'productId': data.productId,
    'productName': data.productName,
    'registeredOwner': data.registeredOwner,
    'releaseId': data.releaseId,
    'deviceId': data.deviceId,
  };
}

double priceIncludeTaxTotalSN(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i].orderTypeId == 1) {
      for (int j = 0; j < orders[i].details.length; j++) {
        amount += orders[i]!.priceIncludeTax ?? 0;
      }
    }
  }
  return amount;
}

double priceIncludeTaxTotalBU(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i].orderTypeId == 2) {
      for (int j = 0; j < orders[i].details.length; j++) {
        amount += orders[i]!.priceIncludeTax ?? 0;
      }
    }
  }
  return amount;
}

double discountTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i].orderTypeId == 1) {
      amount += orders[i]!.discount ?? 0;
    }
  }
  return amount;
}

double priceIncludeTaxTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += orders[i]!.priceIncludeTax ?? 0;
  }
  return amount;
}

double purchasePriceTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += orders[i]!.purchasePrice ?? 0;
  }
  return amount;
}

double priceDiffTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += orders[i]!.priceDiff ?? 0;
  }
  return amount;
}

double taxBaseTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += orders[i]!.taxBase ?? 0;
  }
  return amount;
}

double taxAmountTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += orders[i]!.taxAmount ?? 0;
  }
  return amount;
}

double priceExcludeTaxTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += orders[i]!.priceExcludeTax ?? 0;
  }
  return amount;
}

double commissionTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    for (int j = 0; j < orders[i].details.length; j++) {
      amount += orders[i]!.details[j].commission ?? 0;
      amount += orders[i]!.details[j].taxAmount ?? 0;
      amount += orders[i]!.details[j].packagePrice ?? 0;
    }
  }
  return amount;
}

double getWeightTotal(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += getWeight(orders[i]!);
  }
  return amount;
}

double getWeightTotalBU(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i].orderTypeId == 2) {
      amount += getWeight(orders[i]!);
    }
  }
  return amount;
}

double getWeightTotalSN(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    if (orders[i].orderTypeId == 1) {
      amount += getWeight(orders[i]!);
    }
  }
  return amount;
}

double getWeightTotalB(List<dynamic> orders) {
  if (orders.isEmpty) {
    return 0;
  }
  double amount = 0;
  for (int i = 0; i < orders.length; i++) {
    amount += orders[i]!.weight ?? 0;
  }
  return amount;
}

double getWeight(dynamic order) {
  double amount = 0;
  for (int j = 0; j < order.details!.length; j++) {
    amount += order.details![j].weight ?? 0;
  }

  return amount;
}

Widget paddedText(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 12)}) =>
    Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );

Widget paddedTextBig(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 14)}) =>
    Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );

Widget paddedTextBigL(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 18)}) =>
    Padding(
      padding: const EdgeInsets.all(5),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );

Widget paddedTextBigXL(final String text,
    {final TextAlign align = TextAlign.left,
      final TextStyle style = const TextStyle(fontSize: 22)}) =>
    Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: align,
        style: style,
      ),
    );

String twoDigit(int num) {
return '${num.toString().length < 2 ? '0$num' : num}';
}