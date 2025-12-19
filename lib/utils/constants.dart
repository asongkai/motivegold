import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motivegold/utils/config.dart';
import 'package:motivegold/utils/util.dart';

const kGrey1 = Color(0xFF9F9F9F);
const kGrey2 = Color(0xFF6D6D6D);
const kGrey3 = Color(0xFFEAEAEA);
const kBlack = Color(0xFF1C1C1C);

var kNonActiveTabStyle = GoogleFonts.roboto(
  textStyle: const TextStyle(fontSize: 14.0, color: kGrey1),
);

var kActiveTabStyle = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 16.0,
    color: kBlack,
    fontWeight: FontWeight.bold,
  ),
);

var kCategoryTitle = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 14.0,
    color: kGrey2,
    fontWeight: FontWeight.bold,
  ),
);

var kDetailContent = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 14.0,
    color: kGrey2,
  ),
);

var kTitleCard = GoogleFonts.roboto(
  textStyle: const TextStyle(
    fontSize: 18.0,
    color: kBlack,
    fontWeight: FontWeight.bold,
  ),
);

var descriptionStyle = GoogleFonts.roboto(
    textStyle: const TextStyle(
  fontSize: 15.0,
  height: 2.0,
));

const kPrimaryColor = Color(0xFFFF8084);
const kAccentColor = Color(0xFFF1F1F1);
const kWhiteColor = Color(0xFFFFFFFF);
const kLightColor = Color(0xFF808080);
const kDarkColor = Color(0xFF303030);
const kTransparent = Colors.transparent;

const kDefaultPadding = 24.0;
const kLessPadding = 10.0;
const kFixPadding = 16.0;
const kLess = 4.0;

const kShape = 30.0;

const kRadius = 0.0;
const kAppBarHeight = 56.0;

const kHeadTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
);

const kSubTextStyle = TextStyle(
  fontSize: 18.0,
  color: kLightColor,
);

const kTitleTextStyle = TextStyle(
  fontSize: 20.0,
  color: kPrimaryColor,
);

const kDarkTextStyle = TextStyle(
  fontSize: 20.0,
  color: kDarkColor,
);

const kDivider = Divider(
  color: kAccentColor,
  thickness: kLessPadding,
);

const kSmallDivider = Divider(
  color: kAccentColor,
  thickness: 5.0,
);

const String success = 'assets/images/success.gif';

class Constants {
  static String isLoggedIn = "IS_LOGGED_IN";

  static const Color clr_blue = Color(0xFF1972d2);
  static const Color clr_red = Color(0xFFF44336);
  static const Color clr_orange = Color(0xFFFF682D);
  static const Color clr_light_grey = Color(0xAAD3D3D3);

  static Color colorCurve =
      Colors.blue[700]!; //Color.fromRGBO(97, 10, 165, 0.8);
  static Color colorCurveSecondary = Colors.blue[700]!
      .withValues(alpha: 0.8); //Color.fromRGBO(97, 10, 155, 0.6);
  static Color backgroundColor = Colors.grey.shade200;
  static Color textPrimaryColor = Colors.black87;

  //Validations REGEX
  static const String PATTERN_EMAIL =
      "^([0-9a-zA-Z]([-.+\\w]*[0-9a-zA-Z])*@([0-9a-zA-Z][-\\w]*[0-9a-zA-Z]\\.)+[a-zA-Z]{2,9})\$";

  static String BACKEND_URL = "${getBackendUrl()}/api";
  static String DOMAIN_URL = "${getBackendUrl()}";

  static const String STORAGE_URL = "gs://app-name.appspot.com";

  static const kGoogleApiKey = "AIzaSyBeTEo6O-FqFeEtrrCqjpcKnBo8iipVnBc";

  static getBackendUrl() {
    if (env == ENV.PRO) {
      return "https://app.quickgoldthai.com"; // Production HTTPS
    } else if (env == ENV.UAT) {
      return "https://srv1104428.hstgr.cloud"; // HTTPS via nginx reverse proxy
    } else {
      // Check if running on web
      if (kIsWeb) {
        return "http://127.0.0.1:5000"; // or "http://localhost:5000"
      } else {
        return defaultTargetPlatform == TargetPlatform.android
            ? "http://10.0.2.2:5000"
            : "http://127.0.0.1:5000";
      }
    }
  }
}
