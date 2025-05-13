import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/screen/gold/gold_price_mini_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';

class SellDialog extends StatefulWidget {
  const SellDialog({super.key});

  @override
  State<SellDialog> createState() => _SellDialogState();
}

class _SellDialogState extends State<SellDialog> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<ProductModel> packageList = [];
  List<WarehouseModel> warehouseList = [];
  List<QtyLocationModel> qtyLocationList = [];
  ProductModel? selectedProduct;
  ProductModel? selectedPackage;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;
  ValueNotifier<dynamic>? packageNotifier;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productWeightRemainCtrl = TextEditingController();
  TextEditingController productWeightBahtRemainCtrl = TextEditingController();
  TextEditingController productCommissionCtrl = TextEditingController();

  // TextEditingController productPriceCtrl = TextEditingController();
  // TextEditingController productPriceTotalCtrl = TextEditingController();
  TextEditingController reserveDateCtrl = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  TextEditingController priceExcludeTaxCtrl = TextEditingController();
  TextEditingController priceIncludeTaxCtrl = TextEditingController();
  TextEditingController priceDiffCtrl = TextEditingController();
  TextEditingController taxBaseCtrl = TextEditingController();
  TextEditingController taxAmountCtrl = TextEditingController();
  TextEditingController purchasePriceCtrl = TextEditingController();

  TextEditingController packageQtyCtrl = TextEditingController();
  TextEditingController packagePriceCtrl = TextEditingController();

  final controller = BoardDateTimeController();

  DateTime date = DateTime.now();

  String? txt;
  bool showCal = false;

  FocusNode bahtFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode comFocus = FocusNode();
  FocusNode packagePriceFocus = FocusNode();
  FocusNode packageQtyFocus = FocusNode();
  FocusNode taxAmountFocus = FocusNode();

  bool bahtReadOnly = false;
  bool gramReadOnly = false;
  bool priceReadOnly = false;
  bool comReadOnly = false;
  bool packagePriceReadOnly = false;
  bool packageQtyReadOnly = false;
  bool taxAmountReadOnly = false;
  String? vatOption;

  @override
  void initState() {
    // implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    packageNotifier = ValueNotifier<ProductModel>(
        ProductModel(id: 0, name: 'เลือกบรรจุภัณฑ์'));
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
    // productPriceCtrl.dispose();
    // productPriceTotalCtrl.dispose();
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
          '/product/type/BAR/4', Global.requestObj(null));
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

      var pg =
          await ApiServices.post('/product/type/PKG', Global.requestObj(null));
      if (pg?.status == "success") {
        var data = jsonEncode(pg?.data);
        // motivePrint(data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          packageList = products;
        });
      } else {
        packageList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/type/BAR/4', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
          // selectedWarehouse = warehouseList.first;
          selectedWarehouse =
              warehouseList.where((e) => e.isDefault == 1).first;
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
      productWeightBahtRemainCtrl.text = formatter.format(
          Global.getTotalWeightByLocation(qtyLocationList) /
              getUnitWeightValue());
      if (Global.toNumber(productWeightRemainCtrl.text) <= 0) {
        Alert.warning(context, 'Warning'.tr(),
            '${productNameCtrl.text} สินค้าไม่มีสต๊อก', 'OK',
            action: () {});
      }
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
                  Container(
                    width: double.infinity,
                    height: 70,
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text(
                            'Include',
                            style: TextStyle(fontSize: 30),
                          ),
                          value: 'Include',
                          groupValue: vatOption,
                          visualDensity: VisualDensity.standard,
                          activeColor: Colors.teal,
                          onChanged: (String? value) {
                            setState(() {
                              vatOption = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text(
                            'Exclude',
                            style: TextStyle(fontSize: 30),
                          ),
                          value: 'Exclude',
                          groupValue: vatOption,
                          visualDensity: VisualDensity.standard,
                          activeColor: Colors.teal,
                          onChanged: (String? value) {
                            setState(() {
                              vatOption = value;
                            });
                          },
                        ),
                      ),
                    ],
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
                                      fontSize: size.getWidthPx(15),
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '(กรัม)',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: size.getWidthPx(10)),
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
                                      fontSize: size.getWidthPx(15),
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '(บาททอง)',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: size.getWidthPx(10)),
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
                              // bahtChanged();
                            },
                            onFocusChange: (value) {
                              if (!value) {
                                bahtChanged();
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
                                  'ราคาขายทอง\nคำแท่ง',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: size.getWidthPx(15),
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: size.getWidthPx(10)),
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
                            enabled: true,
                            controller: priceExcludeTaxCtrl,
                            readOnly: priceReadOnly,
                            focusNode: priceFocus,
                            inputFormat: [
                              ThousandsFormatter(allowFraction: true)
                            ],
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
                            onChanged: (String value) {
                              // priceChanged();
                            },
                            onFocusChange: (value) {
                              if (!value) {
                                priceChanged();
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
                                  'ค่าบล็อกทอง',
                                  style: TextStyle(
                                      fontSize: size.getWidthPx(15),
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: size.getWidthPx(10)),
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
                            onChanged: (String value) {
                              // comChanged();
                            },
                            onFocusChange: (value) {
                              if (!value) {
                                comChanged();
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
                                  'ค่าแพ็คเกจ',
                                  style: TextStyle(
                                      fontSize: size.getWidthPx(15),
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                              ],
                            )),
                        Expanded(
                            flex: 6,
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 60,
                                  child: MiraiDropDownMenu<ProductModel>(
                                    key: UniqueKey(),
                                    children: packageList,
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
                                        fontSize: size.getWidthPx(10),
                                      );
                                    },
                                    onChanged: (ProductModel value) {
                                      selectedPackage = value;
                                      packageNotifier!.value = value;
                                      setState(() {});
                                    },
                                    child: DropDownObjectChildWidget(
                                      key: GlobalKey(),
                                      fontSize: size.getWidthPx(10),
                                      projectValueNotifier: packageNotifier!,
                                    ),
                                  ),
                                ),
                                if (selectedPackage != null)
                                  Positioned(
                                    right: 5,
                                    top: 15,
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(100.0)),
                                        // padding: const EdgeInsets.only(
                                        //     left: 5.0, right: 5.0),
                                        child: Row(
                                          children: [
                                            ClipOval(
                                              child: SizedBox(
                                                width: 30.0,
                                                height: 30.0,
                                                child: RawMaterialButton(
                                                  elevation: 10.0,
                                                  child: const Icon(
                                                    Icons.clear,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      // Global.branchList = [];
                                                      selectedPackage = null;
                                                      packageNotifier =
                                                          ValueNotifier<
                                                                  ProductModel>(
                                                              selectedPackage ??
                                                                  ProductModel(
                                                                      id: 0,
                                                                      name:
                                                                          'เลือกบรรจุภัณฑ์'));
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )),
                      ],
                    ),
                  ),
                  if (selectedPackage != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: numberTextField(
                                labelText: "จำนวน",
                                inputType: TextInputType.number,
                                controller: packageQtyCtrl,
                                focusNode: packageQtyFocus,
                                readOnly: packageQtyReadOnly,
                                fontSize: size.getWidthPx(15),
                                inputFormat: [
                                  ThousandsFormatter(allowFraction: true)
                                ],
                                clear: () {
                                  setState(() {
                                    packageQtyCtrl.text = "";
                                  });
                                },
                                onTap: () {
                                  txt = 'package_qty';
                                  closeCal();
                                },
                                openCalc: () {
                                  if (!showCal) {
                                    txt = 'package_qty';
                                    packageQtyFocus.requestFocus();
                                    openCal();
                                  }
                                },
                                onChanged: (String value) {}),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 6,
                            child: numberTextField(
                                labelText: "ราคารวม",
                                inputType: TextInputType.phone,
                                controller: packagePriceCtrl,
                                focusNode: packagePriceFocus,
                                readOnly: packagePriceReadOnly,
                                fontSize: size.getWidthPx(15),
                                inputFormat: [
                                  ThousandsFormatter(allowFraction: true)
                                ],
                                clear: () {
                                  setState(() {
                                    packagePriceCtrl.text = "";
                                  });
                                  getOtherAmount();
                                },
                                onTap: () {
                                  txt = 'package_price';
                                  closeCal();
                                },
                                openCalc: () {
                                  if (!showCal) {
                                    txt = 'package_price';
                                    packagePriceFocus.requestFocus();
                                    openCal();
                                  }
                                },
                                onFocusChange: (bool value) {
                                  if (!value) {
                                    getOtherAmount();
                                  }
                                }),
                          ),
                        ],
                      ),
                    ),
                  if (vatOption == 'Exclude')
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
                                    'ภาษีมูลค่าเพิ่ม 7%',
                                    style: TextStyle(
                                        fontSize: size.getWidthPx(15),
                                        color: textColor),
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
                                controller: taxAmountCtrl,
                                focusNode: taxAmountFocus,
                                readOnly: taxAmountReadOnly,
                                fontSize: size.getWidthPx(12),
                                inputFormat: [
                                  ThousandsFormatter(allowFraction: true)
                                ],
                                clear: () {
                                  setState(() {
                                    taxAmountCtrl.text = "";
                                  });
                                  getOtherAmount();
                                },
                                onTap: () {
                                  txt = 'tax_amount';
                                  closeCal();
                                },
                                openCalc: () {
                                  if (!showCal) {
                                    txt = 'tax_amount';
                                    taxAmountFocus.requestFocus();
                                    openCal();
                                  }
                                },
                                onChanged: (String value) {},
                                onFocusChange: (value) {
                                  if (!value) {
                                    getOtherAmount();
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
                                  'รวมราคาขาย',
                                  style: TextStyle(
                                      fontSize: size.getWidthPx(15),
                                      color: textColor),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '',
                                  style: TextStyle(
                                      color: textColor,
                                      fontSize: size.getWidthPx(10)),
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
                              labelColor: Colors.grey,
                              controller: priceIncludeTaxCtrl,
                              align: TextAlign.right,
                              inputFormat: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                              enabled: false),
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
                              if (txt == 'gram') {
                                productWeightCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                gramChanged();
                              }
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
                                priceExcludeTaxCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                priceChanged();
                              }
                              if (txt == 'package_qty') {
                                packageQtyCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                getOtherAmount();
                              }
                              if (txt == 'package_price') {
                                packagePriceCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                getOtherAmount();
                              }
                              if (txt == 'tax_amount') {
                                taxAmountCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                getOtherAmount();
                              }
                              FocusScope.of(context).requestFocus(FocusNode());
                              closeCal();
                            }
                            if (kDebugMode) {
                              // print('$key\t$value\t$expression');
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
                                fontSize: size.getWidthPx(15)),
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
                              fontSize: size.getWidthPx(15)),
                        ),
                      ],
                    ),
                    onPressed: () async {

                      if (Global.toNumber(productWeightRemainCtrl.text) <= 0) {
                        Alert.warning(context, 'Warning'.tr(),
                            '${productNameCtrl.text} สินค้าไม่มีสต๊อก', 'OK',
                            action: () {});
                        return;
                      }

                      if (vatOption == null || vatOption == "") {
                        Alert.warning(context, 'คำเตือน',
                            'กรุณาเลือกตัวเลือกภาษีมูลค่าเพิ่ม', 'OK',
                            action: () {});
                        return;
                      }

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

                      if (Global.toNumber(productWeightCtrl.text) > Global.toNumber(productWeightRemainCtrl.text)) {
                        Alert.warning(context, 'Warning'.tr(),
                            'ไม่สามารถขายได้มากกว่าสต๊อกที่มีอยู่ \nที่มีอยู่: ${productWeightRemainCtrl.text}\nขาย: ${productWeightCtrl.text}', 'OK',
                            action: () {});
                        return;
                      }

                      var realPrice = Global.getBuyThengPrice(
                          Global.toNumber(productWeightCtrl.text));
                      var price = Global.toNumber(priceExcludeTaxCtrl.text);
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
                            'OK',
                            action: () {});

                        return;
                      }
                      Alert.info(
                          context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                          action: () async {
                        Global.sellThengOrderDetail!.add(
                          OrderDetailModel(
                              productName: productNameCtrl.text,
                              productId: selectedProduct!.id,
                              binLocationId: selectedWarehouse!.id,
                              sellTPrice: Global.toNumber(Global.goldDataModel?.theng!.sell),
                              buyTPrice: Global.toNumber(Global.goldDataModel?.theng!.buy),
                              sellPrice: Global.toNumber(Global.goldDataModel?.paphun!.sell),
                              buyPrice: Global.toNumber(Global.goldDataModel?.paphun!.buy),
                              weight: Global.toNumber(productWeightCtrl.text),
                              weightBath:
                                  Global.toNumber(productWeightBahtCtrl.text),
                              commission:
                                  Global.toNumber(productCommissionCtrl.text),
                              taxBase: 0,
                              taxAmount: Global.toNumber(taxAmountCtrl.text),
                              priceIncludeTax:
                                  Global.toNumber(priceIncludeTaxCtrl.text),
                              priceExcludeTax:
                                  Global.toNumber(priceExcludeTaxCtrl.text),
                              packageId: selectedPackage?.id,
                              packageQty: Global.toInt(packageQtyCtrl.text),
                              packagePrice:
                                  Global.toNumber(packagePriceCtrl.text),
                              vatOption: vatOption,
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
    );
  }

  void getOtherAmount() {
    priceExcludeTaxCtrl.text = Global.format(
        Global.toNumber(productWeightBahtCtrl.text) *
            Global.toNumber(Global.goldDataModel?.theng?.sell));
    double com = Global.toNumber(productCommissionCtrl.text);
    double pkg = Global.toNumber(packagePriceCtrl.text);
    double exclude = Global.toNumber(priceExcludeTaxCtrl.text);
    taxAmountCtrl.text = vatOption == 'Exclude'
        ? Global.format((com + pkg) * getVatValue())
        : '0';

    priceIncludeTaxCtrl.text = Global.format(
        Global.toNumber(priceExcludeTaxCtrl.text) +
            com +
            pkg +
            Global.toNumber(taxAmountCtrl.text));
  }

  void comChanged() {
    if (productCommissionCtrl.text.isNotEmpty) {
      getOtherAmount();
      setState(() {});
    }
  }

  void priceChanged() {
    if (priceExcludeTaxCtrl.text.isNotEmpty) {
      getOtherAmount();
      setState(() {});
    }
  }

  void gramChanged() {
    // motivePrint(productWeightCtrl.text);
    if (productWeightCtrl.text.isNotEmpty) {
      productWeightBahtCtrl.text = Global.format(
          Global.toNumber(productWeightCtrl.text) / getUnitWeightValue());
      motivePrint(Global.toNumber(productWeightCtrl.text));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyThengPrice(Global.toNumber(productWeightCtrl.text)));
      getOtherAmount();
    } else {
      productWeightBahtCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      priceExcludeTaxCtrl.text = "";
      priceIncludeTaxCtrl.text = "";
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = Global.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyThengPrice(Global.toNumber(productWeightCtrl.text)));
      getOtherAmount();
    } else {
      productWeightCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      priceExcludeTaxCtrl.text = "";
      priceIncludeTaxCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    priceExcludeTaxCtrl.text = "";
    priceIncludeTaxCtrl.text = "";
    packageQtyCtrl.text = "";
    packagePriceCtrl.text = "";
    taxAmountCtrl.text = "";
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
    packageNotifier = ValueNotifier<ProductModel>(
        selectedPackage ?? ProductModel(id: 0, name: 'เลือกบรรจุภัณฑ์'));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }
}
