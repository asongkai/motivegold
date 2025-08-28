import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';

class AddRateIntScreen extends StatefulWidget {
  const AddRateIntScreen({super.key});

  @override
  State<AddRateIntScreen> createState() => _AddRateIntScreenState();
}

class _AddRateIntScreenState extends State<AddRateIntScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController amountFromCtrl = TextEditingController();
  final TextEditingController amountToCtrl = TextEditingController();
  final TextEditingController rateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("เพิ่มอัตราดอกเบี้ย",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
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
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    buildTextFieldBig(
                                      labelText: 'ชื่ออัตราดอกเบี้ย'.tr(),
                                      labelColor: Colors.orange,
                                      validator: null,
                                      inputType: TextInputType.text,
                                      controller: nameCtrl,
                                    ),
                                    const SizedBox(height: 15),
                                    buildTextFieldBig(
                                      labelText: 'มูลค่าเริ่มต้น'.tr(),
                                      labelColor: Colors.orange,
                                      validator: null,
                                      inputType: TextInputType.number,
                                      controller: amountFromCtrl,
                                      inputFormat: [
                                        ThousandsFormatter(
                                            allowFraction: true)
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    buildTextFieldBig(
                                      labelText: 'มูลค่าสิ้นสุด'.tr(),
                                      labelColor: Colors.orange,
                                      validator: null,
                                      inputType: TextInputType.number,
                                      controller: amountToCtrl,
                                      inputFormat: [
                                        ThousandsFormatter(
                                            allowFraction: true)
                                      ],
                                    ),
                                    const SizedBox(height: 15),
                                    buildTextFieldBig(
                                      labelText: 'เรต (%)'.tr(),
                                      labelColor: Colors.orange,
                                      validator: null,
                                      inputType: TextInputType.number,
                                      controller: rateCtrl,
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
                if (nameCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกชื่ออัตราดอกเบี้ย', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (amountFromCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกจำนวนเงินตั้งแต่', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (amountToCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกจำนวนเงินถึง', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (rateCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกอัตราดอกเบี้ย', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "id": 0,
                  "name": nameCtrl.text,
                  "amountFrom": Global.toNumber(amountFromCtrl.text),
                  "amountTo": Global.toNumber(amountToCtrl.text),
                  "rate": Global.toNumber(rateCtrl.text),
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
                        var result = await ApiServices.post(
                            '/rateint/create', object);
                        await pr.hide();
                        if (result?.status == "success") {
                          if (mounted) {
                            Alert.success(context, 'Success'.tr(), '', 'OK'.tr(),
                                action: () {
                                  Navigator.of(context).pop();
                                });
                          }
                        } else {
                          if (mounted) {
                            Alert.warning(context, 'Warning'.tr(), result!.message!,
                                'OK'.tr(),
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
                  const SizedBox(width: 2),
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