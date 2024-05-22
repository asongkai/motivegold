
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modal_dialog/flutter_modal_dialog.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/util.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import '../../../../api/api_services.dart';
import '../../../../model/product_category.dart';
import '../../../../model/warehouseModel.dart';
import '../../../../utils/alert.dart';
import '../../../../utils/global.dart';


class EditProductCategoryScreen extends StatefulWidget {
  final ProductCategoryModel productCategory;
  final int index;
  const EditProductCategoryScreen({super.key, required this.productCategory, required this.index});

  @override
  State<EditProductCategoryScreen> createState() => _EditProductCategoryScreenState();
}

class _EditProductCategoryScreenState extends State<EditProductCategoryScreen> {
  final TextEditingController nameCtrl = TextEditingController();

  @override
  void initState() {
    // implement initState
    super.initState();
    nameCtrl.text = widget.productCategory.name!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("แก้ไขหมวดหมู่สินค้า"),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: SingleChildScrollView(
            child: SizedBox(
              // height: MediaQuery.of(context).size.height,
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Padding(
                            padding:
                            const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                buildTextFieldBig(
                                  labelText: 'ชื่อหมวดหมู่สินค้า'.tr(),
                                  textColor: Colors
                                      .orange,
                                  validator: null,
                                  inputType: TextInputType.text,
                                  controller: nameCtrl,
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
                if (nameCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกข้อมูล', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "id": widget.productCategory.id,
                  "name": nameCtrl.text,
                  "companyId": Global.user?.companyId,
                  "branchId": Global.user?.branchId
                });

                // return;
                final ProgressDialog pr = ProgressDialog(context,
                    type: ProgressDialogType.normal,
                    isDismissible: true,
                    showLogs: true);
                await pr.show();
                pr.update(message: 'processing'.tr());
                try {
                  var result = await ApiServices.put('/productcategory', widget.productCategory.id, object);
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
