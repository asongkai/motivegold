import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/screen/auth/signin_screen.dart';
import 'package:motivegold/screen/tab_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';

import '../api/api_services.dart';
import '../model/branch.dart';
import '../model/company.dart';
import '../utils/constants.dart';

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

    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await deviceInfo.androidInfo;
      Global.deviceDetail = info;
      // print(info.toMap());
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await deviceInfo.iosInfo;
      Global.deviceDetail = info;
      // print(info.toMap());
    } else if (Platform.isLinux) {
      LinuxDeviceInfo info = await deviceInfo.linuxInfo;
      Global.deviceDetail = info;
      // print(info.toMap());
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo info = await deviceInfo.macOsInfo;
      Global.deviceDetail = info;
      // print(info.toMap());
    } else if (Platform.isWindows) {
      WindowsDeviceInfo info = await deviceInfo.windowsInfo;
      Global.deviceDetail = info;
      // print(info.toMap());
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
