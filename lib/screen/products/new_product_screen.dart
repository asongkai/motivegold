import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/product_category.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class NewProductScreen extends StatefulWidget {
  final bool showBackButton;

  const NewProductScreen({super.key, required this.showBackButton});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final TextEditingController productCodeCtrl = TextEditingController();
  final TextEditingController productNameCtrl = TextEditingController();
  final TextEditingController productTypeCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();
  final TextEditingController productCategoryCtrl = TextEditingController();

  WarehouseModel? selectedBin;
  ProductCategoryModel? selectedCategory;
  ProductTypeModel? selectedType;
  ProductTypeModel? selectedProductType;
  bool loading = false;

  List<ProductTypeModel> productTypeList = [];
  List<ProductCategoryModel> productCategoryList = [];
  List<WarehouseModel> locationList = [];

  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? productTypeNotifier;
  ValueNotifier<dynamic>? productCategoryNotifier;
  ValueNotifier<dynamic>? typeNotifier;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภท'));
    productCategoryNotifier = ValueNotifier<ProductCategoryModel>(
        ProductCategoryModel(id: 0, name: 'เลือกหมวดหมู่'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    typeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกสถานะสินค้า'));
    productCodeCtrl.text = generateProductCode(4).toUpperCase();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/producttype/all', Global.requestObj(null));
      // print(result!.toJson());
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);

        List<ProductTypeModel> products = productTypeListModelFromJson(data);
        setState(() {
          productTypeList = products;
        });
      } else {
        productTypeList = [];
      }

      var warehouse = await ApiServices.post(
          '/productcategory/all', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<ProductCategoryModel> warehouses =
            productCategoryListModelFromJson(data);
        setState(() {
          productCategoryList = warehouses;
        });
      } else {
        productCategoryList = [];
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
      appBar: AppBar(
        title: const Text('เพิ่มสินค้าใหม่'),
        automaticallyImplyLeading: widget.showBackButton,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading
              ? const LoadingProgress()
              : SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'รหัสสินค้า'.tr(),
                                        validator: null,
                                        enabled: true,
                                        inputType: TextInputType.text,
                                        controller: productCodeCtrl,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
                                    child: MiraiDropDownMenu<ProductTypeModel>(
                                      key: UniqueKey(),
                                      children: productTypeList,
                                      space: 4,
                                      maxHeight: 360,
                                      showSearchTextField: true,
                                      selectedItemBackgroundColor:
                                          Colors.transparent,
                                      emptyListMessage: 'ไม่มีข้อมูล',
                                      showSelectedItemBackgroundColor: true,
                                      itemWidgetBuilder: (
                                        int index,
                                        ProductTypeModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                        return DropDownItemWidget(
                                          project: project,
                                          isItemSelected: isItemSelected,
                                          firstSpace: 10,
                                          fontSize: size.getWidthPx(6),
                                        );
                                      },
                                      onChanged: (ProductTypeModel value) {
                                        productTypeCtrl.text = value.name!;
                                        selectedProductType = value;
                                        productTypeNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(6),
                                        projectValueNotifier:
                                            productTypeNotifier!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
                                    child:
                                        MiraiDropDownMenu<ProductCategoryModel>(
                                      key: UniqueKey(),
                                      children: productCategoryList,
                                      space: 4,
                                      maxHeight: 360,
                                      showSearchTextField: true,
                                      selectedItemBackgroundColor:
                                          Colors.transparent,
                                      emptyListMessage: 'ไม่มีข้อมูล',
                                      showSelectedItemBackgroundColor: true,
                                      itemWidgetBuilder: (
                                        int index,
                                        ProductCategoryModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                        return DropDownItemWidget(
                                          project: project,
                                          isItemSelected: isItemSelected,
                                          firstSpace: 10,
                                          fontSize: size.getWidthPx(6),
                                        );
                                      },
                                      onChanged: (ProductCategoryModel value) {
                                        productCategoryCtrl.text = value.name!;
                                        selectedCategory = value;
                                        productCategoryNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(6),
                                        projectValueNotifier:
                                            productCategoryNotifier!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
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
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'ชื่อสินค้า'.tr(),
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: productNameCtrl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
                                    child: MiraiDropDownMenu<ProductTypeModel>(
                                      key: UniqueKey(),
                                      children: productTypes(),
                                      space: 4,
                                      maxHeight: 360,
                                      showSearchTextField: true,
                                      selectedItemBackgroundColor:
                                          Colors.transparent,
                                      emptyListMessage: 'ไม่มีข้อมูล',
                                      showSelectedItemBackgroundColor: true,
                                      itemWidgetBuilder: (
                                        int index,
                                        ProductTypeModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                        return DropDownItemWidget(
                                          project: project,
                                          isItemSelected: isItemSelected,
                                          firstSpace: 10,
                                          fontSize: size.getWidthPx(6),
                                        );
                                      },
                                      onChanged: (ProductTypeModel value) {
                                        typeCtrl.text = value.name!;
                                        selectedType = value;
                                        typeNotifier!.value = value;
                                      },
                                      child: DropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(6),
                                        projectValueNotifier: typeNotifier!,
                                      ),
                                    ),
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

                if (productCodeCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกรหัสสินค้า', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (productNameCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกชื่อสินค้า', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (productTypeCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณาเลือกประเภทสินค้า', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (productCategoryCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณาเลือกหมวดหมู่สินค้า', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (typeCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณาเลือกสถานะสินค้า', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "name": productNameCtrl.text,
                  "productTypeId": selectedProductType!.id,
                  "productCategoryId": selectedCategory!.id,
                  "productCode": productCodeCtrl.text,
                  "type": selectedType!.code
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
                        await ApiServices.post('/product/create', object);
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
}
