import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

class EditBranchScreen extends StatefulWidget {
  final bool showBackButton;
  final BranchModel branch;
  final int index;

  const EditBranchScreen({
    super.key,
    required this.showBackButton,
    required this.branch,
    required this.index,
  });

  @override
  State<EditBranchScreen> createState() => _EditBranchScreenState();
}

class _EditBranchScreenState extends State<EditBranchScreen> {
  int? id;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();
  final TextEditingController branchCodeCtrl = TextEditingController();
  final TextEditingController branchIdCtrl = TextEditingController();
  final TextEditingController licenseNumberCtrl = TextEditingController();

  // New PP.01 address field controllers
  final TextEditingController buildingCtrl = TextEditingController();
  final TextEditingController roomCtrl = TextEditingController();
  final TextEditingController floorCtrl = TextEditingController();
  final TextEditingController villageNoCtrl = TextEditingController();
  final TextEditingController alleyCtrl = TextEditingController();
  final TextEditingController roadCtrl = TextEditingController();
  final TextEditingController subDistrictCtrl = TextEditingController();
  final TextEditingController postalCodeCtrl = TextEditingController();

  bool loading = false;
  bool isHeadquarter = true; // Radio button state
  bool showAbbreviatedName = false; // Checkbox for branch mode

  List<CompanyModel>? companies;
  CompanyModel? selectedCompany;
  ValueNotifier<dynamic>? companyNotifier;

  @override
  void initState() {
    super.initState();
    id = widget.branch.id;
    nameCtrl.text = widget.branch.name;
    emailCtrl.text = widget.branch.email ?? '';
    phoneCtrl.text = widget.branch.phone ?? '';
    addressCtrl.text = widget.branch.address ?? '';
    villageCtrl.text = widget.branch.village ?? '';
    districtCtrl.text = widget.branch.district ?? '';
    provinceCtrl.text = widget.branch.province ?? '';
    branchCodeCtrl.text = widget.branch.branchCode ?? '';
    branchIdCtrl.text = widget.branch.branchId ?? '';
    licenseNumberCtrl.text = widget.branch.oldGoldLicenseNumber ?? '';

    // Initialize new PP.01 fields
    buildingCtrl.text = widget.branch.building ?? '';
    roomCtrl.text = widget.branch.room ?? '';
    floorCtrl.text = widget.branch.floor ?? '';
    villageNoCtrl.text = widget.branch.villageNo ?? '';
    alleyCtrl.text = widget.branch.alley ?? '';
    roadCtrl.text = widget.branch.road ?? '';
    subDistrictCtrl.text = widget.branch.subDistrict ?? '';
    postalCodeCtrl.text = widget.branch.postalCode ?? '';

    // Initialize headquarter flag
    isHeadquarter = widget.branch.isHeadquarter ?? true;

    // Initialize show abbreviated name flag
    showAbbreviatedName = widget.branch.showAbbreviatedName ?? false;
    Global.provinceNotifier = ValueNotifier<ProvinceModel>(
        ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด', nameEn: '', geographyId: 0));
    Global.amphureNotifier = ValueNotifier<AmphureModel>(
        AmphureModel(id: 0, nameTh: 'เลือกอำเภอ/เขต', nameEn: '', provinceId: 0));
    Global.tambonNotifier = ValueNotifier<TambonModel>(
        TambonModel(id: 0, nameTh: 'เลือกตำบล/แขวง', nameEn: '', amphureId: 0, zipCode: 0));
    // Initialize location dropdowns
    initializeLocationDropdowns();

    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.get('/company');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<CompanyModel> products = companyListModelFromJson(data);
        setState(() {
          companies = products;
        });
        if (Global.user!.userType == 'COMPANY') {
          selectedCompany = companies!
              .where((element) => element.id == Global.user!.companyId)
              .first;
          companyCtrl.text = selectedCompany!.name;
        } else if (Global.user!.userType == 'ADMIN') {
          // Initialize companyNotifier for ADMIN users
          // Find the company associated with this branch
          selectedCompany = companies!
              .where((element) => element.id == widget.branch.companyId)
              .firstOrNull;
          if (selectedCompany != null) {
            companyCtrl.text = selectedCompany!.name;
            companyNotifier = ValueNotifier<CompanyModel>(selectedCompany!);
          } else {
            // If no company found, initialize with first company or placeholder
            companyNotifier = ValueNotifier<CompanyModel>(
              companies!.isNotEmpty
                ? companies!.first
                : CompanyModel(id: 0, name: 'เลือกบริษัท')
            );
          }
        }
      } else {
        companies = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {
      loading = false;
    });
  }

