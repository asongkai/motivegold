import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivegold/screen/landing_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/localbindings.dart';
import 'package:motivegold/utils/util.dart';

class SignInTen extends StatefulWidget {
  const SignInTen({super.key});

  @override
  State<SignInTen> createState() => _SignInTenState();
}

class _SignInTenState extends State<SignInTen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool rememberMe = false;

  // Constants for storage keys
  static const String _rememberMeKey = 'remember_me';
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  // Load saved credentials if remember me was enabled
  Future<void> _loadSavedCredentials() async {
    try {
      final savedRememberMe = await LocalStorage.sharedInstance.getBool(_rememberMeKey) ?? false;

      if (savedRememberMe) {
        final savedUsername = await LocalStorage.sharedInstance.getString(_savedUsernameKey) ?? '';
        final savedPassword = await LocalStorage.sharedInstance.getString(_savedPasswordKey) ?? '';

        setState(() {
          rememberMe = savedRememberMe;
          emailController.text = savedUsername;
          passController.text = savedPassword;
        });
      } else {
        // Set default values if not remembering
        setState(() {
          emailController.text = 'com';
          passController.text = '1234';
        });
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
      // Fallback to default values
      setState(() {
        emailController.text = 'com';
        passController.text = '1234';
      });
    }
  }

  // Save credentials if remember me is enabled
  Future<void> _saveCredentials() async {
    try {
      await LocalStorage.sharedInstance.setBool(_rememberMeKey, rememberMe);

      if (rememberMe) {
        await LocalStorage.sharedInstance.setString(_savedUsernameKey, emailController.text);
        await LocalStorage.sharedInstance.setString(_savedPasswordKey, passController.text);
      } else {
        // Clear saved credentials if remember me is disabled
        await LocalStorage.sharedInstance.deleteValue(_savedUsernameKey);
        await LocalStorage.sharedInstance.deleteValue(_savedPasswordKey);
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                buildCard(size),
                // buildFooter(size),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(Size size) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: size.width * 0.9,
      height: size.height * 0.8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //logo & login text here
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                logo(size.height / 8, size.height / 8),
                SizedBox(
                  height: size.height * 0.03,
                ),
                richText(24),
              ],
            ),
          ),

          //email , password textField and rememberForget text here
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                emailTextField(size),
                // SizedBox(
                //   height: size.height * 0.02,
                // ),
                passwordTextField(size),
                // SizedBox(
                //   height: size.height * 0.01,
                // ),

                //remember & forget text
                buildRememberForgetSection(size),
              ],
            ),
          ),

          //sign in button
          Expanded(
            flex: 3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //sign in button here
                GestureDetector(
                  onTap: () async {
                    var authObject = encoder.convert({
                      "username": emailController.text,
                      "password": passController.text,
                      "deviceDetail": Global.deviceDetail.toString()
                    });

                    final ProgressDialog pr = ProgressDialog(context,
                        type: ProgressDialogType.normal,
                        isDismissible: true,
                        showLogs: true);
                    await pr.show();
                    pr.update(message: 'processing'.tr());
                    try {
                      var result =
                      await ApiServices.post('/user/login', authObject);
                      motivePrint(result?.data);
                      await pr.hide();
                      if (result?.status == "success") {
                        // Save credentials if login is successful
                        await _saveCredentials();

                        var userData = result?.data;
                        UserModel user = UserModel.fromJson(userData);

                        setState(() {
                          Global.user = user;
                          Global.isLoggedIn = true;
                        });

                        if (mounted) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const LandingScreen()));
                        }
                      } else {
                        if (mounted) {
                          Alert.warning(context, 'Warning'.tr(),
                              result!.message ?? 'Unable to connect to server', 'OK'.tr(),
                              action: () {});
                        }
                      }
                    } catch (e) {
                      await pr.hide();
                      if (mounted) {
                        Alert.warning(
                            context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                            action: () {});
                      }
                    }
                  },
                  child: signInButton(size),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget welcomeText() {
    return Center(
      child: Text.rich(
        TextSpan(
          style: GoogleFonts.inter(
            fontSize: 22.0,
            color: Colors.black,
            height: 1.59,
          ),
          children: const [
            TextSpan(
              text: 'Welcome Back',
            ),
            TextSpan(
              text: ', ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: 'Login',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
            TextSpan(
              text: ' ',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: 'for Continue !',
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/images/logo.png',
      height: height_,
      width: width_,
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: fontSize,
          color: const Color(0xFF21899C),
          letterSpacing: 2.000000061035156,
        ),
        children: [
          TextSpan(
            text: 'เข้าสู่ระบบ'.tr(),
            style: const TextStyle(
                color: Color(0xFFFE9879),
                fontWeight: FontWeight.w800,
                fontFamily: 'NotoSansLao'),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return SizedBox(
      height: size.height / 12,
      child: TextField(
        controller: emailController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: 'ใส่อีเมลของคุณ',
          hintStyle: GoogleFonts.inter(
            fontSize: 16.0,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          fillColor: emailController.text.isNotEmpty
              ? Colors.transparent
              : const Color.fromRGBO(248, 247, 251, 1),
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide(
                color: emailController.text.isEmpty
                    ? Colors.transparent
                    : const Color.fromRGBO(44, 185, 176, 1),
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: const BorderSide(
                color: Color.fromRGBO(44, 185, 176, 1),
              )),
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: emailController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color.fromRGBO(44, 185, 176, 1),
            size: 16,
          ),
          suffix: Container(
            alignment: Alignment.center,
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: const Color.fromRGBO(44, 185, 176, 1),
            ),
            child: emailController.text.isEmpty
                ? const Center()
                : const Icon(
              Icons.check,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return SizedBox(
      height: size.height / 12,
      child: TextField(
        controller: passController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.visiblePassword,
        obscureText: true,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: 'ใส่รหัสผ่านของคุณ',
          hintStyle: GoogleFonts.inter(
            fontSize: 16.0,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          fillColor: passController.text.isNotEmpty
              ? Colors.transparent
              : const Color.fromRGBO(248, 247, 251, 1),
          filled: true,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: BorderSide(
                color: passController.text.isEmpty
                    ? Colors.transparent
                    : const Color.fromRGBO(44, 185, 176, 1),
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(40),
              borderSide: const BorderSide(
                color: Color.fromRGBO(44, 185, 176, 1),
              )),
          prefixIcon: Icon(
            Icons.lock_outline_rounded,
            color: passController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color.fromRGBO(44, 185, 176, 1),
            size: 16,
          ),
          suffix: Container(
            alignment: Alignment.center,
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: const Color.fromRGBO(44, 185, 176, 1),
            ),
            child: passController.text.isEmpty
                ? const Center()
                : const Icon(
              Icons.check,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRememberForgetSection(Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          // Remember Me with bigger, professional styling
          GestureDetector(
            onTap: () {
              setState(() {
                rememberMe = !rememberMe;
              });
            },
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: rememberMe
                          ? const Color.fromRGBO(44, 185, 176, 1)
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                    color: rememberMe
                        ? const Color.fromRGBO(44, 185, 176, 1)
                        : Colors.white,
                    boxShadow: rememberMe ? [
                      BoxShadow(
                        color: const Color.fromRGBO(44, 185, 176, 1).withOpacity(0.2),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                        spreadRadius: 0,
                      ),
                    ] : [],
                  ),
                  child: rememberMe
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                      : null,
                ),
                const SizedBox(width: 14),
                Text(
                  'จดจำฉัน',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    color: const Color(0xFF374151),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // GestureDetector(
          //   onTap: () {
          //     // Add forgot password functionality here
          //   },
          //   child: Text(
          //     'ลืมรหัสผ่าน?',
          //     style: GoogleFonts.inter(
          //       fontSize: 17,
          //       color: const Color(0xFF21899C),
          //       fontWeight: FontWeight.w600,
          //       letterSpacing: 0.2,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget signInButton(Size size) {
    return Container(
      alignment: Alignment.center,
      height: size.height / 13,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.orange,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4C2E84).withOpacity(0.2),
            offset: const Offset(0, 15.0),
            blurRadius: 60.0,
          ),
        ],
      ),
      child: Text(
        'เข้าสู่ระบบ',
        style: GoogleFonts.inter(
          fontSize: 16.0,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }


}