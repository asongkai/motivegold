import 'dart:convert';

import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:masked_text/masked_text.dart';
import 'package:motivegold/constants/device_type.dart';
import 'package:motivegold/model/redeem/redeem.dart';
import 'package:motivegold/model/redeem/redeem_detail.dart';
import 'package:motivegold/screen/gold/gold_mini_widget.dart';
import 'package:motivegold/screen/gold/gold_price_screen.dart';
import 'package:motivegold/screen/pos/redeem/redeem_check_screen.dart';
import 'package:motivegold/screen/pos/redeem/dialog/add_redeem_item_dialog.dart';
import 'package:motivegold/utils/calculator/calc.dart';
import 'package:motivegold/utils/cart/cart.dart';
import 'package:motivegold/utils/drag/drag_area.dart';
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
    orderDateCtrl.text = Global.formatDateD(DateTime.now().toString());
    getRedeemCart();
    calTotal();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    orderDateCtrl.dispose();
    weightGramCtrl.dispose();
    weightBahtCtrl.dispose();
    referenceNumberCtrl.dispose();
    redeemValueCtrl.dispose();
    depositAmountCtrl.dispose();
    benefitReceiveCtrl.dispose();
    orderDateCtrl.dispose();
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
    setState(() {
      showCal = true;
    });
  }

  void closeCal() {
    benefitReceiveReadOnly = false;
    gramReadOnly = false;
    depositAmountReadOnly = false;
    redemptionValueReadOnly = false;
    priceDiffReadOnly = false;
    taxAmountReadOnly = false;
    setState(() {
      showCal = false;
    });
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
            fontSize: 16.sp, //size.getWidthPx(10),
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
                      closeCal();
                    },
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.9,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: stmBgColorLight,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: GoldMiniWidget(),
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
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
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
                                            prefixIcon: GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        SfDatePickerDialog(
                                                      initialDate:
                                                          DateTime.now(),
                                                      onDateSelected: (date) {
                                                        motivePrint(
                                                            'You picked: $date');
                                                        // Your logic here
                                                        String formattedDate =
                                                            DateFormat(
                                                                    'dd-MM-yyyy')
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
                                                  Icons.calendar_today,
                                                  size: 40,
                                                )),
                                            //icon of text field
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10.0,
                                                    horizontal: 10.0),
                                            labelText: "",
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
                              ),
                              SizedBox(
                                child: Row(
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'เลขที่ขายฝาก',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: buildTextFieldBig(
                                            labelText: "",
                                            inputType: TextInputType.text,
                                            enabled: true,
                                            controller: referenceNumberCtrl,
                                            fontSize: size.getWidthPx(12)),
                                      ),
                                    ),
                                  ],
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
                                            'น้ำหนักรวม (กรัม)',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: numberTextField(
                                            labelText: "",
                                            inputType: TextInputType.number,
                                            controller: weightGramCtrl,
                                            focusNode: gramFocus,
                                            readOnly: gramReadOnly,
                                            // fontSize: size.getWidthPx(12),
                                            inputFormat: [
                                              ThousandsFormatter(
                                                  allowFraction: true)
                                            ],
                                            clear: () {
                                              setState(() {
                                                weightGramCtrl.text = "";
                                              });
                                              gramChanged();
                                            },
                                            onTap: () {
                                              txt = 'gram';
                                              closeCal();
                                            },
                                            openCalc: () {
                                              if (!showCal) {
                                                txt = 'gram';
                                                gramFocus.requestFocus();
                                                openCal();
                                              }
                                            },
                                            onChanged: (String value) {
                                              gramChanged();
                                            }),
                                      ),
                                    ),
                                  ],
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
                                            'มูลค่าขายฝาก',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, top: 8.0),
                                        child: numberTextField(
                                            labelText: "",
                                            inputType: TextInputType.phone,
                                            controller: depositAmountCtrl,
                                            focusNode: depositAmountFocus,
                                            readOnly: depositAmountReadOnly,
                                            // fontSize: size.getWidthPx(12),
                                            inputFormat: [
                                              ThousandsFormatter(
                                                  allowFraction: true)
                                            ],
                                            clear: () {
                                              setState(() {
                                                depositAmountCtrl.text = "";
                                              });
                                              depositAmountChanged();
                                            },
                                            onTap: () {
                                              txt = 'deposit_amount';
                                              closeCal();
                                            },
                                            openCalc: () {
                                              if (!showCal) {
                                                txt = 'deposit_amount';
                                                depositAmountFocus
                                                    .requestFocus();
                                                openCal();
                                              }
                                            },
                                            onFocusChange: (bool value) {
                                              if (!value) {
                                                depositAmountChanged();
                                              }
                                            }),
                                      ),
                                    ),
                                  ],
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
                                            'มูลค่าสินไถ่',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, top: 8.0),
                                        child: numberTextField(
                                          labelText: "",
                                          inputType: TextInputType.phone,
                                          controller: redeemValueCtrl,
                                          focusNode: redemptionValueFocus,
                                          readOnly: redemptionValueReadOnly,
                                          inputFormat: [
                                            ThousandsFormatter(
                                                allowFraction: true)
                                          ],
                                          clear: () {
                                            setState(() {
                                              redeemValueCtrl.text = "";
                                            });
                                            redeemValueChanged();
                                          },
                                          onTap: () {
                                            txt = 'redemption_value';
                                            closeCal();
                                          },
                                          openCalc: () {
                                            if (!showCal) {
                                              txt = 'redemption_value';
                                              redemptionValueFocus
                                                  .requestFocus();
                                              openCal();
                                            }
                                          },
                                          onFocusChange: (bool value) {
                                            if (!value) {
                                              redeemValueChanged();
                                            }
                                          },
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
                                        flex: 4,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            'ผลประโยชน์ที่รับวันนี้',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10),
                                                color: textColor),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 6,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            right: 8.0, top: 8.0),
                                        child: numberTextField(
                                          labelText: "",
                                          inputType: TextInputType.phone,
                                          controller: benefitReceiveCtrl,
                                          focusNode: benefitReceiveFocus,
                                          readOnly: benefitReceiveReadOnly,
                                          inputFormat: [
                                            ThousandsFormatter(
                                                allowFraction: true)
                                          ],
                                          clear: () {
                                            setState(() {
                                              benefitReceiveCtrl.text = "";
                                            });
                                            benefitReceiveChanged();
                                          },
                                          onTap: () {
                                            txt = 'benefit_receive';
                                            closeCal();
                                          },
                                          openCalc: () {
                                            if (!showCal) {
                                              txt = 'benefit_receive';
                                              benefitReceiveFocus
                                                  .requestFocus();
                                              openCal();
                                            }
                                          },
                                          onFocusChange: (bool value) {
                                            if (!value) {
                                              benefitReceiveChanged();
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: SizedBox(
                                    width: 250,
                                    height: 100,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: snBgColor,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 3),
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
                                          calTotal();
                                          setState(() {});
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.add,
                                              size: size.getWidthPx(10)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'เพิ่ม',
                                            style: TextStyle(
                                                fontSize: size.getWidthPx(10)),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: stmBgColorLight,
                                ),
                                child: Column(
                                  children: [
                                    if (Global.redeemSingleDetail!.isNotEmpty)
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
                                                    fontSize:
                                                        size.getWidthPx(8),
                                                    color: textColor,
                                                  )),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Text('น้ำหนัก (กรัม)',
                                                  textAlign: TextAlign.right,
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
                                                    fontSize:
                                                        size.getWidthPx(8),
                                                    color: textColor,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            Global.redeemSingleDetail!.length,
                                        itemBuilder: (context, index) {
                                          return _itemOrderList(
                                              order: Global
                                                  .redeemSingleDetail![index],
                                              index: index);
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showCal)
                    DragArea(
                        closeCal: closeCal,
                        child: Container(
                            width: 350,
                            height: 500,
                            padding: const EdgeInsets.all(5),
                            decoration:
                                const BoxDecoration(color: Color(0xffcccccc)),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Calc(
                                  closeCal: closeCal,
                                  onChanged: (key, value, expression) {
                                    if (key == 'ENT') {
                                      if (txt == 'gram') {
                                        weightGramCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                        gramChanged();
                                      }
                                      if (txt == 'deposit_amount') {
                                        depositAmountCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                        depositAmountChanged();
                                      }
                                      if (txt == 'redemption_value') {
                                        redeemValueCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                        redeemValueChanged();
                                      }
                                      if (txt == 'benefit_receive') {
                                        benefitReceiveCtrl.text = value != null
                                            ? "${Global.format(value)}"
                                            : "";
                                        benefitReceiveChanged();
                                      }
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      closeCal();
                                    }
                                    if (kDebugMode) {
                                      print('$key\t$value\t$expression');
                                    }
                                  },
                                ),
                                Positioned(
                                  left: 5.0,
                                  top: 5.0,
                                  child: InkWell(
                                    onTap: closeCal,
                                    child: const CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.close,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )))
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
                          fontSize: size.getWidthPx(10),
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

                        if (weightGramCtrl.text.isEmpty) {
                          Alert.warning(
                              context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK');
                          return;
                        }

                        if (depositAmountCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณากรอกมูลค่าขายฝาก', 'OK');
                          return;
                        }

                        if (redeemValueCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณากรอกมูลค่าสินไถ่', 'OK');
                          return;
                        }

                        Global.redeemSingleDetail!.add(
                          RedeemDetailModel.fromJson(
                            jsonDecode(
                              jsonEncode(
                                RedeemDetailModel(
                                  productId: selectedProduct?.id,
                                  weight: Global.toNumber(weightGramCtrl.text),
                                  weightBath:
                                      Global.toNumber(weightBahtCtrl.text),
                                  taxBase: Global.toNumber(
                                          redeemValueCtrl.text) -
                                      Global.toNumber(depositAmountCtrl.text),
                                  taxAmount:
                                      (Global.toNumber(redeemValueCtrl.text) -
                                              Global.toNumber(
                                                  depositAmountCtrl.text)) *
                                          getVatValue(),
                                  depositAmount:
                                      Global.toNumber(depositAmountCtrl.text),
                                  redemptionValue:
                                      Global.toNumber(redeemValueCtrl.text),
                                  redemptionVat:
                                      ((Global.toNumber(redeemValueCtrl.text) -
                                                  Global.toNumber(
                                                      depositAmountCtrl.text)) *
                                              getVatValue()) +
                                          Global.toNumber(redeemValueCtrl.text),
                                  benefitAmount: Global.toNumber(
                                              benefitReceiveCtrl.text) !=
                                          0
                                      ? Global.toNumber(benefitReceiveCtrl.text)
                                      : Global.toNumber(redeemValueCtrl.text) -
                                          Global.toNumber(
                                              depositAmountCtrl.text),
                                  paymentAmount: lineAmount,
                                  qty: 1,
                                  referenceNo: referenceNumberCtrl.text,
                                ),
                              ),
                            ),
                          ),
                        );
                        setState(() {});

                        RedeemModel order = RedeemModel(
                            redeemId: '',
                            redeemDate: Global.convertDate(orderDateCtrl.text),
                            details: Global.redeemSingleDetail!.reversed.toList(),
                            redeemTypeId: 1);
                        final data = order.toJson();
                        Global.redeems.add(RedeemModel.fromJson(data));
                        widget.refreshCart(Global.redeems.length.toString());
                        writeRedeemCart();
                        Global.redeemSingleDetail!.clear();
                        resetText();
                        setState(() {});

                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text(
                            "เพิ่มลงในรถเข็นสำเร็จ...",
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

                        if (weightGramCtrl.text.isEmpty) {
                          Alert.warning(
                              context, 'คำเตือน', 'กรุณาใส่น้ำหนัก', 'OK');
                          return;
                        }

                        if (depositAmountCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณากรอกมูลค่าขายฝาก', 'OK');
                          return;
                        }

                        if (redeemValueCtrl.text.isEmpty) {
                          Alert.warning(context, 'คำเตือน',
                              'กรุณากรอกมูลค่าสินไถ่', 'OK');
                          return;
                        }

                        Global.redeemSingleDetail!.add(
                          RedeemDetailModel.fromJson(
                            jsonDecode(
                              jsonEncode(
                                RedeemDetailModel(
                                  productId: selectedProduct?.id,
                                  weight: Global.toNumber(weightGramCtrl.text),
                                  weightBath:
                                      Global.toNumber(weightBahtCtrl.text),
                                  taxBase: Global.toNumber(
                                          redeemValueCtrl.text) -
                                      Global.toNumber(depositAmountCtrl.text),
                                  taxAmount:
                                      (Global.toNumber(redeemValueCtrl.text) -
                                              Global.toNumber(
                                                  depositAmountCtrl.text)) *
                                          getVatValue(),
                                  depositAmount:
                                      Global.toNumber(depositAmountCtrl.text),
                                  redemptionValue:
                                      Global.toNumber(redeemValueCtrl.text),
                                  redemptionVat:
                                      ((Global.toNumber(redeemValueCtrl.text) -
                                                  Global.toNumber(
                                                      depositAmountCtrl.text)) *
                                              getVatValue()) +
                                          Global.toNumber(redeemValueCtrl.text),
                                  benefitAmount: Global.toNumber(
                                              benefitReceiveCtrl.text) !=
                                          0
                                      ? Global.toNumber(benefitReceiveCtrl.text)
                                      : Global.toNumber(redeemValueCtrl.text) -
                                          Global.toNumber(
                                              depositAmountCtrl.text),
                                  paymentAmount: lineAmount,
                                  qty: 1,
                                  referenceNo: referenceNumberCtrl.text,
                                ),
                              ),
                            ),
                          ),
                        );
                        setState(() {});

                        RedeemModel order = RedeemModel(
                            redeemId: '',
                            redeemDate: Global.convertDate(orderDateCtrl.text),
                            details: Global.redeemSingleDetail!.reversed.toList(),
                            redeemTypeId: 1);
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

  void gramChanged() {
    if (weightGramCtrl.text.isNotEmpty) {
      weightBahtCtrl.text = Global.format(
          (Global.toNumber(weightGramCtrl.text) / getUnitWeightValue()));
    } else {
      weightBahtCtrl.text = "";
    }
    getOtherAmount();
  }

  void depositAmountChanged() {
    getOtherAmount();
  }

  void redeemValueChanged() {
    getOtherAmount();
  }

  void benefitReceiveChanged() {
    getOtherAmount();
  }

  void getOtherAmount() {
    calTotal();
  }

  void calTotal() {
    totalAmount = 0;
    if (benefitReceiveCtrl.text.isNotEmpty &&
        Global.toNumber(benefitReceiveCtrl.text) > 0) {
      lineAmount = Global.toNumber(depositAmountCtrl.text) +
          Global.toNumber(benefitReceiveCtrl.text);
    } else {
      lineAmount = Global.toNumber(redeemValueCtrl.text);
    }

    totalAmount += lineAmount;

    if (Global.redeemSingleDetail != null &&
        Global.redeemSingleDetail!.isNotEmpty) {
      for (int i = 0; i < Global.redeemSingleDetail!.length; i++) {
        totalAmount += Global.redeemSingleDetail![i].paymentAmount ?? 0;
      }
    }

    setState(() {});
  }

  resetText() {
    weightGramCtrl.text = "";
    depositAmountCtrl.text = "";
    weightBahtCtrl.text = "";
    redeemValueCtrl.text = "";
    benefitReceiveCtrl.text = "";
    referenceNumberCtrl.text = "";
    orderDateCtrl.text = "";
    totalAmount = 0;
    lineAmount = 0;
    Global.refillAttach = null;
    setState(() {});
  }

  removeProduct(index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
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
