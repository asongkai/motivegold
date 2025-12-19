import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/image/profile_image.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/util.dart';
// Platform-specific imports
import 'package:motivegold/widget/payment/web_file_picker.dart'
    if (dart.library.io) 'package:motivegold/widget/payment/mobile_file_picker.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:sizer/sizer.dart';

class EditCompanyScreen extends StatefulWidget {
  final bool showBackButton;
  final CompanyModel company;
  final int index;

  const EditCompanyScreen({
    super.key,
    required this.showBackButton,
    required this.company,
    required this.index,
  });

  @override
  State<EditCompanyScreen> createState() => _EditCompanyScreenState();
}

class _EditCompanyScreenState extends State<EditCompanyScreen> {
  int? id;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController taxNumberCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();

  // New fields for PP.01 layout
  final TextEditingController buildingCtrl = TextEditingController();
  final TextEditingController roomCtrl = TextEditingController();
  final TextEditingController floorCtrl = TextEditingController();
  final TextEditingController villageNoCtrl = TextEditingController();
  final TextEditingController alleyCtrl = TextEditingController();
  final TextEditingController roadCtrl = TextEditingController();
  final TextEditingController subDistrictCtrl = TextEditingController();
  final TextEditingController postalCodeCtrl = TextEditingController();

  bool nonStock = false;

  bool loading = false;
  String? logo;
  File? file;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    id = widget.company.id;
    motivePrint(widget.company.toJson());
    nameCtrl.text = widget.company.name;
    emailCtrl.text = widget.company.email ?? '';
    phoneCtrl.text = widget.company.phone ?? '';
    addressCtrl.text = widget.company.address ?? '';
    villageCtrl.text = widget.company.village ?? '';
    taxNumberCtrl.text = widget.company.taxNumber ?? '';
    nonStock = widget.company.stock == 1 ? false : true;

    // Initialize new PP.01 fields
    buildingCtrl.text = widget.company.building ?? '';
    roomCtrl.text = widget.company.room ?? '';
    floorCtrl.text = widget.company.floor ?? '';
    villageNoCtrl.text = widget.company.villageNo ?? '';
    alleyCtrl.text = widget.company.alley ?? '';
    roadCtrl.text = widget.company.road ?? '';
    postalCodeCtrl.text = widget.company.postalCode ?? '';

