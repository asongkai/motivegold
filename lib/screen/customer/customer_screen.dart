import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/screen/customer/add_customer_screen.dart';
import 'package:motivegold/screen/customer/edit_customer_screen.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
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
import 'package:sizer/sizer.dart';

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
    customerTypeNotifier = ValueNotifier<ProductTypeModel?>(null);
    selectedCustomerType = null; //customerTypes()[1];
    if (widget.selected == true) {
      defaultCustomerType();
      search();
    } else {
      loadData();
    }
  }

  defaultCustomerType() {
    final validOrderTypeIds = {5, 10, 6, 11, 8, 9}; // Use Set for faster lookup

    if (Global.orders
        .any((order) => validOrderTypeIds.contains(order.orderTypeId))) {
      customerTypeNotifier =
          ValueNotifier<ProductTypeModel>(customerTypes()[0]);
      selectedCustomerType = customerTypes()[0];
    } else {
      customerTypeNotifier =
          ValueNotifier<ProductTypeModel>(customerTypes()[1]);
      selectedCustomerType = customerTypes()[1];
    }

    search();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });

    try {
      var result = await ApiServices.post(
          '/customer/all',
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

    if (selectedCustomerType == null && emailCtrl.text.isEmpty && phoneCtrl.text.isEmpty) {
      loadData();
      return;
    }

    setState(() {
      loading = true;
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
          customers = products.reversed.toList();
          filterList = products.reversed.toList();
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

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.selected ?? false,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("รายชื่อลูกค้า",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w900)),
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
                    child: Container(
                      color: Colors.teal[900],
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              size: 50,
                              color: Colors.white,
                            ),
                            Text(
                              'เพิ่มลูกค้า',
                              style: TextStyle(
                                  fontSize: 14.sp, //size.getWidthPx(10),
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'เลือกประเภทลูกค้า',
                                        style: TextStyle(
                                            fontSize: size.getWidthPx(8),
                                            color: textColor),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      SizedBox(
                                        height: 50,
                                        child:
                                            MiraiDropDownMenu<ProductTypeModel>(
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
                                              fontSize: size.getWidthPx(8),
                                            );
                                          },
                                          onChanged:
                                              (ProductTypeModel value) async {
                                            selectedCustomerType = value;
                                            customerTypeNotifier!.value = value;
                                            search();
                                          },
                                          child: DropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: size.getWidthPx(8),
                                            projectValueNotifier:
                                                customerTypeNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                        labelColor: Colors.deepPurple[700],
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
                                        labelColor: Colors.deepPurple[700],
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
                                        labelColor: Colors.deepPurple[700],
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
                                        labelColor: Colors.deepPurple[700],
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
                                      labelColor: Colors.deepPurple[700],
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
                                      labelColor: Colors.deepPurple[700],
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
                                    selectedCustomerType = null;
                                    customerTypeNotifier =
                                        ValueNotifier<ProductTypeModel?>(null);
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
      ),
    );
  }

  Widget productCard(List<CustomerModel?> ods) {
    return filterList!.isEmpty
        ? Container(
            margin: const EdgeInsets.only(top: 50),
            child: const NoDataFoundWidget(),
          )
        : Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Header Row
                    _buildHeaderRow(),
                    const Divider(height: 1, color: Colors.grey),

                    // Data Rows
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ods.length,
                      itemBuilder: (context, i) {
                        return Column(
                          children: [
                            _buildDataRow(i, ods[i]),
                            const Divider(height: 0.2, color: Colors.grey),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }

// Function to build the header row
  Widget _buildHeaderRow() {
    return Row(
      children: [
        // No column
        Expanded(
          flex: 1,
          child: Center(
            child: paddedTextBigL('No', align: TextAlign.center),
          ),
        ),

        // Customer Name column
        Expanded(
          flex: 4,
          child: Center(
            child: paddedTextBigL('ชื่อเต็ม', align: TextAlign.left),
          ),
        ),

        // Contact Information column
        Expanded(
          flex: 4,
          child: Center(
            child: paddedTextBigL('ข้อมูลการติดต่อ', align: TextAlign.left),
          ),
        ),

        // Action Buttons column
        Expanded(
          flex: 3,
          child: Center(
            child: paddedTextBigL('', align: TextAlign.center),
          ),
        ),
      ],
    );
  }

// Function to build each data row
  Widget _buildDataRow(int index, CustomerModel? customer) {
    return InkWell(
      onTap: () {
        // 🔥 Handle full row tap here
        print("Row tapped for customer: ${customer.firstName}");
        if (widget.selected == true) {
          setState(() {
            Global.customer = customer;
          });
          Navigator.of(context).pop();
        }
      },
      child: Row(
        children: [
          // No column
          Expanded(
            flex: 1,
            child: Center(
              child: paddedTextBigL('${index + 1}', align: TextAlign.center),
            ),
          ),

          // Customer Name column
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  paddedTextBigL('ชื่อ: ${getCustomerName(customer!)}',
                      align: TextAlign.left),
                  if (customer.nationality == "Thai" ||
                      customer.nationality == "")
                    paddedTextBigL(
                        '${getIdTitle(selectedCustomerType)}: ${selectedCustomerType?.code == 'general' ? customer.idCard : customer.taxNumber}',
                        align: TextAlign.left),
                  if (customer.nationality == "Foreigner")
                    paddedTextBigL(
                        'Work permit: ${customer.workPermit} \nPassport: ${customer.passportId} \nTax ID: ${customer.taxNumber}',
                        align: TextAlign.left),
                ],
              ),
            ),
          ),

          // Contact Information column
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  paddedTextBigL(
                      'Email: ${customer.email} \nโทรศัพท์: ${customer.phoneNumber}',
                      align: TextAlign.left),
                ],
              ),
            ),
          ),

          // Action Buttons column
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.selected == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: selectButton(customer),
                    ),
                  editButton(customer),
                  if (widget.selected != true) const SizedBox(height: 8),
                  if (widget.selected != true)
                    deleteButton(context, customer.id!, index),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Custom Edit Button
  Widget editButton(CustomerModel customer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCustomerScreen(c: customer),
            fullscreenDialog: true,
          ),
        ).whenComplete(() {
          loadData();
          setState(() {});
        });
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: Colors.white,
            ),
            SizedBox(width: 8), // Add spacing between icon and text
            Text(
              'แก้ไข',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

// Custom Delete Button
  Widget deleteButton(BuildContext context, int customerId, int index) {
    return GestureDetector(
      onTap: () {
        deleteCustomer(context, customerId, index);
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.close,
              color: Colors.white,
            ),
            SizedBox(width: 8), // Add spacing between icon and text
            Text(
              'ลบ',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

// Custom Select Button
  Widget selectButton(CustomerModel customer) {
    return GestureDetector(
      onTap: () {
        setState(() {
          Global.customer = customer;
        });
        Navigator.of(context).pop();
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.teal[700],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_outlined,
              color: Colors.white,
            ),
            SizedBox(width: 8), // Add spacing between icon and text
            Text(
              'เลือก',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
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
