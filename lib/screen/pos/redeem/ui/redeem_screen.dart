import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masked_text/masked_text.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/screen/gold/gold_mini_widget.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/redeem/dialog/edit_redeem_item_dialog.dart';
import 'package:motivegold/screen/pos/redeem/redeem_check_screen.dart';
import 'package:motivegold/screen/pos/redeem/dialog/add_redeem_item_dialog.dart';
import 'package:motivegold/utils/calculator/manager.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/product.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';

class RedeemScreen extends StatefulWidget {
  final Function(dynamic value) refreshCart;
  int cartCount;

  RedeemScreen({super.key, required this.refreshCart, required this.cartCount});

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

  TextEditingController weightGramCtrl = TextEditingController();
  TextEditingController weightBahtCtrl = TextEditingController();
  TextEditingController referenceNumberCtrl = TextEditingController();
  TextEditingController redeemValueCtrl = TextEditingController();
  TextEditingController depositAmountCtrl = TextEditingController();
  TextEditingController benefitReceiveCtrl = TextEditingController();
  TextEditingController orderDateCtrl = TextEditingController();

  final boardCtrl = BoardDateTimeController();

  double lineAmount = 0;
  double totalAmount = 0;

  DateTime date = DateTime.now();
  String? txt;

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
  String? vatOption = 'Include';

  @override
  void initState() {
    super.initState();
    orderDateCtrl.text = Global.formatDateD(DateTime.now().toString());
    getRedeemCart();
    calTotal();
  }

  @override
  void dispose() {
    super.dispose();
    orderDateCtrl.dispose();
    weightGramCtrl.dispose();
    weightBahtCtrl.dispose();
    referenceNumberCtrl.dispose();
    redeemValueCtrl.dispose();
    depositAmountCtrl.dispose();
    benefitReceiveCtrl.dispose();
    depositAmountFocus.dispose();
    gramFocus.dispose();
    redemptionValueFocus.dispose();
    benefitReceiveFocus.dispose();
    priceDiffFocus.dispose();
    taxAmountFocus.dispose();
  }

  void openCal() {
    if (txt == 'purchase') {
      benefitReceiveReadOnly = true;
    }
    if (txt == 'gram') {
      gramReadOnly = true;
    }
    if (txt == 'price_include') {
      depositAmountReadOnly = true;
    }
    if (txt == 'price_exclude') {
      redemptionValueReadOnly = true;
    }
    if (txt == 'price_diff') {
      priceDiffReadOnly = true;
    }
    if (txt == 'tax_amount') {
      taxAmountReadOnly = true;
    }
    AppCalculatorManager.showCalculator(
      inputTarget: txt,
      onClose: closeCal,
      onChanged: (key, value, expression) {
        if (key == 'ENT') {
          FocusScope.of(context).requestFocus(FocusNode());
          closeCal();
        }
        print('Calculator: $key, $value, $expression');
      },
    );
    setState(() {});
  }

