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
import 'package:motivegold/screen/gold/gold_mini_widget.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/ui/text_header.dart';
import 'package:sizer/sizer.dart';

class AddSellItemDialog extends StatefulWidget {
  const AddSellItemDialog({super.key, required this.index});

  final int index;

  @override
  State<AddSellItemDialog> createState() => _AddSellItemDialogState();
}

class _AddSellItemDialogState extends State<AddSellItemDialog> {
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

  TextEditingController currentCtrl = TextEditingController();

  String? txt;
  bool showCal = false;

  FocusNode bahtFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode priceFocus = FocusNode();
  FocusNode comFocus = FocusNode();
  FocusNode priceTotalFocus = FocusNode();

  bool bahtReadOnly = false;
  bool gramReadOnly = false;
  bool priceReadOnly = false;
  bool comReadOnly = false;
  bool priceTotalReadOnly = false;

  @override
  void initState() {
    // implement initState
    super.initState();
    Global.appBarColor = snBgColor;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
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
        warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
            WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
        await loadQtyByLocation(selectedWarehouse!.id!);
        setState(() {});
      } else {
        warehouseList = [];
      }

      if (selectedProduct != null) {
        sumSellTotal(selectedProduct!.id!);
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

      if (Global.company?.stock == 1) {
        if (Global.toNumber(productWeightRemainCtrl.text) <= 0) {
          Alert.warning(context, 'Warning'.tr(),
              '${productNameCtrl.text} สินค้าไม่มีสต๊อก', 'OK',
              action: () {});
        }
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
    if (txt == 'price_total') {
      priceTotalReadOnly = true;
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
          if (txt == 'gram') {
            productWeightGramCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            gramChanged();
          }
          if (txt == 'baht') {
            productWeightBahtCtrl.text =
                value != null ? "${Global.format(value)}" : "";
            bahtChanged();
          }
          if (txt == 'price') {
            productPriceCtrl.text =
                value != null ? "${Global.formatInt(value)}" : "";
            priceChanged();
          }

          if (txt == 'price_total') {
            productPriceTotalCtrl.text =
                value != null ? "${Global.formatInt(value)}" : "";
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
    priceTotalReadOnly = false;
    AppCalculatorManager.hideCalculator();
    setState(() {
      showCal = false;
    });
  }

  void gramChanged() {
    if (productWeightGramCtrl.text != "") {
      productWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productWeightGramCtrl.text) / getUnitWeightValue(selectedProduct?.id)));
      marketPriceTotalCtrl.text = Global.format(Global.getBuyPrice(
          Global.toNumber(productWeightGramCtrl.text), Global.goldDataModel, selectedProduct!.id!));
      productPriceCtrl.text = Global.format(
          Global.getSellPrice(Global.toNumber(productWeightGramCtrl.text), selectedProduct!.id!));
    } else {
      productWeightGramCtrl.text = "";
      productWeightBahtCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      productPriceCtrl.text = "";
      productCommissionCtrl.text = "";
    }
    setState(() {});
  }

