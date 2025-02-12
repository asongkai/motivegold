import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class RefillDialog extends StatefulWidget {
  const RefillDialog({super.key});

  @override
  State<RefillDialog> createState() => _RefillDialogState();
}

class _RefillDialogState extends State<RefillDialog> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  ProductTypeModel? selectedProductType;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? productTypeNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productSellPriceCtrl = TextEditingController();
  TextEditingController productBuyPriceCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  TextEditingController referenceNumberCtrl = TextEditingController();

  TextEditingController productSellThengPriceCtrl = TextEditingController();
  TextEditingController productBuyThengPriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxCtrl = TextEditingController();
  TextEditingController priceIncludeTaxCtrl = TextEditingController();
  TextEditingController priceDiffCtrl = TextEditingController();
  TextEditingController taxBaseCtrl = TextEditingController();
  TextEditingController taxAmountCtrl = TextEditingController();
  TextEditingController purchasePriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceIncludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceDiffTotalCtrl = TextEditingController();
  TextEditingController taxBaseTotalCtrl = TextEditingController();
  TextEditingController taxAmountTotalCtrl = TextEditingController();
  TextEditingController purchasePriceTotalCtrl = TextEditingController();

  TextEditingController orderDateCtrl = TextEditingController();
  final boardCtrl = BoardDateTimeController();

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
    Global.appBarColor = rfBgColor;
    productTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภท'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    loadProducts();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/product/type/NEW/5', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        // motivePrint(data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.where((e) => e.isDefault == 1).first;
            productNotifier = ValueNotifier<ProductModel>(
                selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
            productCodeCtrl.text =
                (selectedProduct != null ? selectedProduct!.productCode : '')!;
            productNameCtrl.text =
                selectedProduct != null ? selectedProduct!.name : '';
          }
        });
      } else {
        productList = [];
      }

      var warehouse =
          await ApiServices.post('/binlocation/all/type/NEW/5', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
          selectedWarehouse = warehouseList.where((e) => e.isDefault == 1).first;
          warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
              WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        });
      } else {
        warehouseList = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    productCodeCtrl.dispose();
    productNameCtrl.dispose();
    productWeightCtrl.dispose();
    productWeightBahtCtrl.dispose();
    productSellPriceCtrl.dispose();
    productBuyPriceCtrl.dispose();
    warehouseCtrl.dispose();

    referenceNumberCtrl.dispose();

    productSellThengPriceCtrl.dispose();
    productBuyThengPriceCtrl.dispose();

    priceExcludeTaxCtrl.dispose();
    priceIncludeTaxCtrl.dispose();
    priceDiffCtrl.dispose();
    taxBaseCtrl.dispose();
    taxAmountCtrl.dispose();
    purchasePriceCtrl.dispose();

    priceExcludeTaxTotalCtrl.dispose();
    priceIncludeTaxTotalCtrl.dispose();
    priceDiffTotalCtrl.dispose();
    taxBaseTotalCtrl.dispose();
    taxAmountTotalCtrl.dispose();
    purchasePriceTotalCtrl.dispose();

    orderDateCtrl.dispose();
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
    final formKey = GlobalKey();
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      body: loading
          ? const Center(
        child: LoadingProgress(),
      )
          :  Stack(
        children: [
          GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 100,
                    decoration: const BoxDecoration(color: rfBgColor),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'เติมทองรูปพรรณใหม่',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: size.getWidthPx(15), color: Colors.white),
                      ),
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
                                  '',
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
                          child: SizedBox(
                            height: 80,
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
                                  fontSize: size.getWidthPx(10),
                                );
                              },
                              onChanged: (ProductModel value) {
                                productCodeCtrl.text =
                                    value.productCode!.toString();
                                productNameCtrl.text = value.name;
                                selectedProduct = value;
                                productNotifier!.value = value;
                              },
                              child: DropDownObjectChildWidget(
                                key: GlobalKey(),
                                fontSize: size.getWidthPx(10),
                                projectValueNotifier: productNotifier!,
                              ),
                            ),
                          ),
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
                                  'น้ำหนัก',
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
                              inputType: TextInputType.number,
                              controller: productWeightBahtCtrl,
                              focusNode: bahtFocus,
                              readOnly: bahtReadOnly,
                              inputFormat: [
                                ThousandsFormatter(
                                    formatter: formatter, allowFraction: true)
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
                        const Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'น้ำหนัก',
                                  style:
                                      TextStyle(fontSize: 50, color: textColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '(กรัม)',
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
                              inputType: TextInputType.number,
                              controller: productWeightCtrl,
                              focusNode: gramFocus,
                              readOnly: gramReadOnly,
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
                                gramChanged();
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
                                  'ราคาสินค้า',
                                  style:
                                      TextStyle(fontSize: 50, color: textColor),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '(บาท)',
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
                            inputType: TextInputType.number,
                            focusNode: priceFocus,
                            readOnly: priceReadOnly,
                            clear: () {
                              setState(() {
                                priceIncludeTaxCtrl.text = "";
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
                            inputFormat: [
                              ThousandsFormatter(allowFraction: true)
                            ],
                            controller: priceIncludeTaxCtrl,
                          ),
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
                                  'คลังสินค้า',
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
                          child: SizedBox(
                            height: 90,
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
                                  fontSize: size.getWidthPx(10),
                                );
                              },
                              onChanged: (WarehouseModel value) {
                                warehouseCtrl.text = value.id!.toString();
                                selectedWarehouse = value;
                                warehouseNotifier!.value = value;
                              },
                              child: DropDownObjectChildWidget(
                                key: GlobalKey(),
                                fontSize: size.getWidthPx(10),
                                projectValueNotifier: warehouseNotifier!,
                              ),
                            ),
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
                              if (txt == 'gram') {
                                productWeightCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                gramChanged();
                              }
                              if (txt == 'baht') {
                                productWeightBahtCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                bahtChanged();
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
                            style: TextStyle(color: Colors.white, fontSize: 30),
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
                    color: rfBgColor,
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
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                    onPressed: () async {
                      if (selectedWarehouse == null) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาเลือกคลังสินค้า', 'OK');
                        return;
                      }

                      if (productWeightCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกน้ำหนัก', 'OK');
                        return;
                      }

                      if (priceIncludeTaxCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกราคา', 'OK');
                        return;
                      }
                      Alert.info(
                          context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                          action: () async {
                        Global.refillOrderDetail!.add(
                          OrderDetailModel(
                              productName: selectedProduct!.name,
                              productId: selectedProduct!.id,
                              binLocationId: selectedWarehouse!.id,
                              binLocationName: selectedWarehouse!.name,
                              sellTPrice: 0,
                              buyTPrice: 0,
                              sellPrice: 0,
                              buyPrice: 0,
                              weight: Global.toNumber(productWeightCtrl.text),
                              weightBath:
                                  Global.toNumber(productWeightBahtCtrl.text),
                              commission: 0,
                              priceIncludeTax:
                                  Global.toNumber(priceIncludeTaxCtrl.text),
                              priceExcludeTax: 0,
                              purchasePrice: 0,
                              priceDiff: 0,
                              taxBase: 0,
                              taxAmount: 0),
                        );
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

  void gramChanged() {
    if (productWeightCtrl.text.isNotEmpty) {
      // productSellPriceCtrl.text = Global.getSellPrice(Global.toNumber(productWeightCtrl.text)).toString();
      // productBuyPriceCtrl.text = Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
      productWeightBahtCtrl.text =
          Global.format((Global.toNumber(productWeightCtrl.text) / getUnitWeightValue()));
    } else {
      productWeightBahtCtrl.text = "";
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text =
          Global.format((Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()));
      // productSellPriceCtrl.text = Global.getSellPrice(Global.toNumber(productWeightCtrl.text)).toString();
      // productBuyPriceCtrl.text = Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
    } else {
      productWeightCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    priceIncludeTaxCtrl.text = "";
    productWeightBahtCtrl.text = "";
    selectedProduct = productList.first;
    productNotifier = ValueNotifier<ProductModel>(
        selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    productCodeCtrl.text =
        (selectedProduct != null ? selectedProduct!.productCode : '')!;
    productNameCtrl.text = selectedProduct != null ? selectedProduct!.name : '';
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.refillOrderDetail!.removeAt(index);
      if (Global.refillOrderDetail!.isEmpty) {
        Global.refillOrderDetail!.clear();
      }
      setState(() {});
    });
  }
}
