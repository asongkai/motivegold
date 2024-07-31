
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/prefix.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';

List<String> prefixFormat = [
  "{BRANCH CODE}-{DOC TYPE}{YY}{MM}-{RUNNING NUMBER (4 DIGITS)}",
  "{BRANCH CODE}-{DOC TYPE}{YY}{MM}-{RUNNING NUMBER (6 DIGITS)}",
];

class OrderIdPrefixScreen extends StatefulWidget {
  const OrderIdPrefixScreen({super.key});

  @override
  State<OrderIdPrefixScreen> createState() => _OrderIdPrefixScreenState();
}

class _OrderIdPrefixScreenState extends State<OrderIdPrefixScreen> {
  final TextEditingController nameCtrl = TextEditingController();

  bool loading = false;
  PrefixModel? prefixModel;
  int selectedOption = 0;

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
      var result =
          await ApiServices.get('/company/configure/prefix/get/${Global.user!.companyId}');
      // print(result!.toJson());
      if (result?.status == "success") {
        PrefixModel model = PrefixModel.fromJson(result?.data);
        setState(() {
          prefixModel = model;
          selectedOption = Global.prefixIndex(model.settingMode!);
          if (selectedOption == 1) {
            nameCtrl.text = prefixFormat[0];
          } else if (selectedOption == 2) {
            nameCtrl.text = prefixFormat[1];
          }
        });
        
      } else {
        prefixModel = null;
        selectedOption = 0;
        nameCtrl.text = "";
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
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("ตั้งค่า ID การทำธุรกรรม"),
      ),
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
                        height: MediaQuery.of(context).size.height * 8 / 10,
                        width: MediaQuery.of(context).size.width,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: RadioListTile(
                                        title: const Text("รีเซ็ต ID ทุกเดือน", style: TextStyle(fontSize: 20),),
                                        value: 1,
                                        visualDensity: VisualDensity.standard,
                                        activeColor: Colors.teal,
                                        groupValue: selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value!;
                                            if (selectedOption == 1) {
                                              nameCtrl.text = prefixFormat[0];
                                            } else if (selectedOption == 2) {
                                              nameCtrl.text = prefixFormat[1];
                                            }
                                          });
                                        }),
                                  ),
                                  Expanded(
                                    child: RadioListTile(
                                        title: const Text("รีเซ็ต ID ทุกปี", style: TextStyle(fontSize: 20),),
                                        value: 2,
                                        visualDensity: VisualDensity.standard,
                                        activeColor: Colors.teal,
                                        groupValue: selectedOption,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedOption = value!;
                                            if (selectedOption == 1) {
                                              nameCtrl.text = prefixFormat[0];
                                            } else if (selectedOption == 2) {
                                              nameCtrl.text = prefixFormat[1];
                                            }
                                          });
                                        }),
                                  )
                                ],
                              ),
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
                                          buildTextField(
                                            labelText: 'ตัวอย่างรูปแบบรหัสธุรกรรม'.tr(),
                                            textColor: Colors.orange,
                                            validator: null,
                                            inputType: TextInputType.text,
                                            enabled: false,
                                            controller: nameCtrl,
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
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.teal[700]!),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () async {
                if (selectedOption == 0) {
                  Alert.warning(
                      context, 'warning'.tr(), 'โปรดเลือกตัวเลือก', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "companyId": Global.user!.companyId.toString(),
                  "settingMode": Global.prefixName(selectedOption),
                  "prefix": ""
                });

                // print(object);
                // return;
                final ProgressDialog pr = ProgressDialog(context,
                    type: ProgressDialogType.normal,
                    isDismissible: true,
                    showLogs: true);
                await pr.show();
                pr.update(message: 'processing'.tr());
                try {
                  var result =
                      await ApiServices.post('/company/configure/prefix/set', object);
                  await pr.hide();
                  if (result?.status == "success") {
                    if (mounted) {
                      Alert.success(context, 'Success'.tr(), '', 'OK'.tr(),
                          action: () {
                        loadData();
                      });
                    }
                  } else {
                    if (mounted) {
                      Alert.warning(
                          context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
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
