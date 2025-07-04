import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';

class SellUsedThengDialog extends StatefulWidget {
  const SellUsedThengDialog({super.key});

  @override
  State<SellUsedThengDialog> createState() => _SellUsedThengDialogState();
}

class _SellUsedThengDialogState extends State<SellUsedThengDialog> {
  bool loading = false;
  Screen? size;
  List<ProductModel> productList = [];
  List<WarehouseModel> fromWarehouseList = [];
  List<WarehouseModel> toWarehouseList = [];
  List<QtyLocationModel> qtyLocationList = [];
  WarehouseModel? selectedFromLocation;
  WarehouseModel? selectedToLocation;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productEntryWeightCtrl = TextEditingController();
  TextEditingController productEntryWeightBahtCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  TextEditingController productSellThengPriceCtrl = TextEditingController();
  TextEditingController productBuyThengPriceCtrl = TextEditingController();
  TextEditingController priceExcludeTaxCtrl = TextEditingController();
  TextEditingController priceIncludeTaxCtrl = TextEditingController();
  TextEditingController priceDiffCtrl = TextEditingController();
  TextEditingController taxBaseCtrl = TextEditingController();
  TextEditingController taxAmountCtrl = TextEditingController();
  TextEditingController purchasePriceCtrl = TextEditingController();

  TextEditingController toWarehouseCtrl = TextEditingController();
  TextEditingController productSellPriceCtrl = TextEditingController();
  TextEditingController productBuyPriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceIncludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceDiffTotalCtrl = TextEditingController();
  TextEditingController taxBaseTotalCtrl = TextEditingController();
  TextEditingController taxAmountTotalCtrl = TextEditingController();
  TextEditingController purchasePriceTotalCtrl = TextEditingController();

  TextEditingController orderDateCtrl = TextEditingController();
  TextEditingController referenceNumberCtrl = TextEditingController();

  ProductModel? selectedProduct;
  ValueNotifier<dynamic>? fromWarehouseNotifier;
  ValueNotifier<dynamic>? toWarehouseNotifier;
  ValueNotifier<dynamic>? branchNotifier;
  ValueNotifier<dynamic>? productNotifier;

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
    Global.appBarColor = suBgColor;
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าต้นทาง'));
    toWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
    branchNotifier = ValueNotifier<BranchModel>(
        BranchModel(id: 0, name: 'เลือกสาขาปลายทาง'));
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
    productEntryWeightCtrl.dispose();
    productEntryWeightBahtCtrl.dispose();
    warehouseCtrl.dispose();

    productSellThengPriceCtrl.dispose();
    productBuyThengPriceCtrl.dispose();
    priceExcludeTaxCtrl.dispose();
    priceIncludeTaxCtrl.dispose();
    priceDiffCtrl.dispose();
    taxBaseCtrl.dispose();
    taxAmountCtrl.dispose();
    purchasePriceCtrl.dispose();

    toWarehouseCtrl.dispose();
    productSellPriceCtrl.dispose();
    productBuyPriceCtrl.dispose();

    priceExcludeTaxTotalCtrl.dispose();
    priceIncludeTaxTotalCtrl.dispose();
    priceDiffTotalCtrl.dispose();
    taxBaseTotalCtrl.dispose();
    taxAmountTotalCtrl.dispose();
    purchasePriceTotalCtrl.dispose();

    orderDateCtrl.dispose();
    referenceNumberCtrl.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/product/type/USED/6', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.where((e) => e.isDefault == 1).first;
            // motivePrint(selectedProduct?.toJson());
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