  void initializeLocationDropdowns() async {
    // Initialize province
    if (widget.branch.provinceId != null) {
      var province = Global.provinceList.firstWhere(
        (p) => p.id == widget.branch.provinceId,
        orElse: () => ProvinceModel(id: 0, nameTh: widget.branch.province ?? '', nameEn: '', geographyId: 0),
      );
      Global.provinceModel = province;
      Global.provinceNotifier = ValueNotifier<ProvinceModel>(province);

      // Load and initialize amphure
      if (province.id != 0) {
        await loadAmphureByProvince(province.id!);
        if (widget.branch.amphureId != null) {
          var amphure = Global.amphureList.firstWhere(
            (a) => a.id == widget.branch.amphureId,
            orElse: () => AmphureModel(id: 0, nameTh: widget.branch.district ?? '', nameEn: '', provinceId: 0),
          );
          Global.amphureModel = amphure;
          Global.amphureNotifier!.value = amphure;

          // Load and initialize tambon
          if (amphure.id != 0) {
            await loadTambonByAmphure(amphure.id!);
            if (widget.branch.tambonId != null) {
              var tambon = Global.tambonList.firstWhere(
                (t) => t.id == widget.branch.tambonId,
                orElse: () => TambonModel(id: 0, nameTh: widget.branch.subDistrict ?? '', nameEn: '', amphureId: 0, zipCode: 0),
              );
              Global.tambonModel = tambon;
              Global.tambonNotifier!.value = tambon;
            }
          }
        }
      }
    } else {
      // Initialize with empty values if no existing location data
      Global.provinceModel = null;
      Global.amphureModel = null;
      Global.tambonModel = null;
      Global.provinceNotifier = ValueNotifier<ProvinceModel>(
          ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด', nameEn: '', geographyId: 0));
      Global.amphureNotifier = ValueNotifier<AmphureModel>(
          AmphureModel(id: 0, nameTh: 'เลือกอำเภอ/เขต', nameEn: '', provinceId: 0));
      Global.tambonNotifier = ValueNotifier<TambonModel>(
          TambonModel(id: 0, nameTh: 'เลือกตำบล/แขวง', nameEn: '', amphureId: 0, zipCode: 0));
    }
    setState(() {});
  }

  // Future<void> loadAmphureByProvince(int provinceId) async {
  //   Global.amphureList.clear();
  //   try {
  //     var result = await ApiServices.get('/location/amphure/$provinceId');
  //     if (result?.status == "success") {
  //       var data = jsonEncode(result?.data);
  //       Global.amphureList = amphureModelFromJson(data);
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e.toString());
  //     }
  //   }
  // }
  //
  // Future<void> loadTambonByAmphure(int amphureId) async {
  //   Global.tambonList.clear();
  //   try {
  //     var result = await ApiServices.get('/location/tambon/$amphureId');
  //     if (result?.status == "success") {
  //       var data = jsonEncode(result?.data);
  //       Global.tambonList = tambonModelFromJson(data);
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e.toString());
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: Text("แก้ไขสาขา",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading
              ? const Center(child: LoadingProgress())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Company Selection Card (Admin only)
                        if (Global.user!.userType == 'ADMIN')
                          _buildInfoCard(
                            title: 'เลือกบริษัท',
                            icon: Icons.business,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[50],
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: MiraiDropDownMenu<CompanyModel>(
                                  key: UniqueKey(),
                                  children: companies ?? [],
                                  space: 4,
                                  maxHeight: 360,
                                  showSearchTextField: true,
                                  selectedItemBackgroundColor:
                                  Colors.transparent,
                                  emptyListMessage: 'ไม่มีข้อมูล',
                                  showSelectedItemBackgroundColor: true,
                                  itemWidgetBuilder: (
                                      int index,
                                      CompanyModel? project, {
                                        bool isItemSelected = false,
                                      }) {
                                    return DropDownItemWidget(
                                      project: project,
                                      isItemSelected: isItemSelected,
                                      firstSpace: 10,
                                      fontSize: 16.sp,
                                    );
                                  },
                                  onChanged: (CompanyModel value) {
                                    companyCtrl.text = value.name;
                                    selectedCompany = value;
                                    companyNotifier!.value = value;
                                  },
                                  child: DropDownObjectChildWidget(
                                    key: GlobalKey(),
                                    fontSize: 16.sp,
                                    projectValueNotifier: companyNotifier!,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        if (Global.user!.userType == 'ADMIN')
                          const SizedBox(height: 20),
                        // Radio Button Selection Card
                        _buildInfoCard(
                          title: 'ประเภทสถานประกอบการ',
                          icon: Icons.check_circle_outline,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    value: true,
                                    groupValue: isHeadquarter,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isHeadquarter = value!;
                                      });
                                    },
                                    title: const Text(
                                      'สำนักงานใหญ่',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    activeColor: Colors.teal[700],
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    value: false,
                                    groupValue: isHeadquarter,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isHeadquarter = value!;
                                      });
                                    },
                                    title: const Text(
                                      'สาขา',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    activeColor: Colors.teal[700],
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Branch Information Card
                        _buildInfoCard(
                          title: isHeadquarter ? 'ข้อมูลสำนักงานใหญ่' : 'ข้อมูลสาขา',
                          icon: Icons.store,
                          children: [
                            _buildModernTextField(
                              controller: licenseNumberCtrl,
                              label: 'เลขที่ใบอนุญาตค้าทองเก่า',
                              icon: Icons.card_membership_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: companyCtrl,
                              label: 'ชื่อผู้ประกอบการ',
                              icon: Icons.business_outlined,
                              enabled: false,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: nameCtrl,
                              label: 'ชื่อสถานประกอบการ',
                              icon: Icons.store_outlined,
                              required: true,
                            ),
                            // Checkbox for branch mode only
                            if (!isHeadquarter) ...[
                              const SizedBox(height: 8),
                              CheckboxListTile(
                                value: showAbbreviatedName,
                                onChanged: (bool? value) {
                                  setState(() {
                                    showAbbreviatedName = value ?? false;
                                  });
                                },
                                title: const Text(
                                  'แสดงชื่อสถานประกอบการในใบเสร็จอย่างย่อ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                                activeColor: Colors.teal[700],
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                              ),
                            ],
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: branchIdCtrl,
                                    label: 'รหัสสาขา',
                                    icon: Icons.numbers_outlined,
                                    keyboardType: TextInputType.phone,
                                    required: true,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: branchCodeCtrl,
                                    label: 'ชื่อย่อสาขา',
                                    icon: Icons.code_outlined,
                                    required: true,
                                    helperText: 'ภาษาอังกฤษเท่านั้น',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Address Information Card (PP.01 Format)
                        _buildInfoCard(
                          title: 'ที่อยู่ตามแบบ ภ.พ.01',
                          icon: Icons.location_on,
                          children: [
                            // Row 1: อาคาร, ห้องเลขที่, ชั้นที่
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: buildingCtrl,
                                    label: 'อาคาร',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: roomCtrl,
                                    label: 'ห้องเลขที่',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: floorCtrl,
                                    label: 'ชั้นที่',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: เลขที่, หมู่บ้าน, หมู่ที่
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: addressCtrl,
                                    label: 'เลขที่',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: villageCtrl,
                                    label: 'หมู่บ้าน',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: villageNoCtrl,
                                    label: 'หมู่ที่',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 3: ตรอก/ซอย, ถนน, ตำบล/แขวง (with number badge)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: alleyCtrl,
                                    label: 'ตรอก/ซอย',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: roadCtrl,
                                    label: 'ถนน',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '3',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'ตำบล/แขวง',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey[50],
                                          border: Border.all(color: Colors.grey[200]!),
                                        ),
                                        child: MiraiDropDownMenu<TambonModel>(
                                          key: UniqueKey(),
                                          children: Global.tambonList,
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor: Colors.transparent,
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
                                              fontSize: 14,
                                            );
                                          },
                                          onChanged: (TambonModel value) {
                                            Global.tambonModel = value;
                                            Global.tambonNotifier!.value = value;
                                            if (value.zipCode != null) {
                                              postalCodeCtrl.text = value.zipCode.toString();
                                            }
                                            setState(() {});
                                          },
                                          child: LocationDropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 14,
                                            projectValueNotifier: Global.tambonNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 4: อำเภอ/เขต (with number badge), จังหวัด (with number badge), รหัสไปรษณีย์
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '2',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'อำเภอ/เขต',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey[50],
                                          border: Border.all(color: Colors.grey[200]!),
                                        ),
                                        child: MiraiDropDownMenu<AmphureModel>(
                                          key: UniqueKey(),
                                          children: Global.amphureList,
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor: Colors.transparent,
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
                                              fontSize: 14,
                                            );
                                          },
                                          onChanged: (AmphureModel value) async {
                                            Global.amphureModel = value;
                                            Global.amphureNotifier!.value = value;
                                            Global.tambonModel = null;
                                            await loadTambonByAmphure(value.id!);
                                            setState(() {});
                                          },
                                          child: LocationDropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 14,
                                            projectValueNotifier: Global.amphureNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            child: const Center(
                                              child: Text(
                                                '1',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'จังหวัด',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black87,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        height: 56,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey[50],
                                          border: Border.all(color: Colors.grey[200]!),
                                        ),
                                        child: MiraiDropDownMenu<ProvinceModel>(
                                          key: UniqueKey(),
                                          children: Global.provinceList,
                                          space: 4,
                                          maxHeight: 360,
                                          showSearchTextField: true,
                                          selectedItemBackgroundColor: Colors.transparent,
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
                                              fontSize: 14,
                                            );
                                          },
                                          onChanged: (ProvinceModel value) async {
                                            Global.provinceModel = value;
                                            Global.provinceNotifier!.value = value;
                                            Global.amphureModel = null;
                                            Global.tambonModel = null;
                                            await loadAmphureByProvince(value.id!);
                                            setState(() {});
                                          },
                                          child: LocationDropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 14,
                                            projectValueNotifier: Global.provinceNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: postalCodeCtrl,
                                    label: 'รหัสไปรษณีย์',
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Contact Information Card
                        _buildInfoCard(
                          title: 'ข้อมูลการติดต่อ',
                          icon: Icons.contact_phone,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTextField(
                                    controller: phoneCtrl,
                                    label: 'โทรศัพท์',
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildTextField(
                                    controller: emailCtrl,
                                    label: 'อีเมล',
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: _updateBranch,
          backgroundColor: Colors.teal[700],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "บันทึก".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal[600], size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
    bool enabled = true,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required)
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          )
        else
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: enabled ? Colors.grey[50] : Colors.grey[100],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled ? Colors.grey[500] : Colors.grey[400],
                size: 20,
              ),
              hintText: 'กรอก$label',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: 'กรอก$label',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  void _updateBranch() async {
    if (nameCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกชื่อสาขา', '', 'ตกลง');
      return;
    }

    if (branchIdCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกรหัสสาขา', '', 'ตกลง');
      return;
    }

    if (branchCodeCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกชื่อย่อสาขา', '', 'ตกลง');
      return;
    }

    var object = Global.requestObj({
      "id": id,
      "companyId": widget.branch.companyId,
      "name": nameCtrl.text,
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "address": addressCtrl.text,
      "village": villageCtrl.text,
      "district": Global.amphureModel?.nameTh ?? "",
      "province": Global.provinceModel?.nameTh ?? "",
      "branchId": branchIdCtrl.text,
      "branchCode": branchCodeCtrl.text,
      "oldGoldLicenseNumber": licenseNumberCtrl.text,
      // Headquarter flag
      "isHeadquarter": isHeadquarter,
      // Show abbreviated name flag (for branch mode)
      "showAbbreviatedName": showAbbreviatedName,
      // New PP.01 address fields
      "building": buildingCtrl.text,
      "room": roomCtrl.text,
      "floor": floorCtrl.text,
      "villageNo": villageNoCtrl.text,
      "alley": alleyCtrl.text,
      "road": roadCtrl.text,
      "subDistrict": Global.tambonModel?.nameTh ?? "",
      "postalCode": postalCodeCtrl.text,
      // Location IDs
      "tambonId": Global.tambonModel?.id,
      "amphureId": Global.amphureModel?.id,
      "provinceId": Global.provinceModel?.id,
    });

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.put('/branch', id, object);
        await pr.hide();
        if (result?.status == "success") {
          if (mounted) {
            Alert.success(context, 'อัปเดตข้อมูลเรียบร้อยแล้ว', '', 'ตกลง',
                action: () {
              Navigator.of(context).pop();
            });
          }
        } else {
          if (mounted) {
            Alert.warning(
                context, result?.message ?? 'เกิดข้อผิดพลาด', '', 'ตกลง');
          }
        }
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.warning(context, 'เกิดข้อผิดพลาด: ${e.toString()}', '', 'ตกลง');
        }
      }
    });
  }
}
