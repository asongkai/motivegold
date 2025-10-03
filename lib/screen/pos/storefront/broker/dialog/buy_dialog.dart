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
import 'package:motivegold/utils/calculator/manager.dart';
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
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productPriceTotalCtrl = TextEditingController();
  TextEditingController reserveDateCtrl = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  final controller = BoardDateTimeController();

  DateTime date = DateTime.now();

  String? txt;

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
      var result = await ApiServices.post(
          '/product/type/BARM/9', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
        if (productList.isNotEmpty) {
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
          '/binlocation/all/type/BARM/9', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        warehouseList = warehouses;
        selectedWarehouse = warehouseList.where((e) => e.isDefault == 1).first;

        warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
            WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        await loadQtyByLocation(selectedWarehouse!.id!);
        setState(() {});
      } else {
        warehouseList = [];
      }

      if (selectedProduct != null) {
        sumBuyThengTotalBroker(selectedProduct!.id!);
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
              getUnitWeightValue(selectedProduct?.id));
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
    AppCalculatorManager.showCalculator(
      onClose: closeCal,
      onChanged: (key, value, expression) {
        if (key == 'ENT') {
          if (txt == 'com') {
            productCommissionCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            comChanged();
          }
          if (txt == 'baht') {
            productWeightBahtCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            bahtChanged();
          }
          if (txt == 'price') {
            productPriceCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            priceChanged();
          }
          FocusScope.of(context).requestFocus(FocusNode());
          closeCal();
        }
        if (kDebugMode) {
          print('$key\t$value\t$expression');
        }
      },
    );
    setState(() {});
  }

  void closeCal() {
    comReadOnly = false;
    gramReadOnly = false;
    bahtReadOnly = false;
    priceReadOnly = false;
    AppCalculatorManager.hideCalculator();
    setState(() {});
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
          closeCal();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              posHeaderText(
                  context, Colors.teal[900]!, 'ซื้อทองแท่งกับโบรกเกอร์'),
              if (selectedProduct != null)
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: GoldMiniWidget(product: selectedProduct!,),
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
                              style:
                                  TextStyle(fontSize: 16.sp, color: textColor),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '(บาททอง)',
                              style:
                                  TextStyle(color: textColor, fontSize: 16.sp),
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
                            txt = 'baht';
                            bahtFocus.requestFocus();
                            openCal();
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
                              'ราคารับซื้อทอง\nคำแท่ง',
                              textAlign: TextAlign.right,
                              style:
                                  TextStyle(fontSize: 16.sp, color: textColor),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '',
                              style:
                                  TextStyle(color: textColor, fontSize: 16.sp),
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
                            txt = 'price';
                            priceFocus.requestFocus();
                            openCal();
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
                    Expanded(
                        flex: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'ค่าบล็อกทอง',
                              style:
                                  TextStyle(fontSize: 16.sp, color: textColor),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '',
                              style:
                                  TextStyle(color: textColor, fontSize: 16.sp),
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
                            txt = 'com';
                            comFocus.requestFocus();
                            openCal();
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
                    Expanded(
                        flex: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'รวมราคารับซื้',
                              style:
                                  TextStyle(fontSize: 16.sp, color: textColor),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              '',
                              style:
                                  TextStyle(color: textColor, fontSize: 16.sp),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        )),
                    Expanded(
                      flex: 6,
                      child: buildTextFieldBig(
                        labelText: "",
                        inputType: TextInputType.number,
                        controller: productPriceTotalCtrl,
                        align: TextAlign.right,
                        inputFormat: [ThousandsFormatter(allowFraction: true)],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.sp),
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
                    color: Colors.teal,
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
                          style:
                              TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ],
                    ),
                    onPressed: () async {
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

                      if (productPriceTotalCtrl.text.isEmpty) {
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

                      Global.buyThengOrderDetailBroker!.add(
                        OrderDetailModel(
                            productName: selectedProduct!.name,
                            productId: selectedProduct!.id,
                            binLocationId: selectedWarehouse!.id,
                            weight: Global.toNumber(productWeightCtrl.text),
                            weightBath:
                                Global.toNumber(productWeightBahtCtrl.text),
                            commission: productCommissionCtrl.text.isEmpty
                                ? 0
                                : Global.toNumber(productCommissionCtrl.text),
                            taxBase: productWeightCtrl.text.isEmpty
                                ? 0
                                : Global.taxBase(
                                    Global.toNumber(productPriceTotalCtrl.text),
                                    Global.toNumber(productWeightCtrl.text), selectedProduct!.id!),
                            priceIncludeTax:
                                Global.toNumber(productPriceTotalCtrl.text),
                            bookDate: null),
                      );
                      sumBuyThengTotalBroker(selectedProduct!.id!);
                      setState(() {});
                      Navigator.of(context).pop();
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

  void comChanged() {
    if (productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text =
          "${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}";
      setState(() {});
    }
  }

  void priceChanged() {
    if (productPriceCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text = Global.format(
          (Global.toNumber(productCommissionCtrl.text) +
              Global.toNumber(productPriceCtrl.text)));
      setState(() {});
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = Global.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue(selectedProduct?.id)));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyThengPrice(Global.toNumber(productWeightCtrl.text), selectedProduct!.id!));
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
