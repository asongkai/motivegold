import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'checkout_screen.dart';


class PaphunBuyScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final Function(dynamic value) refreshHold;
  int cartCount;

  PaphunBuyScreen(
      {super.key,
      required this.refreshCart,
      required this.refreshHold,
      required this.cartCount});

  @override
  State<PaphunBuyScreen> createState() => _PaphunBuyScreenState();
}

class _PaphunBuyScreenState extends State<PaphunBuyScreen> {
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

  @override
  void initState() {
    // implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumBuyTotal();
    loadProducts();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post('/product/type/USED', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
      } else {
        productList = [];
      }

      var warehouse = await ApiServices.post('/binlocation/all', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
          selectedWarehouse = warehouseList.first;
          warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
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

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey();
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'รับซื้อทองเก่า',
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
                              onPressed: () {
                                resetText();
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
                                              child: InkResponse(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: const CircleAvatar(
                                                  backgroundColor: Colors.red,
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
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      3 /
                                                      4,
                                                  child: SingleChildScrollView(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 100,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 5,
                                                                child: Padding(
                                                                  padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      8.0),
                                                                  child:
                                                                  SizedBox(
                                                                    height: 80,
                                                                    child: MiraiDropDownMenu<
                                                                        ProductModel>(
                                                                      key:
                                                                      UniqueKey(),
                                                                      children:
                                                                      productList,
                                                                      space: 4,
                                                                      maxHeight:
                                                                      360,
                                                                      showSearchTextField:
                                                                      true,
                                                                      selectedItemBackgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                      emptyListMessage: 'ไม่มีข้อมูล',
                                                                      showSelectedItemBackgroundColor:
                                                                      true,
                                                                      itemWidgetBuilder:
                                                                          (
                                                                          int index,
                                                                          ProductModel?
                                                                          project, {
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
                                                                          size.getWidthPx(6),
                                                                        );
                                                                      },
                                                                      onChanged:
                                                                          (ProductModel
                                                                      value) {
                                                                        productCodeCtrl.text = value
                                                                            .productCode!
                                                                            .toString();
                                                                        productNameCtrl.text =
                                                                            value.name;
                                                                        selectedProduct = value;
                                                                        productNotifier!.value =
                                                                            value;
                                                                      },
                                                                      child:
                                                                      DropDownObjectChildWidget(
                                                                        key:
                                                                        GlobalKey(),
                                                                        fontSize:
                                                                        size.getWidthPx(6),
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
                                                          child:
                                                              buildTextFieldBig(
                                                            labelText:
                                                                "รหัสสินค้า",
                                                            textColor:
                                                                Colors.orange,
                                                            controller:
                                                                productCodeCtrl,
                                                            enabled: false,
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
                                                                child:
                                                                    buildTextFieldBig(
                                                                        labelText:
                                                                            "น้ำหนัก (gram)",
                                                                        inputType:
                                                                            TextInputType
                                                                                .number,
                                                                        textColor:
                                                                            Colors
                                                                                .orange,
                                                                        controller:
                                                                            productWeightCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction: true)
                                                                        ],
                                                                        onChanged:
                                                                            (String
                                                                                value) {
                                                                          if (productWeightCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productWeightBahtCtrl.text =
                                                                                formatter.format((Global.toNumber(productWeightCtrl.text) / 15.16).toPrecision(2));
                                                                          } else {
                                                                            productWeightBahtCtrl.text =
                                                                                "";
                                                                          }
                                                                          if (productWeightCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productPriceBaseCtrl.text =
                                                                                Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
                                                                            // productPriceCtrl.text =
                                                                            //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
                                                                            setState(() {});
                                                                          } else {
                                                                            productPriceBaseCtrl.text =
                                                                                "";
                                                                            productPriceCtrl.text =
                                                                                "";
                                                                          }
                                                                        }),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child:
                                                                    buildTextFieldBig(
                                                                        labelText:
                                                                            "น้ำหนัก (บาททอง)",
                                                                        inputType:
                                                                            TextInputType
                                                                                .number,
                                                                        textColor:
                                                                            Colors
                                                                                .orange,
                                                                        controller:
                                                                            productWeightBahtCtrl,
                                                                        inputFormat: [
                                                                          ThousandsFormatter(
                                                                              allowFraction: true)
                                                                        ],
                                                                        onChanged:
                                                                            (String
                                                                                value) {
                                                                          if (productWeightBahtCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            productWeightCtrl.text =
                                                                                formatter.format((Global.toNumber(productWeightBahtCtrl.text) * 15.16).toPrecision(2));
                                                                          } else {
                                                                            productWeightCtrl.text =
                                                                                "";
                                                                          }
                                                                          if (productWeightCtrl
                                                                              .text
                                                                              .isNotEmpty) {
                                                                            // productPriceCtrl.text =
                                                                            //     Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
                                                                            productPriceBaseCtrl.text =
                                                                                Global.getBuyPrice(Global.toNumber(productWeightCtrl.text)).toString();
                                                                            setState(() {});
                                                                          } else {
                                                                            productPriceCtrl.text =
                                                                                "";
                                                                            productPriceBaseCtrl.text =
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
                                                        SizedBox(
                                                          height: 100,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 5,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child:
                                                                      buildTextFieldBig(
                                                                    labelText:
                                                                        "ราคาซื้อ (ฐานภาษี)",
                                                                    enabled:
                                                                        false,
                                                                    textColor:
                                                                        Colors
                                                                            .black38,
                                                                    inputFormat: [
                                                                      ThousandsFormatter(
                                                                          allowFraction:
                                                                              true)
                                                                    ],
                                                                    controller:
                                                                        productPriceBaseCtrl,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Expanded(
                                                                flex: 5,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: buildTextFieldBig(
                                                                      labelText:
                                                                          "ราคาซื้อ",
                                                                      inputType:
                                                                          TextInputType
                                                                              .number,
                                                                      textColor:
                                                                          Colors
                                                                              .orange,
                                                                      controller:
                                                                          productPriceCtrl,
                                                                      inputFormat: [
                                                                        ThousandsFormatter(
                                                                            allowFraction:
                                                                                true)
                                                                      ],
                                                                      enabled:
                                                                          true),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),

                                                        SizedBox(
                                                          height: 100,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                flex: 5,
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
                                                                      emptyListMessage: 'ไม่มีข้อมูล',
                                                                      showSelectedItemBackgroundColor:
                                                                      true,
                                                                      itemWidgetBuilder:
                                                                          (
                                                                          int index,
                                                                          WarehouseModel?
                                                                          project, {
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
                                                                          size.getWidthPx(6),
                                                                        );
                                                                      },
                                                                      onChanged:
                                                                          (WarehouseModel
                                                                      value) {
                                                                        warehouseCtrl.text = value
                                                                            .id!
                                                                            .toString();
                                                                        selectedWarehouse =
                                                                            value;
                                                                        warehouseNotifier!.value =
                                                                            value;
                                                                      },
                                                                      child:
                                                                      DropDownObjectChildWidget(
                                                                        key:
                                                                        GlobalKey(),
                                                                        fontSize:
                                                                        size.getWidthPx(6),
                                                                        projectValueNotifier:
                                                                        warehouseNotifier!,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .all(8.0),
                                                          child: OutlinedButton(
                                                            child: const Text(
                                                                "เพิ่ม"),
                                                            onPressed: () {
                                                              if (productCodeCtrl
                                                                  .text
                                                                  .isEmpty) {
                                                                Alert.warning(
                                                                    context,
                                                                    'คำเตือน',
                                                                    'กรุณาเลือกสินค้า',
                                                                    'OK');
                                                                return;
                                                              }

                                                              if (productWeightBahtCtrl
                                                                  .text
                                                                  .isEmpty) {
                                                                Alert.warning(
                                                                    context,
                                                                    'คำเตือน',
                                                                    'กรุณาใส่น้ำหนัก',
                                                                    'OK');
                                                                return;
                                                              }

                                                              if (productPriceCtrl
                                                                  .text
                                                                  .isEmpty) {
                                                                Alert.warning(
                                                                    context,
                                                                    'คำเตือน',
                                                                    'กรุณากรอกราคา',
                                                                    'OK');
                                                                return;
                                                              }

                                                              if (selectedWarehouse == null) {
                                                                Alert.warning(
                                                                    context,
                                                                    'คำเตือน',
                                                                    'กรุณาเลือกคลังสินค้า',
                                                                    'OK');
                                                                return;
                                                              }

                                                              var realPrice = Global.toNumber(productPriceBaseCtrl.text);
                                                              var price = Global
                                                                  .toNumber(
                                                                  productPriceCtrl
                                                                      .text);
                                                              var check =
                                                                  price -
                                                                      realPrice;

                                                              if (check >
                                                                  10000) {
                                                                Alert.warning(
                                                                    context,
                                                                    'คำเตือน',
                                                                    'ราคาที่ป้อนสูงกว่าราคาตลาด ${Global.format(check)}',
                                                                    'OK');

                                                                return;
                                                              }

                                                              if (check <
                                                                  -10000) {
                                                                Alert.warning(
                                                                    context,
                                                                    'คำเตือน',
                                                                    'ราคาที่ป้อนน้อยกว่าราคาตลาด ${Global.format(check)}',
                                                                    'OK');

                                                                return;
                                                              }

                                                              Global
                                                                  .buyOrderDetail!
                                                                  .add(
                                                                OrderDetailModel(
                                                                  productName:
                                                                  productNameCtrl
                                                                      .text,
                                                                  binLocationId: selectedWarehouse!.id,
                                                                  productId: selectedProduct!.id,
                                                                  weight: Global
                                                                      .toNumber(
                                                                      productWeightCtrl
                                                                          .text),
                                                                  weightBath: Global
                                                                      .toNumber(
                                                                      productWeightBahtCtrl
                                                                          .text),
                                                                  commission: 0,
                                                                  taxBase: 0,
                                                                  priceIncludeTax: productWeightCtrl
                                                                      .text
                                                                      .isEmpty
                                                                      ? 0
                                                                      : Global.toNumber(
                                                                      productPriceCtrl
                                                                          .text),
                                                                ),
                                                              );
                                                              sumBuyTotal();
                                                              setState(() {});
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                            },
                                                          ),
                                                        ),
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
                            // flex: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: bgColor2,
                              ),
                              child: ListView.builder(
                                  itemCount: Global.buyOrderDetail!.length,
                                  itemBuilder: (context, index) {
                                    return _itemOrderList(
                                        order: Global.buyOrderDetail![index],
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
                                      "${formatter.format(Global.buySubTotal)} บาท",
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
                                          if (Global.buyOrderDetail!.isEmpty) {
                                            return;
                                          }

                                          final ProgressDialog pr = ProgressDialog(context,
                                              type: ProgressDialogType.normal,
                                              isDismissible: true,
                                              showLogs: true);
                                          await pr.show();
                                          pr.update(message: 'processing'.tr());
                                          try {
                                            var result = await ApiServices.post('/order/gen/2', Global.requestObj(null));
                                            await pr.hide();
                                            if (result!.status == "success") {
                                              OrderModel order = OrderModel(
                                                  orderId: result.data,
                                                  orderDate: DateTime.now().toUtc(),
                                                  details: Global.buyOrderDetail!,
                                                  orderTypeId: 2);
                                              final data = order.toJson();
                                              Global.orders
                                                  ?.add(OrderModel.fromJson(data));
                                              widget.refreshCart(
                                                  Global.orders?.length.toString());
                                              Global.buyOrderDetail!.clear();
                                              setState(() {
                                                Global.buySubTotal = 0;
                                                Global.buyTax = 0;
                                                Global.buyTotal = 0;
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
                                                      backgroundColor: Colors
                                                          .teal,
                                                    ));
                                              }
                                            } else {
                                              if (mounted) {
                                                Alert.warning(
                                                    context, 'Warning'.tr(), 'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน', 'OK'.tr(),
                                                    action: () {});
                                              }
                                            }

                                          } catch (e) {
                                            await pr.hide();
                                            if (mounted) {
                                              Alert.warning(
                                                  context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
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
                                                  fontSize: size.getWidthPx(8)),
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
                                          if (Global.buyOrderDetail!.isEmpty) {
                                            return;
                                          }

                                          OrderModel order = OrderModel(
                                              orderId: "",
                                              orderDate: DateTime.now().toUtc(),
                                              details: Global.buyOrderDetail!,
                                              orderTypeId: 2);

                                          final data = order.toJson();
                                          Global.holdOrder(
                                              OrderModel.fromJson(data));
                                          Future.delayed(
                                              const Duration(milliseconds: 500),
                                                  () async {
                                                String holds =
                                                (await Global.getHoldList())
                                                    .length
                                                    .toString();
                                                widget.refreshHold(holds);
                                                setState(() {});
                                              });

                                          Global.buyOrderDetail!.clear();
                                          setState(() {
                                            Global.buySubTotal = 0;
                                            Global.buyTax = 0;
                                            Global.buyTotal = 0;
                                          });
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "ระงับการสั่งซื้อสำเร็จ...",
                                                    style: TextStyle(
                                                        fontSize: 22),
                                                  ),
                                                  backgroundColor: Colors
                                                      .teal,
                                                ));
                                          }


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
                                                  fontSize: size.getWidthPx(8)),
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
                                          if (Global.buyOrderDetail!.isEmpty) {
                                            return;
                                          }

                                          final ProgressDialog pr = ProgressDialog(context,
                                              type: ProgressDialogType.normal,
                                              isDismissible: true,
                                              showLogs: true);
                                          await pr.show();
                                          pr.update(message: 'processing'.tr());
                                          try {
                                            var result = await ApiServices.post('/order/gen/2', Global.requestObj(null));
                                            await pr.hide();
                                            if (result!.status == "success") {
                                              OrderModel order = OrderModel(
                                                  orderId: result.data,
                                                  orderDate: DateTime.now().toUtc(),
                                                  details: Global.buyOrderDetail!,
                                                  orderTypeId: 2);
                                              final data = order.toJson();
                                              Global.orders
                                                  ?.add(OrderModel.fromJson(data));
                                              widget.refreshCart(
                                                  Global.orders?.length.toString());
                                              Global.buyOrderDetail!.clear();
                                              setState(() {
                                                Global.buySubTotal = 0;
                                                Global.buyTax = 0;
                                                Global.buyTotal = 0;
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
                                                        widget.refreshHold(
                                                            holds);
                                                        widget.refreshCart(
                                                            Global
                                                                .orders?.length
                                                                .toString());
                                                        setState(() {});
                                                      });
                                                });
                                              }
                                            } else {
                                              if (mounted) {
                                                Alert.warning(
                                                    context, 'Warning'.tr(), 'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน', 'OK'.tr(),
                                                    action: () {});
                                              }
                                            }

                                          } catch (e) {
                                            await pr.hide();
                                            if (mounted) {
                                              Alert.warning(
                                                  context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
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
                                                  fontSize: size.getWidthPx(8)),
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
                    )),
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
    productPriceCtrl.text = "";
    productPriceBaseCtrl.text = "";
    productWeightBahtCtrl.text = "";
    warehouseCtrl.text = "";
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }

  removeProduct(index) {
    Global.buyOrderDetail!.removeAt(index);
    if (Global.buyOrderDetail!.isEmpty) {
      Global.buyOrderDetail!.clear();
    }
    sumBuyTotal();
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
              leftValue: formatter.format(order.priceIncludeTax!),
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