      var warehouse = await ApiServices.post(
          '/binlocation/all/type/USED/6', Global.requestObj(null));
      // print(warehouse!.data);
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        setState(() {
          fromWarehouseList = warehouseListModelFromJson(data);
          if (fromWarehouseList.isNotEmpty) {
            selectedFromLocation =
                fromWarehouseList.where((e) => e.isDefault == 1).first;
            selectedFromLocation ??= fromWarehouseList.first;
            fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
                selectedFromLocation ??
                    WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));

            loadToWarehouseNoId(selectedFromLocation!.id!);
          } else {
            toWarehouseList = warehouseListModelFromJson(data);
          }
        });
      } else {
        fromWarehouseList = [];
        toWarehouseList = [];
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

      productWeightCtrl.text =
          formatter.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtCtrl.text = formatter
          .format(Global.getTotalWeightByLocation(qtyLocationList) / getUnitWeightValue());
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void loadToWarehouseNoId(int id) async {
    try {
      setState(() {
        toWarehouseList.clear();
        toWarehouseCtrl.text = "";
      });
      var data =
          fromWarehouseList.where((element) => element.id != id).toList();
      toWarehouseList.addAll(data);
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          toWarehouseNotifier = ValueNotifier<WarehouseModel>(
              WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
        });
      });
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
                          decoration: const BoxDecoration(color: suBgColor),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'ขายทองเก่าร้านขายส่ง',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        // SizedBox(
                        //   height: 100,
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         flex: 5,
                        //         child:
                        //             Padding(
                        //           padding:
                        //               const EdgeInsets
                        //                   .all(
                        //                   8.0),
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
                        //                   project:
                        //                       project,
                        //                   isItemSelected:
                        //                       isItemSelected,
                        //                   firstSpace:
                        //                       10,
                        //                   fontSize:
                        //                       18.sp,
                        //                 );
                        //               },
                        //               onChanged:
                        //                   (ProductModel
                        //                       value) {
                        //                 productCodeCtrl.text =
                        //                     value.productCode!;
                        //                 productNameCtrl.text =
                        //                     value.name;
                        //                 productNotifier!.value =
                        //                     value;
                        //                 if (warehouseCtrl.text !=
                        //                     "") {
                        //                   loadQtyByLocation(selectedFromLocation!.id!);
                        //                 }
                        //               },
                        //               child:
                        //                   DropDownObjectChildWidget(
                        //                 key:
                        //                     GlobalKey(),
                        //                 fontSize:
                        //                     18.sp,
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
                        SizedBox(
                          height: 100,
                          child: Row(
                            children: [
                              const Expanded(
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'คลังสินค้าต้นทาง',
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
                                child: SizedBox(
                                  height: 80,
                                  child: MiraiDropDownMenu<WarehouseModel>(
                                    key: UniqueKey(),
                                    children: fromWarehouseList,
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
                                        fontSize: 18.sp,
                                      );
                                    },
                                    onChanged: (WarehouseModel value) {
                                      warehouseCtrl.text = value.id!.toString();
                                      selectedFromLocation = value;
                                      fromWarehouseNotifier!.value = value;
                                      if (productCodeCtrl.text != "") {
                                        loadQtyByLocation(value.id!);
                                      }
                                      if (selectedFromLocation != null) {
                                        loadToWarehouseNoId(
                                            selectedFromLocation!.id!);
                                      }
                                    },
                                    child: DropDownObjectChildWidget(
                                      key: GlobalKey(),
                                      fontSize: 18.sp,
                                      projectValueNotifier:
                                          fromWarehouseNotifier!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Row(
                        //     children: [
                        //       const Expanded(
                        //           flex: 6,
                        //           child: Row(
                        //             mainAxisAlignment: MainAxisAlignment.end,
                        //             children: [
                        //               Text(
                        //                 'น้ำหนักทั้งหมด',
                        //                 style: TextStyle(
                        //                     fontSize: 50, color: textColor),
                        //               ),
                        //               SizedBox(
                        //                 width: 10,
                        //               ),
                        //               Text(
                        //                 '(บาททอง)',
                        //                 style: TextStyle(
                        //                     color: textColor, fontSize: 30),
                        //               ),
                        //               SizedBox(
                        //                 width: 10,
                        //               ),
                        //             ],
                        //           )),
                        //       Expanded(
                        //         flex: 6,
                        //         child: buildTextFieldBig(
                        //             labelText: "",
                        //             inputType: TextInputType.phone,
                        //             enabled: false,
                        //             controller: productWeightBahtCtrl,
                        //             inputFormat: [
                        //               ThousandsFormatter(allowFraction: true)
                        //             ],
                        //             onChanged: (String value) {
                        //               if (productWeightBahtCtrl
                        //                   .text.isNotEmpty) {
                        //                 productWeightCtrl.text = Global.format(
                        //                     (Global.toNumber(
                        //                             productWeightBahtCtrl
                        //                                 .text) *
                        //                         getUnitWeightValue()));
                        //               } else {
                        //                 productWeightCtrl.text = "";
                        //               }
                        //             }),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Row(children: [
                        //       const Expanded(
                        //           flex: 6,
                        //           child: Row(
                        //             mainAxisAlignment: MainAxisAlignment.end,
                        //             children: [
                        //               Text(
                        //                 'น้ำหนักทั้งหมด',
                        //                 style: TextStyle(
                        //                     fontSize: 50, color: textColor),
                        //               ),
                        //               SizedBox(
                        //                 width: 10,
                        //               ),
                        //               Text(
                        //                 '(กรัม)',
                        //                 style: TextStyle(
                        //                     color: textColor, fontSize: 30),
                        //               ),
                        //               SizedBox(
                        //                 width: 10,
                        //               ),
                        //             ],
                        //           )),
                        //       Expanded(
                        //         flex: 6,
                        //         child: buildTextFieldBig(
                        //             labelText: "",
                        //             inputType: TextInputType.number,
                        //             enabled: false,
                        //             controller: productWeightCtrl,
                        //             inputFormat: [
                        //               ThousandsFormatter(allowFraction: true)
                        //             ],
                        //             onChanged: (String value) {
                        //               if (productWeightCtrl.text.isNotEmpty) {
                        //                 productWeightBahtCtrl.text =
                        //                     Global.format((Global.toNumber(
                        //                             productWeightCtrl.text) /
                        //                         getUnitWeightValue()));
                        //               } else {
                        //                 productWeightBahtCtrl.text = "";
                        //               }
                        //             }),
                        //       ),
                        //     ])),
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
                                        'ป้อนน้ำหนัก',
                                        style: TextStyle(
                                            fontSize: 50, color: textColor),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '(บาททอง)',
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
                                child: numberTextField(
                                    labelText: "",
                                    inputType: TextInputType.phone,
                                    controller: productEntryWeightBahtCtrl,
                                    focusNode: bahtFocus,
                                    readOnly: bahtReadOnly,
                                    inputFormat: [
                                      ThousandsFormatter(
                                          formatter: formatter,
                                          allowFraction: true)
                                    ],
                                    clear: () {
                                      setState(() {
                                        productEntryWeightBahtCtrl.text = "";
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
                            child: Row(children: [
                              const Expanded(
                                  flex: 6,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        'ป้อนน้ำหนัก',
                                        style: TextStyle(
                                            fontSize: 50, color: textColor),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '(กรัม)',
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
                                child: numberTextField(
                                    labelText: "",
                                    inputType: TextInputType.number,
                                    controller: productEntryWeightCtrl,
                                    focusNode: gramFocus,
                                    readOnly: gramReadOnly,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    clear: () {
                                      setState(() {
                                        productEntryWeightCtrl.text = "";
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
                            ])),
                        const SizedBox(
                          width: 10,
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
                                        style: TextStyle(
                                            fontSize: 50, color: textColor),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '(บาท)',
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
                                child: numberTextField(
                                  labelText: "",
                                  inputType: TextInputType.phone,
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
                                  controller: priceIncludeTaxCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
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
                                        'คลังสินค้าปลายทาง',
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
                                child: SizedBox(
                                  height: 80,
                                  child: MiraiDropDownMenu<WarehouseModel>(
                                    key: UniqueKey(),
                                    children: toWarehouseList,
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
                                        fontSize: 18.sp,
                                      );
                                    },
                                    onChanged: (WarehouseModel value) {
                                      toWarehouseCtrl.text =
                                          value.id!.toString();
                                      selectedToLocation = value;
                                      toWarehouseNotifier!.value = value;
                                    },
                                    child: DropDownObjectChildWidget(
                                      key: GlobalKey(),
                                      fontSize: 18.sp,
                                      projectValueNotifier:
                                          toWarehouseNotifier!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
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
                                    if (txt == 'gram') {
                                      productEntryWeightCtrl.text =
                                          value != null
                                              ? "${Global.format(value)}"
                                              : "";
                                      gramChanged();
                                    }
                                    if (txt == 'baht') {
                                      productEntryWeightBahtCtrl.text =
                                          value != null
                                              ? "${Global.format(value)}"
                                              : "";
                                      bahtChanged();
                                    }
                                    if (txt == 'price') {
                                      priceIncludeTaxCtrl.text = value != null
                                          ? "${Global.format(value)}"
                                          : "";
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
                    color: suBgColor,
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
                      if (selectedProduct == null) {
                        Alert.warning(
                            context, 'คำเตือน', 'Cannot load product please close and try again', 'OK', action: () {});
                        return;
                      }

                      if (selectedFromLocation == null) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาเลือกคลังสินค้า', 'OK', action: () {});
                        return;
                      }

                      if (productEntryWeightCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกน้ำหนัก', 'OK', action: () {});
                        return;
                      }

                      if (priceIncludeTaxCtrl.text.isEmpty) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณากรอกราคา', 'OK', action: () {});
                        return;
                      }

                      if (selectedToLocation == null) {
                        Alert.warning(context, 'คำเตือน',
                            'กรุณาเลือกคลังสินค้าปลายทาง', 'OK', action: () {});
                        return;
                      }
                      // Alert.info(
                      //     context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                      //     action: () async {
                        Global.usedSellDetail!.add(
                          OrderDetailModel(
                            productName: selectedProduct!.name,
                            productId: selectedProduct!.id,
                            binLocationId: selectedFromLocation!.id,
                            toBinLocationId: selectedToLocation!.id,
                            binLocationName: selectedFromLocation!.name,
                            toBinLocationName: selectedToLocation!.name,
                            sellTPrice: 0,
                            buyTPrice: 0,
                            sellPrice: 0,
                            buyPrice: 0,
                            weight:
                                Global.toNumber(productEntryWeightCtrl.text),
                            weightBath: Global.toNumber(
                                productEntryWeightBahtCtrl.text),
                            commission: 0,
                            priceIncludeTax:
                                Global.toNumber(priceIncludeTaxCtrl.text),
                            priceExcludeTax: 0,
                            purchasePrice: 0,
                            priceDiff: 0,
                            taxBase: 0,
                            taxAmount: 0,
                          ),
                        );
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

  void bahtChanged() {
    if (productEntryWeightBahtCtrl.text.isNotEmpty) {
      productEntryWeightCtrl.text = Global.format(
          (Global.toNumber(productEntryWeightBahtCtrl.text) * getUnitWeightValue()));
    } else {
      productEntryWeightCtrl.text = "";
    }
  }

  void gramChanged() {
    if (productEntryWeightCtrl.text.isNotEmpty) {
      productEntryWeightBahtCtrl.text =
          Global.format((Global.toNumber(productEntryWeightCtrl.text) / getUnitWeightValue()));
    } else {
      productEntryWeightBahtCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productWeightBahtCtrl.text = "";
    productEntryWeightCtrl.text = "";
    productEntryWeightBahtCtrl.text = "";
    warehouseCtrl.text = "";
    toWarehouseCtrl.text = "";
    productNotifier = ValueNotifier<ProductModel>(
        selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    productCodeCtrl.text =
        (selectedProduct != null ? selectedProduct!.productCode : '')!;
    productNameCtrl.text = selectedProduct != null ? selectedProduct!.name : '';
    fromWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าต้นทาง'));
    toWarehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้าปลายทาง'));
    branchNotifier = ValueNotifier<BranchModel>(
        BranchModel(id: 0, name: 'เลือกสาขาปลายทาง'));
  }
}
