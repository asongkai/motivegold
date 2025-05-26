
import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/redeem/redeem_check_screen.dart';
import 'package:motivegold/screen/pos/redeem/dialog/add_redeem_item_dialog.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

class RedeemScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  int cartCount;

  RedeemScreen(
      {super.key, required this.refreshCart, required this.cartCount});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  bool loading = false;
  List<ProductModel> productList = [];
  List<WarehouseModel> warehouseList = [];
  ProductModel? selectedProduct;
  ProductTypeModel? selectedProductType;
  WarehouseModel? selectedWarehouse;
  ValueNotifier<dynamic>? productNotifier;
  ValueNotifier<dynamic>? productTypeNotifier;
  ValueNotifier<dynamic>? warehouseNotifier;
  TextEditingController orderDateCtrl = TextEditingController();
  final boardCtrl = BoardDateTimeController();

  double totalAmount = 0;

  DateTime date = DateTime.now();
  String? txt;
  bool showCal = false;

  FocusNode depositAmountFocus = FocusNode();
  FocusNode gramFocus = FocusNode();
  FocusNode redemptionValueFocus = FocusNode();
  FocusNode benefitReceiveFocus = FocusNode();
  FocusNode priceDiffFocus = FocusNode();
  FocusNode taxAmountFocus = FocusNode();

  bool depositAmountReadOnly = false;
  bool gramReadOnly = false;
  bool redemptionValueReadOnly = false;
  bool benefitReceiveReadOnly = false;
  bool priceDiffReadOnly = false;
  bool taxAmountReadOnly = false;

  late Screen size;

  @override
  void initState() {
    // implement initState
    super.initState();

    // Sample data
    // orderDateCtrl.text = "01-02-2025";
    getRedeemCart();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    orderDateCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: stmBgColor,
        title: Text(
          'ธุรกรรมไถ่ถอน - ขายฝาก',
          style: TextStyle(fontSize: size.getWidthPx(10), color: textWhite),
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
                  color: textWhite,
                ),
                Text(
                  'ราคาทองคำ',
                  style:
                      TextStyle(fontSize: size.getWidthPx(6), color: textWhite),
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
            : Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: size.hp(100),
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: stmBgColorLight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: MaskedTextField(
                                          controller: orderDateCtrl,
                                          mask: "##-##-####",
                                          maxLength: 10,
                                          keyboardType: TextInputType.number,
                                          //editing controller of this TextField
                                          style: TextStyle(
                                              fontSize: size.getWidthPx(12)),
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white70,
                                            hintText: 'dd-mm-yyyy',
                                            labelStyle: TextStyle(
                                                fontSize: size.getWidthPx(12),
                                                color: Colors.blue[900],
                                                fontWeight: FontWeight.w900),
                                            prefixIcon: const Icon(
                                                Icons.calendar_today),
                                            //icon of text field
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 10.0),
                                            labelText: "วันที่ไถ่ถอน",
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                getProportionateScreenWidth(2),
                                              ),
                                              borderSide: const BorderSide(
                                                color: kGreyShade3,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
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
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width: 150,
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
                                        Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const AddRedeemItemDialog(),
                                                    fullscreenDialog: true))
                                            .whenComplete(() {
                                          setState(() {});
                                        });
                                      },
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                      color: stmBgColorLight,
                                    ),
                                    child: Column(
                                      children: [
                                        if (Global
                                            .redeemSingleDetail!.isNotEmpty)
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
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.getWidthPx(8),
                                                        color: textColor,
                                                      )),
                                                ),
                                                // Expanded(
                                                //   flex: 3,
                                                //   child: Text('รายการ',
                                                //       textAlign: TextAlign.center,
                                                //       style: TextStyle(
                                                //         fontSize:
                                                //         size.getWidthPx(8),
                                                //         color: textColor,
                                                //       )),
                                                // ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text('น้ำหนัก (กรัม)',
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.getWidthPx(8),
                                                        color: textColor,
                                                      )),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text('จำนวนเงิน',
                                                        textAlign:
                                                            TextAlign.right,
                                                        style: TextStyle(
                                                          fontSize: size
                                                              .getWidthPx(8),
                                                          color: textColor,
                                                        )),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Text('',
                                                      style: TextStyle(
                                                        fontSize:
                                                            size.getWidthPx(8),
                                                        color: textColor,
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Expanded(
                                          child: ListView.builder(
                                              itemCount: Global
                                                  .redeemSingleDetail!.length,
                                              itemBuilder: (context, index) {
                                                return _itemOrderList(
                                                    order: Global
                                                            .redeemSingleDetail![
                                                        index],
                                                    index: index);
                                              }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 5),
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
                                                fontSize: size.getWidthPx(8),
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue[900]),
                                          ),
                                          Text(
                                            "${Global.format(Global.getRedeemTotalPayment(Global.redeemSingleDetail ?? []))} บาท",
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
                        backgroundColor: Colors.purple[700],
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (orderDateCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณาป้อนวันที่ใบกำกับภาษี', 'OK');
                          return;
                        }

                        if (!checkDate(orderDateCtrl.text)) {
                          Alert.warning(context, 'คำเตือน',
                              'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK',
                              action: () {});
                          return;
                        }

                        RedeemModel order = RedeemModel(
                            redeemId: '',
                            redeemDate: Global.convertDate(orderDateCtrl.text),
                            details:
                            Global.redeemSingleDetail!,
                            redeemTypeId: 1);
                        final data = order.toJson();
                        Global.redeems.add(
                            RedeemModel.fromJson(data));
                        widget.refreshCart(Global
                            .redeems.length
                            .toString());
                        writeRedeemCart();
                        Global.redeemSingleDetail!.clear();
                        setState(() {

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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'เพิ่มลงในรถเข็น',
                            style: TextStyle(
                                fontSize: size.getWidthPx(8), color: textWhite),
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
                        Global.redeemSingleDetail?.clear();
                        orderDateCtrl.text = "";
                        setState(() {});
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
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        if (orderDateCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณาป้อนวันที่ใบกำกับภาษี', 'OK');
                          return;
                        }

                        if (!checkDate(orderDateCtrl.text)) {
                          Alert.warning(context, 'คำเตือน',
                              'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK',
                              action: () {});
                          return;
                        }
                        
                        RedeemModel order = RedeemModel(
                            redeemId: '',
                            redeemDate: Global.convertDate(orderDateCtrl.text),
                            details:
                            Global.redeemSingleDetail!,
                            redeemTypeId: 1);
                        final data = order.toJson();
                        Global.redeems.add(
                            RedeemModel.fromJson(data));
                        widget.refreshCart(Global
                            .redeems.length
                            .toString());
                        writeRedeemCart();
                        Global.redeemSingleDetail!.clear();

                        if (mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const RedeemCheckOutScreen()))
                              .whenComplete(() {
                            Future.delayed(
                                const Duration(
                                    milliseconds: 500),
                                    () async {
                                  widget.refreshCart(Global
                                      .ordersPapun?.length
                                      .toString());
                                  writeCart();
                                  setState(() {});
                                });
                          });
                        }

                        // Alert.info(
                        //     context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                        //     action: () async {
                        //   try {
                        //     if (mounted) {
                        //
                        //     }
                        //   } catch (e) {
                        //     if (mounted) {
                        //       Alert.warning(context, 'Warning'.tr(),
                        //           e.toString(), 'OK'.tr(),
                        //           action: () {});
                        //     }
                        //   }
                        // });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.arrow_forward,
                            color: textWhite,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'เช็คเอาท์',
                            style: TextStyle(
                                fontSize: size.getWidthPx(8), color: textWhite),
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

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      Global.redeemSingleDetail!.removeAt(index);
      if (Global.redeemSingleDetail!.isEmpty) {
        Global.redeemSingleDetail!.clear();
      }
      setState(() {});
    });
  }

  Widget _itemOrderList({required RedeemDetailModel order, required index}) {
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
                    fontSize: size.getWidthPx(8),
                    color: textColor,
                  )),
            ),
            // Expanded(
            //   flex: 3,
            //   child: Text(Global.format(order.weight),
            //       textAlign: TextAlign.center,
            //       style: TextStyle(
            //         fontSize: size.getWidthPx(8),
            //         color: textColor,
            //       )),
            // ),
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
                child: Text(Global.format(order.paymentAmount ?? 0),
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
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             EditSaleDialog(index: index),
                        //         fullscreenDialog: true))
                        //     .whenComplete(() {
                        //   setState(() {});
                        // });
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
                        // removeProduct(index);
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
