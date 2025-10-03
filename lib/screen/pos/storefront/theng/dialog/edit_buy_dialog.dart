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

class EditBuyThengDialog extends StatefulWidget {
  const EditBuyThengDialog({super.key});

  @override
  State<EditBuyThengDialog> createState() => _EditBuyThengDialogState();
}

class _EditBuyThengDialogState extends State<EditBuyThengDialog> {
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
  FocusNode priceTotalFocus = FocusNode();
  FocusNode comFocus = FocusNode();

  bool bahtReadOnly = false;
  bool gramReadOnly = false;
  bool priceReadOnly = false;
  bool priceTotalReadOnly = false;
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

      if (selectedProduct != null) {
        sumBuyThengTotal(selectedProduct!.id!);
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
          if (txt == 'baht') {
            productWeightBahtCtrl.text =
            value != null ? "${Global.format(value)}" : "";
            bahtChanged();
          }
          if (txt == 'gram') {
            productWeightCtrl.text =
            value != null ? "${Global.format(value)}" : "";
            gramChanged();
          }

          if (txt == 'com') {
            productCommissionCtrl.text =
            value != null ? "${Global.format(value)}" : "";
            comChanged();
          }

          if (txt == 'price') {
            priceExcludeTaxCtrl.text =
            value != null ? "${Global.format(value)}" : "";
            priceChanged();
          }

          if (txt == 'price_total') {
            priceIncludeTaxCtrl.text =
            value != null ? "${Global.format(value)}" : "";
            priceTotalChanged();
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
    comReadOnly = false;
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
              posHeaderText(context, btBgColor, 'ซื้อทองคำแท่ง'),
              if (selectedProduct != null)
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: GoldMiniWidget(product: selectedProduct!, screen: 3),
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
                              '(กรัม)',
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
                        controller: productWeightCtrl,
                        readOnly: gramReadOnly,
                        focusNode: gramFocus,
                        inputFormat: [ThousandsFormatter(allowFraction: true)],
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
                              'ราคารวมทองคำแท่งรับซื้อ',
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
                        controller: priceExcludeTaxCtrl,
                        readOnly: priceReadOnly,
                        focusNode: priceFocus,
                        inputFormat: [ThousandsFormatter(allowFraction: true)],
                        clear: () {
                          setState(() {
                            priceExcludeTaxCtrl.text = "";
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
                      ),
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
                              'หัก ค่าบล็อก',
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
                            comChanged();
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
                          onFocusChange: (value) {
                            if (!value) {
                              comChanged();
                            }
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
                              'รวมราคารับซื้อสุทธิ',
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
                          controller: priceIncludeTaxCtrl,
                          readOnly: priceTotalReadOnly,
                          focusNode: priceTotalFocus,
                          inputFormat: [
                            ThousandsFormatter(allowFraction: true)
                          ],
                          clear: () {
                            setState(() {
                              priceIncludeTaxCtrl.text = "";
                            });
                            priceTotalChanged();
                          },
                          onTap: () {
                            txt = 'price_total';
                            closeCal();
                          },
                          openCalc: () {
                            if (!showCal) {
                              txt = 'price_total';
                              priceTotalFocus.requestFocus();
                              openCal();
                            }
                          },
                          onFocusChange: (value) {
                            if (!value) {
                              priceTotalChanged();
                            }
                          }),
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

                      if (priceIncludeTaxCtrl.text.isEmpty) {
                        Alert.warning(context, 'คำเตือน', 'กรุณากรอกราคา', 'OK',
                            action: () {});
                        return;
                      }

                      Global.buyThengOrderDetail!.add(
                        OrderDetailModel(
                            productName: selectedProduct!.name,
                            productId: selectedProduct!.id,
                            binLocationId: selectedWarehouse!.id,
                            sellTPrice: Global.toNumber(
                                Global.goldDataModel?.theng!.sell),
                            buyTPrice: Global.toNumber(
                                Global.goldDataModel?.theng!.buy),
                            sellPrice: Global.toNumber(
                                Global.goldDataModel?.paphun!.sell),
                            buyPrice: Global.toNumber(
                                Global.goldDataModel?.paphun!.buy),
                            weight: Global.toNumber(productWeightCtrl.text),
                            weightBath:
                            Global.toNumber(productWeightBahtCtrl.text),
                            commission:
                            Global.toNumber(productCommissionCtrl.text),
                            taxBase: 0,
                            priceExcludeTax:
                            Global.toNumber(priceExcludeTaxCtrl.text),
                            priceIncludeTax:
                            Global.toNumber(priceIncludeTaxCtrl.text),
                            bookDate: null),
                      );
                      sumBuyThengTotal(selectedProduct!.id!);
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

  void gramChanged() {
    if (productWeightCtrl.text != "") {
      productWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productWeightCtrl.text) /
              getUnitWeightValue(selectedProduct?.id)));
      // marketPriceTotalCtrl.text = Global.format(
      //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text), Global.goldDataModel));
      priceExcludeTaxCtrl.text = Global.format(Global.getBuyThengPrice(
          Global.toNumber(productWeightCtrl.text), selectedProduct!.id!));
      comChanged();
    } else {
      productWeightCtrl.text = "";
      productWeightBahtCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      priceExcludeTaxCtrl.text = "";
      productCommissionCtrl.text = "";
    }
    setState(() {});
  }

  void comChanged() {
    if (priceExcludeTaxCtrl.text.isNotEmpty) {
      priceIncludeTaxCtrl.text =
      "${Global.format(Global.toNumber(priceExcludeTaxCtrl.text) - Global.toNumber(productCommissionCtrl.text))}";
      setState(() {});
    } else {
      priceIncludeTaxCtrl.text = "";
    }

    setState(() {});
  }

  void priceChanged() {
    if (priceExcludeTaxCtrl.text.isNotEmpty && Global.toNumber(priceExcludeTaxCtrl.text) != 0) {
      priceIncludeTaxCtrl.text = Global.format(
          Global.toNumber(priceExcludeTaxCtrl.text) -
              Global.toNumber(productCommissionCtrl.text));
      setState(() {});
    } else {
      productCommissionCtrl.text = "";
      priceIncludeTaxCtrl.text = "";
    }
    setState(() {});
  }

  void priceTotalChanged() {
    if (priceIncludeTaxCtrl.text.isNotEmpty &&
        priceExcludeTaxCtrl.text.isNotEmpty && Global.toNumber(priceIncludeTaxCtrl.text) != 0) {
      productCommissionCtrl.text = Global.format(
          (Global.toNumber(priceExcludeTaxCtrl.text) -
              Global.toNumber(priceIncludeTaxCtrl.text)) <=
              0
              ? 0
              : Global.toNumber(priceExcludeTaxCtrl.text) -
              Global.toNumber(priceIncludeTaxCtrl.text));
      setState(() {});
    } else {
      productCommissionCtrl.text = "";
    }
    setState(() {});
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = Global.format4(
          (Global.toNumber(productWeightBahtCtrl.text) *
              getUnitWeightValue(selectedProduct?.id)));
      // marketPriceTotalCtrl.text = Global.format(
      //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text), Global.goldDataModel));
      priceExcludeTaxCtrl.text = Global.format(Global.getBuyThengPrice(
          Global.toNumber(productWeightCtrl.text), selectedProduct!.id!));
      comChanged();
    } else {
      productWeightCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      priceExcludeTaxCtrl.text = "";
      productCommissionCtrl.text = "";
    }
    setState(() {});
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
