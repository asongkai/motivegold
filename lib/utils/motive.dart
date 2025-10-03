import 'dart:io';

import 'package:flutter/material.dart';

class Motive {
  static List<File>? imagesFileList = [];

  static TextEditingController sellNewGoldRemarkCtrl = TextEditingController();
  static TextEditingController buyUsedGoldRemarkCtrl = TextEditingController();
  static TextEditingController sellNewThengGoldRemarkCtrl = TextEditingController();
  static TextEditingController buyUsedThengGoldRemarkCtrl = TextEditingController();

  static void reset() {
    imagesFileList?.clear();
  }
}
