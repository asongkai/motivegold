import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_mini_widget.dart';
import 'package:motivegold/screen/gold/gold_price_mini_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/ui/text_header.dart';
import 'package:sizer/sizer.dart';

class BuyDialog extends StatefulWidget {
  const BuyDialog({super.key});

  @override
  State<BuyDialog> createState() => _BuyDialogState();
}

class _BuyDialogState extends State<BuyDialog> {
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
  // TextEditingController productPriceCtrl = TextEditingController();
  // TextEditingController productPriceTotalCtrl = TextEditingController();
  final TextEditingController reserveDateCtrl = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  TextEditingController priceExcludeTaxCtrl = TextEditingController();
  TextEditingController priceIncludeTaxCtrl = TextEditingController();

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
    sumBuyThengTotal();
    loadProducts();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    warehouseCtrl.dispose();
    marketPriceTotalCtrl.dispose();
    reserveDateCtrl.dispose();
    priceIncludeTaxCtrl.dispose();
    priceExcludeTaxCtrl.dispose();
    productCommissionCtrl.dispose();
    productWeightBahtRemainCtrl.dispose();
    productWeightRemainCtrl.dispose();
    productWeightBahtCtrl.dispose();
    productWeightCtrl.dispose();
    productNameCtrl.dispose();
    productCodeCtrl.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/product/type/BAR/44', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
        if (productList.isNotEmpty) {
          // selectedProduct = productList.first;
          selectedProduct = productList.where((e) => e.isDefault == 1).first;
          productCodeCtrl.text =
              (selectedProduct != null ? selectedProduct?.productCode! : "")!;
          productNameCtrl.text =
              (selectedProduct != null ? selectedProduct?.name : "")!;
          productNotifier = ValueNotifier<ProductModel>(
              selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
        }
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/type/BAR/44', Global.requestObj(null));
      // motivePrint(warehouse?.toJson());
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        warehouseList = warehouses;
        selectedWarehouse = warehouseList.where((e) => e.isDefault == 1).first;
        // motivePrint(selectedWarehouse?.toJson());
        warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
            WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        setState(() {});
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
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<QtyLocationModel> qtys = qtyLocationListModelFromJson(data);
        setState(() {
          qtyLocationList = qtys;
        });
      } else {
        qtyLocationList = [];
      }
      // await pr.hide();

