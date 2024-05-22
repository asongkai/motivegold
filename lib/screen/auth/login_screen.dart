import 'package:animate_do/animate_do.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/screen/tab_screen.dart';
import 'package:motivegold/widget/languageIntro.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../api/api_services.dart';
import '../../utils/alert.dart';
import '../../utils/constants.dart';
import '../../utils/global.dart';
import '../../utils/localbindings.dart';
import '../../utils/util.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, colors: [
              Colors.orange.shade800,
              Colors.orange.shade500,
              Colors.orange.shade400
            ])),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 80,
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FadeInUp(
                          duration: const Duration(milliseconds: 1000),
                          child: Text(
                            "login".tr(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 40),
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      FadeInUp(
                          duration: const Duration(milliseconds: 1300),
                          child: const Text(
                            "Welcome Back",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 60,
                          ),
                          FadeInUp(
                              duration: const Duration(milliseconds: 1400),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: const [
                                      BoxShadow(
                                          color:
                                              Color.fromRGBO(225, 95, 27, .3),
                                          blurRadius: 20,
                                          offset: Offset(0, 10))
                                    ]),
                                child: Column(
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color:
                                                      Colors.grey.shade200))),
                                      child: TextField(
                                        controller: emailCtrl,
                                        decoration: InputDecoration(
                                            hintText: "Email".tr(),
                                            hintStyle: const TextStyle(
                                                color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  color:
                                                      Colors.grey.shade200))),
                                      child: TextField(
                                        controller: passwordCtrl,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                            hintText: "Password".tr(),
                                            hintStyle: const TextStyle(
                                                color: Colors.grey),
                                            border: InputBorder.none),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          const SizedBox(
                            height: 40,
                          ),
                          FadeInUp(
                              duration: const Duration(milliseconds: 1500),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.grey),
                              )),
                          const SizedBox(
                            height: 40,
                          ),
                          FadeInUp(
                              duration: const Duration(milliseconds: 1600),
                              child: MaterialButton(
                                onPressed: () async {
                                  var authObject = encoder.convert({
                                    "username": emailCtrl.text,
                                    "password": passwordCtrl.text,
                                  });

                                  print(authObject);
                                  // return;
                                  final ProgressDialog pr = ProgressDialog(
                                      context,
                                      type: ProgressDialogType.normal,
                                      isDismissible: true,
                                      showLogs: true);
                                  await pr.show();
                                  pr.update(message: 'processing'.tr());
                                  try {
                                    var result = await ApiServices.post(
                                        '/user/login', authObject);
                                    await pr.hide();
                                    if (result?.status == "success") {
                                      var userData = result?.data;
                                      UserModel user =
                                          UserModel.fromJson(userData);
                                      LocalStorage.sharedInstance.writeValue(
                                          key: 'user',
                                          value: encoder.convert(user));
                                      setState(() {
                                        Global.user = user;
                                        Global.isLoggedIn = true;
                                      });
                                      LocalStorage.sharedInstance.setAuthStatus(
                                          key: Constants.isLoggedIn,
                                          value: "true");
                                      print(userData);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                              content:
                                                  Text('loginSuccess'.tr())));

                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const TabScreen(
                                                      title: 'GOLD')));
                                    } else {
                                      Alert.warning(context, 'Warning'.tr(),
                                          result!.message!, 'OK'.tr(),
                                          action: () {});
                                    }
                                  } catch (e) {
                                    await pr.hide();
                                    Alert.warning(context, 'Warning'.tr(),
                                        e.toString(), 'OK'.tr(),
                                        action: () {});
                                  }
                                },
                                height: 50,
                                // margin: EdgeInsets.symmetric(horizontal: 50),
                                color: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                // decoration: BoxDecoration(
                                // ),
                                child: Center(
                                  child: Text(
                                    "login".tr(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          const LanguageIntro(),
        ],
      ),
    );
  }
}
