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
import 'package:sizer/sizer.dart';

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
    unitDefaultValue.text = widget.product.unitWeight.toString();

    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
      await ApiServices.post('/producttype/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("แก้ไขสินค้า",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Code Section
                  _buildFormSection(
                    title: 'ข้อมูลพื้นฐาน',
                    icon: Icons.info_outline_rounded,
                    color: Colors.blue,
                    children: [
                      _buildTextField(
                        label: 'รหัสสินค้า',
                        controller: productCodeCtrl,
                        icon: Icons.qr_code_rounded,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Product Type and Category Section
                  _buildFormSection(
                    title: 'ประเภทและหมวดหมู่',
                    icon: Icons.category_rounded,
                    color: Colors.orange,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdownField(
                              label: 'ประเภท',
                              icon: Icons.widgets_rounded,
                              notifier: productTypeNotifier!,
                              items: productTypeList,
                              onChanged: (ProductTypeModel value) {
                                productTypeCtrl.text = value.name!;
                                selectedProductType = value;
                                productTypeNotifier!.value = value;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'หมวดหมู่',
                              icon: Icons.view_module_rounded,
                              notifier: productCategoryNotifier!,
                              items: productCategoryList,
                              onChanged: (dynamic value) {
                                productCategoryCtrl.text = value.name!;
                                selectedCategory = value;
                                productCategoryNotifier!.value = value;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Product Details Section
                  _buildFormSection(
                    title: 'รายละเอียดสินค้า',
                    icon: Icons.inventory_2_rounded,
                    color: Colors.green,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              label: 'ชื่อสินค้า',
                              controller: productNameCtrl,
                              icon: Icons.shopping_bag_rounded,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDropdownField(
                              label: 'สถานะสินค้า',
                              icon: Icons.flag_rounded,
                              notifier: typeNotifier!,
                              items: productTypes(),
                              onChanged: (ProductTypeModel value) {
                                typeCtrl.text = value.name!;
                                selectedType = value;
                                typeNotifier!.value = value;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildWeightField(),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildTextField(
          labelText: '',
          validator: null,
          enabled: true,
          inputType: TextInputType.text,
          controller: controller,
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required ValueNotifier notifier,
    required List<T> items,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: MiraiDropDownMenu<T>(
            key: UniqueKey(),
            children: items,
            space: 4,
            maxHeight: 360,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (
                int index,
                T? project, {
                  bool isItemSelected = false,
                }) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 10,
                fontSize: 16.sp,
              );
            },
            onChanged: onChanged,
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 16.sp,
              projectValueNotifier: notifier,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.scale_rounded, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              'น้ำหนักหน่วยกรัม',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        buildTextFieldBig(
          labelText: '',
          labelColor: Colors.orange,
          inputType: TextInputType.phone,
          controller: unitDefaultValue,
          inputFormat: [
            ThousandsFormatter(allowFraction: true)
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'ตัวอย่าง: 15.16',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
            onPressed: _handleSave,
            icon: const Icon(Icons.save_rounded, size: 24),
            label: Text(
              "บันทึก".tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() async {
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
  }
}