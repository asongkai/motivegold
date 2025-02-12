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
import 'package:motivegold/widget/customer/location.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:thai_idcard_reader_flutter/thai_idcard_reader_flutter.dart';

class EditCustomerScreen extends StatefulWidget {
  const EditCustomerScreen({super.key, required this.c});

  final CustomerModel c;

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
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

  final ImagePicker imagePicker = ImagePicker();
  List<File>? imageFiles = [];

  bool isSeller = false;
  bool isCustomer = false;
  bool isBuyer = false;

  ProductTypeModel? selectedType;
  ValueNotifier<dynamic>? typeNotifier;
  List<CustomerModel> customers = [];
  bool loading = false;
  CustomerModel? selectedCustomer;

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
    // implement initState
    super.initState();
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
  }

  init() async {
    setState(() {
      loading = true;
    });

    isSeller = widget.c.isSeller == 1 ? true : false;
    isBuyer = widget.c.isBuyer == 1 ? true : false;
    isCustomer = widget.c.isCustomer == 1 ? true : false;
    idCardCtrl.text = widget.c.idCard ?? '';
    companyNameCtrl.text = widget.c.companyName ?? '';
    firstNameCtrl.text = widget.c.firstName ?? '';
    lastNameCtrl.text = widget.c.lastName ?? '';
    emailAddressCtrl.text = widget.c.email ?? '';
    phoneCtrl.text = widget.c.phoneNumber ?? '';
    addressCtrl.text = widget.c.address ?? '';
    remarkCtrl.text = widget.c.remark ?? '';
    Global.addressCtrl.text = widget.c.address ?? '';

    birthDateCtrl.text =
        widget.c.doB != null ? Global.dateOnlyT(widget.c.doB.toString()) : '';

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

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("แก้ไขลูกค้า"),
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
                child: SingleChildScrollView(
                  child: SizedBox(
                    // height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
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
                                    fontSize: size.getWidthPx(8),
                                  );
                                },
                                onChanged: (ProductTypeModel value) {
                                  selectedType = value;
                                  typeNotifier!.value = value;
                                  setState(() {});
                                },
                                child: DropDownObjectChildWidget(
                                  key: GlobalKey(),
                                  fontSize: size.getWidthPx(8),
                                  projectValueNotifier: typeNotifier!,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          if (selectedType?.code == 'general')
                            if (_device != null)
                              UsbDeviceCard(
                                device: _device,
                              ),
                          if (selectedType?.code == 'general')
                            if (_card != null) Text(_card.toString()),
                          if (selectedType?.code == 'general')
                            if (_device == null || !_device!.isAttached) ...[
                              const EmptyHeader(
                                text: 'เสียบเครื่องอ่านบัตรก่อน',
                              ),
                            ],
                          if (selectedType?.code == 'general')
                            if (_error != null) Text(_error.toString()),
                          if (selectedType?.code == 'general')
                            if (_data == null &&
                                (_device != null &&
                                    _device!.hasPermission)) ...[
                              const EmptyHeader(
                                icon: Icons.credit_card,
                                text: 'เสียบบัตรประชาชนได้เลย',
                              ),
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
                          if (selectedType?.code == 'general')
                            const SizedBox(
                              height: 10,
                            ),
                          if (selectedType?.code == 'general')
                            if (_data != null)
                              if (_data!.photo.isNotEmpty)
                                Center(
                                  child: Image.memory(
                                    Uint8List.fromList(_data!.photo),
                                  ),
                                ),
                          const SizedBox(
                            height: 10,
                          ),
                          Card(
                            child: Row(
                              children: [
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text(
                                      "คือลูกค้า",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    value: isCustomer,
                                    visualDensity: VisualDensity.standard,
                                    activeColor: Colors.teal,
                                    onChanged: (newValue) {
                                      setState(() {
                                        isCustomer = newValue!;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text(
                                      "เป็นผู้ซื้อ",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    value: isBuyer,
                                    visualDensity: VisualDensity.standard,
                                    activeColor: Colors.teal,
                                    onChanged: (newValue) {
                                      setState(() {
                                        isBuyer = newValue!;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                ),
                                Expanded(
                                  child: CheckboxListTile(
                                    title: const Text(
                                      "เป็นผู้ขาย",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    value: isSeller,
                                    visualDensity: VisualDensity.standard,
                                    activeColor: Colors.teal,
                                    onChanged: (newValue) {
                                      setState(() {
                                        isSeller = newValue!;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 15,
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
                                        labelText: getIdTitle(selectedType),
                                        validator: null,
                                        inputType: TextInputType.text,
                                        controller: idCardCtrl,
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
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                          controller: lastNameCtrl,
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
                                        labelText: 'อีเมล'.tr(),
                                        validator: null,
                                        inputType: TextInputType.emailAddress,
                                        controller: emailAddressCtrl,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      buildTextFieldBig(
                                        labelText: 'โทรศัพท์'.tr(),
                                        validator: null,
                                        inputType: TextInputType.phone,
                                        controller: phoneCtrl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (selectedType?.code == 'general')
                            const SizedBox(
                              height: 15,
                            ),
                          if (selectedType?.code == 'general')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, right: 8.0),
                                    child: TextField(
                                      controller: birthDateCtrl,
                                      //editing controller of this TextField
                                      style: const TextStyle(fontSize: 38),
                                      decoration: InputDecoration(
                                        prefixIcon:
                                            const Icon(Icons.calendar_today),
                                        //icon of text field
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10.0,
                                                horizontal: 10.0),
                                        labelText: "วันเกิด".tr(),
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
                                      readOnly: true,
                                      //set it true, so that user will not able to edit text
                                      onTap: () async {
                                        DateTime? pickedDate = await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(DateTime.now().year - 200),
                                            //DateTime.now() - not to allow to choose before today.
                                            lastDate: DateTime(2101));
                                        if (pickedDate != null) {
                                          motivePrint(
                                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                          motivePrint(
                                              formattedDate); //formatted date output using intl package =>  2021-03-16
                                          //you can implement different kind of Date Format here according to your requirement
                                          setState(() {
                                            birthDateCtrl.text =
                                                formattedDate; //set output date to TextField value.
                                          });
                                        } else {
                                          motivePrint("Date is not selected");
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 15,
                          ),
                          // const LocationEntryWidget(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
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
                                          fontSize: size.getWidthPx(8),
                                        );
                                      },
                                      onChanged: (ProvinceModel value) {
                                        Global.provinceModel = value;
                                        Global.provinceNotifier!.value = value;
                                        loadAmphureByProvince(value.id);
                                      },
                                      child: LocationDropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(8),
                                        projectValueNotifier:
                                            Global.provinceNotifier!,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
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
                                          fontSize: size.getWidthPx(8),
                                        );
                                      },
                                      onChanged: (AmphureModel value) {
                                        Global.amphureModel = value;
                                        Global.amphureNotifier!.value = value;
                                        loadTambonByAmphure(value.id);
                                      },
                                      child: LocationDropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(8),
                                        projectValueNotifier:
                                            Global.amphureNotifier!,
                                      ),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 70,
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
                                          fontSize: size.getWidthPx(8),
                                        );
                                      },
                                      onChanged: (TambonModel value) {
                                        Global.tambonModel = value;
                                        Global.tambonNotifier!.value = value;
                                      },
                                      child: LocationDropDownObjectChildWidget(
                                        key: GlobalKey(),
                                        fontSize: size.getWidthPx(8),
                                        projectValueNotifier:
                                            Global.tambonNotifier!,
                                      ),
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
                  ),
                ),
              ),
            ),
      persistentFooterButtons: [
        SizedBox(
            height: 70,
            width: 150,
            child: ElevatedButton(
              style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  backgroundColor:
                      WidgetStateProperty.all<Color>(Colors.teal[700]!),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.teal[700]!)))),
              onPressed: () async {
                // if (idCardCtrl.text.isEmpty) {
                //   Alert.warning(
                //       context, 'คำเตือน', 'กรุณากรอก${getIdTitle(selectedType)}', 'OK',
                //       action: () {});
                //   return;
                // }

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
                  "nationality    ": '',
                  "postalCode": '',
                  "photoUrl": '',
                  "branchCode": branchCodeCtrl.text,
                  "idCard":
                      selectedType?.code == "general" ? idCardCtrl.text : "",
                  "taxNumber":
                      selectedType?.code == "company" ? idCardCtrl.text : "",
                  "isSeller": isSeller ? 1 : 0,
                  "isBuyer": isBuyer ? 1 : 0,
                  "isCustomer": isCustomer ? 1 : 0,
                  "remark": remarkCtrl.text,
                });

                // print(customerObject);
                // return;
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
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "บันทึก".tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  const Icon(
                    Icons.save,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            )),
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
