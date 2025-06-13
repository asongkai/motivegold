import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/bank/bank.dart';
import 'package:motivegold/model/bank/bank_account.dart';
import 'package:motivegold/model/default/default_payment.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

// import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';

class PaymentMethodWidget extends StatefulWidget {
  const PaymentMethodWidget({super.key, this.index, this.payment});

  final int? index;
  final DefaultPaymentModel? payment;

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget> {
  bool loading = false;
  ValueNotifier<dynamic>? paymentNotifier;
  ValueNotifier<dynamic>? bankNotifier;
  ValueNotifier<dynamic>? accountNotifier;

  @override
  void initState() {
    // implement initState
    super.initState();
    paymentNotifier = ValueNotifier<ProductTypeModel>(Global.selectedPayment ??
        ProductTypeModel(name: 'เลือกวิธีการชำระเงิน', code: '', id: 0));
    bankNotifier = ValueNotifier<BankModel>(
        Global.selectedBank ?? BankModel(name: 'เลือกธนาคาร', code: '', id: 0));
    accountNotifier = ValueNotifier<BankAccountModel>(Global.selectedAccount ??
        BankAccountModel(name: 'เลือกบัญชีธนาคาร', id: 0));
    Global.paymentDateCtrl.text =
        Global.formatDateDD(DateTime.now().toString());
    init();

    if (widget.index != null) {}
  }

  init() async {
    setState(() {
      loading = true;
    });

    try {
      if (Global.bankList.isEmpty) {
        var office =
            await ApiServices.post('/bank/all', Global.requestObj(null));
        // kclPrint(province?.toJson());
        if (office?.status == "success") {
          var data = jsonEncode(office?.data);
          List<BankModel> products = bankModelFromJson(data);
          setState(() {
            Global.bankList = products;
          });
        } else {
          Global.bankList = [];
        }
      }

      if (Global.accountList.isEmpty) {
        var office =
            await ApiServices.post('/bankaccount/all', Global.requestObj(null));
        // kclPrint(province?.toJson());
        if (office?.status == "success") {
          var data = jsonEncode(office?.data);
          List<BankAccountModel> products = bankAccountModelFromJson(data);
          setState(() {
            Global.accountList = products;
          });
        } else {
          Global.accountList = [];
        }
      }

      if (widget.index != null) {
        Global.currentPaymentMethod =
            Global.paymentList?[widget.index!].paymentMethod;
        Global.paymentDateCtrl.text = Global.formatDateDD(
            Global.paymentList![widget.index!].paymentDate.toString());
        Global.paymentDetailCtrl.text =
            Global.paymentList![widget.index!].paymentDetail ?? '';
        Global.amountCtrl.text =
            Global.format(Global.paymentList![widget.index!].amount ?? 0);
        Global.selectedPayment = paymentTypes()
            .where((e) =>
                e.code == Global.paymentList?[widget.index!].paymentMethod)
            .first;
        paymentNotifier = ValueNotifier<ProductTypeModel>(Global
                .selectedPayment ??
            ProductTypeModel(name: 'เลือกวิธีการชำระเงิน', code: '', id: 0));

        if (Global.paymentList?[widget.index!].paymentMethod == 'TR') {
          Global.selectedBank = Global.bankList
              .where((e) => e.id == Global.paymentList?[widget.index!].bankId)
              .first;
          Global.selectedAccount = Global.accountList
              .where((e) =>
                  e.accountNo == Global.paymentList?[widget.index!].accountNo)
              .first;
          filterAccount(Global.selectedBank?.id);
          Global.refNoCtrl.text =
              Global.paymentList?[widget.index!].referenceNumber ?? '';
          bankNotifier = ValueNotifier<BankModel>(Global.selectedBank ??
              BankModel(name: 'เลือกธนาคาร', code: '', id: 0));
          accountNotifier = ValueNotifier<BankAccountModel>(
              Global.selectedAccount ??
                  BankAccountModel(name: 'เลือกบัญชีธนาคาร', id: 0));
        }

        if (Global.paymentList?[widget.index!].paymentMethod == 'CR') {
          Global.cardNameCtrl.text =
              Global.paymentList?[widget.index!].cardName ?? '';
          Global.cardNumberCtrl.text =
              Global.paymentList?[widget.index!].cardNo ?? '';
          Global.cardExpireDateCtrl.text = Global.formatDateDD(
              Global.paymentList![widget.index!].cardExpiryDate.toString());
        }
      }

      if (widget.payment != null && widget.index == null) {
        Global.selectedPayment = paymentTypes()
            .where((e) => e.code == widget.payment?.paymentCode)
            .first;
        paymentNotifier = ValueNotifier<ProductTypeModel>(Global
                .selectedPayment ??
            ProductTypeModel(name: 'เลือกวิธีการชำระเงิน', code: '', id: 0));
        Global.currentPaymentMethod = widget.payment?.paymentCode ?? '';

        if (widget.payment?.paymentCode == 'TR') {
          Global.selectedBank = Global.bankList
              .where((e) => e.id == widget.payment?.bankId)
              .first;
          Global.selectedAccount = Global.accountList
              .where((e) => e.accountNo == widget.payment?.accountNo)
              .first;
          filterAccount(Global.selectedBank?.id);
          bankNotifier = ValueNotifier<BankModel>(Global.selectedBank ??
              BankModel(name: 'เลือกธนาคาร', code: '', id: 0));
          accountNotifier = ValueNotifier<BankAccountModel>(
              Global.selectedAccount ??
                  BankAccountModel(name: 'เลือกบัญชีธนาคาร', id: 0));
        }
        motivePrint(Global.currentPaymentMethod);
        setState(() {

        });
      }
    } catch (e) {
      motivePrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  final picker = ImagePicker();

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        Global.paymentAttachment = File(pickedFile.path);
      }
    });
  }

