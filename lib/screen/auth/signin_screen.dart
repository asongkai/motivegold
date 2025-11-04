import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivegold/screen/landing_screen.dart';
import 'package:motivegold/utils/config.dart';
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
  final ScrollController _scrollController = ScrollController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Constants for storage keys
  static const String _rememberMeKey = 'remember_me';
  static const String _savedUsernameKey = 'saved_username';
  static const String _savedPasswordKey = 'saved_password';

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();

    // Add listeners to text controllers for dynamic UI updates
    emailController.addListener(() => setState(() {}));
    passController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    _scrollController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // Load saved credentials if remember me was enabled
  Future<void> _loadSavedCredentials() async {
    try {
      final savedRememberMe =
          await LocalStorage.sharedInstance.getBool(_rememberMeKey) ?? false;

      if (savedRememberMe) {
        final savedUsername =
            await LocalStorage.sharedInstance.getString(_savedUsernameKey) ??
                '';
        final savedPassword =
            await LocalStorage.sharedInstance.getString(_savedPasswordKey) ??
                '';

        setState(() {
          rememberMe = savedRememberMe;
          emailController.text = savedUsername;
          passController.text = savedPassword;
        });
      }
    } catch (e) {
      print('Error loading saved credentials: $e');
    }
  }

  // Save credentials if remember me is enabled
  Future<void> _saveCredentials() async {
    try {
      await LocalStorage.sharedInstance.setBool(_rememberMeKey, rememberMe);

      if (rememberMe) {
        await LocalStorage.sharedInstance
            .setString(_savedUsernameKey, emailController.text);
        await LocalStorage.sharedInstance
            .setString(_savedPasswordKey, passController.text);
      } else {
        // Clear saved credentials if remember me is disabled
        await LocalStorage.sharedInstance.deleteValue(_savedUsernameKey);
        await LocalStorage.sharedInstance.deleteValue(_savedPasswordKey);
      }
    } catch (e) {
      print('Error saving credentials: $e');
    }
  }

  Future<void> _performLogin() async {
    if (emailController.text.isEmpty || passController.text.isEmpty) {
      Alert.warning(
          context, 'Warning'.tr(), 'กรุณากรอกข้อมูลให้ครบถ้วน', 'OK'.tr(),
          action: () {});
      return;
    }

    var authObject = encoder.convert({
      "username": emailController.text,
      "password": passController.text,
      "deviceDetail": Global.deviceDetail.toString()
    });

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());

    // motivePrint(env.name);

    try {
      var result = await ApiServices.post('/user/login', authObject);
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
              MaterialPageRoute(builder: (context) => const LandingScreen()));
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
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: isTablet ? _buildTabletLayout(size) : _buildMobileLayout(size),
        ),
      ),
    );
  }

  Widget _buildTabletLayout(Size size) {
    return Center(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          width: size.width * 0.5, // Use 50% of screen width
          constraints: BoxConstraints(
            maxWidth: 500,
            minWidth: 400,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo section
              Container(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 240, // Increased from 100
                      width: 240, // Increased from 100
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 24),
                    Text.rich(
                      TextSpan(
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          color: const Color(0xFF21899C),
                          letterSpacing: 2.0,
                        ),
                        children: [
                          TextSpan(
                            text: 'เข้าสู่ระบบ'.tr(),
                            style: const TextStyle(
                              color: Color(0xFFFE9879),
                              fontWeight: FontWeight.w800,
                              fontFamily: 'NotoSansLao',
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Form section
              Container(
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: emailController,
                      focusNode: _emailFocusNode,
                      hintText: 'ใส่อีเมลของคุณ',
                      icon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                      isTablet: true,
                    ),
                    SizedBox(height: 24),
                    _buildTextField(
                      controller: passController,
                      focusNode: _passwordFocusNode,
                      hintText: 'ใส่รหัสผ่านของคุณ',
                      icon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _performLogin(),
                      isTablet: true,
                    ),
                    SizedBox(height: 24),
                    _buildRememberMe(true),
                    SizedBox(height: 32),
                    _buildSignInButton(true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(Size size) {
    return Center(
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo section
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                    width: 80,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20),
                  Text.rich(
                    TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        color: const Color(0xFF21899C),
                        letterSpacing: 2.0,
                      ),
                      children: [
                        TextSpan(
                          text: 'เข้าสู่ระบบ'.tr(),
                          style: const TextStyle(
                            color: Color(0xFFFE9879),
                            fontWeight: FontWeight.w800,
                            fontFamily: 'NotoSansLao',
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              SizedBox(height: 40),

              // Form fields
              _buildTextField(
                controller: emailController,
                focusNode: _emailFocusNode,
                hintText: 'ใส่อีเมลของคุณ',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                isTablet: false,
              ),

              SizedBox(height: 20),

              _buildTextField(
                controller: passController,
                focusNode: _passwordFocusNode,
                hintText: 'ใส่รหัสผ่านของคุณ',
                icon: Icons.lock_outline_rounded,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _performLogin(),
                isTablet: false,
              ),

              SizedBox(height: 20),

              _buildRememberMe(false),

              SizedBox(height: 30),

              _buildSignInButton(false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    required bool isTablet,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,
      style: GoogleFonts.inter(
        fontSize: isTablet ? 16.0 : 16.0,
        color: const Color(0xFF151624),
      ),
      cursorColor: const Color(0xFF151624),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(
          fontSize: isTablet ? 14.0 : 14.0,
          color: const Color(0xFF151624).withOpacity(0.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 20,
          vertical: isTablet ? 16 : 16,
        ),
        fillColor: controller.text.isNotEmpty
            ? Colors.transparent
            : const Color.fromRGBO(248, 247, 251, 1),
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: controller.text.isEmpty
                ? Colors.transparent
                : const Color.fromRGBO(44, 185, 176, 1),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: const Color.fromRGBO(44, 185, 176, 1),
            width: 2,
          ),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.all(16),
          child: Icon(
            icon,
            color: controller.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color.fromRGBO(44, 185, 176, 1),
            size: isTablet ? 22 : 20,
          ),
        ),
        suffixIcon: controller.text.isEmpty
            ? null
            : Padding(
                padding: EdgeInsets.all(16),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromRGBO(44, 185, 176, 1),
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRememberMe(bool isTablet) {
    return GestureDetector(
      onTap: () {
        setState(() {
          rememberMe = !rememberMe;
        });
      },
      child: Row(
        children: [
          Container(
            width: isTablet ? 24 : 22,
            height: isTablet ? 24 : 22,
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
            ),
            child: rememberMe
                ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: isTablet ? 16 : 14,
                  )
                : null,
          ),
          SizedBox(width: 12),
          Text(
            'จดจำฉัน',
            style: GoogleFonts.inter(
              fontSize: isTablet ? 16 : 15,
              color: const Color(0xFF374151),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton(bool isTablet) {
    return GestureDetector(
      onTap: _performLogin,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          vertical: isTablet ? 16 : 14,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
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
            fontSize: isTablet ? 18.0 : 16.0,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
