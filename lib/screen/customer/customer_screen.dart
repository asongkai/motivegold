import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/customer/add_customer_screen.dart';
import 'package:motivegold/screen/customer/edit_customer_screen.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key, this.selected, this.type});

  final bool? selected;
  final String? type;

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  bool loading = false;
  List<CustomerModel>? customers = [];
  List<CustomerModel?>? filterList = [];
  Screen? size;
  TextEditingController firstNameCtrl = TextEditingController();
  TextEditingController lastNameCtrl = TextEditingController();
  TextEditingController emailCtrl = TextEditingController();
  TextEditingController phoneCtrl = TextEditingController();
  TextEditingController companyNameCtrl = TextEditingController();
  TextEditingController idCardCtrl = TextEditingController();
  ProductTypeModel? selectedCustomerType;
  static ValueNotifier<dynamic>? customerTypeNotifier;

  @override
  void initState() {
    super.initState();
    customerTypeNotifier = ValueNotifier<ProductTypeModel>(customerTypes()[1]);
    selectedCustomerType = customerTypes()[1];
    loadData();
    // search();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });

    motivePrint({
      "customerType": selectedCustomerType?.code,
      "idCard":
      selectedCustomerType?.code == "general" ? idCardCtrl.text : "",
      "taxNumber":
      selectedCustomerType?.code == "company" ? idCardCtrl.text : "",
      "firstName": firstNameCtrl.text,
      "lastName": lastNameCtrl.text,
      "companyName": companyNameCtrl.text,
      "email": emailCtrl.text,
      "phoneNumber": phoneCtrl.text,
      "type": widget.type ?? "",
    });

    try {
      var result = await ApiServices.post(
          '/customer/search',
          Global.requestObj({
            "customerType": selectedCustomerType?.code,
            "idCard":
                selectedCustomerType?.code == "general" ? idCardCtrl.text : "",
            "taxNumber":
                selectedCustomerType?.code == "company" ? idCardCtrl.text : "",
            "firstName": firstNameCtrl.text,
            "lastName": lastNameCtrl.text,
            "companyName": companyNameCtrl.text,
            "email": emailCtrl.text,
            "phoneNumber": phoneCtrl.text,
            "type": widget.type ?? "",
          }));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<CustomerModel> products = customerListModelFromJson(data);
        if (products.isNotEmpty) {
          customers = products;
          filterList = products;
        } else {
          customers!.clear();
          filterList!.clear();
        }
        setState(() {});
      } else {
        customers = [];
      }
    } catch (e) {
      motivePrint(e.toString());
    }
    setState(() {
      loading = false;
    });
  }

  void search() async {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายชื่อลูกค้า'),
        actions: [
          if (widget.selected != true)
            GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(
                  MaterialPageRoute(
                    builder: (context) => const AddCustomerScreen(),
                  ),
                )
                    .whenComplete(() {
                  loadData();
                });
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.add,
                    size: 50,
                  ),
                  Text(
                    'เพิ่มลูกค้า',
                    style: TextStyle(fontSize: size.getWidthPx(6)),
                  )
                ],
              ),
            ),
          const SizedBox(
            width: 20,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
              child: Column(
            children: [
              SizedBox(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        getProportionateScreenWidth(
                          8,
                        ),
                      ),
                      topRight: Radius.circular(
                        getProportionateScreenWidth(
                          8,
                        ),
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: getProportionateScreenWidth(0),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 50,
                                  child: MiraiDropDownMenu<ProductTypeModel>(
                                    key: UniqueKey(),
                                    children: customerTypes(),
                                    space: 4,
                                    maxHeight: 360,
                                    showSearchTextField: true,
                                    selectedItemBackgroundColor:
                                        Colors.transparent,
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
                                        fontSize: size.getWidthPx(5),
                                      );
                                    },
                                    onChanged: (ProductTypeModel value) async {
                                      selectedCustomerType = value;
                                      customerTypeNotifier!.value = value;
                                      search();
                                    },
                                    child: DropDownObjectChildWidget(
                                      key: GlobalKey(),
                                      fontSize: size.getWidthPx(5),
                                      projectValueNotifier:
                                          customerTypeNotifier!,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (selectedCustomerType?.code == 'general')
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildTextField(
                                      labelText:
                                          getIdTitle(selectedCustomerType),
                                      textColor: Colors.deepPurple[700],
                                      onSubmitted: (value) {
                                        search();
                                      },
                                      controller: idCardCtrl),
                                ),
                              ),
                            if (selectedCustomerType?.code == 'general')
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildTextField(
                                      labelText: "ชื่อ",
                                      textColor: Colors.deepPurple[700],
                                      onSubmitted: (value) {
                                        search();
                                      },
                                      controller: firstNameCtrl),
                                ),
                              ),
                            if (selectedCustomerType?.code == 'general')
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildTextField(
                                      labelText: "นามสกุล",
                                      textColor: Colors.deepPurple[700],
                                      onSubmitted: (value) {
                                        search();
                                      },
                                      controller: lastNameCtrl),
                                ),
                              ),
                            if (selectedCustomerType?.code == 'company')
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: buildTextField(
                                      labelText: "ชื่อบริษัท",
                                      textColor: Colors.deepPurple[700],
                                      onSubmitted: (value) {
                                        search();
                                      },
                                      controller: companyNameCtrl),
                                ),
                              ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextField(
                                    labelText: "อีเมล",
                                    textColor: Colors.deepPurple[700],
                                    onSubmitted: (value) {
                                      search();
                                    },
                                    controller: emailCtrl),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildTextField(
                                    labelText: "โทรศัพท์",
                                    textColor: Colors.deepPurple[700],
                                    onSubmitted: (value) {
                                      search();
                                    },
                                    controller: phoneCtrl),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(3.0)),
                              child: KclButton(
                                onTap: () {
                                  firstNameCtrl.text = "";
                                  lastNameCtrl.text = "";
                                  emailCtrl.text = "";
                                  phoneCtrl.text = "";
                                  companyNameCtrl.text = "";
                                  idCardCtrl.text = "";
                                  firstNameCtrl.text = "";
                                  lastNameCtrl.text = "";
                                  selectedCustomerType = customerTypes()[1];
                                  customerTypeNotifier =
                                      ValueNotifier<ProductTypeModel>(
                                          selectedCustomerType ??
                                              customerTypes()[1]);
                                  loadData();
                                },
                                color: Colors.redAccent,
                                icon: Icons.clear,
                                text: 'Reset',
                                fullWidth: false,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: getProportionateScreenWidth(3.0)),
                              child: KclButton(
                                onTap: search,
                                icon: Icons.search,
                                text: 'ค้นหา',
                                fullWidth: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Divider(
                thickness: 1.0,
              ),
              loading
                  ? Container(
                      margin: const EdgeInsets.only(top: 100),
                      child: const LoadingProgress())
                  : productCard(filterList!),
            ],
          )),
        ),
      ),
    );
  }

  Widget productCard(List<CustomerModel?> ods) {
    return filterList!.isEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 100),
            child: const NoDataFoundWidget())
        : Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  border: TableBorder.all(color: Colors.grey[300]!),
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(4),
                    2: FlexColumnWidth(4),
                    3: FlexColumnWidth(3)
                  },
                  children: [
                    TableRow(children: [
                      SizedBox(
                          width: 50,
                          child: paddedTextBigL('No', align: TextAlign.center)),
                      paddedTextBigL('ชื่อเต็ม', align: TextAlign.center),
                      paddedTextBigL('ข้อมูลการติดต่อ',
                          align: TextAlign.center),
                      // paddedTextBigL('เลขประจําตัวผู้เสียภาษี',
                      //     align: TextAlign.center),
                      // paddedTextBigL('ที่อยู่', align: TextAlign.center),
                      paddedTextBigL('', align: TextAlign.center),
                    ]),
                    for (int i = 0; i < ods.length; i++)
                      TableRow(
                        decoration: const BoxDecoration(),
                        children: [
                          paddedTextBigL('${i + 1}', align: TextAlign.center),
                          paddedTextBigL(
                              'ชื่อ: \n${ods[i]?.firstName} ${ods[i]?.lastName} \n${getIdTitle(selectedCustomerType)}: \n${selectedCustomerType?.code == 'general' ? ods[i]?.idCard : ods[i]?.taxNumber}',
                              align: TextAlign.left),
                          paddedTextBigL(
                              'Email: \n${ods[i]?.email} \nโทรศัพท์: \n${ods[i]?.phoneNumber}',
                              align: TextAlign.left),
                          // paddedTextBigL('${ods[i]?.taxNumber}',
                          //     align: TextAlign.center),
                          // paddedTextBigL('${ods[i]?.address}',
                          //     align: TextAlign.center),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [

                                  Row(
                                    children: [

                                      if (widget.selected == true)
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                Global.customer = ods[i];
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            child: Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                  color: Colors.teal[700],
                                                  borderRadius:
                                                  BorderRadius.circular(8)),
                                              child: const Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.check_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    'เลือก',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 20),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (widget.selected == true)
                                        const SizedBox(
                                          width: 10,
                                        ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            EditCustomerScreen(
                                                                c: ods[i]!),
                                                        fullscreenDialog: true))
                                                .whenComplete(() {
                                              loadData();
                                              setState(() {});
                                            });
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.blue[700],
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: const Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  'แก้ไข',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (widget.selected != true)
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      if (widget.selected != true)
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            deleteCustomer(
                                                context, ods[i]!.id, i);
                                          },
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            child: const Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  'ลบ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),

                              ],
                            ),
                          )
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
  }

  deleteCustomer(BuildContext context, int? id, int i) {
    motivePrint('deleted');
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.delete('/customer', id);
        await pr.hide();
        if (result?.status == "success") {
          filterList!.removeAt(i);
          setState(() {});
        } else {
          if (mounted) {
            Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
                action: () {});
          }
        }
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
              action: () {});
        }
      }
    });
  }
}
