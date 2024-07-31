import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/checkout_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:pattern_formatter/pattern_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class BuyThengMatchingScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final Function(dynamic value) refreshHold;
  int cartCount;

  BuyThengMatchingScreen(
      {super.key,
      required this.refreshCart,
      required this.refreshHold,
      required this.cartCount});

  @override
  State<BuyThengMatchingScreen> createState() => _BuyThengMatchingScreenState();
}

class _BuyThengMatchingScreenState extends State<BuyThengMatchingScreen> {
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
  final TextEditingController bookDate = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  final controller = BoardDateTimeController();

  DateTime date = DateTime.now();

  @override
  void initState() {
    // implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumBuyThengTotal();
    loadProducts();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/product/type/BARM', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.isNotEmpty ? productList.first : null;
            productCodeCtrl.text =
            (selectedProduct != null ? selectedProduct?.productCode! : "")!;
            productNameCtrl.text =
            (selectedProduct != null ? selectedProduct?.name : "")!;
            productNotifier =
                ValueNotifier<ProductModel>(selectedProduct ??
                    ProductModel(name: 'เลือกสินค้า', id: 0));
          }
        });

      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post(
          '/binlocation/all/sell', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        warehouseList = warehouses;
        selectedWarehouse = warehouseList.first;
        warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ??
            WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
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
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
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
      await pr.hide();

      productWeightRemainCtrl.text =
          formatter.format(Global.getTotalWeightByLocation(qtyLocationList));
      productWeightBahtRemainCtrl.text = formatter
          .format(Global.getTotalWeightByLocation(qtyLocationList) / 15.16);
      setState(() {});
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey();
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'ซื้อทองแท่ง (จับคู่)',
          style: TextStyle(fontSize: 32),
        ),
        // backgroundColor: bgColor,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GoldPriceScreen(
                            showBackButton: true,
                          ),
                      fullscreenDialog: true));
            },
            child: Row(
              children: [
                const Icon(
                  Icons.price_change_outlined,
                  size: 50,
                ),
                Text(
                  'ราคาทองคำ',
                  style: TextStyle(fontSize: size.getWidthPx(6)),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: loading
              ? const LoadingProgress()
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: bgColor3.withAlpha(80),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 150,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.orange,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  resetText();
                                  await loadQtyByLocation(selectedWarehouse!.id!);
                                  if (mounted) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  right: -40.0,
                                                  top: -40.0,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const CircleAvatar(
                                                      backgroundColor: Colors
                                                          .red,
                                                      child: Icon(Icons.close),
                                                    ),
                                                  ),
                                                ),
                                                Form(
                                                  key: formKey,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(context)
                                                          .requestFocus(
                                                          FocusNode());
                                                    },
                                                    child: SizedBox(
                                                      width:
                                                      MediaQuery
                                                          .of(context)
                                                          .size
                                                          .width *
                                                          3 /
                                                          4,
                                                      child:
                                                      SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            const SizedBox(
                                                              height: 20,
                                                            ),
                                                            // Row(
                                                            //   mainAxisAlignment:
                                                            //       MainAxisAlignment
                                                            //           .spaceBetween,
                                                            //   crossAxisAlignment:
                                                            //       CrossAxisAlignment
                                                            //           .center,
                                                            //   children: [
                                                            //     Expanded(
                                                            //       child: Padding(
                                                            //         padding: const EdgeInsets
                                                            //             .only(
                                                            //             left: 8.0,
                                                            //             right:
                                                            //                 8.0),
                                                            //         child:
                                                            //             TextField(
                                                            //           controller:
                                                            //               reserveDateCtrl,
                                                            //           //editing controller of this TextField
                                                            //           style: const TextStyle(
                                                            //               fontSize:
                                                            //                   38),
                                                            //           decoration:
                                                            //               InputDecoration(
                                                            //             prefixIcon:
                                                            //                 const Icon(
                                                            //                     Icons.calendar_today),
                                                            //             //icon of text field
                                                            //             floatingLabelBehavior:
                                                            //                 FloatingLabelBehavior
                                                            //                     .always,
                                                            //             contentPadding: const EdgeInsets
                                                            //                 .symmetric(
                                                            //                 vertical:
                                                            //                     10.0,
                                                            //                 horizontal:
                                                            //                     10.0),
                                                            //             labelText:
                                                            //                 "วันที่จอง"
                                                            //                     .tr(),
                                                            //             border:
                                                            //                 OutlineInputBorder(
                                                            //               borderRadius:
                                                            //                   BorderRadius.circular(
                                                            //                 getProportionateScreenWidth(
                                                            //                     8),
                                                            //               ),
                                                            //               borderSide:
                                                            //                   const BorderSide(
                                                            //                 color:
                                                            //                     kGreyShade3,
                                                            //               ),
                                                            //             ),
                                                            //             enabledBorder:
                                                            //                 OutlineInputBorder(
                                                            //               borderRadius:
                                                            //                   BorderRadius.circular(
                                                            //                 getProportionateScreenWidth(
                                                            //                     2),
                                                            //               ),
                                                            //               borderSide:
                                                            //                   const BorderSide(
                                                            //                 color:
                                                            //                     kGreyShade3,
                                                            //               ),
                                                            //             ),
                                                            //           ),
                                                            //           readOnly:
                                                            //               true,
                                                            //           //set it true, so that user will not able to edit text
                                                            //           onTap:
                                                            //               () async {
                                                            //             final pickedDate = await showBoardDateTimePicker(
                                                            //                 context:
                                                            //                     context,
                                                            //                 pickerType: DateTimePickerType
                                                            //                     .datetime,
                                                            //                 initialDate:
                                                            //                     DateTime.now());
                                                            //             if (pickedDate !=
                                                            //                 null) {
                                                            //               setState(() =>
                                                            //                   date =
                                                            //                       pickedDate);
                                                            //             }
                                                            //             if (pickedDate !=
                                                            //                 null) {
                                                            //               motivePrint(
                                                            //                   pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                                            //               String
                                                            //                   formattedDate =
                                                            //                   DateFormat('yyyy-MM-dd HH:mm:ss').format(pickedDate);
                                                            //               motivePrint(
                                                            //                   formattedDate); //formatted date output using intl package =>  2021-03-16
                                                            //               //you can implement different kind of Date Format here according to your requirement
                                                            //               setState(
                                                            //                   () {
                                                            //                 reserveDateCtrl.text =
                                                            //                     formattedDate; //set output date to TextField value.
                                                            //               });
                                                            //             } else {
                                                            //               motivePrint(
                                                            //                   "Date is not selected");
                                                            //             }
                                                            //           },
                                                            //         ),
                                                            //       ),
                                                            //     ),
                                                            //   ],
                                                            // ),
                                                            // const SizedBox(
                                                            //   height: 15,
                                                            // ),
                                                            SizedBox(
                                                              height: 100,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    flex: 5,
                                                                    child:
                                                                    Padding(
                                                                      padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child:
                                                                      SizedBox(
                                                                        height:
                                                                        80,
                                                                        child: MiraiDropDownMenu<
                                                                            ProductModel>(
                                                                          key:
                                                                          UniqueKey(),
                                                                          children:
                                                                          productList,
                                                                          space:
                                                                          4,
                                                                          maxHeight:
                                                                          360,
                                                                          showSearchTextField:
                                                                          true,
                                                                          selectedItemBackgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                          emptyListMessage:
                                                                          'ไม่มีข้อมูล',
                                                                          showSelectedItemBackgroundColor:
                                                                          true,
                                                                          itemWidgetBuilder:
                                                                              (
                                                                              int index,
                                                                              ProductModel?
                                                                              project,
                                                                              {
                                                                                bool isItemSelected =
                                                                                false,
                                                                              }) {
                                                                            return DropDownItemWidget(
                                                                              project:
                                                                              project,
                                                                              isItemSelected:
                                                                              isItemSelected,
                                                                              firstSpace:
                                                                              10,
                                                                              fontSize:
                                                                              size
                                                                                  .getWidthPx(
                                                                                  6),
                                                                            );
                                                                          },
                                                                          onChanged:
                                                                              (
                                                                              ProductModel
                                                                              value) {
                                                                            productCodeCtrl
                                                                                .text =
                                                                                value
                                                                                    .productCode!
                                                                                    .toString();
                                                                            productNameCtrl
                                                                                .text =
                                                                                value
                                                                                    .name;
                                                                            selectedProduct =
                                                                                value;
                                                                            productNotifier!
                                                                                .value =
                                                                                value;
                                                                            if (selectedWarehouse !=
                                                                                null) {
                                                                              loadQtyByLocation(
                                                                                  selectedWarehouse!
                                                                                      .id!);
                                                                              setState(() {});
                                                                            }
                                                                          },
                                                                          child:
                                                                          DropDownObjectChildWidget(
                                                                            key:
                                                                            GlobalKey(),
                                                                            fontSize:
                                                                            size
                                                                                .getWidthPx(
                                                                                6),
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
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                              child: buildTextFieldBig(
                                                                  labelText:
                                                                  "รหัสสินค้า",
                                                                  textColor:
                                                                  Colors
                                                                      .orange,
                                                                  controller:
                                                                  productCodeCtrl,
                                                                  enabled: false),
                                                            ),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                    child:
                                                                    SizedBox(
                                                                      height: 80,
                                                                      child: MiraiDropDownMenu<
                                                                          WarehouseModel>(
                                                                        key:
                                                                        UniqueKey(),
                                                                        children:
                                                                        warehouseList,
                                                                        space: 4,
                                                                        maxHeight:
                                                                        360,
                                                                        showSearchTextField:
                                                                        true,
                                                                        selectedItemBackgroundColor:
                                                                        Colors
                                                                            .transparent,
                                                                        emptyListMessage:
                                                                        'ไม่มีข้อมูล',
                                                                        showSelectedItemBackgroundColor:
                                                                        true,
                                                                        itemWidgetBuilder:
                                                                            (
                                                                            int index,
                                                                            WarehouseModel?
                                                                            project,
                                                                            {
                                                                              bool isItemSelected =
                                                                              false,
                                                                            }) {
                                                                          return DropDownItemWidget(
                                                                            project:
                                                                            project,
                                                                            isItemSelected:
                                                                            isItemSelected,
                                                                            firstSpace:
                                                                            10,
                                                                            fontSize:
                                                                            size
                                                                                .getWidthPx(
                                                                                6),
                                                                          );
                                                                        },
                                                                        onChanged:
                                                                            (
                                                                            WarehouseModel
                                                                            value) {
                                                                          warehouseCtrl
                                                                              .text =
                                                                              value
                                                                                  .id!
                                                                                  .toString();
                                                                          selectedWarehouse =
                                                                              value;
                                                                          warehouseNotifier!
                                                                              .value =
                                                                              value;
                                                                          loadQtyByLocation(
                                                                              value
                                                                                  .id!);
                                                                          setState(
                                                                                  () {});
                                                                        },
                                                                        child:
                                                                        DropDownObjectChildWidget(
                                                                          key:
                                                                          GlobalKey(),
                                                                          fontSize:
                                                                          size
                                                                              .getWidthPx(
                                                                              6),
                                                                          projectValueNotifier:
                                                                          warehouseNotifier!,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: buildTextFieldBig(
                                                                        labelText:
                                                                        "น้ำหนัก (บาททอง) ที่เหลืออยู่",
                                                                        inputType:
                                                                        TextInputType
                                                                            .phone,
                                                                        textColor:
                                                                        Colors
                                                                            .black38,
                                                                        enabled:
                                                                        false,
                                                                        controller:
                                                                        productWeightBahtRemainCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction:
                                                                              true)
                                                                        ],
                                                                        onChanged:
                                                                            (
                                                                            String
                                                                            value) {}),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                    buildTextFieldBig(
                                                                        labelText:
                                                                        "น้ำหนัก (บาททอง)",
                                                                        inputType: TextInputType
                                                                            .phone,
                                                                        textColor: Colors
                                                                            .orange,
                                                                        controller:
                                                                        productWeightBahtCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction: true)
                                                                        ],
                                                                        onChanged:
                                                                            (
                                                                            String value) {
                                                                          if (productWeightBahtCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productWeightCtrl
                                                                                .text =
                                                                                formatter
                                                                                    .format(
                                                                                    (Global
                                                                                        .toNumber(
                                                                                        productWeightBahtCtrl
                                                                                            .text) *
                                                                                        15.16)
                                                                                        .toPrecision(
                                                                                        2));
                                                                            marketPriceTotalCtrl
                                                                                .text =
                                                                                Global
                                                                                    .format(
                                                                                    Global
                                                                                        .getBuyThengPrice(
                                                                                        Global
                                                                                            .toNumber(
                                                                                            productWeightCtrl
                                                                                                .text)));
                                                                            productPriceCtrl
                                                                                .text =
                                                                                marketPriceTotalCtrl
                                                                                    .text;
                                                                            productPriceTotalCtrl
                                                                                .text =
                                                                            productCommissionCtrl
                                                                                .text
                                                                                .isNotEmpty
                                                                                ? '${Global
                                                                                .format(
                                                                                Global
                                                                                    .toNumber(
                                                                                    productCommissionCtrl
                                                                                        .text) +
                                                                                    Global
                                                                                        .toNumber(
                                                                                        productPriceCtrl
                                                                                            .text))}'
                                                                                : Global
                                                                                .format(
                                                                                Global
                                                                                    .toNumber(
                                                                                    productPriceCtrl
                                                                                        .text))
                                                                                .toString();
                                                                          } else {
                                                                            productWeightCtrl
                                                                                .text =
                                                                            "";
                                                                            marketPriceTotalCtrl
                                                                                .text =
                                                                            "";
                                                                            productPriceCtrl
                                                                                .text =
                                                                            "";
                                                                            productPriceTotalCtrl
                                                                                .text =
                                                                            "";
                                                                          }
                                                                        }),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: buildTextFieldBig(
                                                                        labelText:
                                                                        "ราคาสมาคม",
                                                                        inputType:
                                                                        TextInputType
                                                                            .number,
                                                                        textColor:
                                                                        Colors
                                                                            .black38,
                                                                        controller:
                                                                        marketPriceTotalCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction:
                                                                              true)
                                                                        ],
                                                                        enabled:
                                                                        false),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                    buildTextFieldBig(
                                                                        labelText:
                                                                        "ราคาขาย",
                                                                        inputType: TextInputType
                                                                            .phone,
                                                                        enabled:
                                                                        true,
                                                                        textColor: Colors
                                                                            .orange,
                                                                        controller:
                                                                        productPriceCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction: true)
                                                                        ],
                                                                        onChanged:
                                                                            (
                                                                            String value) {
                                                                          if (productPriceCtrl
                                                                              .text
                                                                              .isNotEmpty &&
                                                                              productCommissionCtrl
                                                                                  .text
                                                                                  .isNotEmpty) {
                                                                            productPriceTotalCtrl
                                                                                .text =
                                                                                formatter
                                                                                    .format(
                                                                                    (Global
                                                                                        .toNumber(
                                                                                        productCommissionCtrl
                                                                                            .text) +
                                                                                        Global
                                                                                            .toNumber(
                                                                                            productPriceCtrl
                                                                                                .text))
                                                                                        .toPrecision(
                                                                                        2));
                                                                            setState(() {});
                                                                          }
                                                                        }),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                    buildTextFieldBig(
                                                                        labelText:
                                                                        "ค่าบล็อกทอง",
                                                                        inputType: TextInputType
                                                                            .phone,
                                                                        textColor: Colors
                                                                            .orange,
                                                                        controller:
                                                                        productCommissionCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction: true)
                                                                        ],
                                                                        onChanged:
                                                                            (
                                                                            String value) {
                                                                          if (productPriceCtrl
                                                                              .text
                                                                              .isNotEmpty &&
                                                                              productCommissionCtrl
                                                                                  .text
                                                                                  .isNotEmpty) {
                                                                            productPriceTotalCtrl
                                                                                .text =
                                                                            "${Global
                                                                                .toNumber(
                                                                                productCommissionCtrl
                                                                                    .text) +
                                                                                Global
                                                                                    .toNumber(
                                                                                    productPriceCtrl
                                                                                        .text)}";
                                                                            setState(() {});
                                                                          }
                                                                        }),
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                    Padding(
                                                                      padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                      child: buildTextFieldBig(
                                                                          labelText:
                                                                          "รวมราคาขาย",
                                                                          inputType:
                                                                          TextInputType
                                                                              .number,
                                                                          textColor:
                                                                          Colors
                                                                              .orange,
                                                                          controller:
                                                                          productPriceTotalCtrl,
                                                                          inputFormat: [
                                                                            ThousandsFormatter(
                                                                                allowFraction: true)
                                                                          ],
                                                                          enabled:
                                                                          false),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                              child:
                                                              OutlinedButton(
                                                                child: const Text(
                                                                    "เพิ่ม"),
                                                                onPressed:
                                                                    () async {
                                                                  // if (reserveDateCtrl
                                                                  //     .text
                                                                  //     .isEmpty) {
                                                                  //   Alert
                                                                  //       .warning(
                                                                  //       context,
                                                                  //       'คำเตือน',
                                                                  //       'กรุณาเลือกวันจอง',
                                                                  //       'OK');
                                                                  //   return;
                                                                  // }

                                                                  if (productCodeCtrl
                                                                      .text
                                                                      .isEmpty) {
                                                                    Alert
                                                                        .warning(
                                                                        context,
                                                                        'คำเตือน',
                                                                        'กรุณาเลือกสินค้า',
                                                                        'OK');
                                                                    return;
                                                                  }

                                                                  if (productWeightBahtCtrl
                                                                      .text
                                                                      .isEmpty) {
                                                                    Alert
                                                                        .warning(
                                                                        context,
                                                                        'คำเตือน',
                                                                        'กรุณาใส่น้ำหนัก',
                                                                        'OK');
                                                                    return;
                                                                  }

                                                                  if (productPriceTotalCtrl
                                                                      .text
                                                                      .isEmpty) {
                                                                    Alert
                                                                        .warning(
                                                                        context,
                                                                        'คำเตือน',
                                                                        'กรุณากรอกราคา',
                                                                        'OK');
                                                                    return;
                                                                  }

                                                                  var realPrice =
                                                                  Global
                                                                      .getBuyThengPrice(
                                                                      Global
                                                                          .toNumber(
                                                                          productWeightCtrl
                                                                              .text));
                                                                  var price = Global
                                                                      .toNumber(
                                                                      productPriceCtrl
                                                                          .text);
                                                                  var check =
                                                                      price -
                                                                          realPrice;

                                                                  if (check >
                                                                      10000) {
                                                                    Alert
                                                                        .warning(
                                                                        context,
                                                                        'คำเตือน',
                                                                        'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global
                                                                            .format(
                                                                            check)}',
                                                                        'OK');

                                                                    return;
                                                                  }

                                                                  if (check <
                                                                      -10000) {
                                                                    Alert
                                                                        .warning(
                                                                        context,
                                                                        'คำเตือน',
                                                                        'ราคาที่ป้อนน้อยกว่าราคาตลาด ${Global
                                                                            .format(
                                                                            check)}',
                                                                        'OK');

                                                                    return;
                                                                  }

                                                                  Global
                                                                      .buyThengOrderDetail!
                                                                      .add(
                                                                    OrderDetailModel(
                                                                        productName: selectedProduct!.name,
                                                                        productId:
                                                                        selectedProduct!
                                                                            .id,
                                                                        binLocationId:
                                                                        selectedWarehouse!
                                                                            .id,
                                                                        weight: Global
                                                                            .toNumber(
                                                                            productWeightCtrl
                                                                                .text),
                                                                        weightBath:
                                                                        Global
                                                                            .toNumber(
                                                                            productWeightBahtCtrl
                                                                                .text),
                                                                        commission: 0,
                                                                        taxBase: 0,
                                                                        priceIncludeTax: Global
                                                                            .toNumber(
                                                                            productPriceTotalCtrl
                                                                                .text),
                                                                        bookDate: bookDate.text != "" ? DateTime
                                                                            .parse(
                                                                            bookDate
                                                                                .text).toUtc() : null),
                                                                  );
                                                                  sumBuyThengTotal();
                                                                  setState(() {});
                                                                  Navigator.of(
                                                                      context)
                                                                      .pop();
                                                                },
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                    setState(() {});
                                  }
                                },
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 32),
                                    SizedBox(width: 6),
                                    Text(
                                      'เพิ่ม',
                                      style: TextStyle(fontSize: 32),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: bgColor2,
                                ),
                                child: ListView.builder(
                                    itemCount: Global.buyThengOrderDetail!.length,
                                    itemBuilder: (context, index) {
                                      return _itemOrderList(
                                          order:
                                              Global.buyThengOrderDetail![index],
                                          index: index);
                                    }),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: bgColor4,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ยอดรวม',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(8),
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF636564)),
                                      ),
                                      Text(
                                        "${Global.format(Global.buyThengSubTotal)} บาท",
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(8),
                                            fontWeight: FontWeight.bold,
                                            color: textColor2),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: bgColor4,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.teal,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (Global
                                                .buyThengOrderDetail!.isEmpty) {
                                              return;
                                            }

                                            final ProgressDialog pr =
                                                ProgressDialog(context,
                                                    type: ProgressDialogType
                                                        .normal,
                                                    isDismissible: true,
                                                    showLogs: true);
                                            await pr.show();
                                            pr.update(
                                                message: 'processing'.tr());
                                            try {
                                              var result =
                                                  await ApiServices.post(
                                                      '/order/gen/33',
                                                      Global.requestObj(null));
                                              await pr.hide();
                                              if (result!.status == "success") {
                                                OrderModel order = OrderModel(
                                                    orderId: result.data,
                                                    orderDate:
                                                        DateTime.now().toUtc(),
                                                    details: Global
                                                        .buyThengOrderDetail!,
                                                    orderTypeId: 33);
                                                final data = order.toJson();
                                                Global.orders?.add(
                                                    OrderModel.fromJson(data));
                                                widget.refreshCart(Global
                                                    .orders?.length
                                                    .toString());
                                                Global.buyThengOrderDetail!
                                                    .clear();
                                                setState(() {
                                                  Global.buyThengSubTotal = 0;
                                                  Global.buyThengTax = 0;
                                                  Global.buyThengTotal = 0;
                                                });
                                                if (mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                          const SnackBar(
                                                    content: Text(
                                                      "เพิ่มลงรถเข็นสำเร็จ...",
                                                      style: TextStyle(
                                                          fontSize: 22),
                                                    ),
                                                    backgroundColor:
                                                        Colors.teal,
                                                  ));
                                                }
                                              } else {
                                                if (mounted) {
                                                  Alert.warning(
                                                      context,
                                                      'Warning'.tr(),
                                                      'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน',
                                                      'OK'.tr(),
                                                      action: () {});
                                                }
                                              }
                                            } catch (e) {
                                              await pr.hide();
                                              if (mounted) {
                                                Alert.warning(
                                                    context,
                                                    'Warning'.tr(),
                                                    e.toString(),
                                                    'OK'.tr(),
                                                    action: () {});
                                              }
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.add, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'เพิ่มลงในรถเข็น',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.getWidthPx(8)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.blue[700],
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (Global
                                                .buyThengOrderDetail!.isEmpty) {
                                              return;
                                            }

                                            OrderModel order = OrderModel(
                                                orderId: "",
                                                orderDate:
                                                    DateTime.now().toUtc(),
                                                details:
                                                    Global.buyThengOrderDetail!,
                                                orderTypeId: 33);

                                            final data = order.toJson();
                                            Global.holdOrder(
                                                OrderModel.fromJson(data));
                                            // print(OrderModel.fromJson(data).toJson());
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 500),
                                                () async {
                                              String holds =
                                                  (await Global.getHoldList())
                                                      .length
                                                      .toString();
                                              widget.refreshHold(holds);
                                              setState(() {});
                                            });

                                            Global.buyThengOrderDetail!.clear();
                                            setState(() {
                                              Global.buyThengSubTotal = 0;
                                              Global.buyThengTax = 0;
                                              Global.buyThengTotal = 0;
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                "ระงับการสั่งซื้อสำเร็จ...",
                                                style: TextStyle(fontSize: 22),
                                              ),
                                              backgroundColor: Colors.teal,
                                            ));
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.save, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'ระงับการสั่งซื้อ',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.getWidthPx(8)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.deepOrange,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (Global
                                                .buyThengOrderDetail!.isEmpty) {
                                              return;
                                            }

                                            final ProgressDialog pr =
                                                ProgressDialog(context,
                                                    type: ProgressDialogType
                                                        .normal,
                                                    isDismissible: true,
                                                    showLogs: true);
                                            await pr.show();
                                            pr.update(
                                                message: 'processing'.tr());
                                            try {
                                              var result =
                                                  await ApiServices.post(
                                                      '/order/gen/33',
                                                      Global.requestObj(null));
                                              await pr.hide();
                                              if (result!.status == "success") {
                                                OrderModel order = OrderModel(
                                                    orderId: result.data,
                                                    orderDate:
                                                        DateTime.now().toUtc(),
                                                    details: Global
                                                        .buyThengOrderDetail!,
                                                    orderTypeId: 33);
                                                final data = order.toJson();
                                                Global.orders?.add(
                                                    OrderModel.fromJson(data));
                                                widget.refreshCart(Global
                                                    .orders?.length
                                                    .toString());
                                                Global.buyThengOrderDetail!
                                                    .clear();
                                                setState(() {
                                                  Global.buyThengSubTotal = 0;
                                                  Global.buyThengTax = 0;
                                                  Global.buyThengTotal = 0;
                                                });
                                                if (mounted) {
                                                  Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const CheckOutScreen()))
                                                      .whenComplete(() {
                                                    Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () async {
                                                      String holds =
                                                          (await Global
                                                                  .getHoldList())
                                                              .length
                                                              .toString();
                                                      widget.refreshHold(holds);
                                                      widget.refreshCart(Global
                                                          .orders?.length
                                                          .toString());
                                                      setState(() {});
                                                    });
                                                  });
                                                }
                                              } else {
                                                if (mounted) {
                                                  Alert.warning(
                                                      context,
                                                      'Warning'.tr(),
                                                      'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน',
                                                      'OK'.tr(),
                                                      action: () {});
                                                }
                                              }
                                            } catch (e) {
                                              await pr.hide();
                                              if (mounted) {
                                                Alert.warning(
                                                    context,
                                                    'Warning'.tr(),
                                                    e.toString(),
                                                    'OK'.tr(),
                                                    action: () {});
                                              }
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.check, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                'เช็คเอาท์',
                                                style: TextStyle(
                                                    fontSize:
                                                        size.getWidthPx(8)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    productPriceCtrl.text = "";
    productPriceTotalCtrl.text = "";
    productWeightBahtCtrl.text = "";
    bookDate.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
    marketPriceTotalCtrl.text = "";
    warehouseCtrl.text = "";
    productNotifier =
        ValueNotifier<ProductModel>(selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    productCodeCtrl.text = (selectedProduct != null ? selectedProduct?.productCode! : "")!;
    productNameCtrl.text = (selectedProduct != null ? selectedProduct?.name : "")!;
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }

  removeProduct(index) {
    Global.buyThengOrderDetail!.removeAt(index);
    if (Global.buyThengOrderDetail!.isEmpty) {
      Global.buyThengOrderDetail!.clear();
    }
    sumBuyThengTotal();
    setState(() {});
  }

  Widget _itemOrderList({required OrderDetailModel order, required index}) {
    return Row(
      children: [
        Expanded(
          flex: 8,
          child: ListTile(
            title: ListTileData(
              leftTitle: order.productName,
              leftValue: Global.format(order.priceIncludeTax!),
              rightTitle: 'น้ำหนัก',
              rightValue: order.weight!.toString(),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  removeProduct(index);
                },
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
