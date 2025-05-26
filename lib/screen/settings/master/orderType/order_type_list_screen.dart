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

class OrderTypeListScreen extends StatefulWidget {
  const OrderTypeListScreen({super.key});

  @override
  State<OrderTypeListScreen> createState() => _OrderTypeListScreenState();
}

class _OrderTypeListScreenState extends State<OrderTypeListScreen> {
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
    // TODO: implement initState
    super.initState();
    productNotifier = ValueNotifier<ProductModel>(
        productModel ?? ProductModel(id: 0, name: 'เลือกสินค้า'));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        warehouseModel ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("จัดการค่าเริ่มต้นของหน้าจอ",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : dataList!.isEmpty
                ? const NoDataFoundWidget()
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height - 350,
                          child: ListView.builder(
                              itemCount: dataList!.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                return productCard(dataList, index);
                              }),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      // motivePrint(Global.requestObj(null));
      var result =
          await ApiServices.post('/ordertype/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        // motivePrint(data);
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

  Widget productCard(List<OrderTypeModel>? list, int index) {
    return Card(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              title: Text(
                'หน้าจอ ${list![index].name!}',
                style: const TextStyle(fontSize: 30),
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'สินค้าเริ่มต้น: ',
                          style: TextStyle(fontSize: 20),
                        ),
                        Flexible(
                            child: Text(
                          '${list[index].productName}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'คลังสินค้าเริ่มต้น: ',
                          style: TextStyle(fontSize: 20),
                          overflow: TextOverflow.visible,
                        ),
                        Flexible(
                            child: Text(
                          '${list[index].warehouseName}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.visible,
                        )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ProgressDialog pr = ProgressDialog(context,
                        type: ProgressDialogType.normal,
                        isDismissible: true,
                        showLogs: true);
                    await pr.show();
                    pr.update(message: 'processing'.tr());
                    try {
                      productModel = null;
                      Response? result;
                      if (list[index].id == 7) {
                        result = await ApiServices.post(
                            '/product/all', Global.requestObj(null));
                      } if (list[index].id == 5) {
                        result = await ApiServices.post(
                            '/product/refill', Global.requestObj(null));
                      } else if (list[index].id == 10 || list[index].id == 11) {
                        result = await ApiServices.post(
                            '/product/type/BAR', Global.requestObj(null));
                      } else {
                        result = await ApiServices.post(
                            '/product/type/${Global.getOrderTypeCode(list[index].id)}',
                            Global.requestObj(null));
                      }
                      if (result?.status == "success") {
                        var data = jsonEncode(result?.data);
                        List<ProductModel> products =
                            productListModelFromJson(data);
                        setState(() {
                          productList = products;
                          if (productList.isNotEmpty) {
                            if (list[index].defaultProductId != null) {
                              for (int i = 0; i < productList.length; i++) {
                                if (list[index].defaultProductId ==
                                    productList[i].id) {
                                  productModel = productList[i];
                                }
                              }
                            }
                            productNotifier = ValueNotifier<ProductModel>(
                                productModel ??
                                    ProductModel(name: 'เลือกสินค้า', id: 0));
                          }
                        });
                      } else {
                        productList = [];
                      }
                      warehouseModel = null;
                      var warehouse = await ApiServices.post(
                          '/binlocation/all/branch', Global.requestObj(null));
                      if (warehouse?.status == "success") {
                        var data = jsonEncode(warehouse?.data);
                        List<WarehouseModel> warehouses =
                            warehouseListModelFromJson(data);
                        warehouseList = warehouses;
                        if (warehouseList.isNotEmpty) {
                          if (list[index].defaultWarehouseId != null) {
                            for (int i = 0; i < warehouseList.length; i++) {
                              if (list[index].defaultWarehouseId ==
                                  warehouseList[i].id) {
                                warehouseModel = warehouseList[i];
                              }
                            }
                          }
                          warehouseNotifier = ValueNotifier<WarehouseModel>(
                              warehouseModel ??
                                  WarehouseModel(
                                      id: 0, name: 'เลือกคลังสินค้า'));
                        }
                      } else {
                        warehouseList = [];
                      }
                      await pr.hide();
                    } catch (e) {
                      await pr.hide();
                      if (mounted) {
                        Alert.warning(
                            context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                            action: () {});
                      }
                    } finally {
                      productDialog(list[index]);
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(8)),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'ตั้งค่าเริ่มต้น',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void productDialog(OrderTypeModel model) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -50.0,
                  top: -50.0,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close),
                      ),
                    ),
                  ),
                ),
                Form(
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: SizedBox(
                      width: (MediaQuery.of(context).orientation == Orientation.landscape)
                          ? MediaQuery.of(context).size.width * 2 / 4
                          : MediaQuery.of(context).size.width * 3 / 4,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 100,
                              decoration: const BoxDecoration(color: btBgColor),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'หน้าจอ ${model.name}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: size?.getWidthPx(15),
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'สินค้าเริ่มต้น',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: size?.getWidthPx(10),
                                    color: textColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 70,
                                child: MiraiDropDownMenu<ProductModel>(
                                  key: UniqueKey(),
                                  children: productList,
                                  space: 4,
                                  maxHeight: 360,
                                  showSearchTextField: true,
                                  selectedItemBackgroundColor:
                                      Colors.transparent,
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
                                      fontSize: size?.getWidthPx(10),
                                    );
                                  },
                                  onChanged: (ProductModel value) async {
                                    productModel = value;
                                    productNotifier!.value = value;
                                    setState(() {

                                    });
                                  },
                                  child: DropDownObjectChildWidget(
                                    key: GlobalKey(),
                                    fontSize: size?.getWidthPx(10),
                                    projectValueNotifier: productNotifier!,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'คลังสินค้าเริ่มต้น',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: size?.getWidthPx(10),
                                    color: textColor),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 80,
                                child: MiraiDropDownMenu<WarehouseModel>(
                                  key: UniqueKey(),
                                  children: warehouseList,
                                  space: 4,
                                  maxHeight: 360,
                                  showSearchTextField: true,
                                  selectedItemBackgroundColor:
                                      Colors.transparent,
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
                                    setState(() {

                                    });
                                  },
                                  child: DropDownObjectChildWidget(
                                    key: GlobalKey(),
                                    fontSize: size?.getWidthPx(8),
                                    projectValueNotifier: warehouseNotifier!,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: KclButton(
                                  text: 'บันทึก',
                                  icon: Icons.save_alt_outlined,
                                  fullWidth: true,
                                  onTap: () {
                                    save(context, model);
                                  },
                                ))
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
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

    // motivePrint(warehouseModel?.toJson());
    // motivePrint(model.toJson());

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        // motivePrint(Global.requestObj(model));
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
