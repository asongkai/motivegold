import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:masked_text/masked_text.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:motivegold/screen/pos/wholesale/used/dialog/sell_used_dialog.dart';
import 'package:motivegold/utils/screen_utils.dart';

import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';

class SellUsedGoldScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final int cartCount;

  const SellUsedGoldScreen(
      {super.key, required this.refreshCart, required this.cartCount});

  @override
  State<SellUsedGoldScreen> createState() => _SellUsedGoldScreenState();
}

class _SellUsedGoldScreenState extends State<SellUsedGoldScreen> {
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
  double? _currentValue = 0;
  String? mode;
  late SimpleCalculator calc;

  @override
  void initState() {
    // implement initState
    // Sample data
    // orderDateCtrl.text = "01-02-2025";
    // referenceNumberCtrl.text = "90803535";
    // productSellThengPriceCtrl.text = "45000";
    // productBuyThengPriceCtrl.text = "44000";
    // productSellPriceCtrl.text = "45000";
    // productBuyPriceCtrl.text = "44000";
    // priceExcludeTaxTotalCtrl.text = "89000";
    // purchasePriceTotalCtrl.text = "88000";
    // priceDiffTotalCtrl.text = "2000";
    // taxBaseTotalCtrl.text = "1000";
    // taxAmountTotalCtrl.text = "500";
    // priceIncludeTaxTotalCtrl.text = "90000";

    super.initState();
    calc = SimpleCalculator(
      value: _currentValue!,
      hideExpression: false,
      hideSurroundingBorder: true,
      autofocus: true,
      onChanged: (key, value, expression) {
        if (mode == 'ts') {
          productSellThengPriceCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 'tb') {
          productBuyThengPriceCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 'ps') {
          productSellPriceCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 'pb') {
          productBuyPriceCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 'p_e_t_total') {
          priceExcludeTaxTotalCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 'p_p') {
          purchasePriceTotalCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 'p_d') {
          priceDiffTotalCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 't_b') {
          taxBaseTotalCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 't_a') {
          taxAmountTotalCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }
        if (mode == 'p_i_t_total') {
          priceIncludeTaxTotalCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }

        if (mode == 'baht') {
          productWeightBahtCtrl.text =
              value != null ? "${Global.format(value)}" : "";
          bahtChanged();
        }
        if (mode == 'gram') {
          productWeightCtrl.text =
              value != null ? "${Global.format(value)}" : "";
          gramChanged();
        }
        if (mode == 'price') {
          priceIncludeTaxCtrl.text =
              value != null ? "${Global.format(value)}" : "";
        }

        setState(() {
          _currentValue = value ?? 0;
        });
        if (kDebugMode) {
          print('$key\t$value\t$expression');
        }
      },
      onTappedDisplay: (value, details) {
        if (kDebugMode) {
          print('$value\t${details.globalPosition}');
        }
      },
      theme: const CalculatorThemeData(
          // borderColor: Colors.black,
          // borderWidth: 2,
          // displayColor: Colors.black,
          // displayStyle: TextStyle(fontSize: 80, color: Colors.yellow),
          // expressionColor: Colors.indigo,
          // expressionStyle: TextStyle(fontSize: 20, color: Colors.white),
          // operatorColor: Colors.pink,
          // operatorStyle: TextStyle(fontSize: 30, color: Colors.white),
          // commandColor: Colors.orange,
          // commandStyle: TextStyle(fontSize: 30, color: Colors.white),
          // numColor: Colors.grey,
          // numStyle: TextStyle(fontSize: 50, color: Colors.white),
          ),
    );
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
      var result =
          await ApiServices.post('/product/type/USED', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
          if (productList.isNotEmpty) {
            selectedProduct = productList.first;
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
          await ApiServices.post('/binlocation/all', Global.requestObj(null));
      // print(warehouse!.data);
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        setState(() {
          fromWarehouseList = warehouseListModelFromJson(data);
          toWarehouseList = warehouseListModelFromJson(data);
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
      productWeightBahtCtrl.text = formatter.format(
          Global.getTotalWeightByLocation(qtyLocationList) /
              getUnitWeightValue());
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

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: suBgColor,
        centerTitle: true,
        title: const Text(
          'ขายทองเก่าร้านขายส่ง',
          style: TextStyle(fontSize: 32),
        ),
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
                  Icons.money,
                  size: 50,
                ),
                Text(
                  'ราคาทองคำ',
                  style: TextStyle(fontSize: size!.getWidthPx(6)),
                )
              ],
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : SingleChildScrollView(
                child: Container(
                  height: size!.hp(110),
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: suBgColorLight,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'HEADER [ส่วนหัว]',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: MaskedTextField(
                                controller: orderDateCtrl,
                                mask: "##-##-####",
                                maxLength: 10,
                                keyboardType: TextInputType.number,
                                //editing controller of this TextField
                                style: const TextStyle(fontSize: 30),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white70,
                                  hintText: 'xx-xx-xxxx',
                                  labelStyle: TextStyle(
                                      fontSize: 25,
                                      color: Colors.blue[900],
                                      fontWeight: FontWeight.w900),
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  //icon of text field
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 10.0),
                                  labelText: "วันที่".tr(),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      getProportionateScreenWidth(8),
                                    ),
                                    borderSide: const BorderSide(
                                      color: kGreyShade3,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      getProportionateScreenWidth(2),
                                    ),
                                    borderSide: const BorderSide(
                                      color: kGreyShade3,
                                    ),
                                  ),
                                ),
                                //set it true, so that user will not able to edit text
                              ),
                            ),
                          ),
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: buildTextFieldX(
                              labelText: "เลขที่อ้างอิง",
                              inputType: TextInputType.text,
                              enabled: true,
                              controller: referenceNumberCtrl,
                            ),
                          ))
                        ],
                      ),
                      SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText: "ทองคำแท่งขายออก",
                                  inputType: TextInputType.phone,
                                  controller: productSellThengPriceCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                    labelText: "ทองคำแท่งรับซื้อ",
                                    inputType: TextInputType.number,
                                    controller: productBuyThengPriceCtrl,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    enabled: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText: "ทองรูปพรรณขายออก",
                                  inputType: TextInputType.phone,
                                  controller: productSellPriceCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                    labelText: "ทองรูปพรรณรับซื้อ",
                                    inputType: TextInputType.number,
                                    controller: productBuyPriceCtrl,
                                    inputFormat: [
                                      ThousandsFormatter(allowFraction: true)
                                    ],
                                    enabled: true),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'FOOTER [ส่วนท้าย]',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText:
                                      "ราคาสินค้า (ไม่รวมภาษีมูลค่าเพิ่ม)",
                                  inputType: TextInputType.phone,
                                  controller: priceExcludeTaxTotalCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText:
                                      "หัก ราคารับซื้อคืน (ฐานภาษียกเว้น)",
                                  inputType: TextInputType.phone,
                                  controller: purchasePriceTotalCtrl,
                                  onChanged: (value) {
                                    calTotal();
                                  },
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText: "ผลต่าง (ฐานภาษี)",
                                  inputType: TextInputType.phone,
                                  controller: priceDiffTotalCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText: "มูลค่าฐานภาษีมูลค่าเพิ่ม",
                                  inputType: TextInputType.phone,
                                  controller: taxBaseTotalCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText: "ภาษีมูลค่าเพิ่ม",
                                  inputType: TextInputType.phone,
                                  controller: taxAmountTotalCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextFieldX(
                                  labelText: "ราคาสินค้า (รวมภาษีมูลค่าเพิ่ม)",
                                  inputType: TextInputType.phone,
                                  controller: priceIncludeTaxTotalCtrl,
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: suBgColor,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            // if (purchasePriceTotalCtrl.text.isEmpty) {
                            //   Alert.warning(context, 'Warning'.tr(), 'กรุณากรอก หัก ราคารับซื้อคืน (ฐานภาษียกเว้น)', 'OK'.tr(),
                            //       action: () {});
                            //   return;
                            // }
                            Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SellUsedDialog(),
                                        fullscreenDialog: true))
                                .whenComplete(() {
                              calTotal();
                              setState(() {});
                            });
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 25),
                              SizedBox(width: 6),
                              Text(
                                'เพิ่ม',
                                style: TextStyle(fontSize: 25),
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
                            color: suBgColorLight,
                          ),
                          child: ListView.builder(
                              itemCount: Global.usedSellDetail!.length,
                              itemBuilder: (context, index) {
                                return _itemOrderList(
                                    order: Global.usedSellDetail![index],
                                    index: index);
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      persistentFooterButtons: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: suBgColorLight,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (Global.usedSellDetail!.isEmpty) {
                          return;
                        }

                        // final ProgressDialog pr = ProgressDialog(context,
                        //     type: ProgressDialogType.normal,
                        //     isDismissible: true,
                        //     showLogs: true);
                        // await pr.show();
                        // pr.update(message: 'processing'.tr());
                        try {
                          // var result = await ApiServices.post(
                          //     '/order/gen/6', Global.requestObj(null));
                          // await pr.hide();
                          // if (result!.status == "success") {
                          OrderModel order = OrderModel(
                              orderId: "",
                              orderDate: Global.convertDate(orderDateCtrl.text),
                              details: Global.usedSellDetail!,
                              referenceNo: referenceNumberCtrl.text,
                              sellTPrice: Global.toNumber(
                                  productSellThengPriceCtrl.text),
                              buyTPrice: Global.toNumber(
                                  productBuyThengPriceCtrl.text),
                              sellPrice:
                                  Global.toNumber(productSellPriceCtrl.text),
                              buyPrice:
                                  Global.toNumber(productBuyPriceCtrl.text),
                              priceIncludeTax: Global.toNumber(
                                  priceIncludeTaxTotalCtrl.text),
                              priceExcludeTax: Global.toNumber(
                                  priceExcludeTaxTotalCtrl.text),
                              purchasePrice:
                                  Global.toNumber(purchasePriceTotalCtrl.text),
                              priceDiff:
                                  Global.toNumber(priceDiffTotalCtrl.text),
                              taxBase: Global.toNumber(taxBaseTotalCtrl.text),
                              taxAmount:
                                  Global.toNumber(taxAmountTotalCtrl.text),
                              orderTypeId: 6,
                              orderStatus: 'PENDING');
                          final data = order.toJson();
                          Global.orders?.add(OrderModel.fromJson(data));
                          widget.refreshCart(Global.orders?.length.toString());
                          Global.usedSellDetail!.clear();
                          if (mounted) {
                            resetTotal();
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                "เพิ่มลงรถเข็นสำเร็จ...",
                                style: TextStyle(fontSize: 22),
                              ),
                              backgroundColor: Colors.teal,
                            ));
                          }
                          // } else {
                          //   if (mounted) {
                          //     Alert.warning(
                          //         context,
                          //         'Warning'.tr(),
                          //         'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน',
                          //         'OK'.tr(),
                          //         action: () {});
                          //   }
                          // }
                        } catch (e) {
                          // await pr.hide();
                          if (mounted) {
                            Alert.warning(context, 'Warning'.tr(), e.toString(),
                                'OK'.tr(),
                                action: () {});
                          }
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'เพิ่มลงในรถเข็น',
                            style: TextStyle(fontSize: size?.getWidthPx(8)),
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
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          Global.usedSellDetail = [];
                          resetTotal();
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.close, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'เคลียร์',
                            style: TextStyle(fontSize: size!.getWidthPx(8)),
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
                        backgroundColor: suBgColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (Global.usedSellDetail!.isEmpty) {
                          Alert.warning(
                              context, 'คำเตือน', 'กรุณาเพิ่มข้อมูลก่อน', 'OK');
                          return;
                        }
                        Alert.info(
                            context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                            action: () async {
                          // final ProgressDialog pr = ProgressDialog(context,
                          //     type: ProgressDialogType.normal,
                          //     isDismissible: true,
                          //     showLogs: true);
                          // await pr.show();
                          // pr.update(message: 'processing'.tr());
                          try {
                            // var result = await ApiServices.post(
                            //     '/order/gen/6', Global.requestObj(null));
                            // await pr.hide();
                            // if (result!.status == "success") {
                            OrderModel order = OrderModel(
                                orderId: "",
                                orderDate:
                                    Global.convertDate(orderDateCtrl.text),
                                details: Global.usedSellDetail!,
                                referenceNo: referenceNumberCtrl.text,
                                sellTPrice: Global.toNumber(
                                    productSellThengPriceCtrl.text),
                                buyTPrice: Global.toNumber(
                                    productBuyThengPriceCtrl.text),
                                sellPrice:
                                    Global.toNumber(productSellPriceCtrl.text),
                                buyPrice:
                                    Global.toNumber(productBuyPriceCtrl.text),
                                priceIncludeTax: Global.toNumber(
                                    priceIncludeTaxTotalCtrl.text),
                                priceExcludeTax: Global.toNumber(
                                    priceExcludeTaxTotalCtrl.text),
                                purchasePrice: Global.toNumber(
                                    purchasePriceTotalCtrl.text),
                                priceDiff:
                                    Global.toNumber(priceDiffTotalCtrl.text),
                                taxBase: Global.toNumber(taxBaseTotalCtrl.text),
                                taxAmount:
                                    Global.toNumber(taxAmountTotalCtrl.text),
                                orderTypeId: 6,
                                orderStatus: 'PENDING');
                            final data = order.toJson();
                            Global.orders?.add(OrderModel.fromJson(data));
                            widget
                                .refreshCart(Global.orders?.length.toString());
                            Global.usedSellDetail!.clear();
                            if (mounted) {
                              resetTotal();
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const WholeSaleCheckOutScreen()))
                                  .whenComplete(() {
                                Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () async {
                                  widget.refreshCart(
                                      Global.orders?.length.toString());
                                  setState(() {});
                                });
                              });
                            }
                            // } else {
                            //   if (mounted) {
                            //     Alert.warning(
                            //         context,
                            //         'Warning'.tr(),
                            //         'ไม่สามารถสร้างรหัสธุรกรรมได้ \nโปรดติดต่อฝ่ายสนับสนุน',
                            //         'OK'.tr(),
                            //         action: () {});
                            //   }
                            // }
                          } catch (e) {
                            // await pr.hide();
                            if (mounted) {
                              Alert.warning(context, 'Warning'.tr(),
                                  e.toString(), 'OK'.tr(),
                                  action: () {});
                            }
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.save),
                          const SizedBox(width: 6),
                          Text(
                            'บันทึก',
                            style: TextStyle(fontSize: size!.getWidthPx(8)),
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
    );
  }

  void bahtChanged() {
    if (productEntryWeightBahtCtrl.text.isNotEmpty) {
      productEntryWeightCtrl.text = Global.format(
          (Global.toNumber(productEntryWeightBahtCtrl.text) *
              getUnitWeightValue()));
    } else {
      productEntryWeightCtrl.text = "";
    }
  }

  void gramChanged() {
    if (productEntryWeightCtrl.text.isNotEmpty) {
      productEntryWeightBahtCtrl.text = Global.format(
          (Global.toNumber(productEntryWeightCtrl.text) /
              getUnitWeightValue()));
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

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.usedSellDetail!.removeAt(index);
      calTotal();
      if (Global.usedSellDetail!.isEmpty) {
        Global.usedSellDetail!.clear();
      }
      setState(() {});
    });
  }

  Widget _itemOrderList({required OrderDetailModel order, required index}) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.white,
            width: 2,
          ),
          bottom: BorderSide(
            color: Colors.white,
            width: 2,
          ),
          left: BorderSide(
            color: Colors.white,
            width: 2,
          ),
          right: BorderSide(
            color: Colors.white,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: ListTile(
              title: ListTileData(
                leftTitle: order.productName,
                leftValue: '${order.weight!.toString()} กรัม',
                rightTitle: 'คลังสินค้า',
                rightValue:
                    '${order.binLocationName} -> ${order.toBinLocationName}',
                single: null,
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
      ),
    );
  }

  void resetTotal() {
    orderDateCtrl.text = "";
    referenceNumberCtrl.text = "";
    productSellThengPriceCtrl.text = "";
    productBuyThengPriceCtrl.text = "";
    productSellPriceCtrl.text = "";
    productBuyPriceCtrl.text = "";
    priceIncludeTaxTotalCtrl.text = "";
    priceExcludeTaxTotalCtrl.text = "";
    purchasePriceTotalCtrl.text = "";
    priceDiffTotalCtrl.text = "";
    taxAmountTotalCtrl.text = "";
    taxBaseTotalCtrl.text = "";
    setState(() {});
  }

  void calTotal() {
    if (purchasePriceTotalCtrl.text.isEmpty) {
      Alert.warning(context, 'Warning'.tr(), 'กรุณากรอก หัก ราคารับซื้อคืน (ฐานภาษียกเว้น)', 'OK'.tr(),
          action: () {});
      return;
    }

    priceIncludeTaxTotalCtrl.text =
        Global.format(Global.usedSellDetail!.fold(0, (i, el) {
      return i + el.priceIncludeTax!;
    }));

    priceDiffTotalCtrl.text = Global.format(
        Global.toNumber(priceIncludeTaxTotalCtrl.text) -
            Global.toNumber(purchasePriceTotalCtrl.text));

    taxBaseTotalCtrl.text = Global.toNumber(priceDiffTotalCtrl.text) < 0 ? "0" :
        Global.format(Global.toNumber(priceDiffTotalCtrl.text) * 100 / 107);

    taxAmountTotalCtrl.text = Global.toNumber(priceDiffTotalCtrl.text) < 0 ? "0" :
        Global.format(Global.toNumber(priceDiffTotalCtrl.text) * 7 / 107);

    priceExcludeTaxTotalCtrl.text = Global.format(
        Global.toNumber(priceIncludeTaxTotalCtrl.text) -
            Global.toNumber(taxAmountTotalCtrl.text));

    if (Global.toNumber(priceIncludeTaxTotalCtrl.text) == 0) {
      priceIncludeTaxTotalCtrl.text = "";
      priceExcludeTaxTotalCtrl.text = "";
      priceDiffTotalCtrl.text = "";
      taxAmountTotalCtrl.text = "";
      taxBaseTotalCtrl.text = "";
    }
    setState(() {});
  }
}
