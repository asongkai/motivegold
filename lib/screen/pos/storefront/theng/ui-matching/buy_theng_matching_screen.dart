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
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/dialog/buy_matching_dialog.dart';
import 'package:motivegold/screen/pos/storefront/theng/dialog/edit_buy_matching_dialog.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

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
  TextEditingController bookDate = TextEditingController();
  TextEditingController unitPriceCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();
  TextEditingController bookDateCtrl = TextEditingController();

  final controller = BoardDateTimeController();

  DateTime date = DateTime.now();
  late Screen size;

  @override
  void initState() {
    // implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumBuyThengTotalMatching();
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
    bookDate.dispose();
    unitPriceCtrl.dispose();
    warehouseCtrl.dispose();
    bookDateCtrl.dispose();
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
            selectedProduct = productList.first;
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
          '/binlocation/all/matching', Global.requestObj(null));
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
    size = Screen(MediaQuery.of(context).size);
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
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const BuyMatchingDialog(),
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
                                        Global.buyThengOrderDetailMatching!.length,
                                    itemBuilder: (context, index) {
                                      return _itemOrderList(
                                          order: Global
                                              .buyThengOrderDetailMatching![index],
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
                                                .buyThengOrderDetailMatching!.isEmpty) {
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
                                                        DateTime.now(),
                                                    details: Global
                                                        .buyThengOrderDetailMatching!,
                                                    orderTypeId: 33);
                                                final data = order.toJson();
                                                Global.ordersThengMatching?.add(
                                                    OrderModel.fromJson(data));
                                                widget.refreshCart(Global
                                                    .ordersThengMatching?.length
                                                    .toString());
                                                writeCart();
                                                Global.buyThengOrderDetailMatching!
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
                                                .buyThengOrderDetailMatching!.isEmpty) {
                                              return;
                                            }

                                            OrderModel order = OrderModel(
                                                orderId: "",
                                                orderDate:
                                                    DateTime.now(),
                                                details:
                                                    Global.buyThengOrderDetailMatching!,
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

                                            Global.buyThengOrderDetailMatching!.clear();
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
                                                .buyThengOrderDetailMatching!.isEmpty) {
                                              return;
                                            }
                                            Alert.info(
                                                context,
                                                'ต้องการบันทึกข้อมูลหรือไม่?',
                                                '',
                                                'ตกลง', action: () async {
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
                                                //         '/order/gen/33',
                                                //         Global.requestObj(
                                                //             null));
                                                // await pr.hide();
                                                // if (result!.status ==
                                                //     "success") {
                                                OrderModel order = OrderModel(
                                                    orderId: "",
                                                    orderDate:
                                                        DateTime.now(),
                                                    details: Global
                                                        .buyThengOrderDetailMatching!,
                                                    orderTypeId: 33);
                                                final data = order.toJson();
                                                Global.ordersThengMatching?.add(
                                                    OrderModel.fromJson(data));
                                                widget.refreshCart(Global
                                                    .ordersThengMatching?.length
                                                    .toString());
                                                writeCart();
                                                Global.buyThengOrderDetailMatching!
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
                                            });
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

  void unitChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty &&
        unitPriceCtrl.text.isNotEmpty) {
      productPriceCtrl.text = Global.format(
          Global.toNumber(unitPriceCtrl.text) *
              Global.toNumber(productWeightBahtCtrl.text));
    } else {
      productPriceCtrl.text = "";
    }
  }

  void bahtChanged() {
    if (productWeightBahtCtrl.text.isNotEmpty) {
      productWeightCtrl.text =
          Global.format(Global.toNumber(productWeightBahtCtrl.text) * getUnitWeightValue());
      // unitPriceCtrl.text = Global.format(Global.getSellThengPrice(getUnitWeightValue()));
      if (unitPriceCtrl.text.isNotEmpty) {
        productPriceCtrl.text = Global.format(
            Global.toNumber(unitPriceCtrl.text) *
                Global.toNumber(productWeightBahtCtrl.text));
      }
    } else {
      productWeightCtrl.text = "";
      unitPriceCtrl.text = "";
      productPriceCtrl.text = "";
    }
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productCommissionCtrl.text = "";
    productPriceCtrl.text = "";
    productWeightBahtCtrl.text = "";
    bookDate.text = "";
    productWeightRemainCtrl.text = "";
    productWeightBahtRemainCtrl.text = "";
    unitPriceCtrl.text = "";
    warehouseCtrl.text = "";
    productNotifier = ValueNotifier<ProductModel>(
        selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    productCodeCtrl.text =
        (selectedProduct != null ? selectedProduct?.productCode! : "")!;
    productNameCtrl.text =
        (selectedProduct != null ? selectedProduct?.name : "")!;
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        selectedWarehouse ?? WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    bookDateCtrl.text = Global.formatDateD(DateTime.now().toString());
  }

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.buyThengOrderDetailMatching!.removeAt(index);
      if (Global.buyThengOrderDetailMatching!.isEmpty) {
        Global.buyThengOrderDetailMatching!.clear();
      }
      sumBuyThengTotalMatching();
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
                leftValue: Global.format(order.priceIncludeTax!),
                rightTitle: 'น้ำหนัก',
                rightValue: '${Global.format(order.weight! / getUnitWeightValue())} บาท',
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EditBuyMatchingDialog(index: index,),
                              fullscreenDialog: true))
                          .whenComplete(() {
                        setState(() {});
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.blue[700],
                          borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          Text(
                            'แก้ไข',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      removeProduct(index);
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          Text(
                            'ลบ',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          )
                        ],
                      ),
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

}
