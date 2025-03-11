import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/master/setting_value.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/screen/auth/signin_screen.dart';
import 'package:motivegold/screen/tab_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:flutter/foundation.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/util.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    // implement initState
    super.initState();
    Timer(const Duration(seconds: 1), () {
      navigateFromSplash();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtils().init(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: LoadingAnimationWidget.threeRotatingDots(
            color: Colors.orange,
            size: 200,
          ),
        ),
      ),
    );
  }

  Future navigateFromSplash() async {
    var lang = await LocalStorage.sharedInstance.readValue('lang');
    String? isLoggedIn =
        await LocalStorage.sharedInstance.loadAuthStatus(Constants.isLoggedIn);
    var user = await LocalStorage.sharedInstance.readValue('user');
    // lang = null;
    if (lang != null) {
      Global.lang = int.parse(lang);
      if (Global.lang == 0) {
        if (mounted) {
          context.setLocale(const Locale('en', 'US'));
        }
      } else if (Global.lang == 1) {
        if (mounted) {
          context.setLocale(const Locale('lo', 'LA'));
        }
      } else if (Global.lang == 2) {
        if (mounted) {
          context.setLocale(const Locale('zh', 'CN'));
        }
      } else {
        if (mounted) {
          context.setLocale(const Locale('vi', 'VN'));
        }
      }
    } else {
      Global.lang = 0;
      LocalStorage.sharedInstance.writeValue(key: 'lang', value: 0.toString());
      if (mounted) {
        context.setLocale(const Locale('en', 'US'));
      }
    }

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      Global.deviceDetail = readWebBrowserInfo(await deviceInfo.webBrowserInfo);
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      if (Platform.isAndroid) {
        // AndroidDeviceInfo info = await deviceInfo.androidInfo;
        Global.deviceDetail =
            readAndroidBuildData(await deviceInfo.androidInfo);
        // motivePrint(info.toMap());
      } else if (Platform.isIOS) {
        // IosDeviceInfo info = await deviceInfo.iosInfo;
        Global.deviceDetail = readIosDeviceInfo(await deviceInfo.iosInfo);
        // print(info.toMap());
      }
    } else if (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.fuchsia) {
      if (Platform.isLinux) {
        // LinuxDeviceInfo info = await deviceInfo.linuxInfo;
        Global.deviceDetail = readLinuxDeviceInfo(await deviceInfo.linuxInfo);
        // print(info.toMap());
      } else if (Platform.isMacOS) {
        // MacOsDeviceInfo info = await deviceInfo.macOsInfo;
        Global.deviceDetail = readMacOsDeviceInfo(await deviceInfo.macOsInfo);
        // print(info.toMap());
      } else if (Platform.isWindows) {
        // WindowsDeviceInfo info = await deviceInfo.windowsInfo;
        Global.deviceDetail =
            readWindowsDeviceInfo(await deviceInfo.windowsInfo);
        // print(info.toMap());
      }
    }

    if (isLoggedIn == null || isLoggedIn == "false") {
      Global.isLoggedIn = false;
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SignInTen()));
      }
    } else {
      Global.isLoggedIn = true;
      Global.user = userModelFromJson(user);
      if (Global.user!.companyId != null) {
        var c = await ApiServices.get('/company/${Global.user?.companyId}');
        // motivePrint(c!.data);
        if (c?.status == "success") {
          var cn = CompanyModel.fromJson(c?.data);
          setState(() {
            Global.company = cn;
          });
        } else {
          Global.company = null;
        }
      }

      var settings = await ApiServices.post('/settings/all', Global.requestObj(null));
      if (settings?.status == "success") {
        motivePrint(settings?.toJson());
        var settingsValueModel = settings?.data != null ? SettingsValueModel.fromJson(settings?.data) : null;
        Global.settingValueModel = settingsValueModel;
      }

      var authObject =
          Global.requestObj({"deviceDetail": Global.deviceDetail.toString()});

      try {
        await ApiServices.post(
            '/user/state/Open/${Global.user!.id}', authObject);
      } catch (e) {
        motivePrint(e.toString());
      }

      // if (Global.user!.branchId != null) {
      var b = await ApiServices.get('/branch/${Global.user?.branchId}');
      // motivePrint(c!.data);
      if (b?.status == "success") {
        var bn = BranchModel.fromJson(b?.data);
        setState(() {
          Global.branch = bn;
        });
      } else {
        Global.branch = null;
      }
      // }

      if (Global.branchList.isEmpty) {
        var b = await ApiServices.get(
            '/branch/by-company/${Global.user?.companyId}');
        // motivePrint(b!.data);
        if (b?.status == "success") {
          var data = jsonEncode(b?.data);
          List<BranchModel> products = branchListModelFromJson(data);
          setState(() {
            Global.branchList = products;
          });
        } else {
          Global.branchList = [];
        }
      }

      var pos = await ApiServices.get(
          '/company/configure/pos/id/get/${await getDeviceId()}');
      // print(result!.data);
      if (pos?.status == "success") {
        var data = PosIdModel.fromJson(pos?.data);
        setState(() {
          Global.posIdModel = data;
        });
      } else {
        Global.posIdModel = null;
      }

      var province =
      await ApiServices.post('/customer/province', Global.requestObj(null));
      // motivePrint(province!.toJson());
      if (province?.status == "success") {
        var data = jsonEncode(province?.data);
        List<ProvinceModel> products = provinceModelFromJson(data);
        setState(() {
          Global.provinceList = products;
        });
      } else {
        Global.provinceList = [];
      }

      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => const SignInTen()));
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const TabScreen(
                      title: "MENU",
                    )));
      }
    }
  }
}
