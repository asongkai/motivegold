import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/storefront/checkout_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/buy_dialog.dart';
import 'package:motivegold/screen/pos/storefront/paphun/dialog/edit_buy_dialog.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/ui/text_header.dart';

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

  late Screen size;

  @override
  void initState() {
    // implement initState
    super.initState();
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
    sumBuyTotal();
    // loadProducts();
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
    productPriceCtrl.dispose();
    productPriceBaseCtrl.dispose();
    warehouseCtrl.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
      Global.appBarColor = buBgColor;
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

      var warehouse =
          await ApiServices.post('/binlocation/all', Global.requestObj(null));
      if (warehouse?.status == "success") {
        var data = jsonEncode(warehouse?.data);
        List<WarehouseModel> warehouses = warehouseListModelFromJson(data);
        setState(() {
          warehouseList = warehouses;
          selectedWarehouse = warehouseList.first;
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

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: buBgColor,
        centerTitle: true,
        title: titleText(context, 'รับซื้อทองคำเก่า'),
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
                        color: buBgColorLight,
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
                                backgroundColor: buBgColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
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
                                color: buBgColorLight,
                              ),
                              child: Column(
                                children: [
                                  if (Global.buyOrderDetail!.isNotEmpty)
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
                                                  fontSize: size.getWidthPx(8),
                                                  color: textColor,
                                                )),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text('รายการ',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: size.getWidthPx(8),
                                                  color: textColor,
                                                )),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text('น้ำหนัก (กรัม)',
                                                textAlign: TextAlign.right,
                                                style: TextStyle(
                                                  fontSize: size.getWidthPx(8),
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
                                                    fontSize:
                                                        size.getWidthPx(8),
                                                    color: textColor,
                                                  )),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text('',
                                                style: TextStyle(
                                                  fontSize: size.getWidthPx(8),
                                                  color: textColor,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Expanded(
                                    child: ListView.builder(
                                        itemCount:
                                            Global.buyOrderDetail!.length,
                                        itemBuilder: (context, index) {
                                          return _itemOrderList(
                                              order:
                                                  Global.buyOrderDetail![index],
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
                              color: buBgColorLight,
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
                                          fontSize: size.getWidthPx(8),
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[900]),
                                    ),
                                    Text(
                                      "${formatter.format(Global.buySubTotal)} บาท",
                                      style: TextStyle(
                                          fontSize: size.getWidthPx(8),
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
                              color: buBgColorLight,
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

                                          // final ProgressDialog pr =
                                          // ProgressDialog(context,
                                          //     type:
                                          //     ProgressDialogType.normal,
                                          //     isDismissible: true,
                                          //     showLogs: true);
                                          // await pr.show();
                                          // pr.update(message: 'processing'.tr());
                                          try {
                                            // var result = await ApiServices.post(
                                            //     '/order/gen/2',
                                            //     Global.requestObj(null));
                                            // await pr.hide();
                                            // if (result!.status == "success") {
                                            OrderModel order = OrderModel(
                                                orderId: "",
                                                orderDate: DateTime.now(),
                                                details: Global.buyOrderDetail!,
                                                orderTypeId: 2);
                                            final data = order.toJson();
                                            Global.ordersPapun?.add(
                                                OrderModel.fromJson(data));
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
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                  "เพิ่มลงรถเข็นสำเร็จ...",
                                                  style:
                                                      TextStyle(fontSize: 22),
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
                                          backgroundColor: Colors.orange,
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
                                              orderDate: DateTime.now(),
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
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                "ระงับการสั่งซื้อสำเร็จ...",
                                                style: TextStyle(fontSize: 22),
                                              ),
                                              backgroundColor: Colors.teal,
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
                                          backgroundColor: buBgColor,
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
                                          // Alert.info(
                                          //     context,
                                          //     'ต้องการบันทึกข้อมูลหรือไม่?',
                                          //     '',
                                          //     'ตกลง', action: () async {
                                          // final ProgressDialog pr =
                                          // ProgressDialog(context,
                                          //     type: ProgressDialogType
                                          //         .normal,
                                          //     isDismissible: true,
                                          //     showLogs: true);
                                          // await pr.show();
                                          // pr.update(
                                          //     message: 'processing'.tr());
                                          try {
                                            // var result =
                                            // await ApiServices.post(
                                            //     '/order/gen/2',
                                            //     Global.requestObj(null));
                                            // await pr.hide();
                                            // if (result!.status == "success") {
                                            OrderModel order = OrderModel(
                                                orderId: "",
                                                orderDate: DateTime.now(),
                                                details: Global.buyOrderDetail!,
                                                orderTypeId: 2);
                                            final data = order.toJson();
                                            Global.ordersPapun?.add(
                                                OrderModel.fromJson(data));
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
                                                  String holds = (await Global
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
                                          // });
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

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.buyOrderDetail!.removeAt(index);
      if (Global.buyOrderDetail!.isEmpty) {
        Global.buyOrderDetail!.clear();
      }
      sumBuyTotal();
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
            flex: 1,
            child: Text('${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.getWidthPx(8),
                  color: textColor,
                )),
          ),
          Expanded(
            flex: 3,
            child: Text(order.productName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size.getWidthPx(8),
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
                    fontSize: size.getWidthPx(8),
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
                    fontSize: size.getWidthPx(8),
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
                                      EditBuyDialog(index: index),
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
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
