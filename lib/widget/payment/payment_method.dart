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
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:motivegold/utils/helps/numeric_formatter.dart';
import 'package:sizer/sizer.dart';

// Platform-specific imports
import 'web_file_picker.dart' if (dart.library.io) 'mobile_file_picker.dart';

class PaymentMethodWidget extends StatefulWidget {
  const PaymentMethodWidget({super.key, this.index, this.payment});

  final int? index;
  final DefaultPaymentModel? payment;

  @override
  State<PaymentMethodWidget> createState() => _PaymentMethodWidgetState();
}

class _PaymentMethodWidgetState extends State<PaymentMethodWidget>
    with SingleTickerProviderStateMixin {
  bool loading = false;
  ValueNotifier<dynamic>? paymentNotifier;
  ValueNotifier<dynamic>? bankNotifier;
  ValueNotifier<dynamic>? accountNotifier;
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
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

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  init() async {
    setState(() {
      loading = true;
    });

    try {
      if (Global.bankList.isEmpty) {
        var office =
        await ApiServices.post('/bank/all', Global.requestObj(null));
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
        triggerAmount();
        setState(() {});
      }

      _animationController?.forward();
    } catch (e) {
      motivePrint(e.toString());
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  final picker = ImagePicker();

  TextEditingController cashCtrl = TextEditingController();
  TextEditingController diffCtrl = TextEditingController();

  Future getImageFromGallery() async {
    if (!kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          Global.paymentAttachment = File(pickedFile.path);
        });
      }
    } else {
      try {
        final result = await WebFilePicker.pickImage();
        if (result != null) {
          setState(() {
            Global.paymentAttachmentWeb = result;
          });
        }
      } catch (e) {
        if (mounted) {
          Alert.warning(context, "Error", "Failed to select image: $e", "OK",
              action: () {});
        }
      }
    }
  }

  Future getImageFromCamera() async {
    if (!kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          Global.paymentAttachment = File(pickedFile.path);
        });
      }
    } else {
      Alert.warning(context, "ไม่รองรับ",
          "การถ่ายภาพจากกล้องบนเว็บยังไม่พร้อมใช้งาน", "OK",
          action: () {});
    }
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('คลังภาพ'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('ถ่ายรูป'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const ModernLoadingWidget()
        : _fadeAnimation != null
        ? FadeTransition(
      opacity: _fadeAnimation!,
      child: _buildContent(),
    )
        : _buildContent();
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('วิธีการชำระเงิน', Icons.payment),
          const SizedBox(height: 20),
          _buildPaymentMethodDropdown(),
          const SizedBox(height: 20),

          // Bank Transfer / Deposit fields
          if (Global.currentPaymentMethod == 'TR' ||
              Global.currentPaymentMethod == 'DP') ...[
            _buildSectionHeader('ข้อมูลธนาคาร', Icons.account_balance),
            const SizedBox(height: 20),
            _buildBankSection(),
            const SizedBox(height: 40),
            _buildReferenceSection(),
            const SizedBox(height: 20),
          ],

          // Credit Card fields
          if (Global.currentPaymentMethod == 'CR') ...[
            _buildSectionHeader('ข้อมูลบัตรเครดิต', Icons.credit_card),
            const SizedBox(height: 30),
            _buildCreditCardSection(),
            const SizedBox(height: 20),
          ],

          // Payment Date and Amount (for all payment methods)
          if (Global.currentPaymentMethod != null) ...[
            _buildSectionHeader('รายละเอียดการชำระเงิน', Icons.info_outline),
            const SizedBox(height: 30),
            _buildPaymentDateSection(),
            const SizedBox(height: 40),
            _buildAmountSection(),
            const SizedBox(height: 20),
          ],

          // Cash specific fields
          if (Global.currentPaymentMethod == "CA") ...[
            _buildCashSection(),
            const SizedBox(height: 20),
          ],

          // Other payment method details
          if (Global.currentPaymentMethod == 'OTH') ...[
            _buildOtherPaymentSection(),
            const SizedBox(height: 20),
          ],

          // Image attachment section
          if (Global.currentPaymentMethod != null &&
              Global.currentPaymentMethod != "CA") ...[
            _buildImageSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF0F766E),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
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
            fontSize: 16.sp,
          );
        },
        onChanged: (ProductTypeModel value) {
          Global.selectedPayment = value;
          Global.currentPaymentMethod = Global.selectedPayment?.code;
          paymentNotifier!.value = value;
          triggerAmount();
        },
        child: DropDownObjectChildWidget(
          key: GlobalKey(),
          fontSize: 16.sp,
          projectValueNotifier: paymentNotifier!,
        ),
      ),
    );
  }

  Widget _buildBankSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
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
                  fontSize: 16.sp,
                );
              },
              onChanged: (BankModel value) {
                Global.selectedBank = value;
                bankNotifier!.value = value;
                filterAccount(value.id);
                setState(() {});
              },
              child: DropDownObjectChildWidget(
                key: GlobalKey(),
                fontSize: 16.sp,
                projectValueNotifier: bankNotifier!,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
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
                  fontSize: 16.sp,
                );
              },
              onChanged: (BankAccountModel value) {
                Global.selectedAccount = value;
                accountNotifier!.value = value;
                setState(() {});
              },
              child: DropDownObjectChildWidget(
                key: GlobalKey(),
                fontSize: 16.sp,
                projectValueNotifier: accountNotifier!,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceSection() {
    return buildTextFieldBig(
      labelText: 'เลขที่อ้างอิง'.tr(),
      validator: null,
      inputType: TextInputType.text,
      controller: Global.refNoCtrl,
    );
  }

  Widget _buildCreditCardSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: buildTextFieldBig(
                labelText: 'ชื่อบนบัตร'.tr(),
                validator: null,
                inputType: TextInputType.text,
                controller: Global.cardNameCtrl,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: TextField(
                  controller: Global.cardExpireDateCtrl,
                  style: TextStyle(fontSize: 18.sp, color: textColor),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18.0, horizontal: 15.0),
                    labelText: "วันหมดอายุบัตร".tr(),
                    labelStyle: TextStyle(fontSize: 18.sp, color: textColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  readOnly: true,
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (_) => SfDatePickerDialog(
                        initialDate: DateTime.now(),
                        onDateSelected: (date) {
                          String formattedDate =
                          DateFormat('yyyy-MM-dd').format(date);
                          setState(() {
                            Global.cardExpireDateCtrl.text = formattedDate;
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
        const SizedBox(height: 30),
        buildTextFieldBig(
          labelText: 'เลขที่บัตรเครดิต'.tr(),
          validator: null,
          inputType: TextInputType.phone,
          controller: Global.cardNumberCtrl,
        ),
      ],
    );
  }

  Widget _buildPaymentDateSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        controller: Global.paymentDateCtrl,
        style: TextStyle(fontSize: 18.sp, color: textColor),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 18.0, horizontal: 15.0),
          labelText: "วันที่จ่ายเงิน".tr(),
          labelStyle: TextStyle(fontSize: 18.sp, color: textColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        readOnly: true,
        onTap: () async {
          showDialog(
            context: context,
            builder: (_) => SfDatePickerDialog(
              initialDate: DateTime.now(),
              onDateSelected: (pickDate) {
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickDate);
                DateTime date = Global.currentOrderType != 5
                    ? DateTime.now()
                    : Global.ordersWholesale![0].orderDate!;
                if (pickDate.isSameDate(date)) {
                  Alert.warning(context, 'Warning'.tr(),
                      'วันที่ชำระเงินไม่ตรงกับวันที่ทำธุรกรรม', 'OK',
                      action: () {});
                }
                if (pickDate.compareTo(date) > 0) {
                  Alert.warning(context, 'Warning'.tr(),
                      'วันที่ชำระเงินมากกว่าวันที่ทำธุรกรรม', 'OK',
                      action: () {});
                }

                setState(() {
                  Global.paymentDateCtrl.text = formattedDate;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountSection() {
    return buildTextFieldBig(
      labelText: 'จำนวนเงิน'.tr(),
      validator: null,
      inputType: TextInputType.number,
      controller: Global.amountCtrl,
      inputFormat: [ThousandsFormatter(allowFraction: true)],
    );
  }

  Widget _buildCashSection() {
    return Column(
      children: [
        const SizedBox(height: 20),
        buildTextFieldBig(
          labelText: 'จำนวนเงินที่ได้รับ/จ่าย',
          validator: null,
          inputType: TextInputType.number,
          controller: cashCtrl,
          onChanged: (value) {
            if (value != "") {
              double num = Global.toNumber(cashCtrl.text) -
                  Global.toNumber(Global.amountCtrl.text);
              diffCtrl.text = num < 0 ? "" : Global.format(num);
            } else {
              diffCtrl.text = "";
            }
          },
          inputFormat: [ThousandsFormatter(allowFraction: true)],
        ),
        const SizedBox(height: 30),
        buildTextFieldBig(
          labelText: 'ผลต่าง',
          validator: null,
          inputType: TextInputType.number,
          enabled: false,
          controller: diffCtrl,
          inputFormat: [ThousandsFormatter(allowFraction: true)],
        ),
      ],
    );
  }

  Widget _buildOtherPaymentSection() {
    return buildTextFieldBig(
      line: 2,
      labelText: 'รายละเอียด'.tr(),
      validator: null,
      inputType: TextInputType.text,
      controller: Global.paymentDetailCtrl,
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_a_photo_outlined,
                color: Color(0xFF0F766E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                Global.currentPaymentMethod == 'DP'
                    ? "เพิ่มสลิปฝากธนาคาร"
                    : "เพิ่มสลิปการชำระเงิน",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: showOptions,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF0F766E),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add_a_photo_outlined),
              label: Text(
                'เลือกรูปภาพ',
                style: TextStyle(fontSize: 16.sp),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Global.paymentAttachment == null &&
                Global.paymentAttachmentWeb == null
                ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ไม่ได้เลือกรูปภาพ',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
                : Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        maxWidth: 300,
                        maxHeight: 200,
                      ),
                      child: kIsWeb
                          ? Image.memory(
                        base64Decode(Global.paymentAttachmentWeb!
                            .split(",")
                            .last),
                        fit: BoxFit.cover,
                      )
                          : Image.file(
                        Global.paymentAttachment!,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            Global.paymentAttachment = null;
                            Global.paymentAttachmentWeb = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void triggerAmount() {
    double amount = 0;

    if (Global.currentOrderType == 5) {
      amount = Global.payToCustomerOrShopValueWholeSale(
          Global.ordersWholesale, Global.discount, Global.addPrice);
    } else if (Global.currentOrderType == 6) {
      amount = Global.payToCustomerOrShopValueWholeSale(
          Global.ordersThengWholesale, Global.discount, Global.addPrice);
    } else {
      if (Global.checkOutMode == 'O') {
        amount = Global.payToCustomerOrShopValue(
            Global.orders, Global.discount, Global.addPrice);
      }

      if (Global.checkOutMode == 'P') {
        amount = Global.getRedeemPaymentTotal(Global.redeems,
            discount: Global.discount);
      }
    }
    if (amount >= 0) {
      Global.amountCtrl.text =
          Global.format(amount - Global.getPaymentListTotal());
    } else {
      Global.amountCtrl.text =
          Global.format(-amount - Global.getPaymentListTotal());
    }
    setState(() {});
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

class ModernLoadingWidget extends StatelessWidget {
  const ModernLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'กำลังโหลดข้อมูล...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}