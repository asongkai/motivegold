import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/product_category.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class EditProductScreen extends StatefulWidget {
  final bool showBackButton;
  final ProductModel product;
  final int index;

  const EditProductScreen(
      {super.key,
      required this.showBackButton,
      required this.product,
      required this.index});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  int? id;
  final TextEditingController productCodeCtrl = TextEditingController();
  final TextEditingController productNameCtrl = TextEditingController();
  final TextEditingController typeCtrl = TextEditingController();
  final TextEditingController productTypeCtrl = TextEditingController();
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
  final TextEditingController unitDefaultValue = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedType = productTypes()
        .where((element) => element.code == widget.product.type)
        .first;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    typeNotifier = ValueNotifier<ProductTypeModel>(
        selectedType ?? ProductTypeModel(id: 0, name: 'เลือกสถานะสินค้า'));
    id = widget.product.id;
    productNameCtrl.text = widget.product.name;
    productCodeCtrl.text = widget.product.productCode!;
    unitDefaultValue.text =
        Global.format(widget.product.unitWeight ?? 0);

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
        // print(widget.product.productTypeId);
        List<ProductTypeModel> types = productTypeListModelFromJson(data);
        var pTypes =
            types.where((e) => e.id == widget.product.productTypeId).toList();
        if (pTypes.isNotEmpty) {
          selectedProductType = pTypes.first;
          productTypeCtrl.text = selectedProductType!.name!;
          productTypeNotifier = ValueNotifier<ProductTypeModel>(
              selectedProductType ??
                  ProductTypeModel(id: 0, name: 'เลือกประเภท'));
        }

        setState(() {
          productTypeList = types;
        });
      } else {
        productTypeList = [];
      }

      var response = await ApiServices.post(
          '/productcategory/all', Global.requestObj(null));
      // print(response!.toJson());
      if (response?.status == "success") {
        var data = jsonEncode(response?.data);
        List<ProductCategoryModel> categories =
            productCategoryListModelFromJson(data);
        var cTypes = categories
            .where((element) => element.id == widget.product.productCategoryId)
            .toList();
        if (cTypes.isNotEmpty) {
          selectedCategory = cTypes.first;
          productCategoryCtrl.text = selectedCategory!.name!;
          productCategoryNotifier = ValueNotifier<ProductCategoryModel>(
              selectedCategory ??
                  ProductCategoryModel(id: 0, name: 'เลือกประเภท'));
        }

        setState(() {
          productCategoryList = categories;
        });
      } else {
        productCategoryList = [];
      }

      selectedType = productTypes()
          .where((element) => element.code == widget.product.type)
          .first;
      if (selectedType != null) {
        typeCtrl.text = selectedType!.name!;
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("แก้ไขสินค้า",
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
                                      buildTextField(
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
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ประเภท',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(10),
                                            color: textColor),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      SizedBox(
                                        height: 70,
                                        child:
                                        MiraiDropDownMenu<ProductTypeModel>(
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
                                              fontSize: size.getWidthPx(10),
                                            );
                                          },
                                          onChanged: (ProductTypeModel value) {
                                            productTypeCtrl.text = value.name!;
                                            selectedProductType = value;
                                            productTypeNotifier!.value = value;
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: size.getWidthPx(10),
                                            projectValueNotifier:
                                            productTypeNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'หมวดหมู่',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(10),
                                            color: textColor),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      SizedBox(
                                        height: 70,
                                        child: MiraiDropDownMenu<
                                            ProductCategoryModel>(
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
                                              fontSize: size.getWidthPx(10),
                                            );
                                          },
                                          onChanged:
                                              (ProductCategoryModel value) {
                                            productCategoryCtrl.text =
                                            value.name!;
                                            selectedCategory = value;
                                            productCategoryNotifier!.value =
                                                value;
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: size.getWidthPx(10),
                                            projectValueNotifier:
                                            productCategoryNotifier!,
                                          ),
                                        ),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'ชื่อสินค้า',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(10),
                                            color: textColor),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      buildTextField(
                                        labelText: '',
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
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'สถานะสินค้า',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(10),
                                            color: textColor),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      SizedBox(
                                        height: 70,
                                        child:
                                        MiraiDropDownMenu<ProductTypeModel>(
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
                                              fontSize: size.getWidthPx(10),
                                            );
                                          },
                                          onChanged: (ProductTypeModel value) {
                                            typeCtrl.text = value.name!;
                                            selectedType = value;
                                            typeNotifier!.value = value;
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: size.getWidthPx(10),
                                            projectValueNotifier: typeNotifier!,
                                          ),
                                        ),
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
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          buildTextFieldBig(
                                            labelText: 'น้ำหนักหน่วยกรัม',
                                            labelColor: Colors.orange,
                                            inputType: TextInputType.phone,
                                            controller: unitDefaultValue,
                                            inputFormat: [
                                              ThousandsFormatter(
                                                  allowFraction: true)
                                            ],
                                          ),
                                          const Text('ตัวอย่าง: 15.16')
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
                if (productNameCtrl.text.trim() == "") {
                  Alert.warning(
                      context, 'warning'.tr(), 'กรุณากรอกข้อมูล', 'OK'.tr(),
                      action: () {});
                  return;
                }

                if (unitDefaultValue.text.trim() == "") {
                  Alert.warning(context, 'warning'.tr(),
                      'กรุณากรอกน้ำหนักหน่วยกรัม', 'OK'.tr(),
                      action: () {});
                  return;
                }

                var object = Global.requestObj({
                  "id": id,
                  "productCode": widget.product.productCode!.isEmpty
                      ? generateRandomString(10).toUpperCase()
                      : widget.product.productCode,
                  "type": selectedType!.code,
                  "name": productNameCtrl.text,
                  "productTypeId": selectedProductType!.id,
                  "productCategoryId": selectedCategory!.id,
                  "companyId": Global.user?.companyId,
                  "branchId": Global.user?.branchId,
                  "unitWeight": Global.toNumber(unitDefaultValue.text),
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
                    var result = await ApiServices.put('/product', id, object);
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
