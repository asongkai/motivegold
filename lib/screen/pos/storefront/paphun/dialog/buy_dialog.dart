import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_mini_widget.dart';
import 'package:motivegold/screen/gold/gold_price_mini_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/ui/text_header.dart';

class BuyDialog extends StatefulWidget {
  const BuyDialog({super.key});

  @override
  State<BuyDialog> createState() => _BuyDialogState();
}

class _BuyDialogState extends State<BuyDialog> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();
  TextEditingController productPriceBaseCtrl = TextEditingController();
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
    // TODO: implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumBuyTotal();
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
    productPriceCtrl.dispose();
    productPriceBaseCtrl.dispose();
    warehouseCtrl.dispose();

    bahtFocus.dispose();
    gramFocus.dispose();
    priceFocus.dispose();
    comFocus.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
      Global.appBarColor = buBgColor;
    });
    try {
      var result = await ApiServices.post(
          '/product/type/USED/2', Global.requestObj(null));
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
          '/binlocation/all/type/USED/2', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
          selectedWarehouse =
              warehouseList.where((e) => e.isDefault == 1).first;
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
    setState(() {
      loading = false;
    });
  }

  void openCal() {
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
                        posHeaderText(context, buBgColor, 'รับซื้อลูกค้า – ทองคำรูปพรรณเก่า 96.5%'),
                        const Padding(
                          padding: EdgeInsets.only(left: 10, right: 10),
                          child: GoldMiniWidget(screen: 2,),
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
                                child: numberTextField(
                                    labelText: "",
                                    inputType: TextInputType.number,
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
                                      gramChanged();
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
                                        'ราคารับซื้อคืน',
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
                                child: numberTextField(
                                    labelText: "",
                                    inputType: TextInputType.number,
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
                                    onChanged: (value) {
                                      var realPrice = Global.getBuyPrice(
                                          Global.toNumber(productWeightCtrl
                                              .text)); //Global.toNumber(productPriceBaseCtrl.text);
                                      var price = Global.toNumber(
                                          productPriceCtrl.text);
                                      var check = price - realPrice;

                                      if (price > realPrice) {
                                        Alert.warning(
                                            context,
                                            'คำเตือน',
                                            'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                                            'OK',
                                            action: () {});
                                        return;
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
                                        'คลังสินค้า',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(15), color: textColor),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        '',
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
                                child: SizedBox(
                                  height: 80,
                                  child: MiraiDropDownMenu<WarehouseModel>(
                                    key: UniqueKey(),
                                    children: warehouseList,
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
                                        fontSize: size.getWidthPx(8),
                                      );
                                    },
                                    onChanged: (WarehouseModel value) {
                                      warehouseCtrl.text = value.id!.toString();
                                      selectedWarehouse = value;
                                      warehouseNotifier!.value = value;
                                    },
                                    child: DropDownObjectChildWidget(
                                      key: GlobalKey(),
                                      fontSize: size.getWidthPx(8),
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
                                      productPriceCtrl.text = value != null
                                          ? "${Global.format(value)}"
                                          : "";
                                      var realPrice = Global.getBuyPrice(
                                          Global.toNumber(productWeightCtrl
                                              .text)); //Global.toNumber(productPriceBaseCtrl.text);
                                      var price = Global.toNumber(
                                          productPriceCtrl.text);
                                      var check = price - realPrice;

                                      // motivePrint(productPriceBaseCtrl.text);

                                      if (price > realPrice) {
                                        Alert.warning(
                                            context,
                                            'คำเตือน',
                                            'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                                            'OK',
                                            action: () {});
                                        // return;
                                      }
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
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                      minWidth: double.infinity,),
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
                            style: TextStyle(color: Colors.white, fontSize: (MediaQuery.of(context).orientation == Orientation.portrait) ? size.getWidthPx(15) : size.getWidthPx(10)),
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
                      minWidth: double.infinity,),
                  child: MaterialButton(
                    color: buBgColor,
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
                          style: TextStyle(color: Colors.white, fontSize: (MediaQuery.of(context).orientation == Orientation.portrait) ? size.getWidthPx(15) : size.getWidthPx(10)),
                        ),
                      ],
                    ),
                    onPressed: () {
                      if (selectedProduct == null) {
                        Alert.warning(
                            context, 'คำเตือน', getDefaultProductMessage(), 'OK');
                        return;
                      }

                      // if (selectedWarehouse == null) {
                      //   Alert.warning(
                      //       context, 'คำเตือน', getDefaultWarehouseMessage(), 'OK');
                      //   return;
                      // }

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

                      if (selectedWarehouse == null) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาเลือกคลังสินค้า', 'OK');
                        return;
                      }

                      var realPrice = Global.getBuyPrice(Global.toNumber(
                          productWeightCtrl
                              .text)); //Global.toNumber(productPriceBaseCtrl.text);
                      realPrice = Global.toNumber(Global.format(realPrice));
                      motivePrint(realPrice);
                      var price = Global.toNumber(productPriceCtrl.text);
                      var check = price - realPrice;
                      motivePrint(price);
                      motivePrint(check);
                      // return;
                      if (price > realPrice) {
                        Alert.warning(
                            context,
                            'คำเตือน',
                            'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                            'OK',
                            action: () {});
                        return;
                      }

                      // if (price < realPrice) {
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
                        Global.buyOrderDetail!.add(
                          OrderDetailModel.fromJson(
                            jsonDecode(
                              jsonEncode(
                                OrderDetailModel(
                                  productName: productNameCtrl.text,
                                  binLocationId: selectedWarehouse!.id,
                                  productId: selectedProduct!.id,
                                  weight:
                                      Global.toNumber(productWeightCtrl.text),
                                  weightBath: Global.toNumber(
                                      productWeightBahtCtrl.text),
                                  commission: 0,
                                  taxBase: 0,
                                  priceIncludeTax: productWeightCtrl
                                          .text.isEmpty
                                      ? 0
                                      : Global.toNumber(productPriceCtrl.text),
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
                        sumBuyTotal();
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
      productWeightBahtCtrl.text =
          Global.format(Global.toNumber(productWeightCtrl.text) / getUnitWeightValue());
    } else {
      productWeightBahtCtrl.text = "";
    }
    if (productWeightCtrl.text.isNotEmpty) {
      productPriceBaseCtrl.text =
          Global.getBuyPrice(Global.toNumber(productWeightCtrl.text))
              .toString();
      // productPriceCtrl.text =
      //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
      setState(() {});
    } else {
      productPriceBaseCtrl.text = "";
      productPriceCtrl.text = "";
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = formatter.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()));
    } else {
      productWeightCtrl.text = "";
    }
    if (productWeightCtrl.text.isNotEmpty) {
      // productPriceCtrl.text =
      //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
      productPriceBaseCtrl.text =
          Global.getBuyPrice(Global.toNumber(productWeightCtrl.text))
              .toString();
      setState(() {});
    } else {
      productPriceCtrl.text = "";
      productPriceBaseCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productPriceCtrl.text = "";
    productPriceBaseCtrl.text = "";
    productWeightBahtCtrl.text = "";
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
