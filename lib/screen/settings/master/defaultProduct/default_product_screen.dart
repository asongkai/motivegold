import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_type.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/response.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';

class DefaultProductScreen extends StatefulWidget {
  const DefaultProductScreen({super.key});

  @override
  State<DefaultProductScreen> createState() => _DefaultProductScreenState();
}

class _DefaultProductScreenState extends State<DefaultProductScreen> {
  bool loading = false;
  List<OrderTypeModel>? dataList = [];
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  Screen? size;
  ProductModel? productModel;
  static ValueNotifier<dynamic>? productNotifier;

  WarehouseModel? warehouseModel;
  static ValueNotifier<dynamic>? warehouseNotifier;

  @override
  void initState() {
    super.initState();
    productNotifier = ValueNotifier<ProductModel>(
        productModel ?? ProductModel(id: 0, name: 'เลือกสินค้า'));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        warehouseModel ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
      await ApiServices.post('/ordertype/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<OrderTypeModel> products = orderTypeModelFromJson(data);
        setState(() {
          dataList = products;
          Global.orderTypes = products;
        });
      } else {
        dataList = [];
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
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("จัดการค่าเริ่มต้นของหน้าจอ",
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : dataList!.isEmpty
            ? const NoDataFoundWidget()
            : Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: dataList!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              return modernProductCard(dataList, index);
            },
          ),
        ),
      ),
    );
  }

  Widget modernProductCard(List<OrderTypeModel>? list, int index) {
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
            // Header Section
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings_applications_rounded,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'หน้าจอ ${list![index].name!}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Content Section with Button Inside
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.inventory_2_outlined,
                          label: 'สินค้าเริ่มต้น',
                          value: list[index].productName ?? 'ยังไม่ได้กำหนด',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.warehouse_outlined,
                          label: 'คลังสินค้าเริ่มต้น',
                          value: list[index].warehouseName ?? 'ยังไม่ได้กำหนด',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Right Button - Inside the grey box
                  SizedBox(
                    width: 200,
                    child: KclButton(
                      text: 'ตั้งค่าเริ่มต้น',
                      icon: Icons.tune_rounded,
                      fullWidth: true,
                      onTap: () async {
                        await _handleSettingsPressed(list[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleSettingsPressed(OrderTypeModel orderType) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal,
        isDismissible: true,
        showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());

    try {
      productModel = null;
      Response? result;
      if (orderType.id == 7) {
        result = await ApiServices.post(
            '/product/all', Global.requestObj(null));
      } if (orderType.id == 5) {
        result = await ApiServices.post(
            '/product/refill', Global.requestObj(null));
      } else if (orderType.id == 10 || orderType.id == 11) {
        result = await ApiServices.post(
            '/product/type/BAR', Global.requestObj(null));
      } else {
        result = await ApiServices.post(
            '/product/type/${Global.getOrderTypeCode(orderType.id)}',
            Global.requestObj(null));
      }

      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            if (orderType.defaultProductId != null) {
              for (int i = 0; i < productList.length; i++) {
                if (orderType.defaultProductId == productList[i].id) {
                  productModel = productList[i];
                }
              }
            }
            productNotifier = ValueNotifier<ProductModel>(
                productModel ?? ProductModel(name: 'เลือกสินค้า', id: 0));
          }
        });
      } else {
        productList = [];
      }

      warehouseModel = null;
      var warehouse = await ApiServices.post(
          '/binlocation/all/branch', Global.requestObj({"branchId": Global.branch?.id}));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        warehouseList = warehouses;
        if (warehouseList.isNotEmpty) {
          if (orderType.defaultWarehouseId != null) {
            for (int i = 0; i < warehouseList.length; i++) {
              if (orderType.defaultWarehouseId == warehouseList[i].id) {
                warehouseModel = warehouseList[i];
              }
            }
          }
          warehouseNotifier = ValueNotifier<WarehouseModel>(
              warehouseModel ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        }
      } else {
        warehouseList = [];
      }
      await pr.hide();
    } catch (e) {
      await pr.hide();
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(), action: () {});
      }
    } finally {
      modernProductDialog(orderType);
    }
  }

  void modernProductDialog(OrderTypeModel model) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: (MediaQuery.of(context).orientation == Orientation.landscape)
                  ? MediaQuery.of(context).size.width * 0.5
                  : MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_applications_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ตั้งค่าหน้าจอ ${model.name}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Selection
                        _buildSectionHeader(
                          icon: Icons.inventory_2_outlined,
                          title: 'สินค้าเริ่มต้น',
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 70,
                          child: MiraiDropDownMenu<ProductModel>(
                            key: UniqueKey(),
                            children: productList,
                            space: 4,
                            maxHeight: 360,
                            showSearchTextField: true,
                            selectedItemBackgroundColor: Colors.transparent,
                            emptyListMessage: 'ไม่มีข้อมูล',
                            showSelectedItemBackgroundColor: true,
                            itemWidgetBuilder: (
                                int index,
                                ProductModel? project, {
                                  bool isItemSelected = false,
                                }) {
                              return DropDownItemWidget(
                                project: project,
                                isItemSelected: isItemSelected,
                                firstSpace: 10,
                                fontSize: 16.sp,
                              );
                            },
                            onChanged: (ProductModel value) async {
                              productModel = value;
                              productNotifier!.value = value;
                              setState(() {});
                            },
                            child: DropDownObjectChildWidget(
                              key: GlobalKey(),
                              fontSize: 16.sp,
                              projectValueNotifier: productNotifier!,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Warehouse Selection
                        _buildSectionHeader(
                          icon: Icons.warehouse_outlined,
                          title: 'คลังสินค้าเริ่มต้น',
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: MiraiDropDownMenu<WarehouseModel>(
                            key: UniqueKey(),
                            children: warehouseList,
                            space: 4,
                            maxHeight: 360,
                            showSearchTextField: true,
                            selectedItemBackgroundColor: Colors.transparent,
                            emptyListMessage: 'ไม่มีข้อมูล',
                            showSelectedItemBackgroundColor: true,
                            itemWidgetBuilder: (
                                int index,
                                WarehouseModel? project, {
                                  bool isItemSelected = false,
                                }) {
                              return DropDownItemWidget(
                                project: project,
                                isItemSelected: isItemSelected,
                                firstSpace: 10,
                                fontSize: size?.getWidthPx(8),
                              );
                            },
                            onChanged: (WarehouseModel value) {
                              warehouseModel = value;
                              warehouseNotifier!.value = value;
                              setState(() {});
                            },
                            child: DropDownObjectChildWidget(
                              key: GlobalKey(),
                              fontSize: size?.getWidthPx(8),
                              projectValueNotifier: warehouseNotifier!,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Save Button
                        KclButton(
                          text: 'บันทึกการตั้งค่า',
                          icon: Icons.save_rounded,
                          fullWidth: true,
                          onTap: () => save(context, model),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
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
    );
  }

  void save(BuildContext context, OrderTypeModel model) {
    if (productModel == null) {
      return;
    }

    if (warehouseModel == null) {
      return;
    }

    model.defaultProductId = productModel?.id;
    model.defaultWarehouseId = warehouseModel?.id;
    model.orderTypeId = model.id;

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            var result = await ApiServices.put(
                '/ordertype', model.id, Global.requestObj(model));
            await pr.hide();
            motivePrint(result?.toJson());
            if (result?.status == "success") {
              if (mounted) {
                loadData();
                Alert.success(context, 'Success'.tr(), '', 'OK'.tr(), action: () {
                  Navigator.of(context).pop();
                });
              }
            } else {
              if (mounted) {
                Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
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
        });
  }
}