//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        Global.paymentAttachment = File(pickedFile.path);
      }
    });
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('คลังภาพ'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('ถ่ายรูป'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return loading
        ? const Center(child: LoadingProgress())
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    Expanded(
                      flex: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          height: 80,
                          child: MiraiDropDownMenu<ProductTypeModel>(
                            key: UniqueKey(),
                            children: paymentTypes(),
                            space: 4,
                            maxHeight: 360,
                            showSearchTextField: true,
                            selectedItemBackgroundColor: Colors.transparent,
                            emptyListMessage: 'ไม่มีข้อมูล',
                            showSelectedItemBackgroundColor: true,
                            otherDecoration: const InputDecoration(),
                            itemWidgetBuilder: (
                              int index,
                              ProductTypeModel? project, {
                              bool isItemSelected = false,
                            }) {
                              return DropDownItemWidget(
                                project: project,
                                isItemSelected: isItemSelected,
                                firstSpace: 10,
                                fontSize: size.getWidthPx(6),
                              );
                            },
                            onChanged: (ProductTypeModel value) {
                              Global.selectedPayment = value;
                              Global.currentPaymentMethod =
                                  Global.selectedPayment?.code;
                              paymentNotifier!.value = value;
                              // motivePrint('amount: ${Global.payToCustomerOrShopValue(Global.ordersPapun, Global.discount)}');
                              double amount = 0;

                              if (Global.currentOrderType == 5) {
                                amount =
                                    Global.payToCustomerOrShopValueWholeSale(
                                        Global.ordersWholesale,
                                        Global.discount);
                              } else if (Global.currentOrderType == 6) {
                                amount =
                                    Global.payToCustomerOrShopValueWholeSale(
                                        Global.ordersThengWholesale,
                                        Global.discount);
                              } else {
                                if (Global.checkOutMode == 'O') {
                                  amount = Global.payToCustomerOrShopValue(
                                      Global.orders, Global.discount);
                                }

                                if (Global.checkOutMode == 'P') {
                                  amount = Global.getRedeemPaymentTotal(
                                      Global.redeems,
                                      discount: Global.discount);
                                }
                              }
                              if (amount >= 0) {
                                Global.amountCtrl.text = Global.format(
                                    amount - Global.getPaymentListTotal());
                              } else {
                                Global.amountCtrl.text = Global.format(
                                    -amount - Global.getPaymentListTotal());
                              }
                              setState(() {});
                            },
                            child: DropDownObjectChildWidget(
                              key: GlobalKey(),
                              fontSize: size.getWidthPx(8),
                              projectValueNotifier: paymentNotifier!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (Global.currentPaymentMethod == 'TR' ||
                  Global.currentPaymentMethod == 'DP')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SizedBox(
                          height: 80,
                          child: MiraiDropDownMenu<BankModel>(
                            key: UniqueKey(),
                            children: Global.bankList,
                            space: 4,
                            maxHeight: 360,
                            showSearchTextField: true,
                            selectedItemBackgroundColor: Colors.transparent,
                            emptyListMessage: 'ไม่มีข้อมูล',
                            showSelectedItemBackgroundColor: true,
                            otherDecoration: const InputDecoration(),
                            itemWidgetBuilder: (
                              int index,
                              BankModel? project, {
                              bool isItemSelected = false,
                            }) {
                              return DropDownItemWidget(
                                project: project,
                                isItemSelected: isItemSelected,
                                firstSpace: 10,
                                fontSize: size.getWidthPx(6),
                              );
                            },
                            onChanged: (BankModel value) {
                              Global.selectedBank = value;
                              bankNotifier!.value = value;
                              filterAccount(value.id);
                              setState(() {});
                              setState(() {});
                            },
                            child: DropDownObjectChildWidget(
                              key: GlobalKey(),
                              fontSize: size.getWidthPx(8),
                              projectValueNotifier: bankNotifier!,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: SizedBox(
                          height: 80,
                          child: MiraiDropDownMenu<BankAccountModel>(
                            key: UniqueKey(),
                            children: Global.filterAccountList,
                            space: 4,
                            maxHeight: 360,
                            showSearchTextField: true,
                            selectedItemBackgroundColor: Colors.transparent,
                            emptyListMessage: 'ไม่มีข้อมูล',
                            showSelectedItemBackgroundColor: true,
                            otherDecoration: const InputDecoration(),
                            itemWidgetBuilder: (
                              int index,
                              BankAccountModel? project, {
                              bool isItemSelected = false,
                            }) {
                              return DropDownItemWidget(
                                project: project,
                                isItemSelected: isItemSelected,
                                firstSpace: 10,
                                fontSize: size.getWidthPx(8),
                              );
                            },
                            onChanged: (BankAccountModel value) {
                              Global.selectedAccount = value;
                              accountNotifier!.value = value;
                              setState(() {});
                              setState(() {});
                            },
                            child: DropDownObjectChildWidget(
                              key: GlobalKey(),
                              fontSize: size.getWidthPx(8),
                              projectValueNotifier: accountNotifier!,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (Global.currentPaymentMethod == 'TR' ||
                  Global.currentPaymentMethod == 'DP')
                const SizedBox(
                  height: 30,
                ),
              if (Global.currentPaymentMethod == 'TR' ||
                  Global.currentPaymentMethod == 'DP')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            buildTextFieldBig(
                              labelText: 'เลขที่อ้างอิง'.tr(),
                              validator: null,
                              inputType: TextInputType.text,
                              controller: Global.refNoCtrl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (Global.currentPaymentMethod == 'CR')
                const SizedBox(
                  height: 20,
                ),
              if (Global.currentPaymentMethod == 'CR')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            buildTextFieldBig(
                              labelText: 'ชื่อบนบัตร'.tr(),
                              validator: null,
                              inputType: TextInputType.text,
                              controller: Global.cardNameCtrl,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8.0, top: 8.0),
                        child: TextField(
                          controller: Global.cardExpireDateCtrl,
                          //editing controller of this TextField
                          style: const TextStyle(fontSize: 38),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today),
                            //icon of text field
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 18.0, horizontal: 15.0),
                            labelText: "วันหมดอายุบัตร".tr(),
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
                          readOnly: true,
                          //set it true, so that user will not able to edit text
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (_) => SfDatePickerDialog(
                                initialDate: DateTime.now(),
                                onDateSelected: (date) {
                                  motivePrint('You picked: $date');
                                  // Your logic here
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd').format(date);
                                  setState(() {
                                    Global.cardExpireDateCtrl.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 15,
              ),
              if (Global.currentPaymentMethod == 'CR')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            buildTextFieldBig(
                              labelText: 'เลขที่บัตรเครดิต'.tr(),
                              validator: null,
                              inputType: TextInputType.phone,
                              controller: Global.cardNumberCtrl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 15,
              ),
              if (Global.currentPaymentMethod != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: TextField(
                          controller: Global.paymentDateCtrl,
                          //editing controller of this TextField
                          style: const TextStyle(fontSize: 38),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.calendar_today),
                            //icon of text field
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            labelText: "วันที่จ่ายเงิน".tr(),
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
                          readOnly: true,
                          //set it true, so that user will not able to edit text
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (_) => SfDatePickerDialog(
                                initialDate: DateTime.now(),
                                onDateSelected: (pickDate) {
                                  motivePrint('You picked: $pickDate');
                                  // Your logic here
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd').format(pickDate);
                                  DateTime date = Global.currentOrderType != 5
                                      ? DateTime.now()
                                      : Global.ordersWholesale![0].orderDate!;
                                  if (pickDate.isSameDate(date)) {
                                    Alert.warning(
                                        context,
                                        'Warning'.tr(),
                                        'วันที่ชำระเงินไม่ตรงกับวันที่ทำธุรกรรม',
                                        'OK',
                                        action: () {});
                                  }
                                  if (pickDate.compareTo(date) > 0) {
                                    Alert.warning(
                                        context,
                                        'Warning'.tr(),
                                        'วันที่ชำระเงินมากกว่าวันที่ทำธุรกรรม',
                                        'OK',
                                        action: () {});
                                  }

                                  setState(() {
                                    Global.paymentDateCtrl.text =
                                        formattedDate; //set output date to TextField value.
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              if (Global.currentPaymentMethod != null)
                const SizedBox(
                  height: 20,
                ),
              if (Global.currentPaymentMethod != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            buildTextFieldBig(
                              labelText: 'จำนวนเงิน'.tr(),
                              validator: null,
                              inputType: TextInputType.number,
                              controller: Global.amountCtrl,
                              inputFormat: [
                                ThousandsFormatter(allowFraction: true)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(
                height: 10,
              ),
              if (Global.currentPaymentMethod == 'OTH')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            buildTextFieldBig(
                              line: 2,
                              labelText: 'รายละเอียด'.tr(),
                              validator: null,
                              inputType: TextInputType.text,
                              controller: Global.paymentDetailCtrl,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (Global.currentPaymentMethod != null &&
                  Global.currentPaymentMethod != "CA")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    Global.currentPaymentMethod == 'DP'
                        ? "เพิ่มสลิปฝากธนาคาร"
                        : "เพิ่มสลิปการชำระเงิน",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              if (Global.currentPaymentMethod != null &&
                  Global.currentPaymentMethod != "CA")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: showOptions,
                      icon: const Icon(
                        Icons.add_a_photo_outlined,
                      ),
                      label: Text(
                        'เลือกรูปภาพ',
                        style: TextStyle(fontSize: size.getWidthPx(8)),
                      ),
                    ),
                  ),
                ),
              if (Global.currentPaymentMethod != null &&
                  Global.currentPaymentMethod != "CA")
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Global.paymentAttachment == null
                        ? Text(
                            'ไม่ได้เลือกรูปภาพ',
                            style: TextStyle(fontSize: size.getWidthPx(6)),
                          )
                        : SizedBox(
                            width: MediaQuery.of(context).size.width / 4,
                            child: Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.file(Global.paymentAttachment!),
                                ),
                                Positioned(
                                  right: 0.0,
                                  top: 0.0,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        Global.paymentAttachment = null;
                                      });
                                    },
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.red,
                                      child: Icon(Icons.close),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                  ),
                ),
            ],
          );
  }

  void filterAccount(int? id) {
    if (Global.accountList.isNotEmpty) {
      Global.filterAccountList =
          Global.accountList.where((e) => e.bankId == id).toList();
    } else {
      Global.filterAccountList = [];
    }
  }
}
