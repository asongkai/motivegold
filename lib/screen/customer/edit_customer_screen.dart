import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/customer/widget/card_reader_info.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';
import 'package:thai_idcard_reader_flutter/thai_idcard_reader_flutter.dart';

class EditCustomerScreen extends StatefulWidget {
  const EditCustomerScreen({super.key, required this.c});

  final CustomerModel c;

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen>
    with TickerProviderStateMixin {
  AnimationController? _fadeController;
  AnimationController? _slideController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  final TextEditingController idCardCtrl = TextEditingController();
  final TextEditingController branchCodeCtrl = TextEditingController();
  final TextEditingController firstNameCtrl = TextEditingController();
  final TextEditingController lastNameCtrl = TextEditingController();
  final TextEditingController emailAddressCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController birthDateCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  TextEditingController companyNameCtrl = TextEditingController();
  TextEditingController remarkCtrl = TextEditingController();
  TextEditingController occupationCtrl = TextEditingController();

  final TextEditingController workPermitCtrl = TextEditingController();
  final TextEditingController passportNoCtrl = TextEditingController();
  final TextEditingController taxNumberCtrl = TextEditingController();
  final TextEditingController postalCodeCtrl = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<File>? imageFiles = [];

  bool isSeller = false;
  bool isCustomer = false;
  bool isBuyer = false;
  String? selectedBusinessType;

  ProductTypeModel? selectedType;
  ValueNotifier<dynamic>? typeNotifier;
  List<CustomerModel> customers = [];
  bool loading = false;
  CustomerModel? selectedCustomer;
  String? nationality;

  ThaiIDCard? _data;
  String? _error;
  UsbDevice? _device;
  dynamic _card;
  StreamSubscription? subscription;
  final List _idCardType = [
    ThaiIDType.cid,
    ThaiIDType.photo,
    ThaiIDType.nameTH,
    ThaiIDType.nameEN,
    ThaiIDType.gender,
    ThaiIDType.birthdate,
    ThaiIDType.address,
    ThaiIDType.issueDate,
    ThaiIDType.expireDate,
  ];
  List<String> selectedTypes = [];

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController!,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController!,
      curve: Curves.easeOutCubic,
    ));

    motivePrint(widget.c.toJson());
    Global.provinceNotifier = ValueNotifier<ProvinceModel>(
        ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
    Global.amphureNotifier =
        ValueNotifier<AmphureModel>(AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
    Global.tambonNotifier =
        ValueNotifier<TambonModel>(TambonModel(id: 0, nameTh: 'เลือกตำบล'));
    var type =
    customerTypes().where((e) => e.code == widget.c.customerType).toList();
    if (type.isNotEmpty) {
      selectedType = type.first;
    } else {
      selectedType = customerTypes()[1];
    }
    typeNotifier =
        ValueNotifier<ProductTypeModel>(selectedType ?? customerTypes()[1]);

    // birthDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    // Global.addressCtrl.text = "";
    ThaiIdcardReaderFlutter.deviceHandlerStream.listen(_onUSB);
    init();

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController?.forward();
        _slideController?.forward();
      }
    });
  }

  @override
  void dispose() {
    _fadeController?.dispose();
    _slideController?.dispose();
    subscription?.cancel();
    super.dispose();
  }

  init() async {
    setState(() {
      loading = true;
    });

    isSeller = widget.c.isSeller == 1 ? true : false;
    isBuyer = widget.c.isBuyer == 1 ? true : false;
    isCustomer = widget.c.isCustomer == 1 ? true : false;

    // Set the selected business type based on existing data
    if (isCustomer) {
      selectedBusinessType = 'customer';
    } else if (isBuyer) {
      selectedBusinessType = 'buyer';
    } else if (isSeller) {
      selectedBusinessType = 'seller';
    }

    nationality = widget.c.nationality ?? '';
    idCardCtrl.text = widget.c.idCard ?? '';
    companyNameCtrl.text = widget.c.companyName ?? '';
    firstNameCtrl.text = widget.c.firstName ?? '';
    lastNameCtrl.text = widget.c.lastName ?? '';
    emailAddressCtrl.text = widget.c.email ?? '';
    phoneCtrl.text = widget.c.phoneNumber ?? '';
    addressCtrl.text = widget.c.address ?? '';
    remarkCtrl.text = widget.c.remark ?? '';
    workPermitCtrl.text = widget.c.workPermit ?? '';
    passportNoCtrl.text = widget.c.passportId ?? '';
    taxNumberCtrl.text = widget.c.taxNumber ?? '';
    postalCodeCtrl.text = widget.c.postalCode ?? '';
    Global.addressCtrl.text = widget.c.address ?? '';
    branchCodeCtrl.text = widget.c.branchCode ?? '';

    birthDateCtrl.text =
    widget.c.doB != null ? Global.dateOnlyT(widget.c.doB.toString()) : '';

    motivePrint(widget.c.toJson());

    try {
      var province =
      await ApiServices.post('/customer/province', Global.requestObj(null));
      // motivePrint(province!.toJson());
      if (province?.status == "success") {
        var data = jsonEncode(province?.data);
        List<ProvinceModel> products = provinceModelFromJson(data);
        setState(() {
          Global.provinceList = products;
        });
      } else {
        Global.provinceList = [];
      }

      filterChungVatById(widget.c.provinceId ?? 0);
      await loadAmphureByProvince(widget.c.provinceId ?? 0);
      filterAmpheryId(widget.c.amphureId ?? 0);
      await loadTambonByAmphure(widget.c.amphureId ?? 0);
      filterTambonById(widget.c.tambonId ?? 0);
      Future.delayed(const Duration(seconds: 3));
      setState(() {});
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      loading = false;
    });
  }

  void _onUSB(usbEvent) {
    try {
      if (usbEvent.hasPermission) {
        subscription =
            ThaiIdcardReaderFlutter.cardHandlerStream.listen(_onData);
      } else {
        if (subscription == null) {
          subscription?.cancel();
          subscription = null;
        }
        _clear();
      }
      setState(() {
        _device = usbEvent;
      });
    } catch (e) {
      setState(() {
        _error = "_onUSB $e";
      });
      Alert.error(context, 'OnUsb', "$e", 'OK', action: () {});
    }
  }

  void _onData(readerEvent) {
    try {
      setState(() {
        _card = readerEvent;
      });
      if (readerEvent.isReady) {
        readCard(only: selectedTypes);
      } else {
        _clear();
      }
    } catch (e) {
      setState(() {
        _error = "_onData $e";
      });
      Alert.error(context, 'OnData', "$e", 'OK', action: () {});
    }
  }

  readCard({List<String> only = const []}) async {
    try {
      var response = await ThaiIdcardReaderFlutter.read(only: only);
      setState(() {
        _data = response;
      });

      if (_data != null) {
        idCardCtrl.text = _data!.cid!;
        if (_data!.firstnameTH != null) {
          firstNameCtrl.text = '${_data!.titleTH} ${_data!.firstnameTH}';
          lastNameCtrl.text = '${_data?.lastnameTH!}';
        } else {
          firstNameCtrl.text = '${_data!.titleEN} ${_data!.firstnameEN}';
          lastNameCtrl.text = '${_data?.lastnameEN!}';
        }
        emailAddressCtrl.text = "";
        phoneCtrl.text = "";
        var address0 = _data!.address ?? "";

        if (address0.isNotEmpty) {
          var sp1 = address0.split("ตำบล");
          var sp2 = sp1[1].split("อำเภอ");
          var sp3 = sp2[1].split("จังหวัด");

          var address = sp1[0].trimLeft().trimRight();
          var tambon = sp2[0].trimLeft().trimRight();
          var ampher = sp3[0].trimLeft().trimRight();
          var chunvat = sp3[1].trimLeft().trimRight();

          Global.addressCtrl.text = address0;

          int? chungVatId = filterChungVatByName(chunvat);
          await loadAmphureByProvince(chungVatId);
          int? ampherId = filterAmpheryName(ampher);
          await loadTambonByAmphure(ampherId);
          int? tambonId = filterTambonByName(tambon);
          Alert.success(context, 'Success', 'ID Synced', 'OK', action: () {
            setState(() {});
          });
        }

        birthDateCtrl.text = Global.formatDateDD(_data!.birthdate!);
      }
      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'ERR readCard $e';
      });
      if (mounted) {
        Alert.warning(context, 'ERR readCard'.tr(), '$e', 'OK'.tr());
      }
    }
  }

  formattedDate(dt) {
    try {
      DateTime dateTime = DateTime.parse(dt);
      String formattedDate = DateFormat.yMMMMd('th_TH').format(dateTime);
      return formattedDate;
    } catch (e) {
      return dt.split('').toString() + e.toString();
    }
  }

  _clear() {
    setState(() {
      _data = null;
    });
  }

  Widget _buildModernCard({
    required Widget child,
    EdgeInsets? padding,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget buildTextFieldBig({
    required String labelText,
    String? validator,
    required TextInputType inputType,
    required TextEditingController controller,
    Widget? prefixIcon,
    int maxLines = 1,
    int line = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: line > 1 ? line : maxLines,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCheckboxTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required Color color,
    required Function(bool?) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: value
            ? LinearGradient(
          colors: [
            color.withValues(alpha:0.1),
            color.withValues(alpha:0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : null,
        color: value ? null : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value ? color : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
        boxShadow: value ? [
          BoxShadow(
            color: color.withValues(alpha:0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: value ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: value ? color : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                  child: value
                      ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  )
                      : null,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: value ? color.withValues(alpha:0.2) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: value ? color : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: value ? color : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: value ? color.withValues(alpha:0.8) : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (value)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'เลือกแล้ว',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("แก้ไขลูกค้า",
              style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: loading
          ? const Center(
        child: LoadingProgress(),
      )
          : SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: FadeTransition(
            opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: SlideTransition(
              position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ประเภทลูกค้า',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 70,
                                child: MiraiDropDownMenu<ProductTypeModel>(
                                  key: UniqueKey(),
                                  children: customerTypes(),
                                  space: 4,
                                  maxHeight: 360,
                                  showSearchTextField: true,
                                  selectedItemBackgroundColor: Colors.transparent,
                                  emptyListMessage: 'ไม่มีข้อมูล',
                                  showSelectedItemBackgroundColor: true,
                                  itemWidgetBuilder: (
                                      int index,
                                      ProductTypeModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                    return DropDownItemWidget(
                                      project: project,
                                      isItemSelected: isItemSelected,
                                      firstSpace: 10,
                                      fontSize: 14.sp,
                                    );
                                  },
                                  onChanged: (ProductTypeModel value) {
                                    selectedType = value;
                                    typeNotifier!.value = value;
                                    setState(() {});
                                  },
                                  child: DropDownObjectChildWidget(
                                    key: GlobalKey(),
                                    fontSize: 14.sp,
                                    projectValueNotifier: typeNotifier!,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        if (selectedType?.code == 'general')
                          if (_device != null)
                            _buildModernCard(
                              child: UsbDeviceCard(
                                device: _device,
                              ),
                            ),
                        if (selectedType?.code == 'general')
                          if (_card != null)
                            _buildModernCard(
                              child: Text(_card.toString(), style: const TextStyle(fontSize: 16)),
                            ),
                        if (selectedType?.code == 'general')
                          if (_device == null || !_device!.isAttached) ...[
                            _buildModernCard(
                              color: Colors.orange[50],
                              child: const EmptyHeader(
                                text: 'เสียบเครื่องอ่านบัตรก่อน',
                              ),
                            ),
                          ],
                        if (selectedType?.code == 'general')
                          if (_error != null)
                            _buildModernCard(
                              color: Colors.red[50],
                              child: Text(_error.toString(), style: TextStyle(color: Colors.red[700], fontSize: 16)),
                            ),
                        if (selectedType?.code == 'general')
                          if (_data == null &&
                              (_device != null &&
                                  _device!.hasPermission)) ...[
                            _buildModernCard(
                              color: Colors.blue[50],
                              child: Column(
                                children: [
                                  const EmptyHeader(
                                    icon: Icons.credit_card,
                                    text: 'เสียบบัตรประชาชนได้เลย',
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: Wrap(children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Checkbox(
                                              value: selectedTypes.isEmpty,
                                              onChanged: (val) {
                                                setState(() {
                                                  if (selectedTypes.isNotEmpty) {
                                                    selectedTypes = [];
                                                  }
                                                });
                                              }),
                                          const Text('readAll'),
                                        ],
                                      ),
                                      for (var ea in _idCardType)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                                value: selectedTypes.contains(ea),
                                                onChanged: (val) {
                                                  motivePrint(ea);
                                                  setState(() {
                                                    if (selectedTypes
                                                        .contains(ea)) {
                                                      selectedTypes.remove(ea);
                                                    } else {
                                                      selectedTypes.add(ea);
                                                    }
                                                  });
                                                }),
                                            Text('$ea'),
                                          ],
                                        ),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        if (selectedType?.code == 'general')
                          const SizedBox(
                            height: 10,
                          ),
                        if (selectedType?.code == 'general')
                          if (_data != null)
                            if (_data!.photo.isNotEmpty)
                              _buildModernCard(
                                child: Center(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      Uint8List.fromList(_data!.photo),
                                    ),
                                  ),
                                ),
                              ),
                        _buildModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ข้อมูลส่วนตัว',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: nationality == 'Thai' ? Colors.teal.withValues(alpha:0.1) : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: nationality == 'Thai' ? Colors.teal : Colors.grey[300]!,
                                          width: nationality == 'Thai' ? 2 : 1,
                                        ),
                                      ),
                                      child: RadioListTile<String>(
                                        title: Text(
                                          'สัญชาติไทย',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        value: 'Thai',
                                        groupValue: nationality,
                                        visualDensity: VisualDensity.standard,
                                        activeColor: Colors.teal,
                                        onChanged: (String? value) {
                                          setState(() {
                                            nationality = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: nationality == 'Foreigner' ? Colors.teal.withValues(alpha:0.1) : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: nationality == 'Foreigner' ? Colors.teal : Colors.grey[300]!,
                                          width: nationality == 'Foreigner' ? 2 : 1,
                                        ),
                                      ),
                                      child: RadioListTile<String>(
                                        title: Text(
                                          'ต่างชาติ',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        value: 'Foreigner',
                                        groupValue: nationality,
                                        visualDensity: VisualDensity.standard,
                                        activeColor: Colors.teal,
                                        onChanged: (String? value) {
                                          setState(() {
                                            nationality = value;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  if (nationality == 'Thai')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText:
                                              getIdTitle(selectedType),
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller:
                                              selectedType?.code ==
                                                  'company'
                                                  ? taxNumberCtrl
                                                  : idCardCtrl,
                                              prefixIcon: Icon(Icons.credit_card, size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (nationality == 'Foreigner')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText: 'Work Permit',
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: workPermitCtrl,
                                              prefixIcon: Icon(Icons.work, size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (nationality == 'Foreigner')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText: 'Passport ID',
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: passportNoCtrl,
                                              prefixIcon: Icon(Icons.flight, size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (nationality == 'Foreigner')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText: 'Tax ID',
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: taxNumberCtrl,
                                              prefixIcon: Icon(Icons.receipt, size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (selectedType?.code == 'company')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText: 'รหัสสาขา'.tr(),
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: branchCodeCtrl,
                                              prefixIcon: Icon(Icons.store, size: 14.sp),
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
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  if (selectedType?.code == 'general')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText: 'ชื่อ'.tr(),
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: firstNameCtrl,
                                              prefixIcon: Icon(Icons.person, size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (selectedType?.code == 'general')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText: 'นามสกุล'.tr(),
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: lastNameCtrl,
                                              prefixIcon: Icon(Icons.person_outline, size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (selectedType?.code == 'company')
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            buildTextFieldBig(
                                              labelText: 'ชื่อบริษัท'.tr(),
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: companyNameCtrl,
                                              prefixIcon: Icon(Icons.business, size: 14.sp),
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
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          buildTextFieldBig(
                                            labelText: 'อีเมล'.tr(),
                                            validator: null,
                                            inputType:
                                            TextInputType.emailAddress,
                                            controller: emailAddressCtrl,
                                            prefixIcon: Icon(Icons.email, size: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          buildTextFieldBig(
                                            labelText: 'โทรศัพท์'.tr(),
                                            validator: null,
                                            inputType: TextInputType.phone,
                                            controller: phoneCtrl,
                                            prefixIcon: Icon(Icons.phone, size: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (selectedType?.code == 'general')
                                const SizedBox(
                                  height: 10,
                                ),
                              if (selectedType?.code == 'general')
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha:0.03),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: birthDateCtrl,
                                            //editing controller of this TextField
                                            style:
                                            TextStyle(fontSize: 14.sp),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                  Icons.calendar_today, size: 14.sp),
                                              //icon of text field
                                              floatingLabelBehavior:
                                              FloatingLabelBehavior
                                                  .always,
                                              contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 16.0),
                                              labelText: "วันเกิด".tr(),
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: const BorderSide(color: Colors.teal, width: 2),
                                              ),
                                            ),
                                            readOnly: true,
                                            //set it true, so that user will not able to edit text
                                            onTap: () async {
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
                                                        DateFormat(
                                                            'yyyy-MM-dd')
                                                            .format(date);
                                                        motivePrint(
                                                            formattedDate); //formatted date output using intl package =>  2021-03-16
                                                        //you can implement different kind of Date Format here according to your requirement
                                                        setState(() {
                                                          birthDateCtrl.text =
                                                              formattedDate; //set output date to TextField value.
                                                        });
                                                      },
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          buildTextFieldBig(
                                            labelText: 'อาชีพ',
                                            inputType: TextInputType.text,
                                            controller: occupationCtrl,
                                            prefixIcon: Icon(Icons.work_outline, size: 14.sp),
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
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          buildTextFieldBig(
                                            labelText:
                                            'รหัสไปรษณีย์ / Postal Code',
                                            inputType: TextInputType.phone,
                                            controller: postalCodeCtrl,
                                            prefixIcon: Icon(Icons.local_post_office, size: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                        _buildModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ประเภทการใช้งาน',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildModernCheckboxTile(
                                title: "ซื้อขายหน้าร้าน",
                                subtitle: "การซื้อขายสินค้าผ่านหน้าร้าน",
                                value: isCustomer,
                                icon: Icons.store,
                                color: Colors.blue,
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue!) {
                                      selectedBusinessType = 'customer';
                                      isCustomer = true;
                                    } else {
                                      selectedBusinessType = null;
                                      isCustomer = false;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModernCheckboxTile(
                                title: "ซื้อขายกับร้านค้าส่ง",
                                subtitle: "การซื้อขายสินค้าขายส่ง",
                                value: isBuyer,
                                icon: Icons.business,
                                color: Colors.green,
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue!) {
                                      selectedBusinessType = 'buyer';
                                      isBuyer = true;
                                    } else {
                                      selectedBusinessType = null;
                                      isBuyer = false;
                                    }
                                  });
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildModernCheckboxTile(
                                title: "ซื้อขายกับร้านทองตู้แดง",
                                subtitle: "การซื้อขายทองผ่านตู้แดง",
                                value: isSeller,
                                icon: Icons.inventory,
                                color: Colors.orange,
                                onChanged: (newValue) {
                                  setState(() {
                                    if (newValue!) {
                                      selectedBusinessType = 'seller';
                                      isSeller = true;
                                    } else {
                                      selectedBusinessType = null;
                                      isSeller = false;
                                    }
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // const LocationEntryWidget(),
                        _buildModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ข้อมูลที่อยู่',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เลือกจังหวัด',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: textColor),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Container(
                                            height: 70,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey[300]!),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha:0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: MiraiDropDownMenu<ProvinceModel>(
                                              key: UniqueKey(),
                                              children: Global.provinceList,
                                              space: 4,
                                              maxHeight: 360,
                                              showSearchTextField: true,
                                              selectedItemBackgroundColor:
                                              Colors.transparent,
                                              emptyListMessage: 'ไม่มีข้อมูล',
                                              showSelectedItemBackgroundColor: true,
                                              itemWidgetBuilder: (
                                                  int index,
                                                  ProvinceModel? project, {
                                                    bool isItemSelected = false,
                                                  }) {
                                                return LocationDropDownItemWidget(
                                                  project: project,
                                                  isItemSelected: isItemSelected,
                                                  firstSpace: 10,
                                                  fontSize: 14.sp,
                                                );
                                              },
                                              onChanged: (ProvinceModel value) {
                                                Global.provinceModel = value;
                                                Global.provinceNotifier!.value =
                                                    value;
                                                loadAmphureByProvince(value.id);
                                              },
                                              child:
                                              LocationDropDownObjectChildWidget(
                                                key: GlobalKey(),
                                                fontSize: 14.sp,
                                                projectValueNotifier:
                                                Global.provinceNotifier!,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เลือกอำเภอ',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: textColor),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Container(
                                            height: 70,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey[300]!),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha:0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: MiraiDropDownMenu<AmphureModel>(
                                              key: UniqueKey(),
                                              children: Global.amphureList,
                                              space: 4,
                                              maxHeight: 360,
                                              showSearchTextField: true,
                                              selectedItemBackgroundColor:
                                              Colors.transparent,
                                              emptyListMessage: 'ไม่มีข้อมูล',
                                              showSelectedItemBackgroundColor: true,
                                              itemWidgetBuilder: (
                                                  int index,
                                                  AmphureModel? project, {
                                                    bool isItemSelected = false,
                                                  }) {
                                                return LocationDropDownItemWidget(
                                                  project: project,
                                                  isItemSelected: isItemSelected,
                                                  firstSpace: 10,
                                                  fontSize: 14.sp,
                                                );
                                              },
                                              onChanged: (AmphureModel value) {
                                                Global.amphureModel = value;
                                                Global.amphureNotifier!.value =
                                                    value;
                                                loadTambonByAmphure(value.id);
                                              },
                                              child:
                                              LocationDropDownObjectChildWidget(
                                                key: GlobalKey(),
                                                fontSize: 14.sp,
                                                projectValueNotifier:
                                                Global.amphureNotifier!,
                                              ),
                                            ),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'เลือกตำบล',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: textColor),
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Container(
                                            height: 70,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey[300]!),
                                              color: Colors.white,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha:0.03),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: MiraiDropDownMenu<TambonModel>(
                                              key: UniqueKey(),
                                              children: Global.tambonList,
                                              space: 4,
                                              maxHeight: 360,
                                              showSearchTextField: true,
                                              selectedItemBackgroundColor:
                                              Colors.transparent,
                                              emptyListMessage: 'ไม่มีข้อมูล',
                                              showSelectedItemBackgroundColor: true,
                                              itemWidgetBuilder: (
                                                  int index,
                                                  TambonModel? project, {
                                                    bool isItemSelected = false,
                                                  }) {
                                                return LocationDropDownItemWidget(
                                                  project: project,
                                                  isItemSelected: isItemSelected,
                                                  firstSpace: 10,
                                                  fontSize: 14.sp,
                                                );
                                              },
                                              onChanged: (TambonModel value) {
                                                Global.tambonModel = value;
                                                Global.tambonNotifier!.value =
                                                    value;
                                              },
                                              child:
                                              LocationDropDownObjectChildWidget(
                                                key: GlobalKey(),
                                                fontSize: 14.sp,
                                                projectValueNotifier:
                                                Global.tambonNotifier!,
                                              ),
                                            ),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          buildTextFieldBig(
                                            line: 3,
                                            labelText: 'ที่อยู่'.tr(),
                                            validator: null,
                                            inputType: TextInputType.text,
                                            controller: Global.addressCtrl,
                                            prefixIcon: Icon(Icons.location_on, size: 14.sp),
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          buildTextFieldBig(
                                            line: 2,
                                            labelText: 'หมายเหตุ'.tr(),
                                            validator: null,
                                            inputType: TextInputType.text,
                                            controller: remarkCtrl,
                                            prefixIcon: Icon(Icons.note, size: 14.sp),
                                          ),
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton(
            style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                backgroundColor:
                WidgetStateProperty.all<Color>(Colors.teal[700]!),
                elevation: WidgetStateProperty.all<double>(0),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: BorderSide.none))),
            onPressed: () async {
              if (nationality == null || nationality == "") {
                Alert.warning(context, 'คำเตือน', 'กรุณาเลือกสัญชาติ', 'OK',
                    action: () {});
                return;
              }

              var customerObject = Global.requestObj({
                "id": widget.c.id,
                "customerType": selectedType?.code,
                "companyName": companyNameCtrl.text,
                "firstName": firstNameCtrl.text,
                "lastName": lastNameCtrl.text,
                "email": emailAddressCtrl.text,
                "doB": birthDateCtrl.text.isEmpty
                    ? ""
                    : DateTime.parse(birthDateCtrl.text).toString(),
                "phoneNumber": phoneCtrl.text,
                "username": generateRandomString(8),
                "password": generateRandomString(10),
                "address": Global.addressCtrl.text,
                "tambonId": Global.tambonModel?.id,
                "amphureId": Global.amphureModel?.id,
                "provinceId": Global.provinceModel?.id,
                "nationality": nationality,
                "postalCode": postalCodeCtrl.text,
                "photoUrl": '',
                "branchCode": branchCodeCtrl.text,
                "idCard":
                selectedType?.code == "general" ? idCardCtrl.text : "",
                "taxNumber": selectedType?.code == "company"
                    ? nationality == 'Thai'
                    ? taxNumberCtrl.text
                    : idCardCtrl.text
                    : nationality == 'Thai'
                    ? idCardCtrl.text
                    : taxNumberCtrl.text,
                "isSeller": isSeller ? 1 : 0,
                "isBuyer": isBuyer ? 1 : 0,
                "isCustomer": isCustomer ? 1 : 0,
                "workPermit": workPermitCtrl.text,
                "passportId": passportNoCtrl.text,
                "remark": remarkCtrl.text,
                "occupation": occupationCtrl.text,
              });

              // print(customerObject);
              // return;
              Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
                  action: () async {
                    final ProgressDialog pr = ProgressDialog(context,
                        type: ProgressDialogType.normal,
                        isDismissible: true,
                        showLogs: true);
                    await pr.show();
                    pr.update(message: 'processing'.tr());
                    // try {
                    var result = await ApiServices.put(
                        '/customer', widget.c.id, customerObject);
                    motivePrint(result?.toJson());
                    await pr.hide();
                    if (result?.status == "success") {
                      if (mounted) {
                        CustomerModel customer =
                        customerModelFromJson(jsonEncode(result!.data!));
                        // print(customer.toJson());
                        setState(() {
                          Global.customer = customer;
                        });
                        Alert.success(context, 'Success'.tr(),
                            "บันทึกเรียบร้อยแล้ว", 'OK'.tr(), action: () {
                              Navigator.of(context).pop();
                            });
                      }
                    } else {
                      if (mounted) {
                        Alert.warning(context, 'Warning'.tr(),
                            result!.message ?? result.data, 'OK'.tr(),
                            action: () {});
                      }
                    }
                    // } catch (e) {
                    //   await pr.hide();
                    //   if (mounted) {
                    //     Alert.warning(
                    //         context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                    //         action: () {});
                    //   }
                    // }
                  });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "บันทึก".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 32),
                ),
                const SizedBox(
                  width: 8,
                ),
                const Icon(
                  Icons.save,
                  color: Colors.white,
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  saveRow() {
    if (birthDateCtrl.text.isEmpty) {
      Alert.warning(
          context, 'คำเตือน'.tr(), 'กรุณาเลือกวันเกิด'.tr(), 'OK'.tr(),
          action: () {});
      return;
    }

    if (Motive.imagesFileList!.isEmpty) {
      Alert.warning(context, 'คำเตือน'.tr(), 'กรุณาเลือกรูปภาพ'.tr(), 'OK'.tr(),
          action: () {});
      return;
    }

    setState(() {});
  }

  openImages() async {
    try {
      var pickedFiles = await imagePicker.pickMultiImage();
      //you can use ImageCourse.camera for Camera capture
      imageFiles = pickedFiles.map((e) => File(e.path)).toList();
      Motive.imagesFileList = imageFiles;
      setState(() {});
    } catch (e) {
      motivePrint("error while picking file.");
    }
  }

  String getCustomerType(CustomerModel e) {
    if (e.isSeller == 1) {
      return 'ผู้ขาย';
    }
    if (e.isBuyer == 1) {
      return 'ผู้ซื้อ';
    }
    if (e.isCustomer == 1) {
      return 'ลูกค้า';
    }
    return 'ลูกค้า';
  }

// loadAmphureByProvince(int? id) async {
//   // final ProgressDialog pr = ProgressDialog(context,
//   //     type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
//   // await pr.show();
//   // pr.update(message: 'processing'.tr());
//   try {
//     var result =
//     await ApiServices.post('/customer/amphure/$id', Global.requestObj(null));
//     // motivePrint(result!.toJson());
//     // await pr.hide();
//     if (result?.status == "success") {
//       var data = jsonEncode(result?.data);
//       List<AmphureModel> products = amphureModelFromJson(data);
//       setState(() {
//         Global.amphureList = products;
//       });
//     } else {
//       Global.amphureList = [];
//     }
//
//   } catch (e) {
//     // await pr.hide();
//     motivePrint(e.toString());
//   }
// }
//
// loadTambonByAmphure(int? id) async {
//   // final ProgressDialog pr = ProgressDialog(context,
//   //     type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
//   // await pr.show();
//   // pr.update(message: 'processing'.tr());
//   try {
//     var result =
//     await ApiServices.post('/customer/tambon/$id', Global.requestObj(null));
//     // motivePrint(result!.toJson());
//     // await pr.hide();
//     if (result?.status == "success") {
//       var data = jsonEncode(result?.data);
//       List<TambonModel> products = tambonModelFromJson(data);
//       setState(() {
//         Global.tambonList = products;
//       });
//     } else {
//       Global.tambonList = [];
//     }
//
//   } catch (e) {
//     // await pr.hide();
//     motivePrint(e.toString());
//   }
// }
}