  void closeCal() {
    benefitReceiveReadOnly = false;
    gramReadOnly = false;
    depositAmountReadOnly = false;
    redemptionValueReadOnly = false;
    priceDiffReadOnly = false;
    taxAmountReadOnly = false;
    AppCalculatorManager.hideCalculator();
    setState(() {});
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
          style: TextStyle(
            fontSize: 16.sp, //16.sp,
            color: textWhite,
          ),
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
                  style: TextStyle(fontSize: 16.sp, color: textWhite),
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
            : GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  closeCal();
                },
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: stmBgColorLight,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const Padding(
                        //   padding: EdgeInsets.only(left: 10, right: 10),
                        //   child: GoldMiniWidget(),
                        // ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        vatOption = 'Include';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: vatOption == 'Include'
                                            ? Colors.teal
                                            : Colors.transparent,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          bottomLeft: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: vatOption == 'Include'
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: vatOption == 'Include'
                                                    ? Colors.white
                                                    : Colors.grey[400]!,
                                                width: 2,
                                              ),
                                            ),
                                            child: vatOption == 'Include'
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.teal,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Include VAT',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: vatOption == 'Include'
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 56,
                                  color: Colors.grey[200],
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        vatOption = 'Exclude';
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 20),
                                      decoration: BoxDecoration(
                                        color: vatOption == 'Exclude'
                                            ? Colors.teal
                                            : Colors.transparent,
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: vatOption == 'Exclude'
                                                  ? Colors.white
                                                  : Colors.transparent,
                                              border: Border.all(
                                                color: vatOption == 'Exclude'
                                                    ? Colors.white
                                                    : Colors.grey[400]!,
                                                width: 2,
                                              ),
                                            ),
                                            child: vatOption == 'Exclude'
                                                ? const Icon(
                                                    Icons.check,
                                                    size: 14,
                                                    color: Colors.teal,
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Exclude VAT',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: vatOption == 'Exclude'
                                                  ? Colors.white
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'วันที่ไถ่ถอน',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 16.sp, color: textColor),
                                    ),
                                  )),
                              Expanded(
                                flex: 6,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: MaskedTextField(
                                    controller: orderDateCtrl,
                                    mask: "##-##-####",
                                    maxLength: 10,
                                    keyboardType: TextInputType.number,
                                    //editing controller of this TextField
                                    style: TextStyle(fontSize: 16.sp),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white70,
                                      hintText: 'dd-mm-yyyy',
                                      labelStyle: TextStyle(
                                          fontSize: 16.sp,
                                          color: Colors.blue[900],
                                          fontWeight: FontWeight.w900),
                                      prefixIcon: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) =>
                                                  SfDatePickerDialog(
                                                initialDate: DateTime.now(),
                                                onDateSelected: (date) {
                                                  motivePrint(
                                                      'You picked: $date');
                                                  // Your logic here
                                                  String formattedDate =
                                                      DateFormat('dd-MM-yyyy')
                                                          .format(date);
                                                  motivePrint(
                                                      formattedDate); //formatted date output using intl package =>  2021-03-16
                                                  //you can implement different kind of Date Format here according to your requirement
                                                  setState(() {
                                                    orderDateCtrl.text =
                                                        formattedDate; //set output date to TextField value.
                                                  });
                                                },
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.calendar_month_outlined,
                                            size: 40,
                                          )),
                                      //icon of text field
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 10.0),
                                      labelText: "",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          getProportionateScreenWidth(2),
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
                            ],
                          ),
                        ),
                        SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                            child: SizedBox(
                              // width: 150,
                              height: 60,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: stmBgColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (vatOption == null || vatOption == "") {
                                    Alert.warning(
                                        context,
                                        'คำเตือน',
                                        'กรุณาเลือกตัวเลือกภาษีมูลค่าเพิ่ม',
                                        'OK',
                                        action: () {});
                                    return;
                                  }

                                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddRedeemItemDialog(
                                                    vatOption: vatOption!,
                                                  ),
                                              fullscreenDialog: true))
                                      .whenComplete(() {
                                    calTotal();
                                    setState(() {});
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 14.sp),
                                    const SizedBox(width: 6),
                                    Text(
                                      'เพิ่มรายการไถ่ถอน',
                                      style: TextStyle(fontSize: 14.sp),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        _buildItemsList(),
                      ],
                    ),
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
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFB22222),
                      // Dark red border like in the image
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'จำนวนเงินรวมที่ลูกค้าต้องชำระ (บาท)',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(
                              0xFF1A237E), // Dark blue color for text
                        ),
                      ),
                      // const SizedBox(
                      //   height: 10,
                      // ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${Global.format(totalAmount)}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(
                                  0xFF1A237E), // Dark blue color for amount
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  // Expanded(
                  //   child: ElevatedButton(
                  //     style: ElevatedButton.styleFrom(
                  //       foregroundColor: Colors.white,
                  //       backgroundColor: Colors.purple[700],
                  //       padding: const EdgeInsets.symmetric(vertical: 8),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     onPressed: () async {
                  //       if (orderDateCtrl.text.isEmpty) {
                  //         Alert.warning(context, 'คำเตือน',
                  //             'กรุณาป้อนวันที่ใบกำกับภาษี', 'OK');
                  //         return;
                  //       }
                  //
                  //       if (!checkDate(orderDateCtrl.text)) {
                  //         Alert.warning(context, 'คำเตือน',
                  //             'วันที่ที่ป้อนมีรูปแบบไม่ถูกต้อง', 'OK',
                  //             action: () {});
                  //         return;
                  //       }
                  //
                  //       if (weightGramCtrl.text.isEmpty) {
                  //         Alert.warning(
                  //             context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK');
                  //         return;
                  //       }
                  //
                  //       if (depositAmountCtrl.text.isEmpty) {
                  //         Alert.warning(context, 'คำเตือน',
                  //             'กรุณากรอกมูลค่าขายฝาก', 'OK');
                  //         return;
                  //       }
                  //
                  //       if (redeemValueCtrl.text.isEmpty) {
                  //         Alert.warning(context, 'คำเตือน',
                  //             'กรุณากรอกมูลค่าสินไถ่', 'OK');
                  //         return;
                  //       }
                  //
                  //       Global.redeemSingleDetail!.add(
                  //         RedeemDetailModel.fromJson(
                  //           jsonDecode(
                  //             jsonEncode(
                  //               RedeemDetailModel(
                  //                 productId: selectedProduct?.id,
                  //                 weight: Global.toNumber(weightGramCtrl.text),
                  //                 weightBath:
                  //                     Global.toNumber(weightBahtCtrl.text),
                  //                 taxBase: Global.toNumber(
                  //                         redeemValueCtrl.text) -
                  //                     Global.toNumber(depositAmountCtrl.text),
                  //                 taxAmount:
                  //                     (Global.toNumber(redeemValueCtrl.text) -
                  //                             Global.toNumber(
                  //                                 depositAmountCtrl.text)) *
                  //                         getVatValue(),
                  //                 depositAmount:
                  //                     Global.toNumber(depositAmountCtrl.text),
                  //                 redemptionValue:
                  //                     Global.toNumber(redeemValueCtrl.text),
                  //                 redemptionVat:
                  //                     ((Global.toNumber(redeemValueCtrl.text) -
                  //                                 Global.toNumber(
                  //                                     depositAmountCtrl.text)) *
                  //                             getVatValue()) +
                  //                         Global.toNumber(redeemValueCtrl.text),
                  //                 benefitAmount: Global.toNumber(
                  //                             benefitReceiveCtrl.text) !=
                  //                         0
                  //                     ? Global.toNumber(benefitReceiveCtrl.text)
                  //                     : Global.toNumber(redeemValueCtrl.text) -
                  //                         Global.toNumber(
                  //                             depositAmountCtrl.text),
                  //                 paymentAmount: lineAmount,
                  //                 qty: 1,
                  //                 referenceNo: referenceNumberCtrl.text,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       );
                  //       setState(() {});
                  //
                  //       RedeemModel order = RedeemModel(
                  //           redeemId: '',
                  //           redeemDate: Global.convertDate(orderDateCtrl.text),
                  //           details:
                  //               Global.redeemSingleDetail!.reversed.toList(),
                  //           redeemTypeId: 1);
                  //       final data = order.toJson();
                  //       Global.redeems.add(RedeemModel.fromJson(data));
                  //       widget.refreshCart(Global.redeems.length.toString());
                  //       writeRedeemCart();
                  //       Global.redeemSingleDetail!.clear();
                  //       resetText();
                  //       setState(() {});
                  //
                  //       ScaffoldMessenger.of(context)
                  //           .showSnackBar(const SnackBar(
                  //         content: Text(
                  //           "เพิ่มลงในรถเข็นสำเร็จ...",
                  //           style: TextStyle(fontSize: 22),
                  //         ),
                  //         backgroundColor: Colors.teal,
                  //       ));
                  //     },
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       children: [
                  //         const Icon(Icons.add, size: 16),
                  //         const SizedBox(width: 6),
                  //         Text(
                  //           'เพิ่มลงในรถเข็น',
                  //           style: TextStyle(fontSize: 16.sp, color: textWhite),
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(
                  //   width: 20,
                  // ),
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

                        // if (weightGramCtrl.text.isEmpty) {
                        //   Alert.warning(
                        //       context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK');
                        //   return;
                        // }
                        //
                        // if (depositAmountCtrl.text.isEmpty) {
                        //   Alert.warning(context, 'คำเตือน',
                        //       'กรุณากรอกมูลค่าขายฝาก', 'OK');
                        //   return;
                        // }
                        //
                        // if (redeemValueCtrl.text.isEmpty) {
                        //   Alert.warning(context, 'คำเตือน',
                        //       'กรุณากรอกมูลค่าสินไถ่', 'OK');
                        //   return;
                        // }

                        // Global.redeemSingleDetail!.add(
                        //   RedeemDetailModel.fromJson(
                        //     jsonDecode(
                        //       jsonEncode(
                        //         RedeemDetailModel(
                        //           productId: selectedProduct?.id,
                        //           weight: Global.toNumber(weightGramCtrl.text),
                        //           weightBath:
                        //               Global.toNumber(weightBahtCtrl.text),
                        //           taxBase: Global.toNumber(
                        //                   redeemValueCtrl.text) -
                        //               Global.toNumber(depositAmountCtrl.text),
                        //           taxAmount:
                        //               (Global.toNumber(redeemValueCtrl.text) -
                        //                       Global.toNumber(
                        //                           depositAmountCtrl.text)) *
                        //                   getVatValue(),
                        //           depositAmount:
                        //               Global.toNumber(depositAmountCtrl.text),
                        //           redemptionValue:
                        //               Global.toNumber(redeemValueCtrl.text),
                        //           redemptionVat:
                        //               ((Global.toNumber(redeemValueCtrl.text) -
                        //                           Global.toNumber(
                        //                               depositAmountCtrl.text)) *
                        //                       getVatValue()) +
                        //                   Global.toNumber(redeemValueCtrl.text),
                        //           benefitAmount: Global.toNumber(
                        //                       benefitReceiveCtrl.text) !=
                        //                   0
                        //               ? Global.toNumber(benefitReceiveCtrl.text)
                        //               : Global.toNumber(redeemValueCtrl.text) -
                        //                   Global.toNumber(
                        //                       depositAmountCtrl.text),
                        //           paymentAmount: lineAmount,
                        //           qty: 1,
                        //           referenceNo: referenceNumberCtrl.text,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // );
                        // setState(() {});

                        RedeemModel order = RedeemModel(
                          redeemId: '',
                          redeemDate: Global.convertDate(orderDateCtrl.text),
                          details: Global.redeemSingleDetail!.reversed.toList(),
                          redeemTypeId: 1,
                          vatOption: vatOption,
                        );
                        final data = order.toJson();
                        Global.redeems.add(RedeemModel.fromJson(data));
                        widget.refreshCart(Global.redeems.length.toString());
                        writeRedeemCart();
                        Global.redeemSingleDetail!.clear();
                        resetText();
                        if (mounted) {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RedeemCheckOutScreen()))
                              .whenComplete(() {
                            Future.delayed(const Duration(milliseconds: 500),
                                () async {
                              widget.refreshCart(
                                  Global.redeems.length.toString());
                              writeRedeemCart();
                              setState(() {});
                            });
                          });
                        }
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
                            'เพิ่มลงรถเข็น/ชำระเงิน',
                            style: TextStyle(fontSize: 16.sp, color: textWhite),
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

  Widget _buildItemsList() {
    if (Global.redeemSingleDetail == null ||
        Global.redeemSingleDetail!.isEmpty) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่มีรายการไถ่ถอน',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'กดปุ่ม "เพิ่ม" เพื่อเริ่มเพิ่มรายการ',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'ลำดับ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'น้ำหนัก (กรัม)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'จำนวนเงิน',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'จัดการ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: Global.redeemSingleDetail!.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              return _itemOrderList(
                order: Global.redeemSingleDetail![index],
                index: index,
              );
            },
          ),
        ],
      ),
    );
  }

  void calTotal() {
    totalAmount = 0;

    if (Global.redeemSingleDetail != null &&
        Global.redeemSingleDetail!.isNotEmpty) {
      for (int i = 0; i < Global.redeemSingleDetail!.length; i++) {
        totalAmount += Global.redeemSingleDetail![i].paymentAmount ?? 0;
      }
    }

    setState(() {});
  }

  resetText() {
    vatOption = "Include";
    orderDateCtrl.text = "";
    totalAmount = 0;
    lineAmount = 0;
    setState(() {});
  }

  removeProduct(index) {
    Alert.info(context, 'ยืนยันการลบ', 'ต้องการลบรายการนี้หรือไม่?', 'ลบ',
        action: () async {
      Global.redeemSingleDetail!.removeAt(index);
      if (Global.redeemSingleDetail!.isEmpty) {
        Global.redeemSingleDetail!.clear();
      }
      calTotal();
      setState(() {});
    });
  }

  Widget _itemOrderList({required RedeemDetailModel order, required index}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[700],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order.weight!.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              Global.format(order.paymentAmount ?? 0),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Edit functionality
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditRedeemItemDialog(index: index, vatOption: order.vatOption ?? '',),
                              fullscreenDialog: true))
                          .whenComplete(() {
                        setState(() {});
                      });
                    },
                    icon: Icon(
                      Icons.edit_outlined,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => removeProduct(index),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red[600],
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
