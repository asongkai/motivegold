
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/master/setting_value.dart';
import 'package:motivegold/model/pos_id.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';

class VatSettingScreen extends StatefulWidget {
  const VatSettingScreen({super.key, this.posIdModel});

  final PosIdModel? posIdModel;

  @override
  State<VatSettingScreen> createState() => _VatSettingScreenState();
}

class _VatSettingScreenState extends State<VatSettingScreen> {
  final TextEditingController vatDefaultValue = TextEditingController();
  final TextEditingController deviceIdCtrl = TextEditingController();

  bool loading = false;
  SettingsValueModel? settingsValueModel;

  @override
  void initState() {
    // implement initState
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      // deviceIdCtrl.text = (await getDeviceId())!;
      var result =
          await ApiServices.post('/settings/vat-by-company', Global.requestObj(null));
      if (result != null) {
        motivePrint(result.toJson());
      }
      if (result?.status == "success" && result?.data != null) {
        settingsValueModel = SettingsValueModel.fromJson(result?.data);
        Global.vatSettingModel = settingsValueModel;
        // motivePrint(settingsValueModel?.toJson());
        vatDefaultValue.text = Global.format(settingsValueModel!.vatValue ?? 0);
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("Set Default Value",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading
              ? const LoadingProgress()
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 7 / 10,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          buildTextFieldBig(
                                            labelText: 'ค่าภาษีมูลค่าเพิ่ม',
                                            labelColor: Colors.orange,
                                            inputType: TextInputType.phone,
                                            controller: vatDefaultValue,
                                            inputFormat: [
                                              ThousandsFormatter(
                                                  allowFraction: true)
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
      persistentFooterButtons: [
        SizedBox(
            height: 70,
            width: 150,
            child: ElevatedButton(
              style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.teal[700]!),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () async {
                if (vatDefaultValue.text.trim() == "") {
                  Alert.warning(context, 'warning'.tr(),
                      'กรุณากรอกค่าภาษีมูลค่าเพิ่ม', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "vatValue": Global.toNumber(vatDefaultValue.text)
                });

                Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                    action: () async {
                  final ProgressDialog pr = ProgressDialog(context,
                      type: ProgressDialogType.normal,
                      isDismissible: true,
                      showLogs: true);
                  await pr.show();
                  pr.update(message: 'processing'.tr());
                  try {
                    var result =
                        await ApiServices.post('/settings/create-vat', object);
                    if (result != null) {
                      motivePrint(result.toJson());
                    }
                    await pr.hide();
                    if (result?.status == "success") {
                      loadData();
                      if (mounted) {
                        Alert.success(context, 'Success'.tr(), 'กรุณาเข้าสู่ระบบใหม่อีกครั้งเพื่อใช้งาน', 'OK'.tr(),
                            action: () {});
                      }
                    } else {
                      if (mounted) {
                        Alert.warning(context, 'Warning'.tr(),
                            result!.message ?? result.data, 'OK'.tr(),
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
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            )),
      ],
    );
  }

  saveRow() {
    setState(() {});
  }
}
