import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/customer.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/model/product_type.dart';
import 'package:motivegold/model/nationality.dart';
import 'package:motivegold/model/occupation.dart';
import 'package:motivegold/model/title_name.dart';
import 'package:motivegold/model/card_type.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/motive.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/date/date_picker.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/LocationDropDownObjectChildWidget.dart';
import 'package:motivegold/widget/dropdown/GroupedDropdownWidget.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:motivegold/widget/customer/customer_summary_panel.dart';
import 'package:motivegold/widget/customer/attachment_section.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';

// Thai ID Card formatter: x xxxx xxxxx xx x
class ThaiIdCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');

    // Limit to 13 digits
    if (text.length > 13) {
      return oldValue;
    }

    // Only allow digits
    if (text.isNotEmpty && !RegExp(r'^[0-9]+$').hasMatch(text)) {
      return oldValue;
    }

    // Format: x xxxx xxxxx xx x
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      // Add space after position 0, 4, 9, 11
      if (i == 0 || i == 4 || i == 9 || i == 11) {
        if (i < text.length - 1) {
          buffer.write(' ');
        }
      }
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

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

  // New controllers for enhanced customer fields
  final TextEditingController middleNameCtrl = TextEditingController();
  final TextEditingController buildingCtrl = TextEditingController();
  final TextEditingController roomNoCtrl = TextEditingController();
  final TextEditingController floorCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController mooCtrl = TextEditingController();
  final TextEditingController soiCtrl = TextEditingController();
  final TextEditingController roadCtrl = TextEditingController();
  final TextEditingController idCardIssueDateCtrl = TextEditingController();
  final TextEditingController idCardExpiryDateCtrl = TextEditingController();
  final TextEditingController entryDateCtrl = TextEditingController();
  final TextEditingController exitDateCtrl = TextEditingController();
  final TextEditingController occupationCustomCtrl = TextEditingController();

  // Company customer specific controllers
  final TextEditingController establishmentNameCtrl = TextEditingController();
  final TextEditingController registrationDateCtrl = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  List<File>? imageFiles = [];

  // Document attachments and photo
  List<PlatformFile> attachedDocuments = [];
  File? customerPhoto;

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

  // Reference data lists
  List<NationalityModel> nationalities = [];
  List<OccupationModel> occupations = [];
  List<TitleNameModel> titleNames = [];
  List<CardTypeModel> cardTypes = [];

  // Selected values for dropdowns
  TitleNameModel? selectedTitleName;
  ValueNotifier<dynamic>? titleNameNotifier;

  NationalityModel? selectedNationality;
  ValueNotifier<dynamic>? nationalityNotifier;

  OccupationModel? selectedOccupation;
  ValueNotifier<dynamic>? occupationNotifier;

  CardTypeModel? selectedCardType;
  ValueNotifier<dynamic>? cardTypeNotifier;

  // Company customer specific state
  NationalityModel? selectedCountry;
  ValueNotifier<dynamic>? countryNotifier;
  String? headquartersOrBranch = 'headquarters'; // Default to headquarters
  OccupationModel? selectedCompanyBusinessType;
  ValueNotifier<dynamic>? companyBusinessTypeNotifier;

  bool loadingReferenceData = false;

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

    // motivePrint(widget.c.toJson());
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

    // Initialize reference data notifiers
    titleNameNotifier = ValueNotifier<TitleNameModel?>(null);
    nationalityNotifier = ValueNotifier<NationalityModel?>(null);
    occupationNotifier = ValueNotifier<OccupationModel?>(null);
    cardTypeNotifier = ValueNotifier<CardTypeModel?>(null);

    // Initialize company customer notifiers
    countryNotifier = ValueNotifier<NationalityModel?>(null);
    companyBusinessTypeNotifier = ValueNotifier<OccupationModel?>(null);

    // birthDateCtrl.text = Global.dateOnlyT(DateTime.now().toString());
    // Global.addressCtrl.text = "";

    // Load reference data
    loadReferenceData();

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

    // Dispose all new controllers
    middleNameCtrl.dispose();
    buildingCtrl.dispose();
    roomNoCtrl.dispose();
    floorCtrl.dispose();
    villageCtrl.dispose();
    mooCtrl.dispose();
    soiCtrl.dispose();
    roadCtrl.dispose();
    idCardIssueDateCtrl.dispose();
    idCardExpiryDateCtrl.dispose();
    entryDateCtrl.dispose();
    exitDateCtrl.dispose();
    occupationCustomCtrl.dispose();
    establishmentNameCtrl.dispose();
    registrationDateCtrl.dispose();

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

    // Load new enhanced fields
    middleNameCtrl.text = widget.c.middleName ?? '';
    buildingCtrl.text = widget.c.building ?? '';
    roomNoCtrl.text = widget.c.roomNo ?? '';
    floorCtrl.text = widget.c.floor ?? '';
    villageCtrl.text = widget.c.village ?? '';
    mooCtrl.text = widget.c.moo ?? '';
    soiCtrl.text = widget.c.soi ?? '';
    roadCtrl.text = widget.c.road ?? '';
    occupationCustomCtrl.text = widget.c.occupationCustom ?? '';

    // Load company-specific fields
    establishmentNameCtrl.text = widget.c.establishmentName ?? '';
    headquartersOrBranch = widget.c.headquartersOrBranch ?? 'headquarters';

    // Load dates
    idCardIssueDateCtrl.text = widget.c.idCardIssueDate != null
        ? Global.dateOnlyT(widget.c.idCardIssueDate.toString()) : '';
    idCardExpiryDateCtrl.text = widget.c.idCardExpiryDate != null
        ? Global.dateOnlyT(widget.c.idCardExpiryDate.toString()) : '';
    entryDateCtrl.text = widget.c.entryDate != null
        ? Global.dateOnlyT(widget.c.entryDate.toString()) : '';
    exitDateCtrl.text = widget.c.exitDate != null
        ? Global.dateOnlyT(widget.c.exitDate.toString()) : '';
    registrationDateCtrl.text = widget.c.registrationDate != null
        ? Global.dateOnlyT(widget.c.registrationDate.toString()) : '';

    // motivePrint(widget.c.toJson());

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

  // Helper method to format Thai ID card number: x xxxx xxxxx xx x
  String formatIdCard(String idCard) {
    final text = idCard.replaceAll(' ', '');
    if (text.length != 13) return idCard;

    return '${text[0]} ${text.substring(1, 5)} ${text.substring(5, 10)} ${text.substring(10, 12)} ${text[12]}';
  }

  // Load all reference data for dropdowns
  Future<void> loadReferenceData() async {
    if (!mounted) return;

    setState(() {
      loadingReferenceData = true;
    });

    try {
      // Load Nationalities
      var nationalitiesResult = await ApiServices.getNationalities();
      if (nationalitiesResult?.status == "success" && nationalitiesResult?.data != null) {
        var data = jsonEncode(nationalitiesResult!.data);
        if (mounted) {
          setState(() {
            nationalities = nationalityListModelFromJson(data);
          });
        }
      }

      // Load Occupations
      var occupationsResult = await ApiServices.getOccupations();
      if (occupationsResult?.status == "success" && occupationsResult?.data != null) {
        var data = jsonEncode(occupationsResult!.data);
        if (mounted) {
          setState(() {
            occupations = occupationListModelFromJson(data);
          });
        }
      }

      // Load TitleNames
      var titleNamesResult = await ApiServices.getTitleNames();
      if (titleNamesResult?.status == "success" && titleNamesResult?.data != null) {
        var data = jsonEncode(titleNamesResult!.data);
        if (mounted) {
          setState(() {
            titleNames = titleNameListModelFromJson(data);
          });
        }
      }

      // Load CardTypes
      var cardTypesResult = await ApiServices.getCardTypes();
      if (cardTypesResult?.status == "success" && cardTypesResult?.data != null) {
        var data = jsonEncode(cardTypesResult!.data);
        if (mounted) {
          setState(() {
            cardTypes = cardTypeListModelFromJson(data);
          });
        }
      }
    } catch (e) {
      motivePrint('Error loading reference data: ${e.toString()}');
    }

    if (mounted) {
      setState(() {
        loadingReferenceData = false;
      });
    }
  }

  // Pick documents for attachment
  Future<void> pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          attachedDocuments.addAll(result.files);
        });
      }
    } catch (e) {
      motivePrint('Error picking documents: ${e.toString()}');
    }
  }

  // Remove attached document
  void removeDocument(int index) {
    setState(() {
      attachedDocuments.removeAt(index);
    });
  }

  // Pick customer photo from camera
  Future<void> pickCustomerPhoto() async {
    try {
      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          customerPhoto = File(photo.path);
        });
      }
    } catch (e) {
      motivePrint('Error picking photo: ${e.toString()}');
    }
  }

  // Pick customer photo from gallery
  Future<void> pickCustomerPhotoFromGallery() async {
    try {
      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          customerPhoto = File(photo.path);
        });
      }
    } catch (e) {
      motivePrint('Error picking photo: ${e.toString()}');
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

  // Check if selected province is Bangkok
  bool _isBangkok() {
    if (Global.provinceModel == null) return false;
    String provinceName = Global.provinceModel?.nameTh?.toLowerCase() ?? '';
    return provinceName.contains('กรุงเทพ') || provinceName.contains('bangkok');
  }

  // Get label for Tambon based on province
  String _getTambonLabel() {
    return _isBangkok() ? 'เลือกแขวง' : 'เลือกตำบล';
  }

  // Get label for Amphure based on province
  String _getAmphureLabel() {
    return _isBangkok() ? 'เลือกเขต' : 'เลือกอำเภอ';
  }

  // Get label for Province (no prefix for Bangkok)
  String _getProvinceLabel() {
    return 'เลือกจังหวัด';
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
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left side - Form
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
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
                              // Title Name Dropdown for Individual Customers
                              if (selectedType?.code == 'general')
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(
                                              'คำนำหน้า',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 70,
                                              child: MiraiDropDownMenu<
                                                  TitleNameModel>(
                                                key: UniqueKey(),
                                                children: titleNames,
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
                                                  TitleNameModel? project, {
                                                  bool isItemSelected = false,
                                                }) {
                                                  return DropDownItemWidget(
                                                    project: project,
                                                    isItemSelected:
                                                        isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 14.sp,
                                                  );
                                                },
                                                onChanged:
                                                    (TitleNameModel value) {
                                                  selectedTitleName = value;
                                                  titleNameNotifier!.value =
                                                      value;
                                                  setState(() {});
                                                },
                                                child:
                                                    DropDownObjectChildWidget(
                                                  key: GlobalKey(),
                                                  fontSize: 14.sp,
                                                  projectValueNotifier:
                                                      titleNameNotifier!,
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
                                  if (nationality == 'Foreigner' && selectedType?.code != 'company')
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
                                  if (nationality == 'Foreigner' && selectedType?.code != 'company')
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
                              // Company customer additional fields
                              // Country dropdown for company
                              if (selectedType?.code == 'company')
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(
                                              'ประเทศ (Country)',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 70,
                                              child: MiraiDropDownMenu<NationalityModel>(
                                                key: UniqueKey(),
                                                children: nationalities,
                                                space: 4,
                                                maxHeight: 360,
                                                showSearchTextField: true,
                                                selectedItemBackgroundColor: Colors.transparent,
                                                emptyListMessage: 'ไม่มีข้อมูล',
                                                showSelectedItemBackgroundColor: true,
                                                itemWidgetBuilder: (int index, NationalityModel? project, {bool isItemSelected = false}) {
                                                  return DropDownItemWidget(
                                                    project: project,
                                                    isItemSelected: isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 14.sp,
                                                  );
                                                },
                                                onChanged: (NationalityModel value) {
                                                  selectedCountry = value;
                                                  countryNotifier!.value = value;
                                                  setState(() {});
                                                },
                                                child: DropDownObjectChildWidget(
                                                  key: GlobalKey(),
                                                  fontSize: 14.sp,
                                                  projectValueNotifier: countryNotifier!,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              // Establishment Name
                              if (selectedType?.code == 'company')
                                const SizedBox(height: 10),
                              if (selectedType?.code == 'company')
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            buildTextFieldBig(
                                              labelText: 'ชื่อสถานประกอบการ',
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: establishmentNameCtrl,
                                              prefixIcon: Icon(Icons.store, size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              // Headquarters or Branch radio buttons
                              if (selectedType?.code == 'company')
                                const SizedBox(height: 10),
                              if (selectedType?.code == 'company')
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        'ประเภทสถานประกอบการ',
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: Text('สำนักงานใหญ่', style: TextStyle(fontSize: 13.sp)),
                                              value: 'headquarters',
                                              groupValue: headquartersOrBranch,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  headquartersOrBranch = value;
                                                });
                                              },
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                          Expanded(
                                            child: RadioListTile<String>(
                                              title: Text('สาขา', style: TextStyle(fontSize: 13.sp)),
                                              value: 'branch',
                                              groupValue: headquartersOrBranch,
                                              onChanged: (String? value) {
                                                setState(() {
                                                  headquartersOrBranch = value;
                                                });
                                              },
                                              dense: true,
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              // Registration Date
                              if (selectedType?.code == 'company')
                                const SizedBox(height: 10),
                              if (selectedType?.code == 'company')
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            GestureDetector(
                                              onTap: () async {
                                                final DateTime? picked = await showDatePicker(
                                                  context: context,
                                                  initialDate: DateTime.now(),
                                                  firstDate: DateTime(1900),
                                                  lastDate: DateTime.now(),
                                                );
                                                if (picked != null) {
                                                  setState(() {
                                                    registrationDateCtrl.text = Global.formatDateT(picked.toString());
                                                  });
                                                }
                                              },
                                              child: AbsorbPointer(
                                                child: buildTextFieldBig(
                                                  labelText: 'วันที่จดทะเบียน',
                                                  validator: null,
                                                  inputType: TextInputType.text,
                                                  controller: registrationDateCtrl,
                                                  prefixIcon: Icon(Icons.calendar_today, size: 14.sp),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              // Business Type dropdown (from Occupations where customerType='company')
                              if (selectedType?.code == 'company')
                                const SizedBox(height: 10),
                              if (selectedType?.code == 'company')
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            GroupedDropdownWidget(
                                              items: occupations.where((o) => o.customerType == 'company').toList(),
                                              selectedItem: selectedCompanyBusinessType,
                                              onChanged: (OccupationModel value) {
                                                setState(() {
                                                  selectedCompanyBusinessType = value;
                                                  companyBusinessTypeNotifier!.value = value;
                                                });
                                              },
                                              label: 'ประเภทธุรกิจ (Business Type)',
                                              height: 50,
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
                              // Middle Name field (for foreigners only)
                              if (selectedType?.code == 'general' &&
                                  nationality == 'Foreigner')
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
                                            buildTextFieldBig(
                                              labelText: 'ชื่อกลาง (Middle Name)',
                                              validator: null,
                                              inputType: TextInputType.text,
                                              controller: middleNameCtrl,
                                              prefixIcon: Icon(Icons.person,
                                                  size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (selectedType?.code == 'general' &&
                                  nationality == 'Foreigner')
                                const SizedBox(
                                  height: 10,
                                ),
                              // Card Type Dropdown (for foreigners only)
                              if (selectedType?.code == 'general' &&
                                  nationality == 'Foreigner')
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            Text(
                                              'ประเภทบัตร (Card Type)',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            SizedBox(
                                              height: 70,
                                              child: MiraiDropDownMenu<
                                                  CardTypeModel>(
                                                key: UniqueKey(),
                                                children: cardTypes,
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
                                                  CardTypeModel? project, {
                                                  bool isItemSelected = false,
                                                }) {
                                                  return DropDownItemWidget(
                                                    project: project,
                                                    isItemSelected:
                                                        isItemSelected,
                                                    firstSpace: 10,
                                                    fontSize: 14.sp,
                                                  );
                                                },
                                                onChanged:
                                                    (CardTypeModel value) {
                                                  selectedCardType = value;
                                                  cardTypeNotifier!.value =
                                                      value;
                                                  setState(() {});
                                                },
                                                child:
                                                    DropDownObjectChildWidget(
                                                  key: GlobalKey(),
                                                  fontSize: 14.sp,
                                                  projectValueNotifier:
                                                      cardTypeNotifier!,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (selectedType?.code == 'general' &&
                                  nationality == 'Foreigner')
                                const SizedBox(
                                  height: 10,
                                ),
                              // ID Card Issue Date and Expiry Date
                              if (selectedType?.code == 'general')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.03),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: idCardIssueDateCtrl,
                                            style: TextStyle(fontSize: 14.sp),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                  Icons.calendar_today,
                                                  size: 14.sp),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 16.0),
                                              labelText: "วันที่ออกบัตร (Issue Date)",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                    color: Colors.teal,
                                                    width: 2),
                                              ),
                                            ),
                                            readOnly: true,
                                            onTap: () async {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    SfDatePickerDialog(
                                                  initialDate: DateTime.now(),
                                                  onDateSelected: (date) {
                                                    String formattedDate =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(date);
                                                    setState(() {
                                                      idCardIssueDateCtrl.text =
                                                          formattedDate;
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.03),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: idCardExpiryDateCtrl,
                                            style: TextStyle(fontSize: 14.sp),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                  Icons.calendar_today,
                                                  size: 14.sp),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 16.0),
                                              labelText: "วันหมดอายุ (Expiry Date)",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                    color: Colors.teal,
                                                    width: 2),
                                              ),
                                            ),
                                            readOnly: true,
                                            onTap: () async {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    SfDatePickerDialog(
                                                  initialDate: DateTime.now(),
                                                  onDateSelected: (date) {
                                                    String formattedDate =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(date);
                                                    setState(() {
                                                      idCardExpiryDateCtrl.text =
                                                          formattedDate;
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
                              if (selectedType?.code == 'general')
                                const SizedBox(
                                  height: 10,
                                ),
                              // Entry/Exit Dates (for foreigners only)
                              if (selectedType?.code == 'general' &&
                                  nationality == 'Foreigner')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.03),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: entryDateCtrl,
                                            style: TextStyle(fontSize: 14.sp),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                  Icons.flight_land,
                                                  size: 14.sp),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 16.0),
                                              labelText: "วันที่เดินทางเข้า (Entry Date)",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                    color: Colors.teal,
                                                    width: 2),
                                              ),
                                            ),
                                            readOnly: true,
                                            onTap: () async {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    SfDatePickerDialog(
                                                  initialDate: DateTime.now(),
                                                  onDateSelected: (date) {
                                                    String formattedDate =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(date);
                                                    setState(() {
                                                      entryDateCtrl.text =
                                                          formattedDate;
                                                    });
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 8.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(alpha: 0.03),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: TextField(
                                            controller: exitDateCtrl,
                                            style: TextStyle(fontSize: 14.sp),
                                            decoration: InputDecoration(
                                              prefixIcon: Icon(
                                                  Icons.flight_takeoff,
                                                  size: 14.sp),
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.always,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 16.0),
                                              labelText: "วันที่เดินทางออก (Exit Date)",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide.none,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                    color: Colors.grey[300]!,
                                                    width: 1),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: const BorderSide(
                                                    color: Colors.teal,
                                                    width: 2),
                                              ),
                                            ),
                                            readOnly: true,
                                            onTap: () async {
                                              showDialog(
                                                context: context,
                                                builder: (_) =>
                                                    SfDatePickerDialog(
                                                  initialDate: DateTime.now(),
                                                  onDateSelected: (date) {
                                                    String formattedDate =
                                                        DateFormat('yyyy-MM-dd')
                                                            .format(date);
                                                    setState(() {
                                                      exitDateCtrl.text =
                                                          formattedDate;
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
                              if (selectedType?.code == 'general' &&
                                  nationality == 'Foreigner')
                                const SizedBox(
                                  height: 10,
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
                              // Occupation Grouped Dropdown
                              if (selectedType?.code == 'general')
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 10),
                                            GroupedDropdownWidget(
                                              items: occupations.where((o) => o.customerType == 'general').toList(),
                                              selectedItem: selectedOccupation,
                                              onChanged: (OccupationModel value) {
                                                setState(() {
                                                  selectedOccupation = value;
                                                  occupationNotifier!.value = value;
                                                  occupationCtrl.text = value.name ?? '';
                                                });
                                              },
                                              label: 'อาชีพ (Occupation)',
                                              height: 50,
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
                              // Custom Occupation field (shows when custom option is selected)
                              if (selectedType?.code == 'general' &&
                                  (selectedOccupation?.name == 'ประสงค์ระบุเอง' ||
                                  selectedOccupation?.name == 'อื่นๆ'))
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
                                            buildTextFieldBig(
                                              labelText: 'ระบุอาชีพ (Specify Occupation)',
                                              inputType: TextInputType.text,
                                              controller: occupationCustomCtrl,
                                              prefixIcon: Icon(Icons.edit,
                                                  size: 14.sp),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              if (selectedType?.code == 'general' &&
                                  (selectedOccupation?.name == 'ประสงค์ระบุเอง' ||
                                  selectedOccupation?.name == 'อื่นๆ'))
                                const SizedBox(
                                  height: 10,
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (!(nationality == 'Foreigner' &&
                                  selectedType?.code == 'general'))
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
                                            const SizedBox(height: 10),
                                            buildTextFieldBig(
                                              labelText:
                                              'รหัสไปรษณีย์ / Postal Code',
                                              inputType: TextInputType.phone,
                                              controller: postalCodeCtrl,
                                              prefixIcon: Icon(
                                                  Icons.local_post_office,
                                                  size: 14.sp),
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
                        if (!(nationality == 'Foreigner' && selectedType?.code == 'general'))
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
                              // Detailed Address Fields
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
                                          const SizedBox(height: 10),
                                          buildTextFieldBig(
                                            labelText: 'อาคาร (Building)',
                                            inputType: TextInputType.text,
                                            controller: buildingCtrl,
                                            prefixIcon: Icon(Icons.apartment,
                                                size: 14.sp),
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
                                        children: [
                                          const SizedBox(height: 10),
                                          buildTextFieldBig(
                                            labelText: 'ห้องเลขที่ (Room No)',
                                            inputType: TextInputType.text,
                                            controller: roomNoCtrl,
                                            prefixIcon: Icon(Icons.meeting_room,
                                                size: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
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
                                          const SizedBox(height: 10),
                                          buildTextFieldBig(
                                            labelText: 'ชั้นที่ (Floor)',
                                            inputType: TextInputType.text,
                                            controller: floorCtrl,
                                            prefixIcon: Icon(Icons.layers,
                                                size: 14.sp),
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
                                        children: [
                                          const SizedBox(height: 10),
                                          buildTextFieldBig(
                                            labelText: 'หมู่ที่ (Moo)',
                                            inputType: TextInputType.text,
                                            controller: mooCtrl,
                                            prefixIcon: Icon(Icons.home,
                                                size: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
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
                                          const SizedBox(height: 10),
                                          buildTextFieldBig(
                                            labelText: 'ตรอก/ซอย (Soi)',
                                            inputType: TextInputType.text,
                                            controller: soiCtrl,
                                            prefixIcon: Icon(Icons.signpost,
                                                size: 14.sp),
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
                                        children: [
                                          const SizedBox(height: 10),
                                          buildTextFieldBig(
                                            labelText: 'ถนน (Road)',
                                            inputType: TextInputType.text,
                                            controller: roadCtrl,
                                            prefixIcon: Icon(Icons.route,
                                                size: 14.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
                                            _getProvinceLabel(),
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
                                              onChanged: (ProvinceModel value) async {
                                                Global.provinceModel = value;
                                                Global.provinceNotifier!.value = value;
                                                // Reset dependent dropdowns
                                                Global.amphureModel = null;
                                                Global.tambonModel = null;
                                                Global.amphureNotifier!.value = AmphureModel(id: 0, nameTh: 'เลือกอำเภอ');
                                                Global.tambonNotifier!.value = TambonModel(id: 0, nameTh: 'เลือกตำบล');
                                                Global.amphureList = [];
                                                Global.tambonList = [];
                                                setState(() {}); // Update UI to show loading state

                                                await loadAmphureByProvince(value.id);
                                                setState(() {}); // Update UI after data loads
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
                                            _getAmphureLabel(),
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
                                              onChanged: (AmphureModel value) async {
                                                Global.amphureModel = value;
                                                Global.amphureNotifier!.value = value;
                                                Global.tambonModel = null;
                                                Global.tambonNotifier!.value = TambonModel(id: 0, nameTh: 'เลือกตำบล');
                                                Global.tambonList = [];
                                                setState(() {}); // Update UI to show loading state
                                                await loadTambonByAmphure(value.id);
                                                setState(() {

                                                });
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
                                            _getTambonLabel(),
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
                        // Customer Photo Upload Section
                        _buildModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'รูปถ่ายลูกค้า',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (customerPhoto != null)
                                Center(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          customerPhoto!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              customerPhoto = null;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: pickCustomerPhoto,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('ถ่ายรูป'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: pickCustomerPhotoFromGallery,
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('เลือกจากคลัง'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // KYC Attachment Sections
                        const SizedBox(height: 20),
                        _buildModernCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'เอกสารแนบ KYC',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // 1. Occupation Documents
                              AttachmentSection(
                                title: 'อาชีพ - ไฟล์ภาพ / วันที่ Attachment',
                                attachmentType: 'Occupation',
                                customerId: widget.c.id,
                              ),

                              const SizedBox(height: 24),

                              // 2. Risk Assessment Form
                              AttachmentSection(
                                title: 'แบบประเมินความเสี่ยงลูกค้า',
                                attachmentType: 'RiskAssessment',
                                customerId: widget.c.id,
                              ),

                              const SizedBox(height: 24),

                              // 3. Customer Photo
                              AttachmentSection(
                                title: 'ภาพลูกค้า',
                                attachmentType: 'Photo',
                                customerId: widget.c.id,
                              ),
                            ],
                          ),
                        ),
                            ], // End of Column children (left side form)
                          ),
                        ), // End of SingleChildScrollView (left side)
                        ), // End of Expanded flex: 2 (left side)
                        const SizedBox(width: 16),
                        // Right side - Summary Panel
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: CustomerSummaryPanel(
                              idCard: idCardCtrl.text,
                              titleName: selectedTitleName?.name,
                              firstName: firstNameCtrl.text,
                              middleName: middleNameCtrl.text,
                              lastName: lastNameCtrl.text,
                              email: emailAddressCtrl.text,
                              phone: phoneCtrl.text,
                              dateOfBirth: widget.c.doB,
                              issueDate: widget.c.idCardIssueDate,
                              expiryDate: widget.c.idCardExpiryDate,
                              building: buildingCtrl.text,
                              roomNo: roomNoCtrl.text,
                              floor: floorCtrl.text,
                              address: addressCtrl.text,
                              village: villageCtrl.text,
                              moo: mooCtrl.text,
                              soi: soiCtrl.text,
                              road: roadCtrl.text,
                              tambon: Global.tambonModel?.nameTh,
                              amphure: Global.amphureModel?.nameTh,
                              province: Global.provinceModel?.nameTh,
                              postalCode: postalCodeCtrl.text,
                              remark: remarkCtrl.text,
                              occupation: selectedOccupation?.name,
                            ),
                          ),
                        ), // End of Expanded flex: 1 (right side)
                      ], // End of Row children
                    ), // End of Row
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
                    : taxNumberCtrl.text;
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
                    await _processUpdate();
                  });
                  return;
                }

                // Check for duplicates (excluding current customer)
                bool isValid = await validateTaxNumber(taxNumber, widget.c.id!);
                if (!isValid) {
                  Alert.warning(context, 'คำเตือน',
                      'Tax number already exists. Please use a different tax number', 'OK',
                      action: () {});
                  return;
                }
              }

              await _processUpdate();
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

  Future<void> _processUpdate() async {
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
      "tambonId": nationality == 'Foreigner' && selectedType?.code == 'general'
          ? 3023
          : Global.tambonModel?.id,
      "amphureId": nationality == 'Foreigner' && selectedType?.code == 'general'
          ? 9614
          : Global.amphureModel?.id,
      "provinceId": nationality == 'Foreigner' && selectedType?.code == 'general'
          ? 78
          : Global.provinceModel?.id,
      "nationality": nationality,
      "postalCode": nationality == 'Foreigner' && selectedType?.code == 'general'
          ? ''
          : postalCodeCtrl.text,
      "branchCode": branchCodeCtrl.text,
      "idCard": selectedType?.code == "general" ? idCardCtrl.text : "",
      "taxNumber": selectedType?.code == "company"
          ? nationality == 'Thai'
          ? taxNumberCtrl.text
          : taxNumberCtrl.text
          : nationality == 'Thai'
          ? idCardCtrl.text
          : taxNumberCtrl.text,
      "isSeller": isSeller ? 1 : 0,
      "isBuyer": isBuyer ? 1 : 0,
      "isCustomer": isCustomer ? 1 : 0,
      "workPermit": nationality == 'Foreigner' ? workPermitCtrl.text : '',
      "passportId": nationality == 'Foreigner' ? passportNoCtrl.text : '',
      "remark": remarkCtrl.text,
      "occupation": occupationCtrl.text,

      // New enhanced fields
      "titleName": selectedTitleName?.name ?? '',
      "middleName": middleNameCtrl.text,
      "building": buildingCtrl.text,
      "roomNo": roomNoCtrl.text,
      "floor": floorCtrl.text,
      "village": villageCtrl.text,
      "moo": mooCtrl.text,
      "soi": soiCtrl.text,
      "road": roadCtrl.text,
      "cardType": selectedCardType?.nameTH ?? '',
      "idCardIssueDate": idCardIssueDateCtrl.text.isEmpty
          ? ""
          : DateTime.parse(idCardIssueDateCtrl.text).toString(),
      "idCardExpiryDate": idCardExpiryDateCtrl.text.isEmpty
          ? ""
          : DateTime.parse(idCardExpiryDateCtrl.text).toString(),
      "entryDate": entryDateCtrl.text.isEmpty
          ? ""
          : DateTime.parse(entryDateCtrl.text).toString(),
      "exitDate": exitDateCtrl.text.isEmpty
          ? ""
          : DateTime.parse(exitDateCtrl.text).toString(),
      "occupationCustom": occupationCustomCtrl.text,
      "attachments": jsonEncode(attachedDocuments.map((file) => {
        "name": file.name,
        "size": file.size,
        "extension": file.extension,
        "path": file.path ?? '',
      }).toList()),
      "photoUrl": customerPhoto?.path ?? '',

      // Company-specific fields
      "country": selectedCountry?.countryTH ?? '',
      "establishmentName": establishmentNameCtrl.text,
      "headquartersOrBranch": headquartersOrBranch ?? '',
      "registrationDate": registrationDateCtrl.text.isEmpty
          ? ""
          : DateTime.parse(registrationDateCtrl.text).toString(),
      "businessType": selectedCompanyBusinessType?.name ?? '',
    });

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal,
              isDismissible: true,
              showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());

          var result = await ApiServices.put(
              '/customer', widget.c.id, customerObject);
          await pr.hide();

          if (result?.status == "success") {
            if (mounted) {
              CustomerModel customer =
              customerModelFromJson(jsonEncode(result!.data!));
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
        });
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

  Future<bool> validateTaxNumber(String taxNumber, int currentCustomerId) async {
    if (taxNumber.isEmpty) return true;

    try {
      var result = await ApiServices.post('/customer/check-tax-number',
          Global.requestObj({
            "taxNumber": taxNumber,
            "excludeId": currentCustomerId // Exclude current customer from duplicate check
          }));

      if (result?.status == "success") {
        return result?.data == null; // true if no duplicate found
      }
      return true;
    } catch (e) {
      return true; // Allow on error to avoid blocking
    }
  }
}