  void comChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text =
          "${Global.format(Global.toNumber(productPriceCtrl.text) + Global.toNumber(productCommissionCtrl.text))}";
      setState(() {});
    } else {
      productPriceTotalCtrl.text = "";
    }

    setState(() {});
  }

  void priceChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text = Global.format(
          Global.toNumber(productPriceCtrl.text) +
              Global.toNumber(productCommissionCtrl.text));
      setState(() {});
    } else {
      productCommissionCtrl.text = "";
      productPriceTotalCtrl.text = "";
    }
    setState(() {});
  }

  void priceTotalChanged() {
    if (productPriceTotalCtrl.text.isNotEmpty &&
        productPriceCtrl.text.isNotEmpty) {
      productCommissionCtrl.text = Global.format(
          Global.toNumber(productPriceTotalCtrl.text) -
              Global.toNumber(productPriceCtrl.text));
      setState(() {});
    } else {
      productCommissionCtrl.text = "";
    }
    setState(() {});
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightGramCtrl.text = Global.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue(selectedProduct?.id)));
      marketPriceTotalCtrl.text = Global.format(Global.getBuyPrice(
          Global.toNumber(productWeightGramCtrl.text), Global.goldDataModel, selectedProduct!.id!));
      productPriceCtrl.text = Global.format(
          Global.getSellPrice(Global.toNumber(productWeightGramCtrl.text), selectedProduct!.id!));
    } else {
      productWeightGramCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      productPriceCtrl.text = "";
      productCommissionCtrl.text = "";
    }
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
        hasChild: false,
        child: TitleContent(
          backButton: true,
        ),
      ),
      body: loading
          ? const Center(
              child: LoadingProgress(),
            )
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(FocusNode());
                closeCal();
              },
              child: SingleChildScrollView(
                child: Container(
                  color: Colors.transparent,
                  // height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      // Container(
                      //   width: double.infinity,
                      //   height: (MediaQuery.of(context).orientation == Orientation.landscape) ? 80 : 70,
                      //   decoration: const BoxDecoration(color: snBgColor),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(8.0),
                      //     child: Text(
                      //       'ขายทองรูปพรรณใหม่ 96.5%',
                      //       textAlign: TextAlign.center,
                      //       style: TextStyle(
                      //           fontSize: (MediaQuery.of(context).orientation == Orientation.landscape) ? 16.sp : 16.sp,
                      //           color: Colors.white),
                      //     ),
                      //   ),
                      // ),
                      posHeaderText(
                          context, snBgColor, 'ขายทองรูปพรรณใหม่ 96.5%'),
                      if (selectedProduct != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: GoldMiniWidget(
                          product: selectedProduct!,
                          screen: 1,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 10, right: 10),
                      //   child: GoldPriceMiniScreen(
                      //     goldDataModel: widget.j == null
                      //         ? Global.sellOrderDetail![widget.index]
                      //             .goldDataModel
                      //         : Global.ordersPapun![widget.index]
                      //             .details![widget.j!].goldDataModel,
                      //   ),
                      // ),
                      SizedBox(
                        height: 90,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        '',
                                        style: TextStyle(
                                            fontSize: 16.sp, color: textColor),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '',
                                        style: TextStyle(
                                            color: textColor, fontSize: 16.sp),
                                      ),
                                      const SizedBox(
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
                                          fontSize: 16.sp,
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
                                        fontSize: 16.sp,
                                        projectValueNotifier: productNotifier!,
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
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '(บาททอง)',
                                      style: TextStyle(
                                          color: textColor, fontSize: 16.sp),
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
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '(กรัม)',
                                      style: TextStyle(
                                          color: textColor, fontSize: 16.sp),
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
                                      'ราคาทองคำแท่งขายออก',
                                      style: TextStyle(
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '(บาท)',
                                      style: TextStyle(
                                          color: textColor, fontSize: 16.sp),
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
                                  controller: productPriceCtrl,
                                  focusNode: priceFocus,
                                  readOnly: priceReadOnly,
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
                                            fontSize: 16.sp, color: textColor),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '(บาท)',
                                        style: TextStyle(
                                            color: textColor, fontSize: 16.sp),
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
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      '(บาท)',
                                      style: TextStyle(
                                          color: textColor, fontSize: 16.sp),
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
                                  focusNode: priceTotalFocus,
                                  readOnly: priceTotalReadOnly,
                                  clear: () {
                                    setState(() {
                                      productPriceTotalCtrl.text = "";
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
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
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
                    minWidth: double.infinity,
                  ),
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
                                fontSize: (MediaQuery.of(context).orientation ==
                                        Orientation.portrait)
                                    ? 16.sp
                                    : 16.sp),
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
                    minWidth: double.infinity,
                  ),
                  child: MaterialButton(
                    color: snBgColor,
                    onPressed: _handleAddItemPressed,
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: (MediaQuery.of(context).orientation ==
                                        Orientation.portrait)
                                    ? 16.sp
                                    : 16.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  // Extract the save logic into a separate method
  Future<void> _handleAddItemPressed() async {
    // Validate all requirements
    if (!_validateItemRequirements()) {
      return;
    }

    // Validate pricing
    if (!_validateItemPricing()) {
      return;
    }

    // Add the item to order
    _addItemToOrder();

    // Update UI and close dialog
    _finalizeItemAddition();
  }

  bool _validateItemRequirements() {
    // Check stock availability if stock management is enabled
    if (_isStockManagementEnabled() && !_hasAvailableStock()) {
      _showStockUnavailableAlert();
      return false;
    }

    // Validate product selection
    if (!_isProductSelected()) {
      _showProductSelectionAlert();
      return false;
    }

    // Validate warehouse selection for stock management
    if (_isStockManagementEnabled() && !_isWarehouseSelected()) {
      _showWarehouseSelectionAlert();
      return false;
    }

    // Validate weight input
    if (!_isWeightProvided()) {
      _showWeightRequiredAlert();
      return false;
    }

    // Validate price input
    if (!_isPriceProvided()) {
      _showPriceRequiredAlert();
      return false;
    }

    // Check stock quantity vs selling quantity
    if (_isStockManagementEnabled() && !_isSellQuantityValid()) {
      _showExceedsStockAlert();
      return false;
    }

    return true;
  }

  bool _validateItemPricing() {
    final realPrice = Global.getBuyPrice(
        Global.toNumber(productWeightGramCtrl.text), Global.goldDataModel, selectedProduct!.id!);
    final enteredPrice = Global.toNumber(productPriceCtrl.text);
    final priceDifference = enteredPrice - realPrice;

    if (enteredPrice < realPrice) {
      Alert.warning(
        context,
        'คำเตือน',
        'ราคาที่ป้อนน้อยกว่าราคาตลาด ${Global.format(priceDifference)}',
        'OK',
        action: () {},
      );
      return false;
    }

    return true;
  }

  void _addItemToOrder() {
    final weight = Global.toNumber(productWeightGramCtrl.text);
    final priceTotal = Global.toNumber(productPriceTotalCtrl.text);
    final purchasePrice = Global.getBuyPrice(weight, Global.goldDataModel, selectedProduct!.id!);
    final priceDiff = priceTotal - purchasePrice;
    final taxBase = _calculateTaxBase();

    if (Global.ordersPapun!.isNotEmpty) {
      Global.ordersPapun![widget.index].details!.add(
        OrderDetailModel.fromJson(
          jsonDecode(
            jsonEncode(
              OrderDetailModel(
                productName: productNameCtrl.text,
                productId: selectedProduct!.id,
                binLocationId: selectedWarehouse!.id,
                weight: weight,
                weightBath: Global.toNumber(productWeightBahtCtrl.text),
                commission: _getCommission(),
                purchasePrice: purchasePrice,
                priceDiff: priceDiff,
                taxAmount: Global.taxAmount(taxBase),
                taxBase: taxBase,
                priceExcludeTax:
                    _calculatePriceExcludeTax(priceTotal, priceDiff),
                priceIncludeTax: priceTotal,
                sellPrice: Global.toNumber(Global.goldDataModel?.paphun?.sell),
                buyPrice: Global.toNumber(Global.goldDataModel?.paphun?.buy),
                sellTPrice: Global.toNumber(Global.goldDataModel?.theng?.sell),
                buyTPrice: Global.toNumber(Global.goldDataModel?.theng?.buy),
                goldDataModel: Global.goldDataModel,
              ),
            ),
          ),
        ),
      );
    } else {
      Global.sellOrderDetail!.add(
        OrderDetailModel(
          productName: productNameCtrl.text,
          productId: selectedProduct!.id,
          binLocationId: selectedWarehouse!.id,
          weight: weight,
          weightBath: Global.toNumber(productWeightBahtCtrl.text),
          commission: _getCommission(),
          purchasePrice: purchasePrice,
          priceDiff: priceDiff,
          taxAmount: Global.taxAmount(taxBase),
          taxBase: taxBase,
          priceExcludeTax: _calculatePriceExcludeTax(priceTotal, priceDiff),
          priceIncludeTax: priceTotal,
          sellPrice: Global.toNumber(Global.goldDataModel?.paphun?.sell),
          buyPrice: Global.toNumber(Global.goldDataModel?.paphun?.buy),
          sellTPrice: Global.toNumber(Global.goldDataModel?.theng?.sell),
          buyTPrice: Global.toNumber(Global.goldDataModel?.theng?.buy),
          goldDataModel: Global.goldDataModel,
        ),
      );
    }
  }

  void _finalizeItemAddition() {
    sumSellTotal(selectedProduct!.id!);
    setState(() {});
    Navigator.of(context).pop();
  }

// Helper methods for validation
  bool _isStockManagementEnabled() => Global.company?.stock == 1;

  bool _hasAvailableStock() =>
      Global.toNumber(productWeightRemainCtrl.text) > 0;

  bool _isProductSelected() => selectedProduct != null;

  bool _isWarehouseSelected() => selectedWarehouse != null;

  bool _isWeightProvided() => productWeightBahtCtrl.text.isNotEmpty;

  bool _isPriceProvided() => productPriceTotalCtrl.text.isNotEmpty;

  bool _isSellQuantityValid() {
    return Global.toNumber(productWeightGramCtrl.text) <=
        Global.toNumber(productWeightRemainCtrl.text);
  }

// Helper methods for calculations
  double _getCommission() {
    return productCommissionCtrl.text.isEmpty
        ? 0
        : Global.toNumber(productCommissionCtrl.text);
  }

  double _calculateTaxBase() {
    if (productWeightGramCtrl.text.isEmpty) return 0;

    return Global.taxBase(
      Global.toNumber(productPriceTotalCtrl.text),
      Global.toNumber(productWeightGramCtrl.text), selectedProduct!.id!,
    );
  }

  double _calculatePriceExcludeTax(double priceTotal, double priceDiff) {
    return priceTotal - (((priceDiff * 100 / 107) * getVatValue()));
  }

// Alert methods
  void _showStockUnavailableAlert() {
    Alert.warning(
      context,
      'Warning'.tr(),
      '${productNameCtrl.text} สินค้าไม่มีสต๊อก',
      'OK',
      action: () {},
    );
  }

  void _showProductSelectionAlert() {
    Alert.warning(
      context,
      'คำเตือน',
      getDefaultProductMessage(),
      'OK',
      action: () {},
    );
  }

  void _showWarehouseSelectionAlert() {
    Alert.warning(
      context,
      'คำเตือน',
      getDefaultWarehouseMessage(),
      'OK',
      action: () {},
    );
  }

  void _showWeightRequiredAlert() {
    Alert.warning(
      context,
      'คำเตือน',
      'กรุณาใส่น้ำหนัก',
      'OK',
      action: () {},
    );
  }

  void _showPriceRequiredAlert() {
    Alert.warning(
      context,
      'คำเตือน',
      'กรุณากรอกราคา',
      'OK',
      action: () {},
    );
  }

  void _showExceedsStockAlert() {
    Alert.warning(
      context,
      'Warning'.tr(),
      'ไม่สามารถขายได้มากกว่าสต๊อกที่มีอยู่ \nที่มีอยู่: ${productWeightRemainCtrl.text}\nขาย: ${productWeightGramCtrl.text}',
      'OK',
      action: () {},
    );
  }
}
