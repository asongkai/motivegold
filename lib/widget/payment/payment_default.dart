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
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

// import 'package:pattern_formatter/numeric_formatter.dart';
import 'package:motivegold/utils/helps/numeric_formatter.dart';

class PaymentDefaultWidget extends StatefulWidget {
  const PaymentDefaultWidget({super.key, this.index, this.payment});

  final int? index;
  final DefaultPaymentModel? payment;

  @override
  State<PaymentDefaultWidget> createState() => _PaymentDefaultWidgetState();
}

class _PaymentDefaultWidgetState extends State<PaymentDefaultWidget> {
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

    if (widget.payment == null) {
      Global.selectedPayment = null;
      paymentNotifier = ValueNotifier<ProductTypeModel>(Global.selectedPayment ??
          ProductTypeModel(name: 'เลือกวิธีการชำระเงิน', code: '', id: 0));
    }
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

      if (widget.payment != null) {
        Global.currentPaymentMethod =
            widget.payment?.paymentCode ?? "";
        Global.selectedPayment = paymentTypes()
            .where((e) =>
        e.code == widget.payment?.paymentCode)
            .first;
        paymentNotifier = ValueNotifier<ProductTypeModel>(Global
            .selectedPayment ??
            ProductTypeModel(name: 'เลือกวิธีการชำระเงิน', code: '', id: 0));

        if (widget.payment?.paymentCode == 'TR') {
          Global.selectedBank = Global.bankList
              .where((e) => e.id == widget.payment?.bankId)
              .first;
          Global.selectedAccount = Global.accountList
              .where((e) =>
          e.accountNo == widget.payment?.accountNo)
              .first;
          filterAccount(Global.selectedBank?.id);
          bankNotifier = ValueNotifier<BankModel>(Global.selectedBank ??
              BankModel(name: 'เลือกธนาคาร', code: '', id: 0));
          accountNotifier = ValueNotifier<BankAccountModel>(
              Global.selectedAccount ??
                  BankAccountModel(name: 'เลือกบัญชีธนาคาร', id: 0));
        }
      } else {
        Global.currentPaymentMethod = null;
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
              if (Global.currentPaymentMethod == 'TR' || Global.currentPaymentMethod == 'DP')
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
                  ],
                ),
              if (Global.currentPaymentMethod == 'TR' || Global.currentPaymentMethod == 'DP')
                const SizedBox(
                  height: 10,
                ),
              if (Global.currentPaymentMethod == 'TR' || Global.currentPaymentMethod == 'DP')
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
