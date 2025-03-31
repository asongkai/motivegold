import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_mini_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class EditBuyDialog extends StatefulWidget {
  const EditBuyDialog({super.key, required this.index, this.j});

  final int index;
  final int? j;

  @override
  State<EditBuyDialog> createState() => _EditBuyDialogState();
}

class _EditBuyDialogState extends State<EditBuyDialog> {
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
    productWeightCtrl.text = widget.j == null
        ? Global.format(Global.buyOrderDetail![widget.index].weight ?? 0)
        : Global.format(
            Global.ordersPapun![widget.index].details![widget.j!].weight ?? 0);
    productWeightBahtCtrl.text = widget.j == null
        ? Global.format(Global.buyOrderDetail![widget.index].weightBath ?? 0)
        : Global.format(
            Global.ordersPapun![widget.index].details![widget.j!].weightBath ?? 0);
    productPriceCtrl.text = widget.j == null
        ? Global.format(
            Global.buyOrderDetail![widget.index].priceIncludeTax ?? 0)
        : Global.format(
            Global.ordersPapun![widget.index].details![widget.j!].priceIncludeTax ??
                0);
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
      var result =
          await ApiServices.post('/product/type/USED/2', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            var productId = widget.j != null
                ? Global.ordersPapun![widget.index].details![widget.j!].productId
                : Global.buyOrderDetail![widget.index].productId;

            selectedProduct = productList.where((e) => e.id == productId).first;
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
          var binId = widget.j != null
              ? Global.ordersPapun![widget.index].details![widget.j!].binLocationId
              : Global.buyOrderDetail![widget.index].binLocationId;

          selectedWarehouse = warehouseList.where((e) => e.id == binId).first;
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
                    height: 100,
                    decoration: const BoxDecoration(color: buBgColor),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'รับซื้อลูกค้า – ทองคำรูปพรรณเก่า 96.5%',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: size.getWidthPx(15), color: Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        GoldPriceMiniScreen(
                          goldDataModel: widget.j == null ? Global
                              .buyOrderDetail![widget.index].goldDataModel : Global
                            .ordersPapun![widget.index].details![widget.j!].goldDataModel,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
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
                  //                 'น้ำหนัก',
                  //                 style:
                  //                     TextStyle(fontSize: 50, color: textColor),
                  //               ),
                  //               SizedBox(
                  //                 width: 10,
                  //               ),
                  //               Text(
                  //                 '(บาททอง)',
                  //                 style:
                  //                     TextStyle(color: textColor, fontSize: 30),
                  //               ),
                  //               SizedBox(
                  //                 width: 10,
                  //               ),
                  //             ],
                  //           )),
                  //       Expanded(
                  //         flex: 6,
                  //         child: numberTextField(
                  //             labelText: "",
                  //             inputType: TextInputType.number,
                  //             controller: productWeightBahtCtrl,
                  //             readOnly: bahtReadOnly,
                  //             focusNode: bahtFocus,
                  //             inputFormat: [
                  //               ThousandsFormatter(allowFraction: true)
                  //             ],
                  //             clear: () {
                  //               setState(() {
                  //                 productWeightBahtCtrl.text = "";
                  //               });
                  //               bahtChanged();
                  //             },
                  //             onTap: () {
                  //               txt = 'baht';
                  //               closeCal();
                  //             },
                  //             openCalc: () {
                  //               if (!showCal) {
                  //                 txt = 'baht';
                  //                 bahtFocus.requestFocus();
                  //                 openCal();
                  //               }
                  //             },
                  //             onChanged: (String value) {
                  //               bahtChanged();
                  //             }),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
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
                        const Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'ราคารับซื้อคืน',
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
                                var realPrice =
                                Global.getBuyPrice(
                                    Global.toNumber(productWeightCtrl
                                        .text));
                                var price = Global.toNumber(productPriceCtrl.text);
                                var check = price - realPrice;

                                if (price > realPrice) {
                                  Alert.warning(
                                      context,
                                      'คำเตือน',
                                      'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                                      'OK', action: () {});
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
                            height: 80,
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
                                productPriceCtrl.text = value != null
                                    ? "${Global.format(value)}"
                                    : "";
                                var realPrice = Global.getBuyPrice(
                                    Global.toNumber(productWeightCtrl
                                        .text));
                                var price = Global.toNumber(productPriceCtrl.text);
                                var check = price - realPrice;

                                if (price > realPrice) {
                                  Alert.warning(
                                      context,
                                      'คำเตือน',
                                      'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                                      'OK', action: () {});
                                  // return;
                                }
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
                    color: buBgColor,
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
                    onPressed: () {
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

                      if (selectedWarehouse == null) {
                        Alert.warning(
                            context, 'คำเตือน', 'กรุณาเลือกคลังสินค้า', 'OK');
                        return;
                      }

                      productPriceBaseCtrl.text = Global.getBuyPriceUsePrice(
                              Global.toNumber(productWeightCtrl.text),
                              Global.toNumber(widget.j == null ? Global
                                  .buyOrderDetail![widget.index]
                                  .goldDataModel
                                  ?.paphun
                                  ?.buy : Global
                                  .ordersPapun![widget.index].details![widget.j!]
                                  .goldDataModel
                                  ?.paphun
                                  ?.buy))
                          .toString();

                      var realPrice = Global.getBuyPrice(
                          Global.toNumber(productWeightCtrl
                              .text));
                      var price = Global.toNumber(productPriceCtrl.text);
                      var check = price - realPrice;

                      if (price > realPrice) {
                        Alert.warning(
                            context,
                            'คำเตือน',
                            'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                            'OK', action: () {});
                        return;
                      }

                      Alert.info(
                          context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                          action: () async {
                        if (widget.j == null) {
                          Global.buyOrderDetail![widget.index] = OrderDetailModel.fromJson(
                              jsonDecode(jsonEncode(OrderDetailModel(
                                  productName: productNameCtrl.text,
                                  binLocationId: selectedWarehouse!.id,
                                  productId: selectedProduct!.id,
                                  weight:
                                      Global.toNumber(productWeightCtrl.text),
                                  weightBath: Global.toNumber(
                                      productWeightBahtCtrl.text),
                                  commission: 0,
                                  taxBase: 0,
                                  priceIncludeTax: productWeightCtrl.text.isEmpty
                                      ? 0
                                      : Global.toNumber(productPriceCtrl.text),
                                  sellPrice: Global
                                      .buyOrderDetail![widget.index].sellPrice,
                                  buyPrice: Global
                                      .buyOrderDetail![widget.index].buyPrice,
                                  sellTPrice: Global
                                      .buyOrderDetail![widget.index].sellTPrice,
                                  buyTPrice:
                                      Global.buyOrderDetail![widget.index].buyTPrice,
                                  goldDataModel: Global.buyOrderDetail![widget.index].goldDataModel))));
                          sumBuyTotal();
                          setState(() {});
                          Navigator.of(context).pop();
                        } else {
                          Global.ordersPapun![widget.index].details![widget.j!] = OrderDetailModel.fromJson(jsonDecode(jsonEncode(OrderDetailModel(
                              productName: productNameCtrl.text,
                              binLocationId: selectedWarehouse!.id,
                              productId: selectedProduct!.id,
                              weight: Global.toNumber(productWeightCtrl.text),
                              weightBath:
                                  Global.toNumber(productWeightBahtCtrl.text),
                              commission: 0,
                              taxBase: 0,
                              priceIncludeTax: productWeightCtrl.text.isEmpty
                                  ? 0
                                  : Global.toNumber(productPriceCtrl.text),
                              sellPrice: Global.ordersPapun![widget.index]
                                  .details![widget.j!].sellPrice,
                              buyPrice: Global.ordersPapun![widget.index]
                                  .details![widget.j!].buyPrice,
                              sellTPrice: Global.ordersPapun![widget.index]
                                  .details![widget.j!].sellTPrice,
                              buyTPrice: Global.ordersPapun![widget.index]
                                  .details![widget.j!].buyTPrice,
                              goldDataModel: Global.ordersPapun![widget.index]
                                  .details![widget.j!].goldDataModel))));
                          sumBuyTotal();
                          setState(() {});
                          Navigator.of(context).pop();
                        }
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
      productWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productWeightCtrl.text) / getUnitWeightValue()));
    } else {
      productWeightBahtCtrl.text = "";
    }
    if (productWeightCtrl.text.isNotEmpty) {
      productPriceBaseCtrl.text = Global.getBuyPriceUsePrice(
              Global.toNumber(productWeightCtrl.text),
              Global.toNumber(widget.j == null
                  ? Global
                      .buyOrderDetail![widget.index].goldDataModel?.paphun?.buy
                  : Global.ordersPapun![widget.index].details![widget.j!]
                      .goldDataModel?.paphun?.buy))
          .toString();
      // productPriceCtrl.text =
      //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
      setState(() {});
    } else {
      productPriceBaseCtrl.text = "";
      productPriceCtrl.text = "";
    }
    productPriceCtrl.text = "";
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = formatter.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()).toPrecision(2));
    } else {
      productWeightCtrl.text = "";
    }
    if (productWeightCtrl.text.isNotEmpty) {
      // productPriceCtrl.text =
      //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
      productPriceBaseCtrl.text = Global.getBuyPriceUsePrice(
              Global.toNumber(productWeightCtrl.text),
              Global.toNumber(widget.j == null
                  ? Global
                      .buyOrderDetail![widget.index].goldDataModel?.paphun?.buy
                  : Global.ordersPapun![widget.index].details![widget.j!]
                      .goldDataModel?.paphun?.buy))
          .toString();
      setState(() {});
    } else {
      productPriceCtrl.text = "";
      productPriceBaseCtrl.text = "";
    }
    productPriceCtrl.text = "";
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