      productWeightRemainCtrl.text =
          formatter.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtRemainCtrl.text = formatter.format(
          Global.getTotalWeightByLocation(qtyLocationList) /
              getUnitWeightValue());
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
      appBar: const CustomAppBar(
        height: 220,
        hasChild: false,
        child: TitleContent(
          backButton: true,
        ),
      ),
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
                  posHeaderText(context, btBgColor, 'ซื้อทองคำแท่ง'),
                  const Padding(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: GoldMiniWidget(screen: 3),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'จำนวนน้ำหนัก',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '(กรัม)',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 16.sp),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 6,
                          child: numberTextField(
                            labelText: "",
                            inputType: TextInputType.phone,
                            controller: productWeightCtrl,
                            readOnly: gramReadOnly,
                            focusNode: gramFocus,
                            inputFormat: [
                              ThousandsFormatter(allowFraction: true)
                            ],
                            clear: () {
                              setState(() {
                                productWeightCtrl.text = "";
                              });
                              gramChanged();
                            },
                            onTap: () {
                              txt = 'gram';
                              closeCal();
                            },
                            openCalc: () {
                              if (!showCal) {
                                txt = 'gram';
                                gramFocus.requestFocus();
                                openCal();
                              }
                            },
                            onChanged: (String value) {
                              // gramChanged();
                            },
                            onFocusChange: (value) {
                              if (!value) {
                                gramChanged();
                              }
                            },
                          ),
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
                        Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'จำนวนน้ำหนัก',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '(บาททอง)',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 16.sp),
                                ),
                                const SizedBox(
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
                        Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'รวมราคารับซื้อ',
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: 16.sp),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            )),
                        Expanded(
                          flex: 6,
                          child: numberTextField(
                              labelText: "",
                              inputType: TextInputType.number,
                              controller: priceIncludeTaxCtrl,
                            readOnly: priceReadOnly,
                            focusNode: priceFocus,
                              inputFormat: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                              clear: () {
                                setState(() {
                                  priceIncludeTaxCtrl.text = "";
                                });
                                bahtChanged();
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
                          ),
                        ),
                      ],
                    ),
                  ),
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
                              if (txt == 'baht') {
                                productWeightBahtCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                bahtChanged();
                              }
                              if (txt == 'gram') {
                                productWeightCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                gramChanged();
                              }

                              if (txt == 'price') {
                                priceIncludeTaxCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
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
      persistentFooterButtons: [
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
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            "ยกเลิก",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp),
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
                    color: btBgColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.save,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          "บันทึก",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      // if (reserveDateCtrl
                      //     .text
                      //     .isEmpty) {
                      //   Alert.warning(
                      //       context,
                      //       'คำเตือน',
                      //       'กรุณาเลือกวันจอง',
                      //       'OK');
                      //   return;
                      // }

                      if (selectedProduct == null) {
                        Alert.warning(context, 'คำเตือน',
                            getDefaultProductMessage(), 'OK',
                            action: () {});
                        return;
                      }

                      if (selectedWarehouse == null) {
                        Alert.warning(context, 'คำเตือน',
                            getDefaultWarehouseMessage(), 'OK',
                            action: () {});
                        return;
                      }

                      if (productWeightBahtCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK',
                            action: () {});
                        return;
                      }

                      if (priceIncludeTaxCtrl.text.isEmpty) {
                        Alert.warning(context, 'คำเตือน', 'กรุณากรอกราคา', 'OK',
                            action: () {});
                        return;
                      }

                      // if (Global.toNumber(
                      //         productWeightCtrl
                      //             .text) >
                      //     Global.toNumber(
                      //         productWeightRemainCtrl
                      //             .text)) {
                      //   Alert.warning(
                      //       context,
                      //       'คำเตือน',
                      //       'ไม่สามารถขายเกินปริมาณคงเหลือได้',
                      //       'OK');
                      //   return;
                      // }

                      // var realPrice =
                      //     Global.getBuyThengPrice(
                      //         Global.toNumber(
                      //             productWeightCtrl.text));
                      // var price = Global
                      //     .toNumber(
                      //         productPriceCtrl
                      //             .text);
                      // var check =
                      //     price -
                      //         realPrice;
                      //
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
                      //
                      // if (check <
                      //     -10000) {
                      //   Alert.warning(
                      //       context,
                      //       'คำเตือน',
                      //       'ราคาที่ป้อนน้อยกว่าราคาตลาด ${Global.format(check)}',
                      //       'OK');
                      //
                      //   return;
                      // }
                      // Alert.info(
                      //     context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                      //     action: () async {
                        Global.buyThengOrderDetail!.add(
                          OrderDetailModel(
                              productName: selectedProduct!.name,
                              productId: selectedProduct!.id,
                              binLocationId: selectedWarehouse!.id,
                              sellTPrice: Global.toNumber(Global.goldDataModel?.theng!.sell),
                              buyTPrice: Global.toNumber(Global.goldDataModel?.theng!.buy),
                              sellPrice: Global.toNumber(Global.goldDataModel?.paphun!.sell),
                              buyPrice: Global.toNumber(Global.goldDataModel?.paphun!.buy),
                              weight: Global.toNumber(productWeightCtrl.text),
                              weightBath:
                                  Global.toNumber(productWeightBahtCtrl.text),
                              commission: 0,
                              taxBase: 0,
                              priceIncludeTax:
                                  Global.toNumber(priceIncludeTaxCtrl.text),
                              bookDate: null),
                        );
                        sumBuyThengTotal();
                        setState(() {});
                        Navigator.of(context).pop();
                      // });
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }


  void gramChanged() {
    if (productWeightCtrl.text.isNotEmpty) {
      productWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productWeightCtrl.text) / getUnitWeightValue()));
    } else {
      productWeightBahtCtrl.text = "";
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = Global.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()));
    } else {
      productWeightCtrl.text = "";
      marketPriceTotalCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    priceIncludeTaxCtrl.text = "";
    priceExcludeTaxCtrl.text = "";
    productWeightBahtCtrl.text = "";
    reserveDateCtrl.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
    marketPriceTotalCtrl.text = "";
    warehouseCtrl.text = "";
    selectedProduct = productList.first;
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
