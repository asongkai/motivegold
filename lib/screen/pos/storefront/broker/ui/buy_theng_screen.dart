import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/storefront/broker/dialog/buy_dialog.dart';
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';

import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/extentions.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class BuyThengBrokerScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final Function(dynamic value) refreshHold;
  int cartCount;

  BuyThengBrokerScreen(
      {super.key,
      required this.refreshCart,
      required this.refreshHold,
      required this.cartCount});

  @override
  State<BuyThengBrokerScreen> createState() => _BuyThengBrokerScreenState();
}

class _BuyThengBrokerScreenState extends State<BuyThengBrokerScreen> {
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
  TextEditingController reserveDateCtrl = TextEditingController();
  TextEditingController marketPriceTotalCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  final controller = BoardDateTimeController();

  DateTime date = DateTime.now();
  double? _currentValue = 0;
  String? mode;
  late SimpleCalculator calc;

  @override
  void initState() {
    // implement initState
    super.initState();
    calc = SimpleCalculator(
      value: _currentValue!,
      hideExpression: false,
      hideSurroundingBorder: true,
      autofocus: true,
      onChanged: (key, value, expression) {
        if (mode == 'com') {
          productCommissionCtrl.text =
              value != null ? "${Global.format(value)}" : "";
          comChanged();
        }
        if (mode == 'price') {
          productPriceCtrl.text =
              value != null ? "${Global.format(value)}" : "";
          priceChanged();
        }
        if (mode == 'baht') {
          productWeightBahtCtrl.text =
              value != null ? "${Global.format(value)}" : "";
          bahtChanged();
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
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumBuyThengTotalBroker();
    loadProducts();
    getCart();
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
    productPriceCtrl.dispose();
    productPriceTotalCtrl.dispose();
    reserveDateCtrl.dispose();
    marketPriceTotalCtrl.dispose();
    warehouseCtrl.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
          await ApiServices.post('/product/type/BAR', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<ProductModel> products = productListModelFromJson(data);
        setState(() {
          productList = products;
        });
        if (productList.isNotEmpty) {
          selectedProduct = productList.first;
          productCodeCtrl.text =
              (selectedProduct != null ? selectedProduct?.productCode! : "")!;
          productNameCtrl.text =
              (selectedProduct != null ? selectedProduct?.name : "")!;
          productNotifier = ValueNotifier<ProductModel>(
              selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
        }
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
    try {
      // final ProgressDialog pr = ProgressDialog(context,
      //     type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      // await pr.show();
      // pr.update(message: 'processing'.tr());
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
      productWeightBahtRemainCtrl.text = formatter
          .format(Global.getTotalWeightByLocation(qtyLocationList) / getUnitWeightValue());
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
        backgroundColor: Colors.teal[900],
        title: const Text(
          'ซื้อทองแท่งกับโบรกเกอร์',
          style: TextStyle(fontSize: 25),
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const BuyDialog(),
                                          fullscreenDialog: true))
                                      .whenComplete(() {
                                    setState(() {});
                                  });
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
                                    itemCount:
                                        Global.buyThengOrderDetailBroker!.length,
                                    itemBuilder: (context, index) {
                                      return _itemOrderList(
                                          order: Global
                                              .buyThengOrderDetailBroker![index],
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
                                        "${Global.format(Global.buyThengSubTotalBroker)} บาท",
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
                                                .buyThengOrderDetailBroker!.isEmpty) {
                                              return;
                                            }

                                            // final ProgressDialog pr =
                                            //     ProgressDialog(context,
                                            //         type: ProgressDialogType
                                            //             .normal,
                                            //         isDismissible: true,
                                            //         showLogs: true);
                                            // await pr.show();
                                            // pr.update(
                                            //     message: 'processing'.tr());
                                            try {
                                              // var result =
                                              //     await ApiServices.post(
                                              //         '/order/gen/9',
                                              //         Global.requestObj(null));
                                              // await pr.hide();
                                              // if (result!.status == "success") {
                                                OrderModel order = OrderModel(
                                                    orderId: "",
                                                    orderDate:
                                                        DateTime.now(),
                                                    details: Global
                                                        .buyThengOrderDetailBroker!,
                                                    orderTypeId: 9);
                                                final data = order.toJson();
                                                Global.ordersBroker?.add(
                                                    OrderModel.fromJson(data));
                                                widget.refreshCart(Global
                                                    .ordersBroker?.length
                                                    .toString());
                                                writeCart();
                                                Global.buyThengOrderDetailBroker!
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
                                                .buyThengOrderDetailBroker!.isEmpty) {
                                              return;
                                            }

                                            OrderModel order = OrderModel(
                                                orderId: "",
                                                orderDate:
                                                    DateTime.now(),
                                                details:
                                                    Global.buyThengOrderDetailBroker!,
                                                orderTypeId: 9);

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

                                            Global.buyThengOrderDetailBroker!.clear();
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
                                                .buyThengOrderDetailBroker!.isEmpty) {
                                              return;
                                            }

                                            // final ProgressDialog pr =
                                            //     ProgressDialog(context,
                                            //         type: ProgressDialogType
                                            //             .normal,
                                            //         isDismissible: true,
                                            //         showLogs: true);
                                            // await pr.show();
                                            // pr.update(
                                            //     message: 'processing'.tr());
                                            try {
                                              // var result =
                                              //     await ApiServices.post(
                                              //         '/order/gen/9',
                                              //         Global.requestObj(null));
                                              // await pr.hide();
                                              // if (result!.status == "success") {
                                                OrderModel order = OrderModel(
                                                    orderId: "",
                                                    orderDate:
                                                        DateTime.now(),
                                                    details: Global
                                                        .buyThengOrderDetailBroker!,
                                                    orderTypeId: 9);
                                                final data = order.toJson();
                                                Global.ordersBroker?.add(
                                                    OrderModel.fromJson(data));
                                                widget.refreshCart(Global
                                                    .ordersBroker?.length
                                                    .toString());
                                                writeCart();
                                                Global.buyThengOrderDetailBroker!
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
                                                          .ordersPapun?.length
                                                          .toString());
                                                      writeCart();
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

  void comChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text =
          "${Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text)}";
      setState(() {});
    }
  }

  void priceChanged() {
    if (productPriceCtrl.text.isNotEmpty &&
        productCommissionCtrl.text.isNotEmpty) {
      productPriceTotalCtrl.text = formatter.format(
          (Global.toNumber(productCommissionCtrl.text) +
                  Global.toNumber(productPriceCtrl.text))
              .toPrecision(2));
      setState(() {});
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text = formatter.format(
          (Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue()));
      marketPriceTotalCtrl.text = Global.format(
          Global.getBuyThengPrice(Global.toNumber(productWeightCtrl.text)));
      productPriceCtrl.text = marketPriceTotalCtrl.text;
      productPriceTotalCtrl.text = productCommissionCtrl.text.isNotEmpty
          ? '${Global.format(Global.toNumber(productCommissionCtrl.text) + Global.toNumber(productPriceCtrl.text))}'
          : Global.format(Global.toNumber(productPriceCtrl.text)).toString();
    } else {
      productWeightCtrl.text = "";
      marketPriceTotalCtrl.text = "";
      productPriceCtrl.text = "";
      productPriceTotalCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    productPriceCtrl.text = "";
    productPriceTotalCtrl.text = "";
    productWeightBahtCtrl.text = "";
    reserveDateCtrl.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
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

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง', action: () async {
      Global.buyThengOrderDetailBroker!.removeAt(index);
      if (Global.buyThengOrderDetailBroker!.isEmpty) {
        Global.buyThengOrderDetailBroker!.clear();
      }
      sumBuyThengTotalBroker();
      setState(() {});
    });
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
              rightValue: '${Global.format(order.weight! / getUnitWeightValue())} บาท',
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
