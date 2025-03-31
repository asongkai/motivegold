import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:masked_text/masked_text.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/wholesale/wholesale_checkout_screen.dart';
import 'package:motivegold/screen/pos/wholesale/refill/dialog/refill_dialog.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/model/order_detail.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class RefillGoldStockScreenOld extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  int cartCount;

  RefillGoldStockScreenOld(
      {super.key, required this.refreshCart, required this.cartCount});

  @override
  State<RefillGoldStockScreenOld> createState() => _RefillGoldStockScreenOldState();
}

class _RefillGoldStockScreenOldState extends State<RefillGoldStockScreenOld> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  ProductTypeModel? selectedProductType;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? productTypeNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;

  TextEditingController productCodeCtrl = TextEditingController();
  TextEditingController productNameCtrl = TextEditingController();
  TextEditingController productWeightCtrl = TextEditingController();
  TextEditingController productWeightBahtCtrl = TextEditingController();
  TextEditingController productSellPriceCtrl = TextEditingController();
  TextEditingController productBuyPriceCtrl = TextEditingController();
  TextEditingController warehouseCtrl = TextEditingController();

  TextEditingController referenceNumberCtrl = TextEditingController();

  TextEditingController productSellThengPriceCtrl = TextEditingController();
  TextEditingController productBuyThengPriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxCtrl = TextEditingController();
  TextEditingController priceIncludeTaxCtrl = TextEditingController();
  TextEditingController priceDiffCtrl = TextEditingController();
  TextEditingController taxBaseCtrl = TextEditingController();
  TextEditingController taxAmountCtrl = TextEditingController();
  TextEditingController purchasePriceCtrl = TextEditingController();

  TextEditingController priceExcludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceIncludeTaxTotalCtrl = TextEditingController();
  TextEditingController priceDiffTotalCtrl = TextEditingController();
  TextEditingController taxBaseTotalCtrl = TextEditingController();
  TextEditingController taxAmountTotalCtrl = TextEditingController();
  TextEditingController purchasePriceTotalCtrl = TextEditingController();

  TextEditingController orderDateCtrl = TextEditingController();
  final boardCtrl = BoardDateTimeController();

  DateTime date = DateTime.now();

  @override
  void initState() {
    // implement initState
    super.initState();

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
    // priceIncludeTaxTotalCtrl.text = "92000";

    Global.appBarColor = rfBgColor;
    productTypeNotifier = ValueNotifier<ProductTypeModel>(
        ProductTypeModel(id: 0, name: 'เลือกประเภท'));
    productNotifier =
        ValueNotifier<ProductModel>(ProductModel(name: 'เลือกสินค้า', id: 0));
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
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
    productSellPriceCtrl.dispose();
    productBuyPriceCtrl.dispose();
    warehouseCtrl.dispose();

    referenceNumberCtrl.dispose();

    productSellThengPriceCtrl.dispose();
    productBuyThengPriceCtrl.dispose();

    priceExcludeTaxCtrl.dispose();
    priceIncludeTaxCtrl.dispose();
    priceDiffCtrl.dispose();
    taxBaseCtrl.dispose();
    taxAmountCtrl.dispose();
    purchasePriceCtrl.dispose();

    priceExcludeTaxTotalCtrl.dispose();
    priceIncludeTaxTotalCtrl.dispose();
    priceDiffTotalCtrl.dispose();
    taxBaseTotalCtrl.dispose();
    taxAmountTotalCtrl.dispose();
    purchasePriceTotalCtrl.dispose();

    orderDateCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey();
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: rfBgColor,
        title: const Text(
          'เติมทอง – ซื้อทองรูปพรรณใหม่ 96.5%',
          style: TextStyle(fontSize: 30, color: textColor),
        ),
        centerTitle: true,
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
                  color: textColor,
                ),
                Text(
                  'ราคาทองคำ',
                  style:
                      TextStyle(fontSize: size.getWidthPx(6), color: textColor),
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
                  height: size.hp(110),
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: rfBgColorLight,
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
                          )),
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
                                  hintText: 'dd-mm-yyyy',
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
                                  inputFormat: [
                                    ThousandsFormatter(allowFraction: true)
                                  ],
                                  onChanged: (value) {
                                    calTotal();
                                  }
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
                            backgroundColor: rfBgColor,
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
                                            const RefillDialog(),
                                        fullscreenDialog: true))
                                .whenComplete(() {
                              calTotal();
                              setState(() {});
                            });
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 25,
                                color: textColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'เพิ่ม',
                                style:
                                    TextStyle(fontSize: 25, color: textColor),
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
                            color: rfBgColorLight,
                          ),
                          child: ListView.builder(
                              itemCount: Global.refillOrderDetail!.length,
                              itemBuilder: (context, index) {
                                return _itemOrderList(
                                    order: Global.refillOrderDetail![index],
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
            color: rfBgColorLight,
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
                        if (Global.refillOrderDetail!.isEmpty) {
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
                          //     '/order/gen/5', Global.requestObj(null));
                          // await pr.hide();
                          // if (result!.status == "success") {
                          OrderModel order = OrderModel(
                              orderId: "",
                              orderDate: Global.convertDate(orderDateCtrl.text),
                              details: Global.refillOrderDetail!,
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
                              orderTypeId: 5);
                          final data = order.toJson();
                          Global.ordersWholesale?.add(OrderModel.fromJson(data));
                          widget.refreshCart(Global.ordersWholesale?.length.toString());
                          writeCart();
                          Global.refillOrderDetail!.clear();
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
                            style: TextStyle(fontSize: size.getWidthPx(8)),
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
                          Global.refillOrderDetail = [];
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
                            style: TextStyle(fontSize: size.getWidthPx(8)),
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
                        backgroundColor: rfBgColor,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (Global.refillOrderDetail!.isEmpty) {
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
                            //     '/order/gen/5', Global.requestObj(null));
                            // await pr.hide();
                            // if (result!.status == "success") {
                            OrderModel order = OrderModel(
                                orderId: "",
                                orderDate:
                                    Global.convertDate(orderDateCtrl.text),
                                details: Global.refillOrderDetail!,
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
                                orderTypeId: 5);
                            final data = order.toJson();
                            // motivePrint(data);
                            // return;
                            Global.ordersWholesale?.add(OrderModel.fromJson(data));
                            widget
                                .refreshCart(Global.ordersWholesale?.length.toString());
                            writeCart();
                            Global.refillOrderDetail!.clear();
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
                                      Global.ordersWholesale?.length.toString());
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
                          const Icon(
                            Icons.save,
                            color: textColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'บันทึก',
                            style: TextStyle(
                                fontSize: size.getWidthPx(8), color: textColor),
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

  resetText() {
    productCodeCtrl.text = "";
    productNameCtrl.text = "";
    productWeightCtrl.text = "";
    priceIncludeTaxCtrl.text = "";
    productWeightBahtCtrl.text = "";
    selectedProduct = productList.first;
    productNotifier = ValueNotifier<ProductModel>(
        selectedProduct ?? ProductModel(name: 'เลือกสินค้า', id: 0));
    productCodeCtrl.text =
        (selectedProduct != null ? selectedProduct!.productCode : '')!;
    productNameCtrl.text = selectedProduct != null ? selectedProduct!.name : '';
    warehouseNotifier = ValueNotifier<WarehouseModel>(
        WarehouseModel(id: 0, name: 'เลือกคลังสินค้า'));
  }

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.refillOrderDetail!.removeAt(index);
      calTotal();
      if (Global.refillOrderDetail!.isEmpty) {
        Global.refillOrderDetail!.clear();
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
                rightValue: '${order.binLocationName}',
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

    priceExcludeTaxTotalCtrl.text =
        Global.format(Global.refillOrderDetail!.fold(0, (i, el) {
      return i + el.priceExcludeTax!;
    }));

    priceDiffTotalCtrl.text = Global.format(
        Global.toNumber(priceExcludeTaxTotalCtrl.text) -
            Global.toNumber(purchasePriceTotalCtrl.text));

    taxBaseTotalCtrl.text = Global.format(
        Global.toNumber(priceExcludeTaxTotalCtrl.text) -
            Global.toNumber(purchasePriceTotalCtrl.text));

    taxAmountTotalCtrl.text =
        Global.format(Global.toNumber(taxBaseTotalCtrl.text) * getVatValue());

    priceIncludeTaxTotalCtrl.text = Global.format(
        Global.toNumber(priceExcludeTaxTotalCtrl.text) +
            Global.toNumber(taxAmountTotalCtrl.text));

    if (Global.toNumber(priceExcludeTaxTotalCtrl.text) == 0) {
      priceIncludeTaxTotalCtrl.text = "";
      priceExcludeTaxTotalCtrl.text = "";
      priceDiffTotalCtrl.text = "";
      taxAmountTotalCtrl.text = "";
      taxBaseTotalCtrl.text = "";
    }
    setState(() {});
  }
}
