import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/qty_location.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/edit_sell_dialog.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/sell_dialog.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/ui/text_header.dart';
import 'package:sizer/sizer.dart';

class PaphunSellScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final Function(dynamic value) refreshHold;
  int cartCount;

  PaphunSellScreen(
      {super.key,
      required this.refreshCart,
      required this.refreshHold,
      required this.cartCount});

  @override
  State<PaphunSellScreen> createState() => _PaphunSellScreenState();
}

class _PaphunSellScreenState extends State<PaphunSellScreen> {
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
  late Screen size;

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
    getCart();
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: snBgColor,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: titleText(context, 'ขายลูกค้า - ทองรูปพรรณใหม่ 96.5%'),
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
                  style: TextStyle(fontSize: 16.sp),
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
                          color: snBgColorLight,
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
                                  backgroundColor: snBgColor,
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
                                                  const SaleDialog(),
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
                                  color: snBgColorLight,
                                ),
                                child: Column(
                                  children: [
                                    if (Global.sellOrderDetail!.isNotEmpty)
                                      Container(
                                        decoration: const BoxDecoration(
                                          border: Border(
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
                                            top: BorderSide(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Text('ลำดับ',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: textColor,
                                                  )),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text('รายการ',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: textColor,
                                                  )),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text('น้ำหนัก (กรัม)',
                                                  textAlign: TextAlign.right,
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: textColor,
                                                  )),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text('จำนวนเงิน',
                                                    textAlign: TextAlign.right,
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color: textColor,
                                                    )),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text('',
                                                  style: TextStyle(
                                                    fontSize: 16.sp,
                                                    color: textColor,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    Expanded(
                                      child: ListView.builder(
                                          itemCount:
                                              Global.sellOrderDetail!.length,
                                          itemBuilder: (context, index) {
                                            return _itemOrderList(
                                                order: Global
                                                    .sellOrderDetail![index],
                                                index: index);
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: snBgColorLight,
                                border: const Border(
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
                                  top: BorderSide(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
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
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900]),
                                      ),
                                      Text(
                                        "${formatter.format(Global.sellSubTotal)} บาท",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[900]),
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
                                color: snBgColorLight,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.orange,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (Global.sellOrderDetail!.isEmpty) {
                                          return;
                                        }

                                        OrderModel order = OrderModel(
                                            orderId: "",
                                            orderDate: DateTime.now(),
                                            details: Global.sellOrderDetail!,
                                            orderTypeId: 1);

                                        final data = order.toJson();
                                        Global.holdOrder(
                                            OrderModel.fromJson(data));
                                        // print(OrderModel.fromJson(data).toJson());
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

                                        Global.sellOrderDetail!.clear();
                                        setState(() {
                                          Global.sellSubTotal = 0;
                                          Global.sellTax = 0;
                                          Global.sellTotal = 0;
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
                                            style: TextStyle(fontSize: 16.sp),
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
                                        backgroundColor: snBgColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      onPressed: () async {
                                        if (Global.sellOrderDetail!.isEmpty) {
                                          return;
                                        }

                                        try {
                                          // Sell new gold
                                          OrderModel newGold = OrderModel(
                                              orderId: '',
                                              orderDate: DateTime.now(),
                                              details: Global.sellOrderDetail!,
                                              orderTypeId: 1);
                                          final newGoldData = newGold.toJson();
                                          Global.ordersPapun?.add(
                                              OrderModel.fromJson(newGoldData));
                                          widget.refreshCart(Global
                                              .ordersPapun?.length
                                              .toString());
                                          writeCart();
                                          Global.sellOrderDetail!.clear();
                                          setState(() {
                                            Global.sellSubTotal = 0;
                                            Global.sellTax = 0;
                                            Global.sellTotal = 0;
                                          });

                                          // Buy used gold
                                          if (Global
                                              .buyOrderDetail!.isNotEmpty) {
                                            OrderModel usedGold = OrderModel(
                                                orderId: "",
                                                orderDate: DateTime.now(),
                                                details: Global.buyOrderDetail!,
                                                orderTypeId: 2);
                                            final usedGoldData =
                                                usedGold.toJson();
                                            Global.ordersPapun?.add(
                                                OrderModel.fromJson(
                                                    usedGoldData));
                                            widget.refreshCart(Global
                                                .ordersPapun?.length
                                                .toString());
                                            writeCart();
                                            Global.buyOrderDetail!.clear();
                                            setState(() {
                                              Global.buySubTotal = 0;
                                              Global.buyTax = 0;
                                              Global.buyTotal = 0;
                                            });
                                          }
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
                                                    (await Global.getHoldList())
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
                                        } catch (e) {
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
                                            'เพิ่มลงรถเข็น/ชำระเงิน',
                                            style: TextStyle(fontSize: 16.sp),
                                          )
                                        ],
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
                  ],
                ),
        ),
      ),
    );
  }

  void gramChanged() {
    if (productWeightGramCtrl.text != "") {
      productWeightBahtCtrl.text = formatter.format(
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
      productPriceTotalCtrl.text = "";
    }
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
      productPriceTotalCtrl.text = "";
    }
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

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.sellOrderDetail!.removeAt(index);
      if (Global.sellOrderDetail!.isEmpty) {
        Global.sellOrderDetail!.clear();
      }
      sumSellTotal();
      setState(() {});
    });
  }

  Widget _itemOrderList({required OrderDetailModel order, required index}) {
    return Container(
      decoration: const BoxDecoration(
        color: snBgColorLight,
        border: Border(
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text('${index + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                  )),
            ),
            Expanded(
              flex: 3,
              child: Text(order.productName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textColor,
                  )),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(order.weight!.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: textColor,
                    )),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(Global.format(order.priceIncludeTax!),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: textColor,
                    )),
              ),
            ),
            Expanded(
              flex: 4,
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditSaleDialog(index: index),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
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
      ),
    );
  }
}
