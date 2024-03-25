import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/checkout_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/product_code_autocomplete.dart';
import 'package:motivegold/widget/product_list_tile.dart';

import '../../model/order_detail.dart';

class POSBuyScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  final Function(dynamic value) refreshHold;
  const POSBuyScreen({super.key, required this.refreshCart, required this.refreshHold});

  @override
  State<POSBuyScreen> createState() => _POSBuyScreenState();
}

class _POSBuyScreenState extends State<POSBuyScreen> {
  List<int> productList = [];
  OrderDetailModel? selectedProduct;
  ProductTypeModel? selectedProductType;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productPriceCtrl = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sumBuyTotal();
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
          'รับซื้อทองเก่า', style: TextStyle(fontSize: 32),
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
              child: const Icon(Icons.price_change_outlined)),
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
          child: Row(
            children: [
              Expanded(
                  flex: 10,
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
                                                    .requestFocus(FocusNode());
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
                                                                    ProductCodeAutocompleteTextField(
                                                                  items:
                                                                      products(),
                                                                  decoration: const InputDecoration(
                                                                      labelText:
                                                                          'รหัสสินค้า',
                                                                      labelStyle: TextStyle(
                                                                          fontSize:
                                                                              32),
                                                                      border:
                                                                          OutlineInputBorder()),
                                                                  validator:
                                                                      (val) {
                                                                    if (products()
                                                                        .contains(
                                                                            val)) {
                                                                      return null;
                                                                    } else {
                                                                      return 'Invalid รหัสสินค้า';
                                                                    }
                                                                  },
                                                                  onItemSelect:
                                                                      (selected) {
                                                                    setState(
                                                                        () {
                                                                      productCodeCtrl
                                                                              .text =
                                                                          selected
                                                                              .productCode
                                                                              .toString();
                                                                      productNameCtrl
                                                                              .text =
                                                                          selected
                                                                              .productName;
                                                                    });
                                                                  },
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
                                                              "ชื่อผลิตภัณฑ์",
                                                          textColor:
                                                              Colors.orange,
                                                          controller:
                                                              productNameCtrl,
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
                                                                    "น้ำหนัก (gram)",
                                                                inputType:
                                                                    TextInputType
                                                                        .number,
                                                                textColor: Colors
                                                                    .orange,
                                                                controller:
                                                                    productWeightCtrl,
                                                                onChanged:
                                                                    (String
                                                                        value) {
                                                                  productWeightCtrl
                                                                          .text =
                                                                      value;
                                                                  if (productWeightCtrl
                                                                          .text
                                                                          .isNotEmpty) {
                                                                    productPriceCtrl
                                                                        .text = Global.getBuyPrice(
                                                                            double.parse(productWeightCtrl.text))
                                                                        .toString();
                                                                    setState(
                                                                        () {});
                                                                  }
                                                                }),
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
                                                                      "ราคาซื้อ",
                                                                  enabled:
                                                                      false,
                                                                  textColor:
                                                                      Colors
                                                                          .orange,
                                                                  controller:
                                                                      productPriceCtrl,
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 10,
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
                                                            Global.buyOrderDetail!.add(
                                                              OrderDetailModel(
                                                                productName:
                                                                    productNameCtrl
                                                                        .text,
                                                                productCode:
                                                                    productCodeCtrl
                                                                        .text,
                                                                weight:
                                                                    productWeightCtrl
                                                                        .text,
                                                                commission: 0,
                                                                taxBase: 0,
                                                                price: productWeightCtrl
                                                                        .text
                                                                        .isEmpty
                                                                    ? 0
                                                                    : Global.getBuyPrice(
                                                                    double.parse(productWeightCtrl.text)),
                                                              ),
                                                            );
                                                            sumBuyTotal();
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
                          flex: 6,
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
                                  return _itemOrder(
                                    order: Global.buyOrderDetail![index],
                                    index: index
                                  );
                                }),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.symmetric(vertical: 10),
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
                                      'ยอดรวมย่อย',
                                      style: TextStyle(
                                          fontSize: size.getWidthPx(8),
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF636564)),
                                    ),
                                    Text(
                                      formatter.format(Global.buySubTotal),
                                      style: TextStyle(
                                          fontSize: size.getWidthPx(8),
                                          fontWeight: FontWeight.bold,
                                          color: textColor2),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ภาษี',
                                      style: TextStyle(
                                          fontSize: size.getWidthPx(8),
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF636564)),
                                    ),
                                    Text(
                                      formatter.format(Global.buyTax),
                                      style: TextStyle(
                                          fontSize: size.getWidthPx(8),
                                          fontWeight: FontWeight.bold,
                                          color: textColor2),
                                    ),
                                  ],
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  height: 2,
                                  width: double.infinity,
                                  color: textColor2,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ทั้งหมด',
                                      style: TextStyle(
                                          fontSize: size.getWidthPx(8),
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF636564)),
                                    ),
                                    Text(
                                      formatter.format(Global.buyTotal),
                                      style: TextStyle(
                                          fontSize: size.getWidthPx(8),
                                          fontWeight: FontWeight.bold,
                                          color: textColor2),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: Row(
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
                                          onPressed: () {
                                            if (Global.buyOrderDetail!.isEmpty) {
                                              return;
                                            }

                                            OrderModel order = OrderModel(
                                                orderId:
                                                generateRandomString(10),
                                                orderDate:
                                                DateTime.now().toString(),
                                                detail: Global.buyOrderDetail!,
                                                type: "buy");
                                            final data = order.toJson();
                                            Global.order?.add(OrderModel.fromJson(data));
                                            widget.refreshCart(Global
                                                .order?.length
                                                .toString());
                                            Global.buyOrderDetail!.clear();
                                            setState(() {
                                              Global.buySubTotal = 0;
                                              Global.buyTax = 0;
                                              Global.buyTotal = 0;
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                              content: Text("เพิ่มลงรถเข็นสำเร็จ...", style: TextStyle(fontSize: 22),),
                                              backgroundColor: Colors.teal,
                                            ));
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
                                                    size.getWidthPx(6)),
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
                                                orderId:
                                                generateRandomString(8),
                                                orderDate:
                                                DateTime.now().toString(),
                                                detail: Global.buyOrderDetail!,
                                                type: "buy");

                                            final data = order.toJson();
                                            Global.holdOrder(OrderModel.fromJson(data));
                                            // print(OrderModel.fromJson(data).toJson());
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds: 500), () async {
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
                                                    size.getWidthPx(6)),
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
                                          onPressed: () {
                                            if (Global.buyOrderDetail!.isEmpty) {
                                              return;
                                            }
                                            OrderModel order = OrderModel(
                                                orderId:
                                                generateRandomString(10),
                                                orderDate:
                                                DateTime.now().toString(),
                                                detail: Global.buyOrderDetail!,
                                                type: "buy");
                                            final data = order.toJson();
                                            Global.order?.add(OrderModel.fromJson(data));
                                            widget.refreshCart(Global
                                                .order?.length
                                                .toString());
                                            Global.buyOrderDetail!.clear();
                                            setState(() {
                                              Global.buySubTotal = 0;
                                              Global.buyTax = 0;
                                              Global.buyTotal = 0;
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                    const CheckOutScreen()));
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
                                                    size.getWidthPx(6)),
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
                  )),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: bgColor3.withAlpha(80),
                        ),
                        child: const GoldPriceScreen(
                          showBackButton: false,
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
    );
  }

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    productPriceCtrl.text = "";
  }

  removeProduct(index) {
    Global.buyOrderDetail!.removeAt(index);
    if (Global.buyOrderDetail!.isEmpty) {
      Global.buyOrderDetail!.clear();
    }
    sumBuyTotal();
    setState(() {});
  }

  Widget _itemOrder({
    required OrderDetailModel order,
    required index
  }) {
    return ListTile(
      title: ProductListTileData(
        leftTitle: order.productName,
        leftValue: formatter.format(order.price!),
        rightTitle: 'น้ำหนัก',
        rightValue: double.parse(order.weight!).toString(),
      ),
      trailing: GestureDetector(
        onTap: () {
          removeProduct(index);
        },
        child: Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(8)),
          child: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
