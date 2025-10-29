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
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
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
  bool isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    customerTypeNotifier = ValueNotifier<ProductTypeModel?>(null);
    selectedCustomerType = null;
    if (widget.selected == true) {
      defaultCustomerType();
      search();
    } else {
      loadData();
    }
  }

  defaultCustomerType() {
    final validOrderTypeIds = {5, 10, 6, 11, 8, 9};

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
    if (selectedCustomerType == null &&
        emailCtrl.text.isEmpty &&
        phoneCtrl.text.isEmpty) {
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

  void _resetFilters() {
    setState(() {
      firstNameCtrl.clear();
      lastNameCtrl.clear();
      emailCtrl.clear();
      phoneCtrl.clear();
      companyNameCtrl.clear();
      idCardCtrl.clear();
      selectedCustomerType = null;
      customerTypeNotifier = ValueNotifier<ProductTypeModel?>(null);
    });
    loadData(); // Call loadData() exactly like original
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
                // if (widget.selected != true)
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
                      decoration: BoxDecoration(
                        color: Colors.teal[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.add,
                              size: 24,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'เพิ่มลูกค้า',
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
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
          child: Column(
            children: [
              // Modern Filter Section
              Container(
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha:0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Filter Header
                    InkWell(
                      onTap: () {
                        setState(() {
                          isFilterExpanded = !isFilterExpanded;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.filter_list,
                                color: Colors.indigo[700], size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ตัวกรองข้อมูลลูกค้า',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            Spacer(),
                            AnimatedRotation(
                              turns: isFilterExpanded ? 0.5 : 0,
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Filter Content
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      height: isFilterExpanded ? null : 0,
                      child: isFilterExpanded
                          ? Padding(
                        padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          children: [
                            Divider(height: 1),
                            SizedBox(height: 16),

                            // Customer Type Dropdown
                            Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ประเภทลูกค้า',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey[300]!),
                                  ),
                                  child:
                                  MiraiDropDownMenu<ProductTypeModel>(
                                    key: ValueKey(
                                        'customer_type_dropdown'),
                                    // Add stable key
                                    children: customerTypes(),
                                    space: 4,
                                    maxHeight: 300,
                                    showSearchTextField: true,
                                    selectedItemBackgroundColor:
                                    Colors.transparent,
                                    emptyListMessage: 'ไม่มีข้อมูล',
                                    showSelectedItemBackgroundColor: true,
                                    itemWidgetBuilder: (int index,
                                        ProductTypeModel? project,
                                        {bool isItemSelected = false}) {
                                      return DropDownItemWidget(
                                        project: project,
                                        isItemSelected: isItemSelected,
                                        firstSpace: 10,
                                        fontSize: 14.sp,
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
                                      fontSize: 14.sp,
                                      projectValueNotifier:
                                      customerTypeNotifier!,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Conditional Fields based on Customer Type
                            if (selectedCustomerType?.code == 'general')
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildTextField(
                                          label: getIdTitle(
                                              selectedCustomerType),
                                          controller: idCardCtrl,
                                          onSubmitted: (value) =>
                                              search(),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          label: "ชื่อ",
                                          controller: firstNameCtrl,
                                          onSubmitted: (value) =>
                                              search(),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: _buildTextField(
                                          label: "นามสกุล",
                                          controller: lastNameCtrl,
                                          onSubmitted: (value) =>
                                              search(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),

                            if (selectedCustomerType?.code == 'company')
                              Column(
                                children: [
                                  _buildTextField(
                                    label: "ชื่อบริษัท",
                                    controller: companyNameCtrl,
                                    onSubmitted: (value) => search(),
                                  ),
                                  SizedBox(height: 16),
                                ],
                              ),

                            // Email and Phone
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    label: "อีเมล",
                                    controller: emailCtrl,
                                    onSubmitted: (value) => search(),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: _buildTextField(
                                    label: "โทรศัพท์",
                                    controller: phoneCtrl,
                                    onSubmitted: (value) => search(),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 16),

                            // Action Buttons - Custom Compact Design
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Reset Button
                                GestureDetector(
                                  onTap: _resetFilters,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.refresh, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'รีเซ็ต',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Search Button
                                GestureDetector(
                                  onTap: search,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.indigo[700],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.search, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text(
                                          'ค้นหา',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                          : SizedBox(),
                    ),
                  ],
                ),
              ),

              // Results Section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: loading
                      ? Center(child: LoadingProgress())
                      : _buildCustomerList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    Function(String)? onSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: 'ค้นหา $label',
              hintStyle: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[500],
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.indigo[700]!),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.clear, size: 18),
                onPressed: () {
                  controller.clear();
                  setState(() {});
                  if (onSubmitted != null) {
                    onSubmitted(''); // Trigger search when cleared
                  }
                },
              )
                  : null,
            ),
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerList() {
    if (filterList!.isEmpty) {
      return Center(child: NoDataFoundWidget());
    }

    return ListView.builder(
      itemCount: filterList!.length,
      itemBuilder: (context, index) {
        return _buildModernCustomerCard(filterList![index]!, index);
      },
    );
  }

  Widget _buildModernCustomerCard(CustomerModel customer, int index) {
    return Container(
      key: ValueKey('customer_${customer.id}_$index'),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (widget.selected == true) {
            setState(() {
              Global.customer = customer;
            });
            Navigator.of(context).pop();
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Expanded area for customer info (left aligned)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with number and customer name
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer Number Badge (top-left)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.indigo[700],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '#${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),

                            // Customer name
                            Expanded(
                              child: Text(
                                getCustomerName(customer),
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[900],
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        // Customer Type Badge (left aligned)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getCustomerTypeColor(customer).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getCustomerTypeColor(customer).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _getCustomerTypeText(customer),
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: _getCustomerTypeColor(customer),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 12),

                        // ID Information (left aligned)
                        _buildModernIdentificationCards(customer),
                      ],
                    ),
                  ),

                  // Action Buttons (right side)
                  Column(
                    children: [
                        Row(
                          children: [
                            if (widget.selected == true)
                              _buildActionButton(
                                icon: Icons.check,
                                label: 'เลือก',
                                color: Colors.teal[700]!,
                                onTap: () {
                                  setState(() {
                                    Global.customer = customer;
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                            SizedBox(width: 8),
                            _buildActionButton(
                              icon: Icons.edit,
                              label: 'แก้ไข',
                              color: Colors.blue[700]!,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditCustomerScreen(c: customer),
                                    fullscreenDialog: true,
                                  ),
                                ).whenComplete(() {
                                  loadData();
                                  setState(() {});
                                });
                              },
                            ),
                            if (widget.selected != true)
                            SizedBox(width: 8),
                            if (widget.selected != true)
                            _buildActionButton(
                              icon: Icons.delete,
                              label: 'ลบ',
                              color: Colors.red[700]!,
                              onTap: () =>
                                  deleteCustomer(context, customer.id!, index),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Contact Information with modern design
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[50]!,
                      Colors.grey[100]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    _buildContactRow(Icons.email_outlined, customer.email ?? 'ไม่ระบุ'),
                    SizedBox(height: 8),
                    _buildContactRow(Icons.phone_outlined, customer.phoneNumber ?? 'ไม่ระบุ'),
                    SizedBox(height: 8),
                    _buildContactRow(Icons.schedule_outlined, 'อัปเดต: ${Global.formatDate(customer.updatedDate.toString())}'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build identification cards for Thai/Foreigner
  Widget _buildModernIdentificationCards(CustomerModel customer) {
    if (customer.nationality == "Foreigner") {
      return Column(
        children: [
          _buildIdentificationCard(
            icon: Icons.work_outline,
            label: 'Work Permit',
            value: customer.workPermit ?? 'ไม่ระบุ',
            color: Colors.purple,
          ),
          SizedBox(height: 6),
          _buildIdentificationCard(
            icon: Icons.flight_takeoff,
            label: 'Passport',
            value: customer.passportId ?? 'ไม่ระบุ',
            color: Colors.green,
          ),
          SizedBox(height: 6),
          _buildIdentificationCard(
            icon: Icons.receipt_long,
            label: 'Tax ID',
            value: customer.taxNumber ?? 'ไม่ระบุ',
            color: Colors.orange,
          ),
        ],
      );
    } else {
      return _buildIdentificationCard(
        icon: Icons.badge_outlined,
        label: getIdTitleName(customer.customerType),
        value: selectedCustomerType?.code == 'general'
            ? (customer.idCard ?? 'ไม่ระบุ')
            : (customer.taxNumber ?? 'ไม่ระบุ'),
        color: Colors.blue,
      );
    }
  }

  // Modern identification card widget
  Widget _buildIdentificationCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color.withOpacity(0.8)),
          SizedBox(width: 6),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.9),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build contact information rows
  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods for customer type styling
  Color _getCustomerTypeColor(CustomerModel customer) {
    if (customer.nationality == "Foreigner") {
      return Colors.purple;
    }
    return customer.customerType == "company" ? Colors.orange : Colors.blue;
  }

  String _getCustomerTypeText(CustomerModel customer) {
    if (customer.nationality == "Foreigner") {
      return "ต่างชาติ";
    }
    return customer.customerType == "company" ? "นิติบุคคล" : "บุคคลธรรมดา";
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha:0.3),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 14),
            SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  deleteCustomer(BuildContext context, int? id, int i) {
    motivePrint('deleted'); // Keep original debug print
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            var result = await ApiServices.delete('/customer', id, queryParams: {
              'userId': Global.user?.id,
              'companyId': Global.company?.id ?? Global.user?.companyId,
              'branchId': Global.branch?.id ?? Global.user?.branchId,
            });
            await pr.hide();
            if (result?.status == "success") {
              filterList!.removeAt(i);
              setState(() {});
              // Keep original Alert.warning pattern but also add modern SnackBar
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