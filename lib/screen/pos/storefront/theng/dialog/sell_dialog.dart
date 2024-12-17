import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/screen/gold/gold_price_mini_screen.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class SellDialog extends StatefulWidget {
  const SellDialog({super.key});

  @override
  State<SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<SellDialog> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  List<QtyLocationModel> qtyLocationList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productWeightRemainCtrl = TextEditingController();
  TextEditingController productWeightBahtRemainCtrl = TextEditingController();
  TextEditingController productCommissionCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productPriceTotalCtrl = TextEditingController();
  TextEditingController reserveDateCtrl = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  final controller = BoardDateTimeController();

  DateTime date = DateTime.now();

  String? txt;
  bool showCal = false;

  FocusNode bahtFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode comFocus = FocusNode();

  bool bahtReadOnly = false;
  bool gramReadOnly = false;
  bool priceReadOnly = false;
  bool comReadOnly = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumSellThengTotal();
    loadProducts();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    productCodeCtrl.dispose();
    productNameCtrl.dispose();
    productWeightCtrl.dispose();
    productWeightBahtCtrl.dispose();
    productWeightRemainCtrl.dispose();
    productWeightBahtRemainCtrl.dispose();
    productCommissionCtrl.dispose();
    productPriceCtrl.dispose();
    productPriceTotalCtrl.dispose();
    reserveDateCtrl.dispose();
    marketPriceTotalCtrl.dispose();
    warehouseCtrl.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/product/type/BARM', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.first;
            productCodeCtrl.text =
                (selectedProduct != null ? selectedProduct?.productCode! : "")!;
            productNameCtrl.text =
                (selectedProduct != null ? selectedProduct?.name : "")!;
            productNotifier = ValueNotifier<ProductModel>(
                selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
          }
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/sell', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
          selectedWarehouse = warehouseList.first;
          warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
              WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        });
        await loadQtyByLocation(selectedWarehouse!.id!);
      } else {
        warehouseList = [];
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

  Future<void> loadQtyByLocation(int id) async {
    try {
      // final ProgressDialog pr = ProgressDialog(context,
      //     type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      // await pr.show();
      // pr.update(message: 'processing'.tr());
      var result = await ApiServices.get(
          '/qtybylocation/by-product-location/$id/${selectedProduct!.id}');
      // await pr.hide();
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        motivePrint(data);
        List<QtyLocationModel> qtys = qtyLocationListModelFromJson(data);
        setState(() {
          qtyLocationList = qtys;
        });
      } else {
        qtyLocationList = [];
      }
      productWeightRemainCtrl.text =
          formatter.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtRemainCtrl.text = formatter
          .format(Global.getTotalWeightByLocation(qtyLocationList) / 15.16);
      setState(() {});
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void openCal() {
    if (txt == 'com') {
      comReadOnly = true;
    }
    if (txt == 'gram') {
      gramReadOnly = true;
    }
    if (txt == 'baht') {
      bahtReadOnly = true;
    }
    if (txt == 'price') {
      priceReadOnly = true;
    }
    setState(() {
      showCal = true;
    });
  }

  void closeCal() {
    // if (txt == 'com') {
      comReadOnly = false;
    // }
    // if (txt == 'gram') {
      gramReadOnly = false;
    // }
    // if (txt == 'baht') {
      bahtReadOnly = false;
    // }
    // if (txt == 'price') {
      priceReadOnly = false;
    // }
    setState(() {
      showCal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
              closeCal();
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: const BoxDecoration(color: stBgColor),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'ขายทองคำแท่ง',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: size.getWidthPx(15), color: Colors.white),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        GoldPriceMiniScreen(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // SizedBox(
                  //   height: 100,
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         flex: 5,
                  //         child:
                  //             Padding(
                  //           padding: const EdgeInsets
                  //               .all(
                  //               8.0),
                  //           child:
                  //               SizedBox(
                  //             height:
                  //                 80,
                  //             child: MiraiDropDownMenu<
                  //                 ProductModel>(
                  //               key:
                  //                   UniqueKey(),
                  //               children:
                  //                   productList,
                  //               space:
                  //                   4,
                  //               maxHeight:
                  //                   360,
                  //               showSearchTextField:
                  //                   true,
                  //               selectedItemBackgroundColor:
                  //                   Colors.transparent,
                  //               emptyListMessage:
                  //                   'ไม่มีข้อมูล',
                  //               showSelectedItemBackgroundColor:
                  //                   true,
                  //               itemWidgetBuilder:
                  //                   (
                  //                 int index,
                  //                 ProductModel?
                  //                     project, {
                  //                 bool isItemSelected =
                  //                     false,
                  //               }) {
                  //                 return DropDownItemWidget(
                  //                   project: project,
                  //                   isItemSelected: isItemSelected,
                  //                   firstSpace: 10,
                  //                   fontSize: size.getWidthPx(6),
                  //                 );
                  //               },
                  //               onChanged:
                  //                   (ProductModel value) {
                  //                 productCodeCtrl.text =
                  //                     value.productCode!.toString();
                  //                 productNameCtrl.text =
                  //                     value.name;
                  //                 selectedProduct =
                  //                     value;
                  //                 productNotifier!.value =
                  //                     value;
                  //                 if (selectedWarehouse !=
                  //                     null) {
                  //                   loadQtyByLocation(selectedWarehouse!.id!);
                  //                   setState(() {});
                  //                 }
                  //               },
                  //               child:
                  //                   DropDownObjectChildWidget(
                  //                 key:
                  //                     GlobalKey(),
                  //                 fontSize:
                  //                     size.getWidthPx(6),
                  //                 projectValueNotifier:
                  //                     productNotifier!,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets
                  //           .all(8.0),
                  //   child: buildTextFieldBig(
                  //       labelText:
                  //           "รหัสสินค้า",
                  //       textColor:
                  //           Colors
                  //               .orange,
                  //       controller:
                  //           productCodeCtrl,
                  //       enabled:
                  //           false),
                  // ),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child:
                  //           Padding(
                  //         padding:
                  //             const EdgeInsets
                  //                 .all(
                  //                 8.0),
                  //         child:
                  //             SizedBox(
                  //           height:
                  //               80,
                  //           child: MiraiDropDownMenu<
                  //               WarehouseModel>(
                  //             key:
                  //                 UniqueKey(),
                  //             children:
                  //                 warehouseList,
                  //             space:
                  //                 4,
                  //             maxHeight:
                  //                 360,
                  //             showSearchTextField:
                  //                 true,
                  //             selectedItemBackgroundColor:
                  //                 Colors.transparent,
                  //             emptyListMessage:
                  //                 'ไม่มีข้อมูล',
                  //             showSelectedItemBackgroundColor:
                  //                 true,
                  //             itemWidgetBuilder:
                  //                 (
                  //               int index,
                  //               WarehouseModel?
                  //                   project, {
                  //               bool isItemSelected =
                  //                   false,
                  //             }) {
                  //               return DropDownItemWidget(
                  //                 project:
                  //                     project,
                  //                 isItemSelected:
                  //                     isItemSelected,
                  //                 firstSpace:
                  //                     10,
                  //                 fontSize:
                  //                     size.getWidthPx(6),
                  //               );
                  //             },
                  //             onChanged:
                  //                 (WarehouseModel
                  //                     value) {
                  //               warehouseCtrl.text = value
                  //                   .id!
                  //                   .toString();
                  //               selectedWarehouse =
                  //                   value;
                  //               warehouseNotifier!.value =
                  //                   value;
                  //               loadQtyByLocation(
                  //                   value.id!);
                  //               setState(
                  //                   () {});
                  //             },
                  //             child:
                  //                 DropDownObjectChildWidget(
                  //               key:
                  //                   GlobalKey(),
                  //               fontSize:
                  //                   size.getWidthPx(6),
                  //               projectValueNotifier:
                  //                   warehouseNotifier!,
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // Padding(
                  //   padding:
                  //       const EdgeInsets
                  //           .all(8.0),
                  //   child: Row(
                  //     children: [
                  //       Expanded(
                  //         child: buildTextFieldBig(
                  //             labelText:
                  //                 "น้ำหนัก (บาททอง) ที่เหลืออยู่",
                  //             inputType:
                  //                 TextInputType
                  //                     .phone,
                  //             textColor:
                  //                 Colors
                  //                     .black38,
                  //             enabled:
                  //                 false,
                  //             controller:
                  //                 productWeightBahtRemainCtrl,
                  //             inputFormat: [
                  //               ThousandsFormatter(
                  //                   allowFraction: true)
                  //             ],
                  //             onChanged:
                  //                 (String
                  //                     value) {}),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'จำนวนน้ำหนัก',
                                  style:
                                      TextStyle(fontSize: 50, color: textColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '(บาททอง)',
                                  style:
                                      TextStyle(color: textColor, fontSize: 30),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 6,
                          child: numberTextField(
                              labelText: "",
                              inputType: TextInputType.phone,
                              controller: productWeightBahtCtrl,
                              readOnly: bahtReadOnly,
                              focusNode: bahtFocus,
                              inputFormat: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                              clear: () {
                                setState(() {
                                  productWeightBahtCtrl.text = "";
                                });
                                bahtChanged();
                              },
                              onTap: () {
                                txt = 'baht';
                                closeCal();
                              },
                              openCalc: () {
                                if (!showCal) {
                                  txt = 'baht';
                                  bahtFocus.requestFocus();
                                  openCal();
                                }
                              },
                              onChanged: (String value) {
                                bahtChanged();
                              }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'ราคาขายทองคำแท่ง',
                                  style:
                                      TextStyle(fontSize: 50, color: textColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style:
                                      TextStyle(color: textColor, fontSize: 30),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 6,
                          child: numberTextField(
                              labelText: "",
                              inputType: TextInputType.phone,
                              enabled: true,
                              controller: productPriceCtrl,
                              readOnly: priceReadOnly,
                              focusNode: priceFocus,
                              inputFormat: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                              clear: () {
                                setState(() {
                                  productPriceCtrl.text = "";
                                });
                                priceChanged();
                              },
                              onTap: () {
                                txt = 'price';
                                closeCal();
                              },
                              openCalc: () {
                                if (!showCal) {
                                  txt = 'price';
                                  priceFocus.requestFocus();
                                  openCal();
                                }
                              },
                              onChanged: (String value) {
                                priceChanged();
                              }),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'ค่าบล็อกทอง',
                                  style:
                                      TextStyle(fontSize: 50, color: textColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style:
                                      TextStyle(color: textColor, fontSize: 30),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 6,
                          child: numberTextField(
                              labelText: "",
                              inputType: TextInputType.phone,
                              controller: productCommissionCtrl,
                              readOnly: comReadOnly,
                              focusNode: comFocus,
                              inputFormat: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                              clear: () {
                                setState(() {
                                  productCommissionCtrl.text = "";
                                });
                                bahtChanged();
                              },
                              onTap: () {
                                txt = 'com';
                                closeCal();
                              },
                              openCalc: () {
                                if (!showCal) {
                                  txt = 'com';
                                  comFocus.requestFocus();
                                  openCal();
                                }
                              },
                              onChanged: (String value) {
                                comChanged();
                              }),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'รวมราคาขาย',
                                  style:
                                      TextStyle(fontSize: 50, color: textColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style:
                                      TextStyle(color: textColor, fontSize: 30),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 6,
                          child: buildTextFieldBig(
                              labelText: "",
                              inputType: TextInputType.number,
                              textColor: Colors.grey,
                              controller: productPriceTotalCtrl,
                              align: TextAlign.right,
                              inputFormat: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                              enabled: false),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: double.infinity, minHeight: 100),
                            child: MaterialButton(
                              color: Colors.redAccent,
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      "ยกเลิก",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 30),
                                    ),
                                  ],
                                ),
                              ),
                              onPressed: () async {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                                minWidth: double.infinity, minHeight: 100),
                            child: MaterialButton(
                              color: stBgColor,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.save,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "บันทึก",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 30),
                                  ),
                                ],
                              ),
                              onPressed: () async {
                                if (productCodeCtrl.text.isEmpty) {
                                  Alert.warning(context, 'คำเตือน',
                                      'กรุณาเลือกสินค้า', 'OK');
                                  return;
                                }

                                if (productWeightBahtCtrl.text.isEmpty) {
                                  Alert.warning(context, 'คำเตือน',
                                      'กรุณาใส่น้ำหนัก', 'OK');
                                  return;
                                }

                                if (productPriceTotalCtrl.text.isEmpty) {
                                  Alert.warning(context, 'คำเตือน',
                                      'กรุณากรอกราคา', 'OK');
                                  return;
                                }

                                var realPrice = Global.getBuyThengPrice(
                                    Global.toNumber(productWeightCtrl.text));
                                var price =
                                    Global.toNumber(productPriceCtrl.text);
                                var check = price - realPrice;

                                // if (check >
                                //     10000) {
                                //   Alert.warning(
                                //       context,
                                //       'คำเตือน',
                                //       'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                                //       'OK');
                                //
                                //   return;
                                // }

                                if (price < realPrice) {
                                  Alert.warning(
                                      context,
                                      'คำเตือน',
                                      'ราคาที่ป้อนน้อยกว่าราคาตลาด ${Global.format(check)}',
                                      'OK');

                                  return;
                                }
                                Alert.info(
                                    context,
                                    'ต้องการบันทึกข้อมูลหรือไม่?',
                                    '',
                                    'ตกลง', action: () async {
                                  Global.sellThengOrderDetail!.add(
                                    OrderDetailModel(
                                        productName: productNameCtrl.text,
                                        productId: selectedProduct!.id,
                                        binLocationId: selectedWarehouse!.id,
                                        weight: Global.toNumber(
                                            productWeightCtrl.text),
                                        weightBath: Global.toNumber(
                                            productWeightBahtCtrl.text),
                                        commission: 0,
                                        taxBase: 0,
                                        priceIncludeTax: Global.toNumber(
                                            productPriceTotalCtrl.text),
                                        bookDate: null),
                                  );
                                  sumSellThengTotal();
                                  setState(() {});
                                  Navigator.of(context).pop();
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          if (showCal)
            DragArea(
                closeCal: closeCal,
                child: Container(
                    width: 350,
                    height: 500,
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(color: Color(0xffcccccc)),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Calc(
                          closeCal: closeCal,
                          onChanged: (key, value, expression) {
                            if (key == 'ENT') {
                              if (txt == 'com') {
                                productCommissionCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                comChanged();
                              }
                              if (txt == 'baht') {
                                productWeightBahtCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                bahtChanged();
                              }
                              if (txt == 'price') {
                                productPriceTotalCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                priceChanged();
                              }
                              FocusScope.of(context).requestFocus(FocusNode());
                              closeCal();
                            }
                            if (kDebugMode) {
                              print('$key\t$value\t$expression');
                            }
                          },
                        ),
                        Positioned(
                          right: -35.0,
                          top: -35.0,
                          child: InkWell(
                            onTap: closeCal,
                            child: const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )))
        ],
      ),
    );
  }

  void comChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text =
          "${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}";
      setState(() {});
    }
  }

  void priceChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text = Global.format(
          Global.toNumber(productCommissionCtrl.text) +
              Global.toNumber(productPriceCtrl.text));
      setState(() {});
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = Global.format(
          (Global.toNumber(productWeightBahtCtrl.text) * 15.16).toPrecision(2));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyThengPrice(Global.toNumber(productWeightCtrl.text)));
      productPriceCtrl.text = marketPriceTotalCtrl.text;
      productPriceTotalCtrl.text = productCommissionCtrl.text.isNotEmpty
          ? '${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}'
          : Global.format(Global.toNumber(productPriceCtrl.text)).toString();
    } else {
      productWeightCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      productPriceCtrl.text = "";
      productPriceTotalCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    productPriceCtrl.text = "";
    productPriceTotalCtrl.text = "";
    productWeightBahtCtrl.text = "";
    reserveDateCtrl.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
    marketPriceTotalCtrl.text = "";
    warehouseCtrl.text = "";
    productCodeCtrl.text =
        (selectedProduct != null ? selectedProduct?.productCode! : "")!;
    productNameCtrl.text =
        (selectedProduct != null ? selectedProduct?.name : "")!;
    productNotifier = ValueNotifier<ProductModel>(
        selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }
}
