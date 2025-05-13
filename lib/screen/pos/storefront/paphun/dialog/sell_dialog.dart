import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_mini_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class SaleDialog extends StatefulWidget {
  const SaleDialog({super.key});

  @override
  State<SaleDialog> createState() => _SaleDialogState();
}

class _SaleDialogState extends State<SaleDialog> {
  late Screen size;
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
  TextEditingController productWeightGramCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productWeightRemainCtrl = TextEditingController();
  TextEditingController productWeightBahtRemainCtrl = TextEditingController();
  TextEditingController productCommissionCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productPriceTotalCtrl = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

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
    Global.appBarColor = snBgColor;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumSellTotal();
    loadProducts();
  }

  @override
  void dispose() {
    super.dispose();
    productCodeCtrl.dispose();
    productNameCtrl.dispose();
    productWeightGramCtrl.dispose();
    productWeightBahtCtrl.dispose();
    productWeightRemainCtrl.dispose();
    productWeightBahtRemainCtrl.dispose();
    productCommissionCtrl.dispose();
    productPriceCtrl.dispose();
    productPriceTotalCtrl.dispose();
    marketPriceTotalCtrl.dispose();
    warehouseCtrl.dispose();

    // currentCtrl.dispose();

    bahtFocus.dispose();
    gramFocus.dispose();
    priceFocus.dispose();
    comFocus.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      // ApiServices api = ApiServices();
      // Global.goldDataModel = await api.getGoldPrice(context);

      var result = await ApiServices.post(
          '/product/type/NEW/1', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
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
          '/binlocation/all/type/NEW/1', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        warehouseList = warehouses;
        selectedWarehouse = warehouseList.where((e) => e.isDefault == 1).first;
        // motivePrint(selectedWarehouse?.toJson());
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
    // final ProgressDialog pr = ProgressDialog(context,
    //     type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    // await pr.show();
    // pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.get(
          '/qtybylocation/by-product-location/$id/${selectedProduct!.id}');
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
      // await pr.hide();

      // motivePrint(productWeightRemainCtrl.text);

      productWeightRemainCtrl.text =
          Global.format(Global.getTotalWeightByLocation(qtyLocationList));

      productWeightBahtRemainCtrl.text = Global.format(
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
      // await pr.hide();
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

  void gramChanged() {
    if (productWeightGramCtrl.text != "") {
      productWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productWeightGramCtrl.text) / getUnitWeightValue()));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyPrice(Global.toNumber(productWeightGramCtrl.text)));
      productPriceCtrl.text = Global.format(
          Global.getSellPrice(Global.toNumber(productWeightGramCtrl.text)));
      // productPriceTotalCtrl.text = productCommissionCtrl.text.isNotEmpty
      //     ? '${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}'
      //     : Global.format(Global.toNumber(productPriceCtrl.text)).toString();
      // productCommissionCtrl.text = Global.format(
      //     Global.getSellPrice(Global.toNumber(productWeightCtrl.text)) - (Global.getSellPrice(1) * Global.toNumber(productWeightCtrl.text)));
    } else {
      productWeightGramCtrl.text = "";
      productWeightBahtCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      productPriceCtrl.text = "";
      // productPriceTotalCtrl.text = "";
    }
    productCommissionCtrl.text = "";
    productPriceTotalCtrl.text = "";
    setState(() {});
  }

  void comChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text =
          "${Global.format(Global.toNumber(productCommissionCtrl.text) + (Global.getSellPrice(1) * Global.toNumber(productWeightGramCtrl.text)))}";
      setState(() {});
    } else {
      productPriceTotalCtrl.text = "";
    }

    setState(() {});
  }

  void priceChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productPriceTotalCtrl.text.isNotEmpty) {
      productCommissionCtrl.text = Global.format(
          Global.toNumber(productPriceTotalCtrl.text) -
              (Global.getSellPrice(1) *
                  Global.toNumber(productWeightGramCtrl.text)));
      setState(() {});
    } else {
      productCommissionCtrl.text = "";
    }
    setState(() {});
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightGramCtrl.text = Global.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyPrice(Global.toNumber(productWeightGramCtrl.text)));
      productPriceCtrl.text = Global.format(
          Global.getSellPrice(Global.toNumber(productWeightGramCtrl.text)));
      // productPriceTotalCtrl.text = productCommissionCtrl.text.isNotEmpty
      //     ? '${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}'
      //     : Global.format(Global.toNumber(productPriceCtrl.text)).toString();
    } else {
      productWeightGramCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      productPriceCtrl.text = "";
      // productPriceTotalCtrl.text = "";
    }
    productCommissionCtrl.text = "";
    productPriceTotalCtrl.text = "";
    setState(() {});
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightGramCtrl.text = "";
    productWeightBahtCtrl.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
    productCommissionCtrl.text = "";
    productPriceCtrl.text = "";
    productPriceTotalCtrl.text = "";

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

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: const CustomAppBar(
        height: 220,
        child: TitleContent(
          backButton: true,
        ),
      ),
      body: loading
          ? const Center(
              child: LoadingProgress(),
            )
          : Stack(
              clipBehavior: Clip.none,
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
                          decoration: const BoxDecoration(color: snBgColor),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'ขายทองรูปพรรณใหม่ 96.5%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: size.getWidthPx(15),
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: GoldPriceMiniScreen(),
                        ),
                        SizedBox(
                          height: 90,
                          child: Padding(
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
                                          style: TextStyle(
                                              fontSize: 50, color: textColor),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '',
                                          style: TextStyle(
                                              color: textColor, fontSize: 30),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    )),
                                Expanded(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: SizedBox(
                                      height: 80,
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
                                        otherDecoration: const InputDecoration(
                                            labelStyle:
                                                TextStyle(color: textColor)),
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
                                          if (selectedWarehouse != null) {
                                            loadQtyByLocation(
                                                selectedWarehouse!.id!);
                                            setState(() {});
                                          }
                                        },
                                        child: DropDownObjectChildWidget(
                                          key: GlobalKey(),
                                          fontSize: size.getWidthPx(10),
                                          projectValueNotifier:
                                              productNotifier!,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                                        'น้ำหนัก',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(15), color: textColor),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '(บาททอง)',
                                        style: TextStyle(
                                            color: textColor, fontSize: size.getWidthPx(10)),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 6,
                                child: numberTextFieldBig(
                                    labelText: "",
                                    inputType: TextInputType.number,
                                    controller: productWeightBahtCtrl,
                                    focusNode: bahtFocus,
                                    readOnly: bahtReadOnly,
                                    inputFormat: [
                                      ThousandsFormatter(
                                          formatter: formatter,
                                          allowFraction: true)
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
                                    onChanged: (value) {
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
                                        'น้ำหนัก',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(15), color: textColor),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '(กรัม)',
                                        style: TextStyle(
                                            color: textColor, fontSize: size.getWidthPx(10)),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 6,
                                child: numberTextFieldBig(
                                    labelText: "",
                                    inputType: TextInputType.number,
                                    controller: productWeightGramCtrl,
                                    focusNode: gramFocus,
                                    readOnly: gramReadOnly,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    clear: () {
                                      setState(() {
                                        productWeightGramCtrl.text = "";
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
                                    onChanged: (value) {
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
                              Expanded(
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'ราคาขายรวม',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(15), color: textColor),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '(บาท)',
                                        style: TextStyle(
                                            color: textColor, fontSize: size.getWidthPx(10)),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  )),
                              Expanded(
                                flex: 6,
                                child: numberTextFieldBig(
                                    labelText: "",
                                    inputType: TextInputType.number,
                                    controller: productPriceTotalCtrl,
                                    focusNode: priceFocus,
                                    readOnly: priceReadOnly,
                                    clear: () {
                                      setState(() {
                                        productPriceTotalCtrl.text = "";
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
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    onFocusChange: (value) {
                                      if (!value) {
                                        priceChanged();
                                      }
                                    }),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 6,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'ค่ากำเหน็จ',
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(15), color: textColor),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '(บาท)',
                                          style: TextStyle(
                                              color: textColor, fontSize: size.getWidthPx(10)),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    )),
                                Expanded(
                                  flex: 6,
                                  child: numberTextFieldBig(
                                      labelText: "",
                                      inputType: TextInputType.phone,
                                      controller: productCommissionCtrl,
                                      focusNode: comFocus,
                                      readOnly: comReadOnly,
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
                          decoration:
                              const BoxDecoration(color: Color(0xffcccccc)),
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
                                    if (txt == 'gram') {
                                      productWeightGramCtrl.text = value != null
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
                                      productPriceTotalCtrl.text = value != null
                                          ? "${Global.format(value)}"
                                          : "";
                                      priceChanged();
                                    }
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                            style: TextStyle(color: Colors.white, fontSize: size.getWidthPx(15)),
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
                padding: const EdgeInsets.all(18.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity, minHeight: 100),
                  child: MaterialButton(
                    color: snBgColor,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
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
                            style: TextStyle(color: Colors.white, fontSize: size.getWidthPx(15)),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () async {
                      if (Global.toNumber(productWeightRemainCtrl.text) <= 0) {
                        Alert.warning(context, 'Warning'.tr(),
                            '${productNameCtrl.text} สินค้าไม่มีสต๊อก', 'OK',
                            action: () {});
                        return;
                      }

                      if (selectedProduct == null) {
                        Alert.warning(context, 'คำเตือน',
                            getDefaultProductMessage(), 'OK');
                        return;
                      }

                      if (selectedWarehouse == null) {
                        Alert.warning(context, 'คำเตือน',
                            getDefaultWarehouseMessage(), 'OK');
                        return;
                      }

                      if (productWeightBahtCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK');
                        return;
                      }

                      if (productPriceTotalCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกราคา', 'OK');
                        return;
                      }

                      if (Global.toNumber(productWeightGramCtrl.text) > Global.toNumber(productWeightRemainCtrl.text)) {
                        Alert.warning(context, 'Warning'.tr(),
                            'ไม่สามารถขายได้มากกว่าสต๊อกที่มีอยู่ \nที่มีอยู่: ${productWeightRemainCtrl.text}\nขาย: ${productWeightGramCtrl.text}', 'OK',
                            action: () {});
                        return;
                      }

                      // if (Global.toNumber(productWeightCtrl
                      //         .text) >
                      //     Global.toNumber(
                      //         productWeightRemainCtrl.text)) {
                      //   Alert.warning(
                      //       context,
                      //       'คำเตือน',
                      //       'ไม่สามารถขายเกินปริมาณคงเหลือได้',
                      //       'OK');
                      //   return;
                      // }

                      var realPrice = Global.getBuyPrice(
                          Global.toNumber(productWeightGramCtrl.text));
                      var price = Global.toNumber(productPriceCtrl.text);
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
                          context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                          action: () async {
                        Global.sellOrderDetail!.add(
                          OrderDetailModel.fromJson(
                            jsonDecode(
                              jsonEncode(
                                OrderDetailModel(
                                  productName: productNameCtrl.text,
                                  productId: selectedProduct!.id,
                                  binLocationId: selectedWarehouse!.id,
                                  weight: Global.toNumber(
                                      productWeightGramCtrl.text),
                                  weightBath: Global.toNumber(
                                      productWeightBahtCtrl.text),
                                  commission: productCommissionCtrl.text.isEmpty
                                      ? 0
                                      : Global.toNumber(
                                          productCommissionCtrl.text),
                                  taxBase: productWeightGramCtrl.text.isEmpty
                                      ? 0
                                      : Global.taxBase(
                                          Global.toNumber(
                                              productPriceTotalCtrl.text),
                                          Global.toNumber(
                                              productWeightGramCtrl.text)),
                                  priceIncludeTax: Global.toNumber(
                                      productPriceTotalCtrl.text),
                                  sellPrice: Global.toNumber(
                                      Global.goldDataModel?.paphun?.sell),
                                  buyPrice: Global.toNumber(
                                      Global.goldDataModel?.paphun?.buy),
                                  sellTPrice: Global.toNumber(
                                      Global.goldDataModel?.theng?.sell),
                                  buyTPrice: Global.toNumber(
                                      Global.goldDataModel?.theng?.buy),
                                  goldDataModel: Global.goldDataModel,
                                ),
                              ),
                            ),
                          ),
                        );
                        sumSellTotal();
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
}
