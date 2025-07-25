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
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_widget.dart';
import 'package:sizer/sizer.dart';

class BuyMatchingDialog extends StatefulWidget {
  const BuyMatchingDialog({super.key});

  @override
  State<BuyMatchingDialog> createState() => _BuyMatchingDialogState();
}

class _BuyMatchingDialogState extends State<BuyMatchingDialog> {
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
  TextEditingController bookDate = TextEditingController();
  TextEditingController unitPriceCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();
  TextEditingController bookDateCtrl = TextEditingController();

  final controller = BoardDateTimeController();

  DateTime date = DateTime.now();
  late Screen size;

  String? txt;
  bool showCal = false;

  FocusNode bahtFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode unitFocus = FocusNode();

  bool bahtReadOnly = false;
  bool gramReadOnly = false;
  bool priceReadOnly = false;
  bool unitReadOnly = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumBuyThengTotalMatching();
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
    bookDate.dispose();
    unitPriceCtrl.dispose();
    warehouseCtrl.dispose();
    bookDateCtrl.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/product/type/BARM/33', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
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
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/type/BARM/33', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        warehouseList = warehouses;
        selectedWarehouse = warehouseList.where((e) => e.isDefault == 1).first;
        // motivePrint(selectedWarehouse?.toJson());
        // selectedWarehouse = warehouseList.first;
        warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
            WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        await loadQtyByLocation(selectedWarehouse!.id!);
        setState(() {});
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
    if (txt == 'unit') {
      unitReadOnly = true;
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
          if (txt == 'unit') {
            unitPriceCtrl.text = value != null ? "${Global.format(value)}" : "";
            unitChanged();
          }
          if (txt == 'baht') {
            productWeightBahtCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            bahtChanged();
          }
          if (txt == 'price') {
            productPriceCtrl.text =
                value != null ? "${Global.format(value)}" : "";
          }
          FocusScope.of(context).requestFocus(FocusNode());
          closeCal();
        }
        if (kDebugMode) {
          print('$key\t$value\t$expression');
        }
      },
    );
    setState(() {
      showCal = true;
    });
  }

  void closeCal() {
    unitReadOnly = false;
    gramReadOnly = false;
    bahtReadOnly = false;
    priceReadOnly = false;
    AppCalculatorManager.hideCalculator();
    setState(() {
      showCal = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
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
              Container(
                width: double.infinity,
                height: (MediaQuery.of(context).orientation ==
                        Orientation.landscape)
                    ? 80
                    : 70,
                decoration: const BoxDecoration(color: Colors.teal),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'ซื้อทองแท่ง (จับคู่)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: (MediaQuery.of(context).orientation ==
                                Orientation.landscape)
                            ? 16.sp
                            : 16.sp,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 6,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'วันจองราคา',
                            style: TextStyle(fontSize: 16.sp, color: textColor),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '',
                            style: TextStyle(color: textColor, fontSize: 16.sp),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      )),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: DateWidget(dateCtrl: bookDateCtrl, label: ''),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
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
                  child: Row(children: [
                    Expanded(
                        flex: 6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'บาททองละ',
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
                          inputType: TextInputType.number,
                          controller: unitPriceCtrl,
                          readOnly: unitReadOnly,
                          focusNode: unitFocus,
                          inputFormat: [
                            ThousandsFormatter(allowFraction: true)
                          ],
                          clear: () {
                            setState(() {
                              unitPriceCtrl.text = "";
                            });
                            unitChanged();
                          },
                          onTap: () {
                            txt = 'unit';
                            closeCal();
                          },
                          openCalc: () {
                            if (!showCal) {
                              txt = 'unit';
                              unitFocus.requestFocus();
                              openCal();
                            }
                          },
                          onChanged: (value) {
                            unitChanged();
                          }),
                    ),
                  ])),
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
                              'จำนวนเงิน',
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
                            if (productPriceCtrl.text.isNotEmpty) {
                              setState(() {});
                            }
                          }),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding:
              //       const EdgeInsets
              //           .all(8.0),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child:
              //             Padding(
              //           padding: const EdgeInsets
              //               .all(
              //               8.0),
              //           child: buildTextFieldBig(
              //               labelText:
              //                   "รวมราคารับซื้",
              //               inputType: TextInputType
              //                   .number,
              //               textColor: Colors
              //                   .orange,
              //               controller:
              //                   productPriceTotalCtrl,
              //               inputFormat: [
              //                 ThousandsFormatter(allowFraction: true)
              //               ],
              //               enabled:
              //                   false),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
                      if (bookDateCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาเลือกวันจอง', 'OK');
                        return;
                      }

                      if (!checkDate(bookDateCtrl.text)) {
                        Alert.warning(context, 'คำเตือน',
                            'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK',
                            action: () {});
                        return;
                      }

                      if (productCodeCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาเลือกสินค้า', 'OK');
                        return;
                      }

                      if (productWeightBahtCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK');
                        return;
                      }

                      if (productPriceCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกราคา', 'OK');
                        return;
                      }

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
                      //     context,
                      //     'ต้องการบันทึกข้อมูลหรือไม่?',
                      //     '',
                      //     'ตกลง', action: () async {
                      Global.buyThengOrderDetailMatching!.add(
                        OrderDetailModel(
                            productName: selectedProduct!.name,
                            productId: selectedProduct!.id,
                            binLocationId: selectedWarehouse!.id,
                            weight: Global.toNumber(productWeightCtrl.text),
                            weightBath:
                                Global.toNumber(productWeightBahtCtrl.text),
                            commission: 0,
                            taxBase: 0,
                            unitCost: Global.toNumber(unitPriceCtrl.text),
                            priceIncludeTax:
                                Global.toNumber(productPriceCtrl.text),
                            bookDate: bookDate.text != ""
                                ? Global.convertDate(bookDate.text)
                                : null),
                      );
                      sumBuyThengTotalMatching();
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

  void unitChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty &&
        unitPriceCtrl.text.isNotEmpty) {
      productPriceCtrl.text = Global.format(
          Global.toNumber(unitPriceCtrl.text) *
              Global.toNumber(productWeightBahtCtrl.text));
    } else {
      productPriceCtrl.text = "";
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = Global.format(
          Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue());
      // unitPriceCtrl.text = Global.format(Global.getSellThengPrice(getUnitWeightValue()));
      if (unitPriceCtrl.text.isNotEmpty) {
        productPriceCtrl.text = Global.format(
            Global.toNumber(unitPriceCtrl.text) *
                Global.toNumber(productWeightBahtCtrl.text));
      }
    } else {
      productWeightCtrl.text = "";
      unitPriceCtrl.text = "";
      productPriceCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    productPriceCtrl.text = "";
    productWeightBahtCtrl.text = "";
    bookDate.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
    unitPriceCtrl.text = "";
    warehouseCtrl.text = "";
    productNotifier = ValueNotifier<ProductModel>(
        selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    productCodeCtrl.text =
        (selectedProduct != null ? selectedProduct?.productCode! : "")!;
    productNameCtrl.text =
        (selectedProduct != null ? selectedProduct?.name : "")!;
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    bookDateCtrl.text = Global.formatDateD(DateTime.now().toString());
  }
}
