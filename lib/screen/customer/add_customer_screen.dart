import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/title_name.dart';
import 'package:motivegold/model/occupation.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/config.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/thai_id_formatter.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/grouped_title_dropdown.dart';
import 'package:motivegold/widget/dropdown/grouped_occupation_dropdown.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';

// Helper class to store file with timestamp
class FileWithTimestamp {
  final PlatformFile file;
  final DateTime addedDateTime;

  FileWithTimestamp(this.file, this.addedDateTime);
}

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen>
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

  // New controllers for additional fields
  final TextEditingController middleNameCtrl = TextEditingController();
  final TextEditingController issueDateCtrl = TextEditingController();
  final TextEditingController expiryDateCtrl = TextEditingController();
  final TextEditingController entryDateCtrl = TextEditingController();
  final TextEditingController exitDateCtrl = TextEditingController();
  final TextEditingController operatorNameCtrl = TextEditingController();
  final TextEditingController businessNameCtrl = TextEditingController();
  final TextEditingController registrationDateCtrl = TextEditingController();

  // Address detail controllers
  final TextEditingController buildingCtrl = TextEditingController();
  final TextEditingController roomNumberCtrl = TextEditingController();
  final TextEditingController floorCtrl = TextEditingController();
  final TextEditingController houseNumberCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController mooCtrl = TextEditingController();
  final TextEditingController soiCtrl = TextEditingController();
  final TextEditingController roadCtrl = TextEditingController();

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

  List<TitleNameModel> titleNames = [];
  TitleNameModel? selectedTitleName;
  ValueNotifier<dynamic>? titleNameNotifier;

  List<OccupationModel> occupations = [];
  OccupationModel? selectedOccupation;
  bool showCustomOccupationInput = false;

  // Additional variables for new fields
  String? selectedCardType;
  String? selectedNationality;
  String? selectedCountry;
  String? companyOfficeType = 'head'; // 'head' or 'branch'

  // KYC file attachments - changed to lists with timestamps
  List<FileWithTimestamp> occupationFiles = [];
  List<FileWithTimestamp> riskAssessmentFiles = [];
  List<FileWithTimestamp> customerPhotoFiles = [];

  // Selected file from dropdown for each section
  FileWithTimestamp? selectedOccupationFile;
  FileWithTimestamp? selectedRiskAssessmentFile;
  FileWithTimestamp? selectedCustomerPhotoFile;

  // Overlay entries and layer links for file dropdowns
  OverlayEntry? _occupationFileOverlay;
  OverlayEntry? _riskFileOverlay;
  OverlayEntry? _photoFileOverlay;
  final LayerLink _occupationFileLayerLink = LayerLink();
  final LayerLink _riskFileLayerLink = LayerLink();
  final LayerLink _photoFileLayerLink = LayerLink();

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

    typeNotifier = ValueNotifier<ProductTypeModel>(customerTypes()[1]);
    selectedType = customerTypes()[1];

    nationality = 'Thai';
    titleNameNotifier = ValueNotifier<TitleNameModel?>(null);

    motivePrint('Current environment: $env');
    motivePrint('Backend URL: ${Constants.BACKEND_URL}');
    _loadTitleNames();
    _loadOccupations();

    // birthDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    Global.addressCtrl.text = "";
    Global.provinceModel = null;
    Global.amphureModel = null;
    Global.tambonModel = null;
    Global.provinceNotifier = ValueNotifier<ProvinceModel>(
        ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
    Global.amphureNotifier =
        ValueNotifier<AmphureModel>(AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
    Global.tambonNotifier =
        ValueNotifier<TambonModel>(TambonModel(id: 0, nameTh: 'เลือกตำบล'));

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
    // Clean up file dropdown overlays
    _occupationFileOverlay?.remove();
    _riskFileOverlay?.remove();
    _photoFileOverlay?.remove();
    super.dispose();
  }

  Future<void> _loadTitleNames() async {
    try {
      motivePrint('Loading title names...');
      var titleNamesResult = await ApiServices.getTitleNames();
      motivePrint('Title names result: ${titleNamesResult?.status}');

      if (titleNamesResult?.status == "success" && titleNamesResult?.data != null) {
        var data = jsonEncode(titleNamesResult!.data);
        motivePrint('Title names data length: ${titleNamesResult.data.length}');

        if (mounted) {
          setState(() {
            titleNames = titleNameListModelFromJson(data);
            motivePrint('Title names loaded: ${titleNames.length} items');
          });
        }
      } else {
        motivePrint('Failed to load title names: status=${titleNamesResult?.status}, data=${titleNamesResult?.data}');
      }
    } catch (e, stackTrace) {
      motivePrint('Error loading title names: $e');
      motivePrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadOccupations() async {
    try {
      motivePrint('Loading occupations...');
      var occupationsResult = await ApiServices.getOccupations();
      motivePrint('Occupations result: ${occupationsResult?.status}');

      if (occupationsResult?.status == "success" && occupationsResult?.data != null) {
        var data = jsonEncode(occupationsResult!.data);
        motivePrint('Occupations data length: ${occupationsResult.data.length}');

        if (mounted) {
          setState(() {
            occupations = occupationListModelFromJson(data);
            motivePrint('Occupations loaded: ${occupations.length} items');

            // Set default to "ประสงค์ระบุเอง"
            selectedOccupation = occupations.firstWhere(
              (occupation) => occupation.name == 'ประสงค์ระบุเอง',
              orElse: () => occupations.isNotEmpty ? occupations[0] : OccupationModel(),
            );

            // Show custom input if "ประสงค์ระบุเอง" is selected
            showCustomOccupationInput = selectedOccupation?.name == 'ประสงค์ระบุเอง';
            motivePrint('Default occupation: ${selectedOccupation?.name}');
          });
        }
      } else {
        motivePrint('Failed to load occupations: status=${occupationsResult?.status}');
      }
    } catch (e, stackTrace) {
      motivePrint('Error loading occupations: $e');
      motivePrint('Stack trace: $stackTrace');
    }
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
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
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
        boxShadow: value
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
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
                    color:
                        value ? color.withValues(alpha: 0.2) : Colors.grey[100],
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
                          color: value
                              ? color.withValues(alpha: 0.8)
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (value)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
            color: Colors.black.withValues(alpha: 0.04),
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
    String? hintText,
    required TextInputType inputType,
    required TextEditingController controller,
    Widget? prefixIcon,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: inputType,
            maxLines: maxLines,
            inputFormatters: inputFormatters,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: hintText ?? labelText,
              prefixIcon: prefixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
        ),
      ],
    );
  }

  Widget buildTextField({
    required String labelText,
    String? validator,
    required TextInputType inputType,
    required TextEditingController controller,
    int line = 1,
    Widget? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: line,
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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

  Widget _buildDateField({
    required String labelText,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14.sp),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 14.sp),
              hintText: labelText,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
            onTap: () async {
              showDialog(
                context: context,
                builder: (_) => SfDatePickerDialog(
                  initialDate: DateTime.now(),
                  onDateSelected: (date) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
                    setState(() {
                      controller.text = formattedDate;
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown({
    required String labelText,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: labelText,
              prefixIcon: icon != null ? Icon(icon, size: 14.sp) : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
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
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: TextStyle(fontSize: 14.sp)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
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
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Text("เพิ่มลูกค้า",
                style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w900)),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: FadeTransition(
            opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
            child: SlideTransition(
              position:
                  _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
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
                                      fontSize: 14.sp,
                                    );
                                  },
                                  onChanged: (ProductTypeModel value) {
                                    selectedType = value;
                                    typeNotifier!.value = value;
                                    if (selectedType?.code == 'general') {
                                      nationality = 'Thai';
                                    }
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
                              // Three horizontal options - matching customer design exactly
                              Row(
                                children: [
                                  // Option 1: ซื้อขายหน้าร้าน
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isCustomer = !isCustomer;
                                          selectedBusinessType = isCustomer ? 'customer' : null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isCustomer ? Colors.pink.withValues(alpha: 0.1) : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isCustomer ? Colors.pink : Colors.grey[300]!,
                                            width: isCustomer ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isCustomer,
                                              activeColor: Colors.pink,
                                              onChanged: (value) {
                                                setState(() {
                                                  isCustomer = value ?? false;
                                                  selectedBusinessType = isCustomer ? 'customer' : null;
                                                });
                                              },
                                            ),
                                            Icon(Icons.store, color: isCustomer ? Colors.pink : Colors.grey, size: 20),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'ซื้อขายหน้าร้าน',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: isCustomer ? FontWeight.w600 : FontWeight.normal,
                                                  color: isCustomer ? Colors.pink : Colors.grey[800],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Option 2: ซื้อขายกับร้านค้าส่ง
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isBuyer = !isBuyer;
                                          selectedBusinessType = isBuyer ? 'buyer' : null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isBuyer ? Colors.pink.withValues(alpha: 0.1) : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isBuyer ? Colors.pink : Colors.grey[300]!,
                                            width: isBuyer ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isBuyer,
                                              activeColor: Colors.pink,
                                              onChanged: (value) {
                                                setState(() {
                                                  isBuyer = value ?? false;
                                                  selectedBusinessType = isBuyer ? 'buyer' : null;
                                                });
                                              },
                                            ),
                                            Icon(Icons.business, color: isBuyer ? Colors.pink : Colors.grey, size: 20),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'ซื้อขายกับร้านค้าส่ง',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: isBuyer ? FontWeight.w600 : FontWeight.normal,
                                                  color: isBuyer ? Colors.pink : Colors.grey[800],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Option 3: ซื้อขายกับร้านทองตู้แดง
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSeller = !isSeller;
                                          selectedBusinessType = isSeller ? 'seller' : null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSeller ? Colors.pink.withValues(alpha: 0.1) : Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSeller ? Colors.pink : Colors.grey[300]!,
                                            width: isSeller ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isSeller,
                                              activeColor: Colors.pink,
                                              onChanged: (value) {
                                                setState(() {
                                                  isSeller = value ?? false;
                                                  selectedBusinessType = isSeller ? 'seller' : null;
                                                });
                                              },
                                            ),
                                            Icon(Icons.inventory, color: isSeller ? Colors.pink : Colors.grey, size: 20),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'ซื้อขายกับร้านทองตู้แดง',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: isSeller ? FontWeight.w600 : FontWeight.normal,
                                                  color: isSeller ? Colors.pink : Colors.grey[800],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                              const SizedBox(height: 20),
                              // Nationality Radio Buttons
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: nationality == 'Thai'
                                            ? Colors.teal.withValues(alpha: 0.1)
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: nationality == 'Thai'
                                              ? Colors.teal
                                              : Colors.grey[300]!,
                                          width: nationality == 'Thai' ? 2 : 1,
                                        ),
                                      ),
                                      child: RadioListTile<String>(
                                        title: Text(
                                          'สัญชาติไทย',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
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
                                        color: nationality == 'Foreigner'
                                            ? Colors.teal.withValues(alpha: 0.1)
                                            : Colors.grey[50],
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: nationality == 'Foreigner'
                                              ? Colors.teal
                                              : Colors.grey[300]!,
                                          width: nationality == 'Foreigner'
                                              ? 2
                                              : 1,
                                        ),
                                      ),
                                      child: RadioListTile<String>(
                                        title: Text(
                                          'ต่างชาติ',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                          ),
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
                              const SizedBox(height: 10),

                              // Conditional Fields Based on Nationality and Customer Type
                              if (nationality == 'Thai' && selectedType?.code == 'general') ...[
                                // Thai + General Customer
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'เลขบัตรประจำตัวประชาชน',
                                    hintText: 'x-xxxx-xxxxx-xx-x',
                                    inputType: TextInputType.number,
                                    controller: idCardCtrl,
                                    prefixIcon: Icon(Icons.credit_card, size: 14.sp),
                                    inputFormatters: [ThaiIdCardFormatter()],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'คำนำหน้า',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            GroupedTitleDropdown(
                                              titleNames: titleNames,
                                              selectedTitle: selectedTitleName,
                                              onChanged: (TitleNameModel value) {
                                                setState(() {
                                                  selectedTitleName = value;
                                                  titleNameNotifier!.value = value;
                                                });
                                              },
                                              emptyMessage: 'ไม่มีข้อมูล',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อ',
                                          inputType: TextInputType.text,
                                          controller: firstNameCtrl,
                                          prefixIcon: Icon(Icons.person, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: buildTextFieldBig(
                                          labelText: 'นามสกุล',
                                          inputType: TextInputType.text,
                                          controller: lastNameCtrl,
                                          prefixIcon: Icon(Icons.person_outline, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อีเมล',
                                          inputType: TextInputType.emailAddress,
                                          controller: emailAddressCtrl,
                                          prefixIcon: Icon(Icons.email, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'โทรศัพท์',
                                          inputType: TextInputType.phone,
                                          controller: phoneCtrl,
                                          prefixIcon: Icon(Icons.phone, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: _buildDateField(
                                    labelText: 'วันเกิด',
                                    controller: birthDateCtrl,
                                    icon: Icons.calendar_today,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันที่ออกบัตร',
                                          controller: issueDateCtrl,
                                          icon: Icons.date_range,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันหมดอายุ',
                                          controller: expiryDateCtrl,
                                          icon: Icons.event_busy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              if (nationality == 'Foreigner' && selectedType?.code == 'general') ...[
                                // Foreigner + General Customer
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: _buildSimpleDropdown(
                                    labelText: 'เลือกประเภทบัตร',
                                    value: selectedCardType,
                                    items: ["บัตรประจำตัวประชาชน", "พาสปอร์ต", "ใบอนุญาตทำงาน"],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCardType = value;
                                      });
                                    },
                                    icon: Icons.badge,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: _buildSimpleDropdown(
                                    labelText: 'เลือกสัญชาติ',
                                    value: selectedNationality,
                                    items: ["ไทย", "ลาว", "จีน", "เวียดนาม", "พม่า", "อื่นๆ"],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedNationality = value;
                                      });
                                    },
                                    icon: Icons.flag,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'Tax ID',
                                          inputType: TextInputType.number,
                                          controller: taxNumberCtrl,
                                          prefixIcon: Icon(Icons.receipt, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'Work Permit',
                                          inputType: TextInputType.text,
                                          controller: workPermitCtrl,
                                          prefixIcon: Icon(Icons.work, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'Passport ID',
                                          inputType: TextInputType.text,
                                          controller: passportNoCtrl,
                                          prefixIcon: Icon(Icons.flight, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'คำนำหน้า',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            GroupedTitleDropdown(
                                              titleNames: titleNames,
                                              selectedTitle: selectedTitleName,
                                              onChanged: (TitleNameModel value) {
                                                setState(() {
                                                  selectedTitleName = value;
                                                  titleNameNotifier!.value = value;
                                                });
                                              },
                                              emptyMessage: 'ไม่มีข้อมูล',
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อ',
                                          inputType: TextInputType.text,
                                          controller: firstNameCtrl,
                                          prefixIcon: Icon(Icons.person, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อกลาง',
                                          inputType: TextInputType.text,
                                          controller: middleNameCtrl,
                                          prefixIcon: Icon(Icons.person_outline, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'นามสกุล',
                                          inputType: TextInputType.text,
                                          controller: lastNameCtrl,
                                          prefixIcon: Icon(Icons.person_outline, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อีเมล',
                                          inputType: TextInputType.emailAddress,
                                          controller: emailAddressCtrl,
                                          prefixIcon: Icon(Icons.email, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'โทรศัพท์',
                                          inputType: TextInputType.phone,
                                          controller: phoneCtrl,
                                          prefixIcon: Icon(Icons.phone, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: _buildDateField(
                                    labelText: 'วันเกิด',
                                    controller: birthDateCtrl,
                                    icon: Icons.calendar_today,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันที่ออกบัตร',
                                          controller: issueDateCtrl,
                                          icon: Icons.date_range,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันหมดอายุ',
                                          controller: expiryDateCtrl,
                                          icon: Icons.event_busy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันที่เข้าประเทศ',
                                          controller: entryDateCtrl,
                                          icon: Icons.flight_land,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันที่เดินทางออก',
                                          controller: exitDateCtrl,
                                          icon: Icons.flight_takeoff,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'อาชีพ',
                                    inputType: TextInputType.text,
                                    controller: occupationCtrl,
                                    prefixIcon: Icon(Icons.work_outline, size: 14.sp),
                                  ),
                                ),
                              ],

                              if (nationality == 'Thai' && selectedType?.code == 'company') ...[
                                // Thai + Company Customer
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'เลขบัตรประจำตัวภาษี',
                                    inputType: TextInputType.number,
                                    controller: taxNumberCtrl,
                                    prefixIcon: Icon(Icons.receipt, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'ชื่อผู้ประกอบการ',
                                    inputType: TextInputType.text,
                                    controller: operatorNameCtrl,
                                    prefixIcon: Icon(Icons.person, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'ชื่อสถานประกอบการ',
                                    inputType: TextInputType.text,
                                    controller: businessNameCtrl,
                                    prefixIcon: Icon(Icons.business, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'รหัสสาขา',
                                    inputType: TextInputType.text,
                                    controller: branchCodeCtrl,
                                    prefixIcon: Icon(Icons.store, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'อีเมล',
                                    inputType: TextInputType.emailAddress,
                                    controller: emailAddressCtrl,
                                    prefixIcon: Icon(Icons.email, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: _buildDateField(
                                    labelText: 'วันที่จดทะเบียน',
                                    controller: registrationDateCtrl,
                                    icon: Icons.app_registration,
                                  ),
                                ),
                              ],

                              if (nationality == 'Foreigner' && selectedType?.code == 'company') ...[
                                // Foreigner + Company Customer
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: _buildSimpleDropdown(
                                    labelText: 'ประเทศ',
                                    value: selectedCountry,
                                    items: ["ไทย", "ลาว", "จีน", "เวียดนาม", "พม่า", "สหรัฐอเมริกา", "อื่นๆ"],
                                    onChanged: (value) {
                                      setState(() {
                                        selectedCountry = value;
                                      });
                                    },
                                    icon: Icons.public,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'เลขบัตรประจำตัวภาษี',
                                    inputType: TextInputType.number,
                                    controller: taxNumberCtrl,
                                    prefixIcon: Icon(Icons.receipt, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'ชื่อผู้ประกอบการ',
                                    inputType: TextInputType.text,
                                    controller: operatorNameCtrl,
                                    prefixIcon: Icon(Icons.person, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'ชื่อสถานประกอบการ',
                                    inputType: TextInputType.text,
                                    controller: businessNameCtrl,
                                    prefixIcon: Icon(Icons.business, size: 14.sp),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: companyOfficeType == 'head'
                                                ? Colors.teal.withValues(alpha: 0.1)
                                                : Colors.grey[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: companyOfficeType == 'head'
                                                  ? Colors.teal
                                                  : Colors.grey[300]!,
                                              width: companyOfficeType == 'head' ? 2 : 1,
                                            ),
                                          ),
                                          child: RadioListTile<String>(
                                            title: Text(
                                              'สำนักงานใหญ่',
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                            value: 'head',
                                            groupValue: companyOfficeType,
                                            activeColor: Colors.teal,
                                            onChanged: (String? value) {
                                              setState(() {
                                                companyOfficeType = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: companyOfficeType == 'branch'
                                                ? Colors.teal.withValues(alpha: 0.1)
                                                : Colors.grey[50],
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: companyOfficeType == 'branch'
                                                  ? Colors.teal
                                                  : Colors.grey[300]!,
                                              width: companyOfficeType == 'branch' ? 2 : 1,
                                            ),
                                          ),
                                          child: RadioListTile<String>(
                                            title: Text(
                                              'สาขา',
                                              style: TextStyle(fontSize: 14.sp),
                                            ),
                                            value: 'branch',
                                            groupValue: companyOfficeType,
                                            activeColor: Colors.teal,
                                            onChanged: (String? value) {
                                              setState(() {
                                                companyOfficeType = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อีเมล',
                                          inputType: TextInputType.emailAddress,
                                          controller: emailAddressCtrl,
                                          prefixIcon: Icon(Icons.email, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'โทรศัพท์',
                                          inputType: TextInputType.phone,
                                          controller: phoneCtrl,
                                          prefixIcon: Icon(Icons.phone, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: _buildDateField(
                                    labelText: 'วันที่จดทะเบียน',
                                    controller: registrationDateCtrl,
                                    icon: Icons.app_registration,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 20),
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
                                // Address detail fields - Row 1: อาคาร | เลขที่ห้อง
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อาคาร',
                                          inputType: TextInputType.text,
                                          controller: buildingCtrl,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'เลขที่ห้อง',
                                          inputType: TextInputType.text,
                                          controller: roomNumberCtrl,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 2: ชั้นที่ | เลขที่ | หมู่บ้าน
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชั้นที่',
                                          inputType: TextInputType.text,
                                          controller: floorCtrl,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'เลขที่',
                                          inputType: TextInputType.text,
                                          controller: houseNumberCtrl,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'หมู่บ้าน',
                                          inputType: TextInputType.text,
                                          controller: villageCtrl,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 3: หมู่ที่ | ตรอก/ซอย | ถนน
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'หมู่ที่',
                                          inputType: TextInputType.text,
                                          controller: mooCtrl,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ตรอก / ซอย',
                                          inputType: TextInputType.text,
                                          controller: soiCtrl,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ถนน',
                                          inputType: TextInputType.text,
                                          controller: roadCtrl,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.grey[300]!),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.03),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: MiraiDropDownMenu<
                                                  ProvinceModel>(
                                                key: UniqueKey(),
                                                children: Global.provinceList,
                                                space: 4,
                                                maxHeight: 360,
                                                showSearchTextField: true,
                                                selectedItemBackgroundColor:
                                                    Colors.transparent,
                                                emptyListMessage: 'ไม่มีข้อมูล',
                                                showSelectedItemBackgroundColor:
                                                    true,
                                                itemWidgetBuilder: (
                                                  int index,
                                                  ProvinceModel? project, {
                                                  bool isItemSelected = false,
                                                }) {
                                                  return LocationDropDownItemWidget(
                                                    project: project,
                                                    isItemSelected:
                                                        isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 14.sp,
                                                  );
                                                },
                                                onChanged: (ProvinceModel
                                                    value) async {
                                                  Global.provinceModel = value;
                                                  Global.provinceNotifier!
                                                      .value = value;
                                                  // Reset dependent dropdowns
                                                  Global.amphureModel = null;
                                                  Global.tambonModel = null;
                                                  Global.amphureNotifier!
                                                          .value =
                                                      AmphureModel(
                                                          id: 0,
                                                          nameTh: 'เลือกอำเภอ');
                                                  Global.tambonNotifier!.value =
                                                      TambonModel(
                                                          id: 0,
                                                          nameTh: 'เลือกตำบล');
                                                  Global.amphureList = [];
                                                  Global.tambonList = [];
                                                  setState(
                                                      () {}); // Update UI to show loading state

                                                  await loadAmphureByProvince(
                                                      value.id);
                                                  setState(
                                                      () {}); // Update UI after data loads
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.grey[300]!),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.03),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: MiraiDropDownMenu<
                                                  AmphureModel>(
                                                key: UniqueKey(),
                                                children: Global.amphureList,
                                                space: 4,
                                                maxHeight: 360,
                                                showSearchTextField: true,
                                                selectedItemBackgroundColor:
                                                    Colors.transparent,
                                                emptyListMessage: 'ไม่มีข้อมูล',
                                                showSelectedItemBackgroundColor:
                                                    true,
                                                itemWidgetBuilder: (
                                                  int index,
                                                  AmphureModel? project, {
                                                  bool isItemSelected = false,
                                                }) {
                                                  return LocationDropDownItemWidget(
                                                    project: project,
                                                    isItemSelected:
                                                        isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 14.sp,
                                                  );
                                                },
                                                onChanged:
                                                    (AmphureModel value) async {
                                                  Global.amphureModel = value;
                                                  Global.amphureNotifier!
                                                      .value = value;
                                                  Global.tambonModel = null;
                                                  Global.tambonNotifier!.value =
                                                      TambonModel(
                                                          id: 0,
                                                          nameTh: 'เลือกตำบล');
                                                  Global.tambonList = [];
                                                  setState(
                                                      () {}); // Update UI to show loading state
                                                  await loadTambonByAmphure(
                                                      value.id);
                                                  setState(() {});
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                    color: Colors.grey[300]!),
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(
                                                            alpha: 0.03),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: MiraiDropDownMenu<
                                                  TambonModel>(
                                                key: UniqueKey(),
                                                children: Global.tambonList,
                                                space: 4,
                                                maxHeight: 360,
                                                showSearchTextField: true,
                                                selectedItemBackgroundColor:
                                                    Colors.transparent,
                                                emptyListMessage: 'ไม่มีข้อมูล',
                                                showSelectedItemBackgroundColor:
                                                    true,
                                                itemWidgetBuilder: (
                                                  int index,
                                                  TambonModel? project, {
                                                  bool isItemSelected = false,
                                                }) {
                                                  return LocationDropDownItemWidget(
                                                    project: project,
                                                    isItemSelected:
                                                        isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 14.sp,
                                                  );
                                                },
                                                onChanged: (TambonModel value) {
                                                  Global.tambonModel = value;
                                                  Global.tambonNotifier!.value =
                                                      value;
                                                  postalCodeCtrl.text =
                                                      value.zipCode.toString();
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
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: buildTextFieldBig(
                                          labelText: 'รหัสไปรษณีย์',
                                          inputType: TextInputType.number,
                                          controller: postalCodeCtrl,
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
                                            buildTextField(
                                              line: 2,
                                              labelText: 'หมายเหตุ'.tr(),
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: remarkCtrl,
                                              prefixIcon:
                                                  Icon(Icons.note, size: 14.sp),
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
                        const SizedBox(height: 10),
                        _buildModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section 1: อาชีพ (Occupation)
                              Text(
                                'อาชีพ (KYC : Know Your Customer)',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // First row: occupation dropdown and custom input field
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ประสงค์ระบุเอง',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          GroupedOccupationDropdown(
                                            occupations: occupations,
                                            selectedOccupation: selectedOccupation,
                                            onChanged: (OccupationModel value) {
                                              setState(() {
                                                selectedOccupation = value;
                                                showCustomOccupationInput =
                                                    value.name == 'ประสงค์ระบุเอง';
                                                if (!showCustomOccupationInput) {
                                                  occupationCtrl.clear();
                                                }
                                              });
                                            },
                                            emptyMessage: 'ไม่มีข้อมูล',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (showCustomOccupationInput) ...[
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: buildTextFieldBig(
                                          labelText: 'ระบุอาชีพ',
                                          inputType: TextInputType.text,
                                          controller: occupationCtrl,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 16),
                              // File attachment row with dropdown and action buttons
                              Row(
                                children: [
                                  // Dropdown for file selection
                                  Expanded(
                                    child: CompositedTransformTarget(
                                      link: _occupationFileLayerLink,
                                      child: Builder(
                                        builder: (BuildContext btnContext) {
                                          return InkWell(
                                            onTap: occupationFiles.isEmpty
                                                ? null
                                                : () {
                                                    if (_occupationFileOverlay == null) {
                                                      showFileSelectionDropdown('occupation', btnContext);
                                                    } else {
                                                      _removeFileOverlay('occupation');
                                                    }
                                                    setState(() {});
                                                  },
                                            child: Container(
                                        height: 60,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!, width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_file, color: Colors.blue, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: selectedOccupationFile != null
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          selectedOccupationFile!.file.name,
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.black87,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          DateFormat('dd/MM/yyyy HH:mm').format(selectedOccupationFile!.addedDateTime),
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      'โฟลเกอ- วันที่ Attachment',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                            ),
                                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                          ],
                                        ),
                                      ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Add button (เพิ่ม)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'เพิ่ม',
                                      icon: Icons.save,
                                      color: const Color(0xFF26A69A),
                                      size: ButtonSize.medium,
                                      onTap: () => pickFile('occupation'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete button (ลบ)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'ลบ',
                                      icon: Icons.delete,
                                      color: selectedOccupationFile != null ? const Color(0xFFE57373) : Colors.grey[300]!,
                                      size: ButtonSize.medium,
                                      variant: selectedOccupationFile != null ? ButtonVariant.primary : ButtonVariant.outlined,
                                      enabled: selectedOccupationFile != null,
                                      onTap: () => removeFileFromList('occupation'),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Section: ประเภทธุรกิจ (Business Type) - Only for company customers
                              if (selectedType?.code == 'company') ...[
                                Text(
                                  'ประเภทธุรกิจ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildSimpleDropdown(
                                  labelText: 'นิติบุคคลทั่วไป',
                                  value: null,
                                  items: ['นิติบุคคลทั่วไป', 'สาขา'],
                                  onChanged: (value) {},
                                ),
                                const SizedBox(height: 32),
                              ],

                              // Section 2: แบบประเมินความเสี่ยงลูกค้า (Risk Assessment)
                              Text(
                                'แบบประเมินความเสี่ยงลูกค้า',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // File attachment row with dropdown and action buttons
                              Row(
                                children: [
                                  // Dropdown for file selection
                                  Expanded(
                                    child: CompositedTransformTarget(
                                      link: _riskFileLayerLink,
                                      child: Builder(
                                        builder: (BuildContext btnContext) {
                                          return InkWell(
                                            onTap: riskAssessmentFiles.isEmpty
                                                ? null
                                                : () {
                                                    if (_riskFileOverlay == null) {
                                                      showFileSelectionDropdown('risk', btnContext);
                                                    } else {
                                                      _removeFileOverlay('risk');
                                                    }
                                                    setState(() {});
                                                  },
                                            child: Container(
                                        height: 60,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!, width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_file, color: Colors.blue, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: selectedRiskAssessmentFile != null
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          selectedRiskAssessmentFile!.file.name,
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.black87,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          DateFormat('dd/MM/yyyy HH:mm').format(selectedRiskAssessmentFile!.addedDateTime),
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      'โฟลเกอ- วันที่ Attachment',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                            ),
                                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                          ],
                                        ),
                                      ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Add button (เพิ่ม)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'เพิ่ม',
                                      icon: Icons.save,
                                      color: const Color(0xFF26A69A),
                                      size: ButtonSize.medium,
                                      onTap: () => pickFile('risk'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete button (ลบ)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'ลบ',
                                      icon: Icons.delete,
                                      color: selectedRiskAssessmentFile != null ? const Color(0xFFE57373) : Colors.grey[300]!,
                                      size: ButtonSize.medium,
                                      variant: selectedRiskAssessmentFile != null ? ButtonVariant.primary : ButtonVariant.outlined,
                                      enabled: selectedRiskAssessmentFile != null,
                                      onTap: () => removeFileFromList('risk'),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 32),

                              // Section 3: ภาพลูกค้า (Customer Photo)
                              Text(
                                'ภาพลูกค้า',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // File attachment row with dropdown and action buttons
                              Row(
                                children: [
                                  // Dropdown for file selection
                                  Expanded(
                                    child: CompositedTransformTarget(
                                      link: _photoFileLayerLink,
                                      child: Builder(
                                        builder: (BuildContext btnContext) {
                                          return InkWell(
                                            onTap: customerPhotoFiles.isEmpty
                                                ? null
                                                : () {
                                                    if (_photoFileOverlay == null) {
                                                      showFileSelectionDropdown('photo', btnContext);
                                                    } else {
                                                      _removeFileOverlay('photo');
                                                    }
                                                    setState(() {});
                                                  },
                                            child: Container(
                                        height: 60,
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!, width: 1),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.attach_file, color: Colors.blue, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: selectedCustomerPhotoFile != null
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Text(
                                                          selectedCustomerPhotoFile!.file.name,
                                                          style: TextStyle(
                                                            fontSize: 12.sp,
                                                            color: Colors.black87,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                        const SizedBox(height: 2),
                                                        Text(
                                                          DateFormat('dd/MM/yyyy HH:mm').format(selectedCustomerPhotoFile!.addedDateTime),
                                                          style: TextStyle(
                                                            fontSize: 11.sp,
                                                            color: Colors.grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      'โฟลเกอ- วันที่ Attachment',
                                                      style: TextStyle(
                                                        fontSize: 12.sp,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                            ),
                                            Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                          ],
                                        ),
                                      ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Add button (เพิ่ม)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'เพิ่ม',
                                      icon: Icons.save,
                                      color: const Color(0xFF26A69A),
                                      size: ButtonSize.medium,
                                      onTap: () => pickFile('photo'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Delete button (ลบ)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'ลบ',
                                      icon: Icons.delete,
                                      color: selectedCustomerPhotoFile != null ? const Color(0xFFE57373) : Colors.grey[300]!,
                                      size: ButtonSize.medium,
                                      variant: selectedCustomerPhotoFile != null ? ButtonVariant.primary : ButtonVariant.outlined,
                                      enabled: selectedCustomerPhotoFile != null,
                                      onTap: () => removeFileFromList('photo'),
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

              // Validate Tax Number
              String taxNumber = '';
              if (selectedType?.code == 'company') {
                taxNumber = nationality == 'Thai'
                    ? taxNumberCtrl.text
                    : idCardCtrl.text;
              } else {
                taxNumber = nationality == 'Thai'
                    ? idCardCtrl.text
                    : taxNumberCtrl.text;
              }

              if (taxNumber.isNotEmpty) {
                // Check length for Thai nationality
                if (nationality == 'Thai' && taxNumber.length != 13) {
                  Alert.info(
                      context,
                      'คำเตือน',
                      'Tax ID ไม่เท่ากับ 13 หลัก\nคุณแน่ใจว่าจะดำเนินการต่อ?',
                      'ตกลง', action: () async {
                    await _processSave();
                  });
                  return;
                }

                // Check for duplicates
                bool isValid = await validateTaxNumber(taxNumber);
                if (!isValid) {
                  Alert.warning(
                      context,
                      'คำเตือน',
                      'Tax number already exists. Please use a different tax number',
                      'OK',
                      action: () {});
                  return;
                }
              }

              await _processSave();
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

  Future<void> _processSave() async {
    if (selectedCustomer == null) {
      var customerObject = Global.requestObj({
        "customerType": selectedType?.code,
        "companyName": companyNameCtrl.text,

        // Name fields
        "titleName": selectedTitleName?.name,
        "firstName": firstNameCtrl.text,
        "middleName": middleNameCtrl.text,
        "lastName": lastNameCtrl.text,

        // Contact info
        "email": emailAddressCtrl.text,
        "doB": birthDateCtrl.text.isEmpty
            ? ""
            : DateTime.parse(birthDateCtrl.text).toString(),
        "phoneNumber": phoneCtrl.text,
        "username": generateRandomString(8),
        "password": generateRandomString(10),

        // Address fields (Thai enhanced structure)
        "building": buildingCtrl.text,
        "roomNo": roomNumberCtrl.text,
        "floor": floorCtrl.text,
        "address": Global.addressCtrl.text, // House number
        "village": villageCtrl.text,
        "moo": mooCtrl.text,
        "soi": soiCtrl.text,
        "road": roadCtrl.text,
        "tambonId":
            nationality == 'Foreigner' && selectedType?.code == 'general'
                ? 3023
                : Global.tambonModel?.id,
        "amphureId":
            nationality == 'Foreigner' && selectedType?.code == 'general'
                ? 9614
                : Global.amphureModel?.id,
        "provinceId":
            nationality == 'Foreigner' && selectedType?.code == 'general'
                ? 78
                : Global.provinceModel?.id,
        "postalCode":
            nationality == 'Foreigner' && selectedType?.code == 'general'
                ? ''
                : postalCodeCtrl.text,

        // Nationality and ID info
        "nationality": nationality,
        "cardType": selectedCardType,
        "idCard": selectedType?.code == "general" ? idCardCtrl.text : "",
        "idCardIssueDate": issueDateCtrl.text.isEmpty
            ? null
            : DateTime.parse(issueDateCtrl.text).toString(),
        "idCardExpiryDate": expiryDateCtrl.text.isEmpty
            ? null
            : DateTime.parse(expiryDateCtrl.text).toString(),

        // Foreign national fields
        "entryDate": entryDateCtrl.text.isEmpty
            ? null
            : DateTime.parse(entryDateCtrl.text).toString(),
        "exitDate": exitDateCtrl.text.isEmpty
            ? null
            : DateTime.parse(exitDateCtrl.text).toString(),
        "passportId": nationality == 'Foreigner' ? passportNoCtrl.text : '',
        "workPermit": nationality == 'Foreigner' ? workPermitCtrl.text : '',

        // Business fields
        "branchCode": branchCodeCtrl.text,
        "taxNumber": selectedType?.code == "company"
            ? nationality == 'Thai'
                ? taxNumberCtrl.text
                : taxNumberCtrl.text
            : nationality == 'Thai'
                ? idCardCtrl.text
                : taxNumberCtrl.text,

        // Occupation
        "occupation": selectedOccupation?.name ?? occupationCtrl.text,
        "occupationCustom": selectedOccupation?.name == 'ประสงค์ระบุเอง'
            ? occupationCtrl.text
            : null,

        // Customer type flags
        "isSeller": isSeller ? 1 : 0,
        "isBuyer": isBuyer ? 1 : 0,
        "isCustomer": isCustomer ? 1 : 0,

        // Other
        "photoUrl": '',
        "remark": remarkCtrl.text,
      });

      Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
          action: () async {
        final ProgressDialog pr = ProgressDialog(context,
            type: ProgressDialogType.normal,
            isDismissible: true,
            showLogs: true);
        await pr.show();
        pr.update(message: 'processing'.tr());

        var result = await ApiServices.post('/customer/create', customerObject);
        await pr.hide();

        if (result?.status == "success") {
          if (mounted) {
            CustomerModel customer =
                customerModelFromJson(jsonEncode(result!.data!));
            setState(() {
              Global.customer = customer;
            });

            // Upload KYC files after customer creation
            await _uploadKycFiles(customer.id!);

            if (mounted) {
              Alert.success(
                  context, 'Success'.tr(), "บันทึกเรียบร้อยแล้ว", 'OK'.tr(),
                  action: () {
                Navigator.of(context).pop();
              });
            }
          }
        } else {
          if (mounted) {
            Alert.warning(context, 'Warning'.tr(),
                result!.message ?? result.data, 'OK'.tr(),
                action: () {});
          }
        }
      });
    } else {
      setState(() {
        Global.customer = selectedCustomer;
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _uploadKycFiles(int customerId) async {
    try {
      // Upload Occupation files
      for (var fileWithTime in occupationFiles) {
        await _uploadSingleFile(
          customerId,
          fileWithTime.file,
          'Occupation',
          fileWithTime.addedDateTime,
        );
      }

      // Upload Risk Assessment files
      for (var fileWithTime in riskAssessmentFiles) {
        await _uploadSingleFile(
          customerId,
          fileWithTime.file,
          'RiskAssessment',
          fileWithTime.addedDateTime,
        );
      }

      // Upload Customer Photo files
      for (var fileWithTime in customerPhotoFiles) {
        await _uploadSingleFile(
          customerId,
          fileWithTime.file,
          'Photo',
          fileWithTime.addedDateTime,
        );
      }
    } catch (e) {
      print('Error uploading KYC files: $e');
      // Don't block the success message, just log the error
    }
  }

  Future<void> _uploadSingleFile(
    int customerId,
    PlatformFile file,
    String attachmentType,
    DateTime attachmentDate,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${Constants.BACKEND_URL}/api/customer/attachment/$customerId'),
      );

      // Add file
      if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      // Add fields
      request.fields['attachmentType'] = attachmentType;
      request.fields['attachmentDate'] = attachmentDate.toIso8601String();

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        if (data['status'] == 'success') {
          print('Successfully uploaded $attachmentType file: ${file.name}');
        }
      }
    } catch (e) {
      print('Error uploading file ${file.name}: $e');
      rethrow;
    }
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

  // 1. Add tax number validation function at the top of your class
  Future<bool> validateTaxNumber(String taxNumber) async {
    if (taxNumber.isEmpty) return true;

    try {
      var result = await ApiServices.post('/customer/check-tax-number',
          Global.requestObj({"taxNumber": taxNumber}));

      if (result?.status == "success") {
        return result?.data == null; // true if no duplicate found
      }
      return true;
    } catch (e) {
      return true; // Allow on error to avoid blocking
    }
  }

  // File picker method for KYC documents
  Future<void> pickFile(String fileType) async {
    try {
      if (fileType == 'photo') {
        // For photos, use ImagePicker to access photo library
        await _pickFromGallery(fileType);
      } else {
        // For documents, show dialog to choose between file or photo
        await _showPickerDialog(fileType);
      }
    } catch (e) {
      motivePrint("Error picking file: $e");
    }
  }

  // Show dialog to choose between file picker or photo gallery
  Future<void> _showPickerDialog(String fileType) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('เลือกแหล่งที่มา', style: TextStyle(fontSize: 16.sp)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: Text('เลือกจากคลังภาพ', style: TextStyle(fontSize: 14.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery(fileType);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.folder_open, color: Colors.orange),
                title: Text('เลือกจากไฟล์', style: TextStyle(fontSize: 14.sp)),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromFiles(fileType);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Pick from photo gallery using ImagePicker
  Future<void> _pickFromGallery(String fileType) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        // Convert XFile to PlatformFile format for consistency
        final File file = File(image.path);
        final int fileSize = await file.length();
        final String fileName = image.path.split('/').last;

        final PlatformFile platformFile = PlatformFile(
          path: image.path,
          name: fileName,
          size: fileSize,
          bytes: await file.readAsBytes(),
        );

        if (!mounted) return;
        setState(() {
          final fileWithTimestamp = FileWithTimestamp(platformFile, DateTime.now());
          if (fileType == 'photo') {
            customerPhotoFiles.add(fileWithTimestamp);
            selectedCustomerPhotoFile = fileWithTimestamp;
          } else if (fileType == 'occupation') {
            occupationFiles.add(fileWithTimestamp);
            selectedOccupationFile = fileWithTimestamp;
          } else if (fileType == 'risk') {
            riskAssessmentFiles.add(fileWithTimestamp);
            selectedRiskAssessmentFile = fileWithTimestamp;
          }
        });
      }
    } catch (e) {
      motivePrint("Error picking from gallery: $e");
    }
  }

  // Pick from file system using FilePicker
  Future<void> _pickFromFiles(String fileType) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile pickedFile = result.files.first;
        String? ext = pickedFile.extension?.toLowerCase();

        // Validate file extension
        List<String> allowedExtensions = [
          'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
          'txt', 'rtf', 'odt', 'ods', 'odp',
          'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp'
        ];
        if (ext == null || !allowedExtensions.contains(ext)) {
          if (!mounted) return;
          Alert.warning(context, 'คำเตือน',
            'กรุณาเลือกไฟล์เอกสารหรือรูปภาพเท่านั้น',
            'OK', action: () {});
          return;
        }

        // Add file to list immediately and select it
        if (!mounted) return;
        setState(() {
          final fileWithTimestamp = FileWithTimestamp(pickedFile, DateTime.now());
          if (fileType == 'occupation') {
            occupationFiles.add(fileWithTimestamp);
            selectedOccupationFile = fileWithTimestamp;
          } else if (fileType == 'risk') {
            riskAssessmentFiles.add(fileWithTimestamp);
            selectedRiskAssessmentFile = fileWithTimestamp;
          }
        });
      }
    } catch (e) {
      motivePrint("Error picking from files: $e");
    }
  }

  // Add file to the list
  void addFileToList(String fileType) {
    setState(() {
      if (fileType == 'occupation' && selectedOccupationFile != null) {
        occupationFiles.add(selectedOccupationFile!);
        // Set as selected in dropdown
        selectedOccupationFile = occupationFiles.last;
      } else if (fileType == 'risk' && selectedRiskAssessmentFile != null) {
        riskAssessmentFiles.add(selectedRiskAssessmentFile!);
        selectedRiskAssessmentFile = riskAssessmentFiles.last;
      } else if (fileType == 'photo' && selectedCustomerPhotoFile != null) {
        customerPhotoFiles.add(selectedCustomerPhotoFile!);
        selectedCustomerPhotoFile = customerPhotoFiles.last;
      }
    });
  }

  // Remove selected file from list
  void removeFileFromList(String fileType) {
    setState(() {
      if (fileType == 'occupation' && selectedOccupationFile != null) {
        occupationFiles.remove(selectedOccupationFile);
        selectedOccupationFile = occupationFiles.isNotEmpty ? occupationFiles.first : null;
      } else if (fileType == 'risk' && selectedRiskAssessmentFile != null) {
        riskAssessmentFiles.remove(selectedRiskAssessmentFile);
        selectedRiskAssessmentFile = riskAssessmentFiles.isNotEmpty ? riskAssessmentFiles.first : null;
      } else if (fileType == 'photo' && selectedCustomerPhotoFile != null) {
        customerPhotoFiles.remove(selectedCustomerPhotoFile);
        selectedCustomerPhotoFile = customerPhotoFiles.isNotEmpty ? customerPhotoFiles.first : null;
      }
    });
  }

  // Format filename to show the end (with date/time) instead of beginning
  String formatFileName(String? fileName, {int maxLength = 60}) {
    if (fileName == null || fileName.isEmpty) {
      return 'โฟลเกอ- วันที่ Attachment';
    }

    if (fileName.length <= maxLength) {
      return fileName;
    }

    // Show the last part of filename (which contains date/time)
    return '...${fileName.substring(fileName.length - maxLength)}';
  }

  // Format file size for display
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Remove file dropdown overlay
  void _removeFileOverlay(String fileType) {
    if (fileType == 'occupation') {
      _occupationFileOverlay?.remove();
      _occupationFileOverlay = null;
    } else if (fileType == 'risk') {
      _riskFileOverlay?.remove();
      _riskFileOverlay = null;
    } else {
      _photoFileOverlay?.remove();
      _photoFileOverlay = null;
    }
  }

  // Show file selection dropdown
  void showFileSelectionDropdown(String fileType, BuildContext buttonContext) {
    List<FileWithTimestamp> files;
    FileWithTimestamp? selectedFile;

    if (fileType == 'occupation') {
      files = occupationFiles;
      selectedFile = selectedOccupationFile;
    } else if (fileType == 'risk') {
      files = riskAssessmentFiles;
      selectedFile = selectedRiskAssessmentFile;
    } else {
      files = customerPhotoFiles;
      selectedFile = selectedCustomerPhotoFile;
    }

    final RenderBox renderBox = buttonContext.findRenderObject() as RenderBox;
    final size = renderBox.size;

    final overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _removeFileOverlay(fileType);
          setState(() {});
        },
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: fileType == 'occupation'
                    ? _occupationFileLayerLink
                    : fileType == 'risk'
                        ? _riskFileLayerLink
                        : _photoFileLayerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: files.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'ไม่มีไฟล์',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final fileWithTimestamp = files[index];
                              final file = fileWithTimestamp.file;
                              final addedDateTime = fileWithTimestamp.addedDateTime;
                              final isSelected = selectedFile?.file.name == file.name;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (fileType == 'occupation') {
                                      selectedOccupationFile = fileWithTimestamp;
                                    } else if (fileType == 'risk') {
                                      selectedRiskAssessmentFile = fileWithTimestamp;
                                    } else {
                                      selectedCustomerPhotoFile = fileWithTimestamp;
                                    }
                                  });
                                  _removeFileOverlay(fileType);
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  color: isSelected
                                      ? Colors.blue.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  child: Row(
                                    children: [
                                      // File icon
                                      Icon(
                                        _getFileIcon(file.extension ?? ''),
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      // File info - showing filename and date as separate columns
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Filename
                                            Text(
                                              file.name,
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                                color: Colors.grey[800],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 2),
                                            // Date/time and file size as separate row
                                            Text(
                                              '${DateFormat('dd/MM/yyyy HH:mm').format(addedDateTime)} • ${_formatFileSize(file.size)}',
                                              style: TextStyle(
                                                fontSize: 11.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Store and insert overlay
    if (fileType == 'occupation') {
      _occupationFileOverlay = overlayEntry;
    } else if (fileType == 'risk') {
      _riskFileOverlay = overlayEntry;
    } else {
      _photoFileOverlay = overlayEntry;
    }

    Overlay.of(buttonContext).insert(overlayEntry);
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  // Download/Save selected file
  void downloadFile(String fileType) {
    FileWithTimestamp? fileWithTimestamp;
    if (fileType == 'occupation') {
      fileWithTimestamp = selectedOccupationFile;
    } else if (fileType == 'risk') {
      fileWithTimestamp = selectedRiskAssessmentFile;
    } else if (fileType == 'photo') {
      fileWithTimestamp = selectedCustomerPhotoFile;
    }

    if (fileWithTimestamp != null) {
      motivePrint("Downloading file: ${fileWithTimestamp.file.name}");
      // TODO: Implement actual download logic
    }
  }

// 2. Replace your tax number field validation with this enhanced version:
  Widget buildTaxNumberField() {
    return buildTextFieldBig(
      labelText: nationality == 'Thai'
          ? (selectedType?.code == 'company'
              ? 'เลขประจำตัวผู้เสียภาษี'
              : 'เลขบัตรประชาชน')
          : 'Tax ID',
      inputType: TextInputType.number,
      controller: selectedType?.code == 'company'
          ? (nationality == 'Thai' ? taxNumberCtrl : idCardCtrl)
          : (nationality == 'Thai' ? idCardCtrl : taxNumberCtrl),
      prefixIcon: Icon(
          nationality == 'Thai'
              ? (selectedType?.code == 'company'
                  ? Icons.receipt
                  : Icons.credit_card)
              : Icons.receipt,
          size: 14.sp),
    );
  }
}