    // Initialize location dropdowns
    Global.provinceModel = null;
    Global.amphureModel = null;
    Global.tambonModel = null;
    Global.provinceNotifier = ValueNotifier<ProvinceModel>(
        ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
    Global.amphureNotifier =
        ValueNotifier<AmphureModel>(AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
    Global.tambonNotifier =
        ValueNotifier<TambonModel>(TambonModel(id: 0, nameTh: 'เลือกตำบล'));

    // Set existing logo if available
    if (widget.company.logo != null && widget.company.logo!.isNotEmpty) {
      logo = widget.company.logo;
    }

    // Load existing location data
    initializeLocationDropdowns();
  }

  void initializeLocationDropdowns() async {
    // Initialize province
    if (widget.company.provinceId != null) {
      var province = Global.provinceList.firstWhere(
        (p) => p.id == widget.company.provinceId,
        orElse: () => ProvinceModel(
            id: 0,
            nameTh: widget.company.province ?? '',
            nameEn: '',
            geographyId: 0),
      );
      Global.provinceModel = province;
      Global.provinceNotifier!.value = province;

      // Load and initialize amphure
      if (province.id != 0) {
        await loadAmphureByProvince(province.id!);
        if (widget.company.amphureId != null) {
          var amphure = Global.amphureList.firstWhere(
            (a) => a.id == widget.company.amphureId,
            orElse: () => AmphureModel(
                id: 0,
                nameTh: widget.company.district ?? '',
                nameEn: '',
                provinceId: 0),
          );
          Global.amphureModel = amphure;
          Global.amphureNotifier!.value = amphure;

          // Load and initialize tambon
          if (amphure.id != 0) {
            await loadTambonByAmphure(amphure.id!);
            if (widget.company.tambonId != null) {
              var tambon = Global.tambonList.firstWhere(
                (t) => t.id == widget.company.tambonId,
                orElse: () => TambonModel(
                    id: 0,
                    nameTh: widget.company.subDistrict ?? '',
                    nameEn: '',
                    amphureId: 0,
                    zipCode: 0),
              );
              Global.tambonModel = tambon;
              Global.tambonNotifier!.value = tambon;
            }
          }
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: Text("แก้ไขบริษัท",
              style: TextStyle(
                  fontSize: 14.sp,
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
                        // Logo Section
                        _buildLogoSection(),

                        const SizedBox(height: 24),

                        // Tax Information Card
                        _buildInfoCard(
                          title: 'ข้อมูลทางภาษี',
                          icon: Icons.assignment_outlined,
                          children: [
                            _buildModernTextField(
                              controller: taxNumberCtrl,
                              label: 'เลขประจำตัวผู้เสียภาษี',
                              icon: Icons.assignment_outlined,
                              required: true,
                            ),
                            const SizedBox(height: 16),
                            _buildModernTextField(
                              controller: nameCtrl,
                              label: 'ชื่อผู้ประกอบการ',
                              icon: Icons.business_outlined,
                              required: true,
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Address Information Card - PP.01 Format
                        _buildInfoCard(
                          title: 'ที่อยู่',
                          icon: Icons.location_on,
                          children: [
                            // Row 1: อาคาร, ห้องเลขที่, ชั้นที่
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: buildingCtrl,
                                    label: 'อาคาร',
                                    icon: Icons.apartment_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: roomCtrl,
                                    label: 'ห้องเลขที่',
                                    icon: Icons.door_front_door_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: floorCtrl,
                                    label: 'ชั้นที่',
                                    icon: Icons.stairs_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 2: เลขที่, หมู่บ้าน, หมู่ที่
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: addressCtrl,
                                    label: 'เลขที่',
                                    icon: Icons.numbers_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 2,
                                  child: _buildModernTextField(
                                    controller: villageCtrl,
                                    label: 'หมู่บ้าน',
                                    icon: Icons.home_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: villageNoCtrl,
                                    label: 'หมู่ที่',
                                    icon: Icons.home_work_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 3: ตรอก/ซอย, ถนน, 3*ตำบล/แขวง
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: alleyCtrl,
                                    label: 'ตรอก/ซอย',
                                    icon: Icons.turn_right_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: roadCtrl,
                                    label: 'ถนน',
                                    icon: Icons.route_outlined,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            child: Center(
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
                                          Text(
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
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
                                              fontSize: 14,
                                            );
                                          },
                                          onChanged: (TambonModel value) {
                                            Global.tambonModel = value;
                                            Global.tambonNotifier!.value =
                                                value;
                                            postalCodeCtrl.text =
                                                value.zipCode.toString();
                                            setState(() {});
                                          },
                                          child:
                                              LocationDropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 14,
                                            projectValueNotifier:
                                                Global.tambonNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Row 4: 2*อำเภอ/เขต, 1*จังหวัด, *รหัสไปรษณีย์
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            child: Center(
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
                                          Text(
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
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
                                              fontSize: 14,
                                            );
                                          },
                                          onChanged:
                                              (AmphureModel value) async {
                                            Global.amphureModel = value;
                                            Global.amphureNotifier!.value =
                                                value;
                                            Global.tambonModel = null;
                                            Global.tambonNotifier!.value =
                                                TambonModel(
                                                    id: 0, nameTh: 'เลือกตำบล');
                                            Global.tambonList = [];
                                            setState(() {});
                                            await loadTambonByAmphure(
                                                value.id!);
                                            setState(() {});
                                          },
                                          child:
                                              LocationDropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 14,
                                            projectValueNotifier:
                                                Global.amphureNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 24,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.red,
                                            ),
                                            child: Center(
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
                                          Text(
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey[300]!),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.03),
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
                                              fontSize: 14,
                                            );
                                          },
                                          onChanged:
                                              (ProvinceModel value) async {
                                            Global.provinceModel = value;
                                            Global.provinceNotifier!.value =
                                                value;
                                            // Reset dependent dropdowns
                                            Global.amphureModel = null;
                                            Global.tambonModel = null;
                                            Global.amphureNotifier!.value =
                                                AmphureModel(
                                                    id: 0,
                                                    nameTh: 'เลือกอำเภอ');
                                            Global.tambonNotifier!.value =
                                                TambonModel(
                                                    id: 0, nameTh: 'เลือกตำบล');
                                            Global.amphureList = [];
                                            Global.tambonList = [];
                                            setState(() {});
                                            await loadAmphureByProvince(
                                                value.id!);
                                            setState(() {});
                                          },
                                          child:
                                              LocationDropDownObjectChildWidget(
                                            key: GlobalKey(),
                                            fontSize: 14,
                                            projectValueNotifier:
                                                Global.provinceNotifier!,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: postalCodeCtrl,
                                    label: '*รหัสไปรษณีย์',
                                    icon: Icons.markunread_mailbox_outlined,
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
                          title: 'ข้อมูลติดต่อ',
                          icon: Icons.contact_phone,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: phoneCtrl,
                                    label: 'โทรศัพท์',
                                    icon: Icons.phone_outlined,
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildModernTextField(
                                    controller: emailCtrl,
                                    label: 'อีเมล',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Settings Card
                        if (Global.user!.userType == 'ADMIN')
                          _buildInfoCard(
                            title: 'การตั้งค่า',
                            icon: Icons.settings,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: CheckboxListTile(
                                  title: const Text(
                                    "Non Stock",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  subtitle: const Text(
                                    "เปิดใช้งานโหมด Non Stock",
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                  value: nonStock,
                                  visualDensity: VisualDensity.compact,
                                  activeColor: Colors.teal,
                                  onChanged: (newValue) {
                                    setState(() {
                                      nonStock = newValue!;
                                    });
                                  },
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
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
          onPressed: _updateCompany,
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

  Widget _buildLogoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          Row(
            children: [
              Icon(Icons.image, color: Colors.teal[600], size: 24),
              const SizedBox(width: 12),
              const Text(
                'โลโก้บริษัท',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _settingModalBottomSheet(context),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Stack(
                children: [
                  Center(
                    child: ClipOval(
                      child: Container(
                        width: 115,
                        height: 115,
                        child: _buildLogoImage(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'แตะเพื่อเปลี่ยนรูป',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoImage() {
    // If we have a newly selected image (file for mobile)
    if (file != null && !kIsWeb) {
      return Image.file(file!, fit: BoxFit.cover);
    }

    // If we have logo data and it's different from the original company logo
    // This means a new image was selected
    if (logo != null && logo != widget.company.logo) {
      try {
        // This is a newly selected base64 image
        return Image.memory(
          base64Decode(
            logo!.startsWith('data:') ? logo!.split(',').last : logo!,
          ),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error decoding new image: $error');
            return Icon(
              Icons.error,
              size: 40,
              color: Colors.red[400],
            );
          },
        );
      } catch (e) {
        print('Error in _buildLogoImage: $e');
        // If base64 decode fails, fall through to show original image
      }
    }

    // If we have an existing logo from the server
    if (widget.company.logo != null && widget.company.logo!.isNotEmpty) {
      return Image.network(
        '${Constants.DOMAIN_URL}/images/${widget.company.logo}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.business,
            size: 40,
            color: Colors.grey[400],
          );
        },
      );
    }

    // Default placeholder
    return Icon(
      Icons.add_a_photo,
      size: 40,
      color: Colors.grey[400],
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required)
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 18,
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
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: Colors.grey[500], size: 20),
              hintText: 'กรอก$label',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  // Future<void> loadAmphureByProvince(int provinceId) async {
  //   Global.amphureList.clear();
  //   Global.tambonList.clear();
  //   Global.amphureModel = null;
  //   Global.tambonModel = null;
  //   Global.amphureNotifier!.value = AmphureModel(
  //       id: 0, nameTh: 'เลือกอำเภอ/เขต', nameEn: '', provinceId: 0);
  //   Global.tambonNotifier!.value = TambonModel(
  //       id: 0, nameTh: 'เลือกตำบล/แขวง', nameEn: '', amphureId: 0, zipCode: 0);
  //
  //   try {
  //     var result = await ApiServices.get('/customer/amphure/$provinceId');
  //     motivePrint(result!.toJson());
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

  // Future<void> loadTambonByAmphure(int amphureId) async {
  //   Global.tambonList.clear();
  //   Global.tambonModel = null;
  //   Global.tambonNotifier!.value = TambonModel(
  //       id: 0, nameTh: 'เลือกตำบล/แขวง', nameEn: '', amphureId: 0, zipCode: 0);
  //
  //   try {
  //     var result = await ApiServices.get('/customer/tambon/$amphureId');
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

  void _updateCompany() async {
    if (nameCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกชื่อผู้ประกอบการ', '', 'ตกลง');
      return;
    }

    if (taxNumberCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกเลขประจำตัวผู้เสียภาษี', '', 'ตกลง');
      return;
    }

    // Clean and validate the logo base64 string before sending
    String? cleanedLogo;
    bool hasNewLogo = false;
    if (logo != null) {
      try {
        // Check if this is a new image (base64) or existing server image
        if (logo != widget.company.logo) {
          // This is a new image - either from camera or gallery
          String base64String = logo!;
          if (base64String.startsWith('data:')) {
            base64String = base64String.split(',').last;
          }

          // Validate base64 string by trying to decode it
          base64Decode(base64String);

          // If successful, use the cleaned string
          cleanedLogo = base64String;
          hasNewLogo = true;
        }
        // If logo hasn't changed, don't include it in the request
      } catch (e) {
        print('Invalid base64 logo data: $e');
        // Set to null if invalid, or show an error to user
        Alert.warning(
            context, 'รูปภาพไม่ถูกต้อง กรุณาเลือกรูปภาพใหม่', '', 'ตกลง');
        return;
      }
    }

    // Build request data - only include logo if it's a new one
    Map<String, dynamic> requestData = {
      "id": id,
      "name": nameCtrl.text,
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "address": addressCtrl.text,
      "village": villageCtrl.text,
      "district": Global.amphureModel?.nameTh ?? widget.company.district ?? "",
      "province": Global.provinceModel?.nameTh ?? widget.company.province ?? "",
      "taxNumber": taxNumberCtrl.text,
      "stock": nonStock ? 0 : 1,
      // New PP.01 fields
      "building": buildingCtrl.text,
      "room": roomCtrl.text,
      "floor": floorCtrl.text,
      "villageNo": villageNoCtrl.text,
      "alley": alleyCtrl.text,
      "road": roadCtrl.text,
      "subDistrict":
          Global.tambonModel?.nameTh ?? widget.company.subDistrict ?? "",
      "postalCode": postalCodeCtrl.text,
      // Location IDs for reference
      "tambonId": Global.tambonModel?.id ?? widget.company.tambonId,
      "amphureId": Global.amphureModel?.id ?? widget.company.amphureId,
      "provinceId": Global.provinceModel?.id ?? widget.company.provinceId,
    };

    // Only include logo field if there's a new logo to upload
    if (hasNewLogo) {
      requestData["logo"] = cleanedLogo;
    }

    var object = Global.requestObj(requestData);

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing');
      try {
        var result = await ApiServices.put('/company', id, object);
        await pr.hide();

        if (result?.status == "success") {
          if (mounted) {
            var c = CompanyModel.fromJson(result?.data);

            // Update local state with new logo
            if (c.logo != null && c.logo!.isNotEmpty) {
              setState(() {
                logo = c.logo;
                widget.company.logo = c.logo;
              });
            }

            if (c.id == Global.company?.id) {
              Global.company = c;
            }

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

  void _settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext bc) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'เลือกรูปภาพ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.blue[600]),
                  ),
                  title: const Text('ถ่ายรูป'),
                  subtitle: const Text('ถ่ายรูปด้วยกล้อง'),
                  onTap: () {
                    pickProfileImage(context, ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.photo, color: Colors.green[600]),
                  ),
                  title: const Text('เลือกรูป'),
                  subtitle: const Text('เลือกรูปจากแกลเลอรี่'),
                  onTap: () {
                    pickProfileImage(context, ImageSource.gallery);
                  },
                ),
                // Show delete button only if logo exists
                if (_hasLogo())
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.delete, color: Colors.red[600]),
                    ),
                    title: const Text('ลบโลโก้'),
                    subtitle: const Text('ลบโลโก้ปัจจุบัน'),
                    onTap: () {
                      Navigator.of(context).pop();
                      _confirmDeleteLogo();
                    },
                  ),
                const SizedBox(height: 20),
              ],
            ),
          );
        });
  }

  /// Check if company has a logo (either new or existing)
  bool _hasLogo() {
    // Check for newly selected image
    if (file != null) return true;
    // Check for new base64 logo
    if (logo != null && logo!.isNotEmpty && logo != widget.company.logo) {
      return true;
    }
    // Check for existing server logo
    if (widget.company.logo != null && widget.company.logo!.isNotEmpty) {
      return true;
    }
    return false;
  }

  /// Show confirmation dialog before deleting logo
  void _confirmDeleteLogo() {
    Alert.info(context, 'ต้องการลบโลโก้หรือไม่?', '', 'ตกลง', action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'กำลังลบโลโก้...');

      try {
        // Send full company data with logo set to null/empty to delete
        var object = Global.requestObj({
          "id": id,
          "name": nameCtrl.text,
          "email": emailCtrl.text,
          "phone": phoneCtrl.text,
          "address": addressCtrl.text,
          "village": villageCtrl.text,
          "district":
              Global.amphureModel?.nameTh ?? widget.company.district ?? "",
          "province":
              Global.provinceModel?.nameTh ?? widget.company.province ?? "",
          "taxNumber": taxNumberCtrl.text,
          "stock": nonStock ? 0 : 1,
          "building": buildingCtrl.text,
          "room": roomCtrl.text,
          "floor": floorCtrl.text,
          "villageNo": villageNoCtrl.text,
          "alley": alleyCtrl.text,
          "road": roadCtrl.text,
          "subDistrict":
              Global.tambonModel?.nameTh ?? widget.company.subDistrict ?? "",
          "postalCode": postalCodeCtrl.text,
          "tambonId": Global.tambonModel?.id ?? widget.company.tambonId,
          "amphureId": Global.amphureModel?.id ?? widget.company.amphureId,
          "provinceId": Global.provinceModel?.id ?? widget.company.provinceId,
          "logo": null, // Set to null to delete logo
        });

        var result = await ApiServices.put('/company', id, object);
        await pr.hide();

        if (result?.status == "success") {
          // Clear local logo state
          setState(() {
            logo = null;
            file = null;
            widget.company.logo = null;
          });

          // Also update Global.company if this is the current company
          if (Global.company?.id == id) {
            Global.company = CompanyModel.fromJson(result?.data);
          }

          if (mounted) {
            Alert.success(context, 'ลบโลโก้เรียบร้อยแล้ว', '', 'ตกลง',
                action: () {});
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

  void pickProfileImage(BuildContext context, ImageSource imageSource) async {
    if (!kIsWeb) {
      final XFile? image = await picker.pickImage(source: imageSource);
      setState(() {
        if (image != null) {
          file = File(image.path);
          logo = Global.imageToBase64(file!);
        }
      });
    } else {
      if (imageSource == ImageSource.camera) {
        Alert.warning(
            context, 'การถ่ายภาพจากกล้องบนเว็บยังไม่พร้อมใช้งาน', '', 'ตกลง');
        return;
      }

      try {
        final result = await WebFilePicker.pickImage();
        setState(() {
          if (result != null) {
            file = null;

            // Clean the base64 string from web picker
            String cleanedResult = result;
            if (cleanedResult.startsWith('data:')) {
              // Keep only the base64 part, remove the data URL prefix
              cleanedResult = cleanedResult.split(',').last;
            }

            // Validate the base64 string
            try {
              base64Decode(cleanedResult);
              logo = cleanedResult; // Only set if valid
            } catch (e) {
              print('Invalid base64 from web picker: $e');
              Alert.warning(
                  context, 'รูปภาพไม่ถูกต้อง กรุณาเลือกรูปภาพใหม่', '', 'ตกลง');
              return;
            }
          }
        });
      } catch (e) {
        debugPrint('Error picking image on web: $e');
        Alert.warning(context, 'เกิดข้อผิดพลาดในการเลือกรูปภาพ', '', 'ตกลง');
      }
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
