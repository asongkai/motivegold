import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import 'package:motivegold/model/card_type.dart';
import 'package:motivegold/model/nationality.dart';
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
import 'package:motivegold/widget/customer/customer_summary_panel.dart';
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
import 'package:motivegold/widget/customer/download_helper_mobile.dart'
    if (dart.library.html) 'package:motivegold/widget/customer/download_helper_web.dart'
    as download_helper;

// Helper class to store file with timestamp
class FileWithTimestamp {
  final PlatformFile file;
  final DateTime addedDateTime;
  final bool
      isExistingFile; // true if file already exists on server, false if newly added
  final String? serverFilePath; // path on server for existing files

  FileWithTimestamp(
    this.file,
    this.addedDateTime, {
    this.isExistingFile = false,
    this.serverFilePath,
  });
}

class EditCustomerScreen extends StatefulWidget {
  final CustomerModel c;
  const EditCustomerScreen({super.key, required this.c});

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
  OccupationModel?
      selectedBusinessTypeOccupation; // For company business type (ประเภทธุรกิจ)

  ProductTypeModel? selectedType;
  ValueNotifier<dynamic>? typeNotifier;
  List<CustomerModel> customers = [];
  bool loading = false;
  CustomerModel? selectedCustomer;
  String? nationality;

  // OCR source tracking: 'manual', 'ocr_api', 'ocr_card_reader'
  String? _idCardSource;

  List<TitleNameModel> titleNames = [];
  TitleNameModel? selectedTitleName;
  ValueNotifier<dynamic>? titleNameNotifier;

  List<OccupationModel> occupations = [];
  OccupationModel? selectedOccupation;
  bool showCustomOccupationInput = false;

  List<CardTypeModel> cardTypes = [];
  CardTypeModel? selectedCardType;
  ValueNotifier<CardTypeModel>? cardTypeNotifier;

  List<NationalityModel> nationalities = [];
  NationalityModel? selectedNationality;
  ValueNotifier<NationalityModel>? nationalityNotifier;

  NationalityModel? selectedCountryModel;
  ValueNotifier<NationalityModel>? countryNotifier;

  // Additional variables for new fields
  String? selectedCountry;
  String? companyOfficeType = 'head'; // 'head' or 'branch'

  // KYC file attachments - changed to lists with timestamps
  List<FileWithTimestamp> occupationFiles = [];
  List<FileWithTimestamp> riskAssessmentFiles = [];
  List<FileWithTimestamp> customerPhotoFiles = [];

  // Track files deleted from server (to be deleted when user saves)
  List<String> deletedServerFiles = [];

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

    motivePrint(
        '╔═══════════════════════════════════════════════════════════════════════════');
    motivePrint('║ EDIT CUSTOMER SCREEN - INITIALIZING');
    motivePrint(
        '╠═══════════════════════════════════════════════════════════════════════════');
    motivePrint('║ Customer ID: ${widget.c.id}');
    motivePrint('║ Customer Type: ${widget.c.customerType}');
    motivePrint('║ Customer Name: ${widget.c.firstName} ${widget.c.lastName}');
    motivePrint(
        '╠═══════════════════════════════════════════════════════════════════════════');
    motivePrint('║ BASIC INFO:');
    motivePrint('║   - ID Card: ${widget.c.idCard}');
    motivePrint('║   - Card Type: ${widget.c.cardType}');
    motivePrint('║   - Nationality: ${widget.c.nationality}');
    motivePrint('║   - Title Name: ${widget.c.titleName}');
    motivePrint('║   - Occupation: ${widget.c.occupation}');
    motivePrint(
        '╠═══════════════════════════════════════════════════════════════════════════');
    motivePrint('║ COMPANY INFO:');
    motivePrint('║   - Company Name: ${widget.c.companyName}');
    motivePrint('║   - Business Name: ${widget.c.establishmentName}');
    motivePrint('║   - Business Type: ${widget.c.businessType}');
    motivePrint('║   - Country: ${widget.c.country}');
    motivePrint('║   - Registration Date: ${widget.c.registrationDate}');
    motivePrint(
        '╠═══════════════════════════════════════════════════════════════════════════');
    motivePrint('║ ADDRESS INFO:');
    motivePrint('║   - Building: ${widget.c.building}');
    motivePrint('║   - Room No: ${widget.c.roomNo}');
    motivePrint('║   - Floor: ${widget.c.floor}');
    motivePrint('║   - Address (บ้านเลขที่): ${widget.c.address}');
    motivePrint('║   - Village: ${widget.c.village}');
    motivePrint('║   - Moo: ${widget.c.moo}');
    motivePrint('║   - Soi: ${widget.c.soi}');
    motivePrint('║   - Road: ${widget.c.road}');
    motivePrint('║   - Postal Code: ${widget.c.postalCode}');
    motivePrint(
        '╠═══════════════════════════════════════════════════════════════════════════');
    motivePrint('║ LOCATION INFO:');
    motivePrint(
        '║   - Province: id=${widget.c.provinceId}, name=${widget.c.provinceName}');
    motivePrint(
        '║   - Amphure: id=${widget.c.amphureId}, name=${widget.c.amphureName}');
    motivePrint(
        '║   - Tambon: id=${widget.c.tambonId}, name=${widget.c.tambonName}');
    motivePrint(
        '╚═══════════════════════════════════════════════════════════════════════════');

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

    // Load existing customer data
    // Convert nationality from DB value to radio button type
    // DB stores: "Thai" for Thai customers, or actual nationality name (e.g., "กัมพูชา") for foreigners
    // Radio buttons need: "Thai" or "Foreigner"
    nationality = (widget.c.nationality == 'Thai') ? 'Thai' : 'Foreigner';

    // Format Thai ID card with dashes (x-xxxx-xxxxx-xx-x)
    String idCard = widget.c.idCard ?? '';
    if (idCard.isNotEmpty && idCard.length == 13) {
      idCard =
          '${idCard.substring(0, 1)}-${idCard.substring(1, 5)}-${idCard.substring(5, 10)}-${idCard.substring(10, 12)}-${idCard.substring(12, 13)}';
    }
    idCardCtrl.text = idCard;

    // Load OCR source - if set, ID card field will be read-only
    _idCardSource = widget.c.idCardSource;

    companyNameCtrl.text = widget.c.companyName ?? '';
    firstNameCtrl.text = widget.c.firstName ?? '';
    middleNameCtrl.text = widget.c.middleName ?? '';
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
    buildingCtrl.text = widget.c.building ?? '';
    roomNumberCtrl.text = widget.c.roomNo ?? '';
    floorCtrl.text = widget.c.floor ?? '';
    // houseNumberCtrl removed - using Global.addressCtrl instead (already set at line 247)
    villageCtrl.text = widget.c.village ?? '';
    mooCtrl.text = widget.c.moo ?? '';
    soiCtrl.text = widget.c.soi ?? '';
    roadCtrl.text = widget.c.road ?? '';

    // Load company-specific fields
    businessNameCtrl.text = widget.c.establishmentName ?? '';

    // Load dates
    issueDateCtrl.text = widget.c.idCardIssueDate != null
        ? Global.dateOnlyT(widget.c.idCardIssueDate.toString())
        : '';
    expiryDateCtrl.text = widget.c.idCardExpiryDate != null
        ? Global.dateOnlyT(widget.c.idCardExpiryDate.toString())
        : '';
    entryDateCtrl.text = widget.c.entryDate != null
        ? Global.dateOnlyT(widget.c.entryDate.toString())
        : '';
    exitDateCtrl.text = widget.c.exitDate != null
        ? Global.dateOnlyT(widget.c.exitDate.toString())
        : '';
    registrationDateCtrl.text = widget.c.registrationDate != null
        ? Global.dateOnlyT(widget.c.registrationDate.toString())
        : '';

    // Load business type checkboxes
    isSeller = widget.c.isSeller == 1 ? true : false;
    isBuyer = widget.c.isBuyer == 1 ? true : false;
    isCustomer = widget.c.isCustomer == 1 ? true : false;
    if (isCustomer)
      selectedBusinessType = 'customer';
    else if (isBuyer)
      selectedBusinessType = 'buyer';
    else if (isSeller) selectedBusinessType = 'seller';

    // Set customer type based on loaded data
    if (widget.c.customerType == 'company') {
      typeNotifier = ValueNotifier<ProductTypeModel>(customerTypes()[0]);
      selectedType = customerTypes()[0];

      // Set company office type based on saved headquartersOrBranch field
      // Do NOT derive from branch code - use the explicit field
      if (widget.c.headquartersOrBranch == 'branch') {
        companyOfficeType = 'branch';
      } else {
        companyOfficeType = 'head';
      }
    } else {
      typeNotifier = ValueNotifier<ProductTypeModel>(customerTypes()[1]);
      selectedType = customerTypes()[1];
    }

    titleNameNotifier = ValueNotifier<TitleNameModel?>(null);

    // Initialize CardType and Nationality notifiers with placeholder values
    cardTypeNotifier = ValueNotifier<CardTypeModel>(
        CardTypeModel(id: 0, nameTH: 'เลือกประเภทบัตร'));
    nationalityNotifier = ValueNotifier<NationalityModel>(
        NationalityModel(id: 0, nationalityTH: 'เลือกสัญชาติ'));
    countryNotifier = ValueNotifier<NationalityModel>(
        NationalityModel(id: 0, countryTH: 'เลือกประเทศ'));

    motivePrint('Current environment: $env');
    motivePrint('Backend URL: ${Constants.BACKEND_URL}');

    // Load ALL dropdown data first, THEN bind values
    _loadAllDropdownData();

    // Load location data for province/amphure/tambon dropdowns
    _initializeLocationData();

    // Reload customer data from API to get attachments field populated
    _reloadCustomerData();

    // Initialize province, amphure, tambon notifiers with placeholder values
    // The actual binding will happen in _bindLocationValues() after data is loaded
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

  Future<void> _loadAllDropdownData() async {
    // Load all dropdown data in parallel, then bind values after ALL are loaded
    await Future.wait([
      _loadTitleNames(),
      _loadOccupations(),
      _loadCardTypes(),
      _loadNationalities(),
    ]);

    // Now that all data is loaded, bind the dropdown values
    _bindDropdownValues();
  }

  Future<void> _loadTitleNames() async {
    try {
      motivePrint('Loading title names...');
      var titleNamesResult = await ApiServices.getTitleNames();
      motivePrint('Title names result: ${titleNamesResult?.status}');

      if (titleNamesResult?.status == "success" &&
          titleNamesResult?.data != null) {
        var data = jsonEncode(titleNamesResult!.data);
        motivePrint('Title names data length: ${titleNamesResult.data.length}');

        if (mounted) {
          setState(() {
            titleNames = titleNameListModelFromJson(data);
            motivePrint('Title names loaded: ${titleNames.length} items');
          });
        }
      } else {
        motivePrint(
            'Failed to load title names: status=${titleNamesResult?.status}, data=${titleNamesResult?.data}');
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

      if (occupationsResult?.status == "success" &&
          occupationsResult?.data != null) {
        var data = jsonEncode(occupationsResult!.data);
        motivePrint(
            'Occupations data length: ${occupationsResult.data.length}');

        if (mounted) {
          setState(() {
            occupations = occupationListModelFromJson(data);
            motivePrint('Occupations loaded: ${occupations.length} items');

            // Set default based on customer type
            if (selectedType?.code == 'company') {
              // For company: default to "นิติบุคคลทั่วไป"
              selectedOccupation = occupations.firstWhere(
                (occupation) => occupation.name == 'นิติบุคคลทั่วไป',
                orElse: () =>
                    occupations.isNotEmpty ? occupations[0] : OccupationModel(),
              );
              showCustomOccupationInput = false;
            } else {
              // For general: default to "ประสงค์ระบุเอง"
              selectedOccupation = occupations.firstWhere(
                (occupation) => occupation.name == 'ประสงค์ระบุเอง',
                orElse: () =>
                    occupations.isNotEmpty ? occupations[0] : OccupationModel(),
              );
              // Show custom input if "ประสงค์ระบุเอง" is selected
              showCustomOccupationInput =
                  selectedOccupation?.name == 'ประสงค์ระบุเอง';
            }
            motivePrint('Default occupation: ${selectedOccupation?.name}');
          });
        }
      } else {
        motivePrint(
            'Failed to load occupations: status=${occupationsResult?.status}');
      }
    } catch (e, stackTrace) {
      motivePrint('Error loading occupations: $e');
      motivePrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadCardTypes() async {
    try {
      motivePrint('Loading card types...');
      var cardTypesResult = await ApiServices.getCardTypes();
      motivePrint('Card types result: ${cardTypesResult?.status}');

      if (cardTypesResult?.status == "success" &&
          cardTypesResult?.data != null) {
        var data = jsonEncode(cardTypesResult!.data);
        motivePrint('Card types data length: ${cardTypesResult.data.length}');

        if (mounted) {
          setState(() {
            cardTypes = cardTypeListModelFromJson(data);
            motivePrint('Card types loaded: ${cardTypes.length} items');
          });
        }
      } else {
        motivePrint(
            'Failed to load card types: status=${cardTypesResult?.status}');
      }
    } catch (e, stackTrace) {
      motivePrint('Error loading card types: $e');
      motivePrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadNationalities() async {
    try {
      motivePrint('Loading nationalities...');
      var nationalitiesResult = await ApiServices.getNationalities();
      motivePrint('Nationalities result: ${nationalitiesResult?.status}');

      if (nationalitiesResult?.status == "success" &&
          nationalitiesResult?.data != null) {
        var data = jsonEncode(nationalitiesResult!.data);
        motivePrint(
            'Nationalities data length: ${nationalitiesResult.data.length}');

        if (mounted) {
          setState(() {
            nationalities = nationalityListModelFromJson(data);
            motivePrint('Nationalities loaded: ${nationalities.length} items');
          });
        }
      } else {
        motivePrint(
            'Failed to load nationalities: status=${nationalitiesResult?.status}');
      }
    } catch (e, stackTrace) {
      motivePrint('Error loading nationalities: $e');
      motivePrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _initializeLocationData() async {
    try {
      motivePrint('=== Initializing location data ===');
      motivePrint(
          'Customer province: id=${widget.c.provinceId}, name=${widget.c.provinceName}');
      motivePrint(
          'Customer amphure: id=${widget.c.amphureId}, name=${widget.c.amphureName}');
      motivePrint(
          'Customer tambon: id=${widget.c.tambonId}, name=${widget.c.tambonName}');

      // Load provinces first
      await _loadProvinces();

      // Use the SAME working pattern as the old edit screen
      // Filter province by ID to find it in the loaded list and set Global.provinceModel
      filterChungVatById(widget.c.provinceId ?? 0);

      // Load amphures for this province and filter by ID
      await loadAmphureByProvince(widget.c.provinceId ?? 0);
      filterAmpheryId(widget.c.amphureId ?? 0);

      // Load tambons for this amphure and filter by ID
      await loadTambonByAmphure(widget.c.amphureId ?? 0);
      filterTambonById(widget.c.tambonId ?? 0);

      // Small delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {});

      motivePrint('=== Location data initialization complete ===');
      motivePrint('Province set: ${Global.provinceModel?.nameTh}');
      motivePrint('Amphure set: ${Global.amphureModel?.nameTh}');
      motivePrint('Tambon set: ${Global.tambonModel?.nameTh}');
    } catch (e, stackTrace) {
      motivePrint('Error initializing location data: $e');
      motivePrint('Stack trace: $stackTrace');
    }
  }

  Future<void> _loadProvinces() async {
    try {
      motivePrint('Loading provinces...');
      var result =
          await ApiServices.post('/customer/province', Global.requestObj(null));
      if (result?.status == "success" && result?.data != null) {
        var data = jsonEncode(result?.data);
        if (mounted) {
          setState(() {
            Global.provinceList = provinceModelFromJson(data);
            motivePrint(
                'Provinces loaded: ${Global.provinceList.length} items');
          });
        }
      }
    } catch (e) {
      motivePrint('Error loading provinces: $e');
      Global.provinceList = [];
    }
  }

  Future<void> _loadAmphures(int provinceId) async {
    try {
      motivePrint('Loading amphures for province $provinceId...');
      var result = await ApiServices.post(
          '/customer/amphure/$provinceId', Global.requestObj(null));
      if (result?.status == "success" && result?.data != null) {
        var data = jsonEncode(result?.data);
        if (mounted) {
          setState(() {
            Global.amphureList = amphureModelFromJson(data);
            motivePrint('Amphures loaded: ${Global.amphureList.length} items');
          });
        }
      }
    } catch (e) {
      motivePrint('Error loading amphures: $e');
      Global.amphureList = [];
    }
  }

  Future<void> _loadTambons(int amphureId) async {
    try {
      motivePrint('Loading tambons for amphure $amphureId...');
      var result = await ApiServices.post(
          '/customer/tambon/$amphureId', Global.requestObj(null));
      if (result?.status == "success" && result?.data != null) {
        var data = jsonEncode(result?.data);
        if (mounted) {
          setState(() {
            Global.tambonList = tambonModelFromJson(data);
            motivePrint('Tambons loaded: ${Global.tambonList.length} items');
          });
        }
      }
    } catch (e) {
      motivePrint('Error loading tambons: $e');
      Global.tambonList = [];
    }
  }

  void _bindDropdownValues() {
    if (!mounted) return;

    motivePrint('=== Binding dropdown values ===');

    setState(() {
      // Bind Title Name
      if (widget.c.titleName != null && titleNames.isNotEmpty) {
        selectedTitleName = titleNames.firstWhere(
          (title) => title.name == widget.c.titleName,
          orElse: () => titleNames.first,
        );
        titleNameNotifier?.value = selectedTitleName;
        motivePrint('Title name bound: ${selectedTitleName?.name}');
      } else {
        motivePrint(
            'Title name not bound: titleName=${widget.c.titleName}, titleNames.length=${titleNames.length}');
      }

      // Bind Nationality
      if (widget.c.nationality != null && nationalities.isNotEmpty) {
        var foundNationality = nationalities.firstWhere(
          (nat) =>
              nat.nationalityEN == widget.c.nationality ||
              nat.nationalityTH == widget.c.nationality,
          orElse: () => nationalities.first,
        );
        selectedNationality = foundNationality;
        nationalityNotifier?.value = foundNationality;
        motivePrint('Nationality bound: ${foundNationality.nationalityTH}');
      } else {
        motivePrint(
            'Nationality not bound: nationality=${widget.c.nationality}, nationalities.length=${nationalities.length}');
      }

      // Bind Card Type
      if (widget.c.cardType != null && cardTypes.isNotEmpty) {
        var foundCardType = cardTypes.firstWhere(
          (cardType) =>
              cardType.nameTH == widget.c.cardType ||
              cardType.nameEN == widget.c.cardType,
          orElse: () => cardTypes.first,
        );
        selectedCardType = foundCardType;
        cardTypeNotifier?.value = foundCardType;
        motivePrint('Card type bound: ${foundCardType.nameTH}');
      } else {
        motivePrint(
            'Card type not bound: cardType=${widget.c.cardType}, cardTypes.length=${cardTypes.length}');
      }

      // Bind Occupation
      if (widget.c.occupation != null && occupations.isNotEmpty) {
        selectedOccupation = occupations.firstWhere(
          (occ) => occ.name == widget.c.occupation,
          orElse: () => occupations.first,
        );
        // Show custom occupation input only if "ประสงค์ระบุเอง" is selected
        showCustomOccupationInput =
            selectedOccupation?.name == 'ประสงค์ระบุเอง';

        // Load custom occupation text if applicable
        if (showCustomOccupationInput && widget.c.occupationCustom != null) {
          occupationCtrl.text = widget.c.occupationCustom!;
          motivePrint('Custom occupation loaded: ${widget.c.occupationCustom}');
        }

        motivePrint(
            'Occupation bound: ${selectedOccupation?.name}, showCustomInput: $showCustomOccupationInput');
      } else {
        motivePrint(
            'Occupation not bound: occupation=${widget.c.occupation}, occupations.length=${occupations.length}');
      }

      // Bind Country (for company customer)
      if (widget.c.country != null && nationalities.isNotEmpty) {
        var foundCountry = nationalities.firstWhere(
          (nat) =>
              nat.countryEN == widget.c.country ||
              nat.countryTH == widget.c.country,
          orElse: () => nationalities.first,
        );
        selectedCountryModel = foundCountry;
        countryNotifier?.value = foundCountry;
        motivePrint('Country bound: ${foundCountry.countryTH}');
      } else {
        motivePrint(
            'Country not bound: country=${widget.c.country}, nationalities.length=${nationalities.length}');
      }

      // Bind Business Type (for company customer) - separate from occupation
      if (widget.c.businessType != null && occupations.isNotEmpty) {
        selectedBusinessTypeOccupation = occupations.firstWhere(
          (occ) => occ.name == widget.c.businessType,
          orElse: () => occupations.first,
        );
        motivePrint(
            'Business type bound: ${selectedBusinessTypeOccupation?.name}');
      } else {
        motivePrint(
            'Business type not bound: businessType=${widget.c.businessType}, occupations.length=${occupations.length}');
      }
    });

    motivePrint('=== Dropdown values binding complete ===');
  }

  void _bindLocationValues() {
    if (!mounted) return;

    motivePrint('=== Binding location values ===');

    setState(() {
      // Bind Province - find by ID if name is missing
      if (widget.c.provinceId != null && Global.provinceList.isNotEmpty) {
        var foundProvince = Global.provinceList.firstWhere(
          (province) => province.id == widget.c.provinceId,
          orElse: () => ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'),
        );
        if (foundProvince.id != 0) {
          Global.provinceModel = foundProvince;
          Global.provinceNotifier?.value = foundProvince;
          motivePrint(
              'Province bound: id=${foundProvince.id}, name=${foundProvince.nameTh}');
        } else {
          motivePrint('Province not found for id=${widget.c.provinceId}');
        }
      } else {
        motivePrint(
            'Province not bound: provinceId=${widget.c.provinceId}, provinceList.length=${Global.provinceList.length}');
      }

      // Bind Amphure - find by ID if name is missing
      if (widget.c.amphureId != null && Global.amphureList.isNotEmpty) {
        var foundAmphure = Global.amphureList.firstWhere(
          (amphure) => amphure.id == widget.c.amphureId,
          orElse: () => AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'),
        );
        if (foundAmphure.id != 0) {
          Global.amphureModel = foundAmphure;
          Global.amphureNotifier?.value = foundAmphure;
          motivePrint(
              'Amphure bound: id=${foundAmphure.id}, name=${foundAmphure.nameTh}');
        } else {
          motivePrint('Amphure not found for id=${widget.c.amphureId}');
        }
      } else {
        motivePrint(
            'Amphure not bound: amphureId=${widget.c.amphureId}, amphureList.length=${Global.amphureList.length}');
      }

      // Bind Tambon - find by ID if name is missing
      if (widget.c.tambonId != null && Global.tambonList.isNotEmpty) {
        var foundTambon = Global.tambonList.firstWhere(
          (tambon) => tambon.id == widget.c.tambonId,
          orElse: () => TambonModel(id: 0, nameTh: 'เลือกตำบล'),
        );
        if (foundTambon.id != 0) {
          Global.tambonModel = foundTambon;
          Global.tambonNotifier?.value = foundTambon;
          motivePrint(
              'Tambon bound: id=${foundTambon.id}, name=${foundTambon.nameTh}');
        } else {
          motivePrint('Tambon not found for id=${widget.c.tambonId}');
        }
      } else {
        motivePrint(
            'Tambon not bound: tambonId=${widget.c.tambonId}, tambonList.length=${Global.tambonList.length}');
      }
    });

    motivePrint('=== Location values binding complete ===');
  }

  Future<void> _reloadCustomerData() async {
    try {
      motivePrint('=== _reloadCustomerData called ===');
      motivePrint(
          'Reloading customer ${widget.c.id} from API to get attachments...');

      final response = await http.get(
        Uri.parse('${Constants.BACKEND_URL}/customer/${widget.c.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic ${base64.encode(utf8.encode('root:t00r'))}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        motivePrint('Customer data reloaded successfully');
        motivePrint(
            'Attachments field from API: ${responseData['attachments']}');

        // Update the customer model with the fresh data including attachments
        widget.c.attachments = responseData['attachments'];

        // Now load the attachments
        _loadAttachments();
      } else {
        motivePrint(
            'Failed to reload customer data. Status: ${response.statusCode}');
      }
    } catch (e) {
      motivePrint('Error reloading customer data: $e');
    }
  }

  void _loadAttachments() {
    motivePrint('=== _loadAttachments called ===');
    motivePrint('Customer ID: ${widget.c.id}');
    motivePrint('Attachments field: ${widget.c.attachments}');
    motivePrint('Attachments is null? ${widget.c.attachments == null}');
    motivePrint('Attachments is empty? ${widget.c.attachments?.isEmpty}');

    if (widget.c.attachments == null || widget.c.attachments!.isEmpty) {
      motivePrint('No attachments to load - exiting _loadAttachments');
      return;
    }

    try {
      motivePrint('Parsing attachments JSON: ${widget.c.attachments}');

      // Parse the attachments JSON array
      final List<dynamic> attachmentsList = jsonDecode(widget.c.attachments!);

      for (var attachment in attachmentsList) {
        final String type = attachment['type'] ?? '';
        final String fileName = attachment['fileName'] ?? '';
        final String filePath = attachment['filePath'] ?? '';
        final String uploadDateStr = attachment['uploadDate'] ?? '';
        final int fileSize = attachment['fileSize'] ?? 0;

        // Parse upload date
        DateTime uploadDate = DateTime.now();
        if (uploadDateStr.isNotEmpty) {
          try {
            uploadDate = DateTime.parse(uploadDateStr);
          } catch (e) {
            motivePrint('Error parsing upload date: $e');
          }
        }

        // Create a mock PlatformFile for display purposes
        // Note: These files are already on the server, so we can't access the actual bytes
        // We're just creating this for display in the dropdown
        final mockFile = PlatformFile(
          name: fileName,
          size: fileSize,
          path: filePath,
        );

        // Mark as existing file from server
        final fileWithTimestamp = FileWithTimestamp(
          mockFile,
          uploadDate,
          isExistingFile: true,
          serverFilePath: filePath,
        );

        // Add to the appropriate list based on type
        if (type == 'Occupation') {
          occupationFiles.add(fileWithTimestamp);
          selectedOccupationFile = fileWithTimestamp;
          motivePrint('Loaded occupation file: $fileName (existing)');
        } else if (type == 'RiskAssessment' || type == 'Risk') {
          riskAssessmentFiles.add(fileWithTimestamp);
          selectedRiskAssessmentFile = fileWithTimestamp;
          motivePrint('Loaded risk assessment file: $fileName (existing)');
        } else if (type == 'CustomerPhoto' || type == 'Photo') {
          customerPhotoFiles.add(fileWithTimestamp);
          selectedCustomerPhotoFile = fileWithTimestamp;
          motivePrint('Loaded customer photo file: $fileName (existing)');
        }
      }

      motivePrint(
          'Attachments loaded successfully. Occupation: ${occupationFiles.length}, Risk: ${riskAssessmentFiles.length}, Photo: ${customerPhotoFiles.length}');

      // Trigger UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      motivePrint('Error loading attachments: $e');
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
    bool readOnly = false,
    FocusNode? focusNode,
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
            readOnly: readOnly,
            focusNode: focusNode,
            style: TextStyle(
              fontSize: 14.sp,
              color: readOnly ? Colors.grey[600] : null,
            ),
            decoration: InputDecoration(
              hintText: hintText ?? labelText,
              prefixIcon: prefixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              filled: true,
              fillColor: readOnly ? Colors.grey[100] : Colors.white,
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

  /// Safely parse date string, returns ISO format string for API
  String? _tryParseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      // Try standard ISO format first (yyyy-MM-dd or yyyy-MM-dd HH:mm:ss)
      DateTime parsed = DateTime.parse(dateStr);
      return parsed.toIso8601String();
    } catch (e) {
      // Try Thai display format (dd/MM/yyyy)
      try {
        DateFormat thaiFormat = DateFormat('dd/MM/yyyy');
        DateTime parsed = thaiFormat.parse(dateStr);
        return parsed.toIso8601String();
      } catch (e2) {
        motivePrint("WARNING: Invalid date format: '$dateStr' (tried ISO and dd/MM/yyyy)");
        return null;
      }
    }
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
            child: Text("แก้ไขลูกค้า",
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
                                      fontSize: 14.sp,
                                    );
                                  },
                                  onChanged: (ProductTypeModel value) {
                                    selectedType = value;
                                    typeNotifier!.value = value;
                                    // Note: Do NOT change nationality here - preserve the customer's existing nationality
                                    // Only set default occupation based on customer type
                                    if (selectedType?.code == 'general') {
                                      // Set default occupation to "ประสงค์ระบุเอง" for general customers
                                      selectedOccupation =
                                          occupations.firstWhere(
                                        (occupation) =>
                                            occupation.name == 'ประสงค์ระบุเอง',
                                        orElse: () => occupations.isNotEmpty
                                            ? occupations[0]
                                            : OccupationModel(),
                                      );
                                      showCustomOccupationInput =
                                          selectedOccupation?.name ==
                                              'ประสงค์ระบุเอง';
                                    } else if (selectedType?.code ==
                                        'company') {
                                      // Set default occupation to "นิติบุคคลทั่วไป" for company customers
                                      selectedOccupation =
                                          occupations.firstWhere(
                                        (occupation) =>
                                            occupation.name ==
                                            'นิติบุคคลทั่วไป',
                                        orElse: () => occupations.isNotEmpty
                                            ? occupations[0]
                                            : OccupationModel(),
                                      );
                                      showCustomOccupationInput = false;
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
                        const SizedBox(height: 10),
                        CustomerSummaryPanel(
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
                          roomNo: roomNumberCtrl.text,
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
                          // Non-Thai general customer fields
                          taxId: taxNumberCtrl.text,
                          workPermit: workPermitCtrl.text,
                          passport: passportNoCtrl.text,
                          // Company customer fields
                          companyName: companyNameCtrl.text,
                          establishmentName: businessNameCtrl.text,
                          taxNumber: taxNumberCtrl.text,
                          branchCode: branchCodeCtrl.text,
                          registrationDate: widget.c.registrationDate,
                          nationality: selectedNationality?.nationalityTH,
                          country: selectedCountry,
                        ),
                        const SizedBox(height: 10),
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
                                          selectedBusinessType =
                                              isCustomer ? 'customer' : null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isCustomer
                                              ? const Color(0xFFFFE8F5)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isCustomer
                                                ? const Color(0xFFE91E63)
                                                : Colors.grey[300]!,
                                            width: isCustomer ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isCustomer,
                                              activeColor:
                                                  const Color(0xFFE91E63),
                                              onChanged: (value) {
                                                setState(() {
                                                  isCustomer = value ?? false;
                                                  selectedBusinessType =
                                                      isCustomer
                                                          ? 'customer'
                                                          : null;
                                                });
                                              },
                                            ),
                                            Icon(Icons.store,
                                                color: isCustomer
                                                    ? const Color(0xFFE91E63)
                                                    : Colors.grey,
                                                size: 20),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'ซื้อขายหน้าร้าน',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: isCustomer
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: isCustomer
                                                      ? const Color(0xFFE91E63)
                                                      : Colors.grey[800],
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
                                          selectedBusinessType =
                                              isBuyer ? 'buyer' : null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isBuyer
                                              ? const Color(0xFFFFF9E6)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isBuyer
                                                ? const Color(0xFFFFC107)
                                                : Colors.grey[300]!,
                                            width: isBuyer ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isBuyer,
                                              activeColor:
                                                  const Color(0xFFFFC107),
                                              onChanged: (value) {
                                                setState(() {
                                                  isBuyer = value ?? false;
                                                  selectedBusinessType =
                                                      isBuyer ? 'buyer' : null;
                                                });
                                              },
                                            ),
                                            Icon(Icons.business,
                                                color: isBuyer
                                                    ? const Color(0xFFFFC107)
                                                    : Colors.grey,
                                                size: 20),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'ซื้อขายกับร้านค้าส่ง',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: isBuyer
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: isBuyer
                                                      ? const Color(0xFFFFC107)
                                                      : Colors.grey[800],
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
                                          selectedBusinessType =
                                              isSeller ? 'seller' : null;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isSeller
                                              ? const Color(0xFFFFEFE6)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSeller
                                                ? const Color(0xFFFF9800)
                                                : Colors.grey[300]!,
                                            width: isSeller ? 2 : 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isSeller,
                                              activeColor:
                                                  const Color(0xFFFF9800),
                                              onChanged: (value) {
                                                setState(() {
                                                  isSeller = value ?? false;
                                                  selectedBusinessType =
                                                      isSeller
                                                          ? 'seller'
                                                          : null;
                                                });
                                              },
                                            ),
                                            Icon(Icons.inventory,
                                                color: isSeller
                                                    ? const Color(0xFFFF9800)
                                                    : Colors.grey,
                                                size: 20),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'ซื้อขายกับร้านทองตู้แดง',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: isSeller
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                  color: isSeller
                                                      ? const Color(0xFFFF9800)
                                                      : Colors.grey[800],
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
                                        onChanged: (String? value) async {
                                          setState(() {
                                            nationality = value;
                                          });
                                          // Note: In edit screen, we don't automatically change province/amphure/tambon
                                          // We keep the existing saved values so user can see and modify them if needed
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Conditional Fields Based on Nationality and Customer Type
                              if (nationality == 'Thai' &&
                                  selectedType?.code == 'general') ...[
                                // Thai + General Customer
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: buildTextFieldBig(
                                    labelText: 'เลขบัตรประจำตัวประชาชน',
                                    hintText: 'x-xxxx-xxxxx-xx-x',
                                    inputType: TextInputType.number,
                                    controller: idCardCtrl,
                                    prefixIcon:
                                        Icon(Icons.credit_card, size: 14.sp),
                                    inputFormatters: [ThaiIdCardFormatter()],
                                    readOnly: _idCardSource != null && _idCardSource!.isNotEmpty,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              onChanged:
                                                  (TitleNameModel value) {
                                                setState(() {
                                                  selectedTitleName = value;
                                                  titleNameNotifier!.value =
                                                      value;
                                                });
                                              },
                                              emptyMessage: 'ไม่มีข้อมูล',
                                              nationality: nationality,
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
                                          prefixIcon:
                                              Icon(Icons.person, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: buildTextFieldBig(
                                          labelText: 'นามสกุล',
                                          inputType: TextInputType.text,
                                          controller: lastNameCtrl,
                                          prefixIcon: Icon(Icons.person_outline,
                                              size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อีเมล',
                                          inputType: TextInputType.emailAddress,
                                          controller: emailAddressCtrl,
                                          prefixIcon:
                                              Icon(Icons.email, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'โทรศัพท์',
                                          inputType: TextInputType.phone,
                                          controller: phoneCtrl,
                                          prefixIcon:
                                              Icon(Icons.phone, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: _buildDateField(
                                    labelText: 'วันเกิด',
                                    controller: birthDateCtrl,
                                    icon: Icons.calendar_today,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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

                              if (nationality == 'Foreigner' &&
                                  selectedType?.code == 'general') ...[
                                // Foreigner + General Customer - Card Type and Nationality on same row
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      // Card Type
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ประเภทบัตร',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
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
                                      const SizedBox(width: 8),
                                      // Nationality
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'สัญชาติ',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: textColor,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withValues(alpha: 0.1),
                                                    spreadRadius: 1,
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: MiraiDropDownMenu<
                                                  NationalityModel>(
                                                key: UniqueKey(),
                                                children: nationalities,
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
                                                  NationalityModel? project, {
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
                                                    (NationalityModel value) {
                                                  selectedNationality = value;
                                                  nationalityNotifier!.value =
                                                      value;
                                                  setState(() {});
                                                },
                                                child:
                                                    DropDownObjectChildWidget(
                                                  key: GlobalKey(),
                                                  fontSize: 14.sp,
                                                  projectValueNotifier:
                                                      nationalityNotifier!,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'Tax ID',
                                          inputType: TextInputType.number,
                                          controller: taxNumberCtrl,
                                          prefixIcon:
                                              Icon(Icons.receipt, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'Work Permit',
                                          inputType: TextInputType.text,
                                          controller: workPermitCtrl,
                                          prefixIcon:
                                              Icon(Icons.work, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'Passport ID',
                                          inputType: TextInputType.text,
                                          controller: passportNoCtrl,
                                          prefixIcon:
                                              Icon(Icons.flight, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                              onChanged:
                                                  (TitleNameModel value) {
                                                setState(() {
                                                  selectedTitleName = value;
                                                  titleNameNotifier!.value =
                                                      value;
                                                });
                                              },
                                              emptyMessage: 'ไม่มีข้อมูล',
                                              nationality: nationality,
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
                                          prefixIcon:
                                              Icon(Icons.person, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อกลาง',
                                          inputType: TextInputType.text,
                                          controller: middleNameCtrl,
                                          prefixIcon: Icon(Icons.person_outline,
                                              size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'นามสกุล',
                                          inputType: TextInputType.text,
                                          controller: lastNameCtrl,
                                          prefixIcon: Icon(Icons.person_outline,
                                              size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อีเมล',
                                          inputType: TextInputType.emailAddress,
                                          controller: emailAddressCtrl,
                                          prefixIcon:
                                              Icon(Icons.email, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'โทรศัพท์',
                                          inputType: TextInputType.phone,
                                          controller: phoneCtrl,
                                          prefixIcon:
                                              Icon(Icons.phone, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: _buildDateField(
                                    labelText: 'วันเกิด',
                                    controller: birthDateCtrl,
                                    icon: Icons.calendar_today,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
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
                              ],

                              if (nationality == 'Thai' &&
                                  selectedType?.code == 'company') ...[
                                // Thai + Company Customer
                                // Row 1: Tax ID | Operator Name (Title Dropdown)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'เลขบัตรประจำตัวภาษี',
                                          inputType: TextInputType.number,
                                          controller: taxNumberCtrl,
                                          prefixIcon:
                                              Icon(Icons.receipt, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อผู้ประกอบการ',
                                          inputType: TextInputType.text,
                                          controller: companyNameCtrl,
                                          prefixIcon:
                                              Icon(Icons.person, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 2: Business Name | Radio buttons (Head/Branch)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อสถานประกอบการ',
                                          inputType: TextInputType.text,
                                          controller: businessNameCtrl,
                                          prefixIcon:
                                              Icon(Icons.business, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          companyOfficeType ==
                                                                  'head'
                                                              ? Colors
                                                                  .teal
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1)
                                                              : Colors.grey[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color:
                                                            companyOfficeType ==
                                                                    'head'
                                                                ? Colors.teal
                                                                : Colors
                                                                    .grey[300]!,
                                                        width:
                                                            companyOfficeType ==
                                                                    'head'
                                                                ? 2
                                                                : 1,
                                                      ),
                                                    ),
                                                    child:
                                                        RadioListTile<String>(
                                                      title: Text(
                                                        'สำนักงานใหญ่',
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                      value: 'head',
                                                      groupValue:
                                                          companyOfficeType,
                                                      visualDensity:
                                                          VisualDensity
                                                              .standard,
                                                      activeColor: Colors.teal,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          companyOfficeType =
                                                              value;
                                                          if (value == 'head') {
                                                            branchCodeCtrl
                                                                .text = '00000';
                                                          } else if (value ==
                                                              'branch') {
                                                            // Clear branch code so user can enter their own
                                                            if (branchCodeCtrl
                                                                    .text ==
                                                                '00000') {
                                                              branchCodeCtrl
                                                                  .text = '';
                                                            }
                                                          }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          companyOfficeType ==
                                                                  'branch'
                                                              ? Colors
                                                                  .teal
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1)
                                                              : Colors.grey[50],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color:
                                                            companyOfficeType ==
                                                                    'branch'
                                                                ? Colors.teal
                                                                : Colors
                                                                    .grey[300]!,
                                                        width:
                                                            companyOfficeType ==
                                                                    'branch'
                                                                ? 2
                                                                : 1,
                                                      ),
                                                    ),
                                                    child:
                                                        RadioListTile<String>(
                                                      title: Text(
                                                        'สาขา',
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                      value: 'branch',
                                                      groupValue:
                                                          companyOfficeType,
                                                      visualDensity:
                                                          VisualDensity
                                                              .standard,
                                                      activeColor: Colors.teal,
                                                      onChanged:
                                                          (String? value) {
                                                        setState(() {
                                                          companyOfficeType =
                                                              value;
                                                          if (value == 'head') {
                                                            branchCodeCtrl
                                                                .text = '00000';
                                                          } else if (value ==
                                                              'branch') {
                                                            // Clear branch code so user can enter their own
                                                            if (branchCodeCtrl
                                                                    .text ==
                                                                '00000') {
                                                              branchCodeCtrl
                                                                  .text = '';
                                                            }
                                                          }
                                                        });
                                                      },
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
                                const SizedBox(height: 10),
                                // Row 3: Branch Code | Email
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'รหัสสาขา',
                                          inputType: TextInputType.text,
                                          controller: branchCodeCtrl,
                                          prefixIcon:
                                              Icon(Icons.store, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อีเมล',
                                          inputType: TextInputType.emailAddress,
                                          controller: emailAddressCtrl,
                                          prefixIcon:
                                              Icon(Icons.email, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 4: Phone | Registration Date
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'โทรศัพท์',
                                          inputType: TextInputType.phone,
                                          controller: phoneCtrl,
                                          prefixIcon:
                                              Icon(Icons.phone, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันที่จดทะเบียน',
                                          controller: registrationDateCtrl,
                                          icon: Icons.app_registration,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              if (nationality == 'Foreigner' &&
                                  selectedType?.code == 'company') ...[
                                // Foreigner + Company Customer
                                // Row 1: Tax ID | Country Dropdown
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'เลขบัตรประจำตัวภาษี',
                                          inputType: TextInputType.number,
                                          controller: taxNumberCtrl,
                                          prefixIcon:
                                              Icon(Icons.receipt, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ประเทศ',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            MiraiDropDownMenu<NationalityModel>(
                                              key: UniqueKey(),
                                              children: nationalities,
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
                                                NationalityModel? project, {
                                                bool isItemSelected = false,
                                              }) {
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 16.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      project?.countryTH ?? '',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .copyWith(
                                                            color: textColor,
                                                            fontSize: 14.sp,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                              onChanged:
                                                  (NationalityModel value) {
                                                selectedCountryModel = value;
                                                countryNotifier!.value = value;
                                                setState(() {});
                                              },
                                              child: Container(
                                                key: GlobalKey(),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.03),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16,
                                                      vertical: 16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 1.0,
                                                    ),
                                                  ),
                                                  child: ValueListenableBuilder<
                                                      NationalityModel>(
                                                    valueListenable:
                                                        countryNotifier!,
                                                    builder: (_, country, __) {
                                                      return Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                country.countryTH ??
                                                                    'เลือกประเทศ',
                                                                maxLines: 1,
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyLarge!
                                                                    .copyWith(
                                                                      color:
                                                                          textColor,
                                                                      fontSize:
                                                                          14.sp,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 2: Operator Name | Business Name
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อผู้ประกอบการ',
                                          inputType: TextInputType.text,
                                          controller: companyNameCtrl,
                                          prefixIcon:
                                              Icon(Icons.person, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'ชื่อสถานประกอบการ',
                                          inputType: TextInputType.text,
                                          controller: businessNameCtrl,
                                          prefixIcon:
                                              Icon(Icons.business, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 3: Radio buttons (Head/Branch)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: companyOfficeType == 'head'
                                                ? Colors.teal
                                                    .withValues(alpha: 0.1)
                                                : Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: companyOfficeType == 'head'
                                                  ? Colors.teal
                                                  : Colors.grey[300]!,
                                              width: companyOfficeType == 'head'
                                                  ? 2
                                                  : 1,
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
                                                // Default branch code to 00000 for head office
                                                if (value == 'head') {
                                                  branchCodeCtrl.text = '00000';
                                                }
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
                                                ? Colors.teal
                                                    .withValues(alpha: 0.1)
                                                : Colors.grey[50],
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color:
                                                  companyOfficeType == 'branch'
                                                      ? Colors.teal
                                                      : Colors.grey[300]!,
                                              width:
                                                  companyOfficeType == 'branch'
                                                      ? 2
                                                      : 1,
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
                                                // Clear branch code when switching to branch so user can enter their own
                                                if (value == 'branch' &&
                                                    branchCodeCtrl.text ==
                                                        '00000') {
                                                  branchCodeCtrl.text = '';
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 4: Branch Code | Email
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'รหัสสาขา',
                                          inputType: TextInputType.text,
                                          controller: branchCodeCtrl,
                                          prefixIcon:
                                              Icon(Icons.store, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'อีเมล',
                                          inputType: TextInputType.emailAddress,
                                          controller: emailAddressCtrl,
                                          prefixIcon:
                                              Icon(Icons.email, size: 14.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Row 5: Phone | Registration Date
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: buildTextFieldBig(
                                          labelText: 'โทรศัพท์',
                                          inputType: TextInputType.phone,
                                          controller: phoneCtrl,
                                          prefixIcon:
                                              Icon(Icons.phone, size: 14.sp),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _buildDateField(
                                          labelText: 'วันที่จดทะเบียน',
                                          controller: registrationDateCtrl,
                                          icon: Icons.app_registration,
                                        ),
                                      ),
                                    ],
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
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
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
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
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
                                        controller: Global.addressCtrl,
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
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
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
                                            height: 50,
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
                                            height: 50,
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
                                            child:
                                                MiraiDropDownMenu<AmphureModel>(
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
                                                Global.amphureNotifier!.value =
                                                    value;
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
                                            height: 50,
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
                                            child:
                                                MiraiDropDownMenu<TambonModel>(
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
                              // Section 1: อาชีพ (Occupation) - Only for general customers
                              if (selectedType?.code != 'company') ...[
                                Text(
                                  'อาชีพ (KYC : Know Your Customer)',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // First row: occupation dropdown and custom input field (2 columns)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'อาชีพ',
                                              style: TextStyle(
                                                fontSize: 13.sp,
                                                color: Colors.grey[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            GroupedOccupationDropdown(
                                              occupations: occupations,
                                              selectedOccupation:
                                                  selectedOccupation,
                                              onChanged:
                                                  (OccupationModel value) {
                                                setState(() {
                                                  selectedOccupation = value;
                                                  showCustomOccupationInput =
                                                      value.name ==
                                                          'ประสงค์ระบุเอง';
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
                                      if (showCustomOccupationInput) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: buildTextFieldBig(
                                            labelText: 'ระบุอาชีพ',
                                            inputType: TextInputType.text,
                                            controller: occupationCtrl,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
                                                      if (_occupationFileOverlay ==
                                                          null) {
                                                        showFileSelectionDropdown(
                                                            'occupation',
                                                            btnContext);
                                                      } else {
                                                        _removeFileOverlay(
                                                            'occupation');
                                                      }
                                                      setState(() {});
                                                    },
                                              child: Container(
                                                height: 60,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                      color: Colors.grey[300]!,
                                                      width: 1),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.attach_file,
                                                        color: Colors.blue,
                                                        size: 18),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child:
                                                          selectedOccupationFile !=
                                                                  null
                                                              ? Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Text(
                                                                      selectedOccupationFile!
                                                                          .file
                                                                          .name,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            12.sp,
                                                                        color: Colors
                                                                            .black87,
                                                                      ),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      maxLines:
                                                                          1,
                                                                    ),
                                                                    const SizedBox(
                                                                        height:
                                                                            2),
                                                                    Text(
                                                                      DateFormat(
                                                                              'dd/MM/yyyy HH:mm')
                                                                          .format(
                                                                              selectedOccupationFile!.addedDateTime),
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            11.sp,
                                                                        color: Colors
                                                                            .grey[600],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              : Text(
                                                                  'ไม่มีการแนบเอกสาร',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12.sp,
                                                                    color: Colors
                                                                            .grey[
                                                                        600],
                                                                  ),
                                                                ),
                                                    ),
                                                    Icon(Icons.arrow_drop_down,
                                                        color:
                                                            Colors.grey[600]),
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
                                        color: selectedOccupationFile != null
                                            ? const Color(0xFFE57373)
                                            : Colors.grey[300]!,
                                        size: ButtonSize.medium,
                                        variant: selectedOccupationFile != null
                                            ? ButtonVariant.primary
                                            : ButtonVariant.outlined,
                                        enabled: selectedOccupationFile != null,
                                        onTap: () =>
                                            removeFileFromList('occupation'),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Save/Download button (บันทึก)
                                    SizedBox(
                                      height: 60,
                                      child: KclButton(
                                        text: 'บันทึก',
                                        icon: Icons.download,
                                        color: selectedOccupationFile != null
                                            ? const Color(0xFF42A5F5)
                                            : Colors.grey[300]!,
                                        size: ButtonSize.medium,
                                        variant: selectedOccupationFile != null
                                            ? ButtonVariant.primary
                                            : ButtonVariant.outlined,
                                        enabled: selectedOccupationFile != null,
                                        onTap: () => downloadFile('occupation'),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                              ],

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
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8.0),
                                  child: GroupedOccupationDropdown(
                                    occupations: occupations
                                        .where((occupation) =>
                                            occupation.category ==
                                            'ประเภทธุรกิจ')
                                        .toList(),
                                    selectedOccupation:
                                        selectedBusinessTypeOccupation,
                                    onChanged: (OccupationModel value) {
                                      setState(() {
                                        selectedBusinessTypeOccupation = value;
                                      });
                                    },
                                    emptyMessage: 'ไม่มีข้อมูล',
                                  ),
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
                                                    if (_riskFileOverlay ==
                                                        null) {
                                                      showFileSelectionDropdown(
                                                          'risk', btnContext);
                                                    } else {
                                                      _removeFileOverlay(
                                                          'risk');
                                                    }
                                                    setState(() {});
                                                  },
                                            child: Container(
                                              height: 60,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.grey[300]!,
                                                    width: 1),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.attach_file,
                                                      color: Colors.blue,
                                                      size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child:
                                                        selectedRiskAssessmentFile !=
                                                                null
                                                            ? Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    selectedRiskAssessmentFile!
                                                                        .file
                                                                        .name,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.sp,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          2),
                                                                  Text(
                                                                    DateFormat(
                                                                            'dd/MM/yyyy HH:mm')
                                                                        .format(
                                                                            selectedRiskAssessmentFile!.addedDateTime),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11.sp,
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                'ไม่มีการแนบเอกสาร',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                ),
                                                              ),
                                                  ),
                                                  Icon(Icons.arrow_drop_down,
                                                      color: Colors.grey[600]),
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
                                      icon: Icons.add,
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
                                      color: selectedRiskAssessmentFile != null
                                          ? const Color(0xFFE57373)
                                          : Colors.grey[300]!,
                                      size: ButtonSize.medium,
                                      variant:
                                          selectedRiskAssessmentFile != null
                                              ? ButtonVariant.primary
                                              : ButtonVariant.outlined,
                                      enabled:
                                          selectedRiskAssessmentFile != null,
                                      onTap: () => removeFileFromList('risk'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Save/Download button (บันทึก)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'บันทึก',
                                      icon: Icons.download,
                                      color: selectedRiskAssessmentFile != null
                                          ? const Color(0xFF42A5F5)
                                          : Colors.grey[300]!,
                                      size: ButtonSize.medium,
                                      variant:
                                          selectedRiskAssessmentFile != null
                                              ? ButtonVariant.primary
                                              : ButtonVariant.outlined,
                                      enabled:
                                          selectedRiskAssessmentFile != null,
                                      onTap: () => downloadFile('risk'),
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
                                                    if (_photoFileOverlay ==
                                                        null) {
                                                      showFileSelectionDropdown(
                                                          'photo', btnContext);
                                                    } else {
                                                      _removeFileOverlay(
                                                          'photo');
                                                    }
                                                    setState(() {});
                                                  },
                                            child: Container(
                                              height: 60,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.grey[300]!,
                                                    width: 1),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.attach_file,
                                                      color: Colors.blue,
                                                      size: 18),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child:
                                                        selectedCustomerPhotoFile !=
                                                                null
                                                            ? Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    selectedCustomerPhotoFile!
                                                                        .file
                                                                        .name,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12.sp,
                                                                      color: Colors
                                                                          .black87,
                                                                    ),
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    maxLines: 1,
                                                                  ),
                                                                  const SizedBox(
                                                                      height:
                                                                          2),
                                                                  Text(
                                                                    DateFormat(
                                                                            'dd/MM/yyyy HH:mm')
                                                                        .format(
                                                                            selectedCustomerPhotoFile!.addedDateTime),
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          11.sp,
                                                                      color: Colors
                                                                              .grey[
                                                                          600],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Text(
                                                                'ไม่มีการแนบเอกสาร',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      12.sp,
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                ),
                                                              ),
                                                  ),
                                                  Icon(Icons.arrow_drop_down,
                                                      color: Colors.grey[600]),
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
                                      icon: Icons.add,
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
                                      color: selectedCustomerPhotoFile != null
                                          ? const Color(0xFFE57373)
                                          : Colors.grey[300]!,
                                      size: ButtonSize.medium,
                                      variant: selectedCustomerPhotoFile != null
                                          ? ButtonVariant.primary
                                          : ButtonVariant.outlined,
                                      enabled:
                                          selectedCustomerPhotoFile != null,
                                      onTap: () => removeFileFromList('photo'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Save/Download button (บันทึก)
                                  SizedBox(
                                    height: 60,
                                    child: KclButton(
                                      text: 'บันทึก',
                                      icon: Icons.download,
                                      color: selectedCustomerPhotoFile != null
                                          ? const Color(0xFF42A5F5)
                                          : Colors.grey[300]!,
                                      size: ButtonSize.medium,
                                      variant: selectedCustomerPhotoFile != null
                                          ? ButtonVariant.primary
                                          : ButtonVariant.outlined,
                                      enabled:
                                          selectedCustomerPhotoFile != null,
                                      onTap: () => downloadFile('photo'),
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
                // Remove formatting (dashes) before checking length
                String cleanTaxNumber = taxNumber.replaceAll('-', '');

                // Check length for Tax ID (both Thai and Foreigner)
                if (cleanTaxNumber.length != 13) {
                  String warningMessage = cleanTaxNumber.length < 13
                      ? 'เลขประจำตัวผู้เสียภาษีไม่ครบ 13 หลัก คุณแน่ใจว่าจะดำเนิการต่อ?'
                      : 'เลขประจำตัวผู้เสียภาษีเกิน 13 หลัก คุณแน่ใจว่าจะดำเนินการต่อ?';
                  Alert.info(context, 'คำเตือน', warningMessage, 'ตกลง',
                      action: () async {
                    await _continueAfterTaxIdWarning();
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

  Future<void> _continueAfterTaxIdWarning() async {
    // Continue validation after Tax ID warning is accepted
    // Skip the normal save confirmation since user already confirmed via Tax ID warning

    // NEW VALIDATION: Block save when company name is empty for company customers
    if (selectedType?.code == 'company') {
      // Company name (ชื่อผู้ประกอบการ) is required for all company customers
      if (companyNameCtrl.text.isEmpty) {
        Alert.warning(context, 'คำเตือน', 'กรุณากรอกชื่อผู้ประกอบการ', 'ตกลง',
            action: () {});
        return;
      }
    }

    // NEW VALIDATION: Row 2 - Warning when head office branch code manually changed from default
    if (selectedType?.code == 'company' && companyOfficeType == 'head') {
      if (branchCodeCtrl.text.isNotEmpty && branchCodeCtrl.text != '00000') {
        Alert.info(
            context,
            'คำเตือน',
            'นิติบุคคลรายนี้เป็นสำนักงานใหญ่ คุณต้องการบันทึกด้วยรหัส ${branchCodeCtrl.text}?',
            'ตกลง', action: () async {
          await _saveDirectly();
        });
        return;
      }
    }

    // NEW VALIDATION: Row 7 - Warning when branch has '00000' branch code
    if (selectedType?.code == 'company' && companyOfficeType == 'branch') {
      if (branchCodeCtrl.text == '00000') {
        Alert.info(
            context,
            'คำเตือน',
            'นิติบุคคลรายนี้เป็นสาขา คุณต้องการบันทึกด้วยรหัสสาขา 00000?',
            'ตกลง', action: () async {
          await _saveDirectly();
        });
        return;
      }
    }

    await _saveDirectly();
  }

  Future<void> _processSave() async {
    // Validate company name is required for company customers
    if (selectedType?.code == 'company') {
      if (companyNameCtrl.text.isEmpty) {
        Alert.warning(context, 'คำเตือน', 'กรุณากรอกชื่อผู้ประกอบการ', 'ตกลง',
            action: () {});
        return;
      }
    }

    // Warning when head office branch code manually changed from default
    if (selectedType?.code == 'company' && companyOfficeType == 'head') {
      if (branchCodeCtrl.text.isNotEmpty && branchCodeCtrl.text != '00000') {
        Alert.info(
            context,
            'คำเตือน',
            'นิติบุคคลรายนี้เป็นสำนักงานใหญ่ คุณต้องการบันทึกด้วยรหัส ${branchCodeCtrl.text}?',
            'ตกลง', action: () async {
          await _saveDirectly();
        });
        return;
      }
    }

    // Warning when branch has '00000' branch code
    if (selectedType?.code == 'company' && companyOfficeType == 'branch') {
      if (branchCodeCtrl.text == '00000') {
        Alert.info(
            context,
            'คำเตือน',
            'นิติบุคคลรายนี้เป็นสาขา คุณต้องการบันทึกด้วยรหัสสาขา 00000?',
            'ตกลง', action: () async {
          await _saveDirectly();
        });
        return;
      }
    }

    if (selectedCustomer == null) {
      Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
          action: () async {
        await _saveDirectly();
      });
    } else {
      setState(() {
        Global.customer = selectedCustomer;
      });
      Navigator.of(context).pop();
    }
  }

  Future<void> _saveDirectly() async {
    // ROW 1: Auto-default branch code to '00000' for head office when empty
    String finalBranchCode = branchCodeCtrl.text;
    if (selectedType?.code == 'company' && companyOfficeType == 'head') {
      if (finalBranchCode.isEmpty) {
        finalBranchCode = '00000';
      }
    }

    var customerObject = Global.requestObj({
      "id": widget.c.id, // IMPORTANT: Include customer ID
      "customerType": selectedType?.code,
      "companyName": companyNameCtrl.text,

      // Company-specific fields
      "establishmentName":
          businessNameCtrl.text, // Maps to EstablishmentName in API
      "headquartersOrBranch":
          companyOfficeType, // 'head' or 'branch' maps to HeadquartersOrBranch
      "registrationDate": registrationDateCtrl.text.isEmpty
          ? null
          : _tryParseDate(registrationDateCtrl.text),
      "businessType": selectedType?.code == "company"
          ? selectedBusinessTypeOccupation?.name
          : null,

      // Name fields
      "titleName": selectedTitleName?.name,
      "firstName": firstNameCtrl.text,
      "middleName": middleNameCtrl.text,
      "lastName": lastNameCtrl.text,

      // Contact info
      "email": emailAddressCtrl.text,
      "doB": birthDateCtrl.text.isEmpty
          ? null
          : _tryParseDate(birthDateCtrl.text),
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
      // Use the selected tambon/amphure/province, don't override with defaults
      "tambonId": Global.tambonModel?.id,
      "amphureId": Global.amphureModel?.id,
      "provinceId": Global.provinceModel?.id,
      "postalCode": postalCodeCtrl.text,

      // Nationality and ID info
      "nationality": nationality == 'Foreigner'
          ? (selectedNationality?.nationalityTH ?? 'Foreigner')
          : nationality,
      "country": selectedCountryModel?.countryTH, // For Company + Foreigner
      "cardType": selectedCardType?.nameTH,
      "idCard": selectedType?.code == "general"
          ? idCardCtrl.text.replaceAll('-', '')
          : "",
      "idCardIssueDate": issueDateCtrl.text.isEmpty
          ? null
          : _tryParseDate(issueDateCtrl.text),
      "idCardExpiryDate": expiryDateCtrl.text.isEmpty
          ? null
          : _tryParseDate(expiryDateCtrl.text),

      // Foreign national fields
      "entryDate": entryDateCtrl.text.isEmpty
          ? null
          : _tryParseDate(entryDateCtrl.text),
      "exitDate": exitDateCtrl.text.isEmpty
          ? null
          : _tryParseDate(exitDateCtrl.text),
      "passportId": nationality == 'Foreigner' ? passportNoCtrl.text : '',
      "workPermit": nationality == 'Foreigner' ? workPermitCtrl.text : '',

      // Business fields
      "branchCode": finalBranchCode,
      "taxNumber": selectedType?.code == "company"
          ? nationality == 'Thai'
              ? taxNumberCtrl.text.replaceAll('-', '')
              : taxNumberCtrl.text
          : nationality == 'Thai'
              ? idCardCtrl.text.replaceAll('-', '')
              : taxNumberCtrl.text,

      // Occupation (for general customers only)
      "occupation": selectedType?.code == "general"
          ? (selectedOccupation?.name ?? occupationCtrl.text)
          : null,
      "occupationCustom": selectedType?.code == "general" &&
              selectedOccupation?.name == 'ประสงค์ระบุเอง'
          ? occupationCtrl.text
          : null,

      // Customer type flags
      "isSeller": isSeller ? 1 : 0,
      "isBuyer": isBuyer ? 1 : 0,
      "isCustomer": isCustomer ? 1 : 0,

      // Other
      "photoUrl": '',
      "remark": remarkCtrl.text,

      // OCR source tracking - preserve existing value
      "idCardSource": _idCardSource,
    });

    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());

    var result =
        await ApiServices.put('/customer', widget.c.id, customerObject);

    if (result?.status == "success") {
      if (mounted) {
        CustomerModel customer =
            customerModelFromJson(jsonEncode(result!.data!));
        setState(() {
          Global.customer = customer;
        });

        // Check if there are any NEW files to upload (exclude existing files)
        int totalNewFiles =
            occupationFiles.where((f) => !f.isExistingFile).length +
                riskAssessmentFiles.where((f) => !f.isExistingFile).length +
                customerPhotoFiles.where((f) => !f.isExistingFile).length;

        motivePrint('Total NEW files to upload: $totalNewFiles');
        motivePrint(
            'Total files in lists: ${occupationFiles.length + riskAssessmentFiles.length + customerPhotoFiles.length}');
        motivePrint('Files to delete: ${deletedServerFiles.length}');

        if (totalNewFiles > 0 || deletedServerFiles.isNotEmpty) {
          // Update progress message for file uploads
          pr.update(message: 'กำลังอัพโหลดไฟล์... (0/$totalNewFiles)');

          // Upload KYC files after customer creation (and delete removed files)
          await _uploadKycFiles(customer.id!, pr, totalNewFiles);
        } else {
          print('No files selected for upload');
        }

        await pr.hide();

        if (mounted) {
          Alert.success(
              context, 'Success'.tr(), "บันทึกเรียบร้อยแล้ว", 'OK'.tr(),
              action: () {
            Navigator.of(context).pop();
          });
        }
      }
    } else {
      await pr.hide();
      if (mounted) {
        Alert.warning(
            context, 'Warning'.tr(), result!.message ?? result.data, 'OK'.tr(),
            action: () {});
      }
    }
  }

  Future<void> _uploadKycFiles(
      int customerId, ProgressDialog pr, int totalFiles) async {
    try {
      int uploadedCount = 0;

      // Step 1: Delete files marked for deletion from server
      if (deletedServerFiles.isNotEmpty) {
        pr.update(
            message: 'กำลังลบไฟล์เก่า... (${deletedServerFiles.length} ไฟล์)');
        await _deleteServerFiles(customerId);
      }

      // Step 2: Upload only NEW files (skip existing files)

      // Upload Occupation files (only new ones)
      for (var fileWithTime in occupationFiles) {
        if (!fileWithTime.isExistingFile) {
          await _uploadSingleFile(
            customerId,
            fileWithTime.file,
            'Occupation',
            fileWithTime.addedDateTime,
          );
          uploadedCount++;
          pr.update(
              message: 'กำลังอัพโหลดไฟล์... ($uploadedCount/$totalFiles)');
        }
      }

      // Upload Risk Assessment files (only new ones)
      for (var fileWithTime in riskAssessmentFiles) {
        if (!fileWithTime.isExistingFile) {
          await _uploadSingleFile(
            customerId,
            fileWithTime.file,
            'RiskAssessment',
            fileWithTime.addedDateTime,
          );
          uploadedCount++;
          pr.update(
              message: 'กำลังอัพโหลดไฟล์... ($uploadedCount/$totalFiles)');
        }
      }

      // Upload Customer Photo files (only new ones)
      for (var fileWithTime in customerPhotoFiles) {
        if (!fileWithTime.isExistingFile) {
          await _uploadSingleFile(
            customerId,
            fileWithTime.file,
            'Photo',
            fileWithTime.addedDateTime,
          );
          uploadedCount++;
          pr.update(
              message: 'กำลังอัพโหลดไฟล์... ($uploadedCount/$totalFiles)');
        }
      }
    } catch (e) {
      motivePrint('Error uploading KYC files: $e');
      // Don't block the success message, just log the error
    }
  }

  // Delete files from server
  Future<void> _deleteServerFiles(int customerId) async {
    try {
      for (var filePath in deletedServerFiles) {
        motivePrint('Deleting server file: $filePath');

        // Extract just the filename from the full path
        final fileName = filePath.split('/').last;

        // Delete the physical file from server (via API call or direct deletion)
        // For now, we'll use a simple HTTP DELETE request
        try {
          final response = await http.delete(
            Uri.parse(
                '${Constants.BACKEND_URL}/customer/attachment/$customerId/$fileName'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization':
                  'Basic ${base64.encode(utf8.encode('root:t00r'))}',
            },
          );

          if (response.statusCode == 200) {
            motivePrint('Successfully deleted file: $fileName');
          } else {
            motivePrint(
                'Failed to delete file: $fileName, status: ${response.statusCode}');
          }
        } catch (e) {
          motivePrint('Error deleting file $fileName: $e');
        }
      }

      // Clear the deleted files list after processing
      deletedServerFiles.clear();
    } catch (e) {
      motivePrint('Error in _deleteServerFiles: $e');
    }
  }

  Future<void> _uploadSingleFile(
    int customerId,
    PlatformFile file,
    String attachmentType,
    DateTime attachmentDate,
  ) async {
    try {
      print('Uploading file: ${file.name} (type: $attachmentType)');
      print('File path: ${file.path}');
      print('Customer ID: $customerId');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Constants.BACKEND_URL}/customer/attachment/$customerId'),
      );

      // Add file - Prioritize bytes for web compatibility
      if (file.bytes != null) {
        print('Adding file from bytes (size: ${file.bytes!.length})');
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else if (file.path != null && file.path!.isNotEmpty) {
        print('Adding file from path: ${file.path}');
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      } else {
        print('WARNING: No file path or bytes available');
      }

      // Add fields
      request.fields['attachmentType'] = attachmentType;
      request.fields['attachmentDate'] = attachmentDate.toIso8601String();
      if (Global.user?.id != null) {
        request.fields['userId'] = Global.user!.id!;
      }

      print('Sending upload request...');
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      print('Upload response status: ${response.statusCode}');
      print('Upload response data: $responseData');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        if (data['status'] == 'success') {
          print('Successfully uploaded $attachmentType file: ${file.name}');
        } else {
          print('Upload failed: ${data['message']}');
        }
      } else {
        print('Upload failed with status code: ${response.statusCode}');
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
      var result = await ApiServices.post(
          '/customer/check-tax-number',
          Global.requestObj({
            "taxNumber": taxNumber,
            "excludeId": widget.c.id // Exclude current customer when editing
          }));

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
                title:
                    Text('เลือกจากคลังภาพ', style: TextStyle(fontSize: 14.sp)),
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
      PlatformFile? platformFile;

      if (kIsWeb) {
        // On web, use FilePicker for images
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          platformFile = result.files.first;
        }
      } else {
        // On mobile/desktop, use ImagePicker
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1920,
          imageQuality: 85,
        );

        if (image != null) {
          // Read bytes first (works on all platforms including web)
          final Uint8List imageBytes = await image.readAsBytes();
          final int fileSize = imageBytes.length;
          final String fileName = image.name;

          // Create PlatformFile with bytes (essential for web)
          platformFile = PlatformFile(
            path: image.path.isNotEmpty
                ? image.path
                : null, // Path may be empty on web
            name: fileName,
            size: fileSize,
            bytes: imageBytes, // Critical for web - bytes must be set
          );
        }
      }

      if (platformFile != null) {
        if (!mounted) return;
        setState(() {
          final fileWithTimestamp =
              FileWithTimestamp(platformFile!, DateTime.now());
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
        motivePrint(
            'Image picked successfully: ${platformFile.name} (${platformFile.size} bytes)');
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
          'pdf',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'ppt',
          'pptx',
          'txt',
          'rtf',
          'odt',
          'ods',
          'odp',
          'jpg',
          'jpeg',
          'png',
          'gif',
          'bmp',
          'tiff',
          'webp'
        ];
        if (ext == null || !allowedExtensions.contains(ext)) {
          if (!mounted) return;
          Alert.warning(context, 'คำเตือน',
              'กรุณาเลือกไฟล์เอกสารหรือรูปภาพเท่านั้น', 'OK',
              action: () {});
          return;
        }

        // Add file to list immediately and select it
        if (!mounted) return;
        setState(() {
          final fileWithTimestamp =
              FileWithTimestamp(pickedFile, DateTime.now());
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

  // Remove selected file from list with confirmation
  Future<void> removeFileFromList(String fileType) async {
    FileWithTimestamp? fileToDelete;
    String fileName = '';

    if (fileType == 'occupation' && selectedOccupationFile != null) {
      fileToDelete = selectedOccupationFile;
      fileName = selectedOccupationFile!.file.name;
    } else if (fileType == 'risk' && selectedRiskAssessmentFile != null) {
      fileToDelete = selectedRiskAssessmentFile;
      fileName = selectedRiskAssessmentFile!.file.name;
    } else if (fileType == 'photo' && selectedCustomerPhotoFile != null) {
      fileToDelete = selectedCustomerPhotoFile;
      fileName = selectedCustomerPhotoFile!.file.name;
    }

    if (fileToDelete == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with warning icon
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange[700],
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'ยืนยันการลบไฟล์',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'คุณต้องการลบไฟล์นี้หรือไม่?',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getFileIcon(
                                    fileToDelete?.file.extension ?? ''),
                                color: Colors.blue[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fileName,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              size: 16, color: Colors.red[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'การดำเนินการนี้ไม่สามารถย้อนกลับได้',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'ยกเลิก',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[500],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'ลบ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );

    // If confirmed, remove the file
    if (confirmed == true) {
      setState(() {
        if (fileType == 'occupation') {
          // If this is an existing server file, track it for deletion
          if (selectedOccupationFile!.isExistingFile &&
              selectedOccupationFile!.serverFilePath != null) {
            deletedServerFiles.add(selectedOccupationFile!.serverFilePath!);
            motivePrint(
                'Marked server file for deletion: ${selectedOccupationFile!.serverFilePath}');
          }
          occupationFiles.remove(selectedOccupationFile);
          selectedOccupationFile =
              occupationFiles.isNotEmpty ? occupationFiles.first : null;
        } else if (fileType == 'risk') {
          // If this is an existing server file, track it for deletion
          if (selectedRiskAssessmentFile!.isExistingFile &&
              selectedRiskAssessmentFile!.serverFilePath != null) {
            deletedServerFiles.add(selectedRiskAssessmentFile!.serverFilePath!);
            motivePrint(
                'Marked server file for deletion: ${selectedRiskAssessmentFile!.serverFilePath}');
          }
          riskAssessmentFiles.remove(selectedRiskAssessmentFile);
          selectedRiskAssessmentFile =
              riskAssessmentFiles.isNotEmpty ? riskAssessmentFiles.first : null;
        } else if (fileType == 'photo') {
          // If this is an existing server file, track it for deletion
          if (selectedCustomerPhotoFile!.isExistingFile &&
              selectedCustomerPhotoFile!.serverFilePath != null) {
            deletedServerFiles.add(selectedCustomerPhotoFile!.serverFilePath!);
            motivePrint(
                'Marked server file for deletion: ${selectedCustomerPhotoFile!.serverFilePath}');
          }
          customerPhotoFiles.remove(selectedCustomerPhotoFile);
          selectedCustomerPhotoFile =
              customerPhotoFiles.isNotEmpty ? customerPhotoFiles.first : null;
        }
      });
    }
  }

  // Format filename to show the end (with date/time) instead of beginning
  String formatFileName(String? fileName, {int maxLength = 60}) {
    if (fileName == null || fileName.isEmpty) {
      return 'ไม่มีการแนบเอกสาร';
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
                              final addedDateTime =
                                  fileWithTimestamp.addedDateTime;
                              final isSelected =
                                  selectedFile?.file.name == file.name;

                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    if (fileType == 'occupation') {
                                      selectedOccupationFile =
                                          fileWithTimestamp;
                                    } else if (fileType == 'risk') {
                                      selectedRiskAssessmentFile =
                                          fileWithTimestamp;
                                    } else {
                                      selectedCustomerPhotoFile =
                                          fileWithTimestamp;
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
  Future<void> downloadFile(String fileType) async {
    FileWithTimestamp? fileWithTimestamp;
    if (fileType == 'occupation') {
      fileWithTimestamp = selectedOccupationFile;
    } else if (fileType == 'risk') {
      fileWithTimestamp = selectedRiskAssessmentFile;
    } else if (fileType == 'photo') {
      fileWithTimestamp = selectedCustomerPhotoFile;
    }

    if (fileWithTimestamp == null) return;

    try {
      Uint8List? fileBytes;
      String fileName = fileWithTimestamp.file.name;

      // Check if this is an existing file from server or a newly added file
      if (fileWithTimestamp.isExistingFile &&
          fileWithTimestamp.serverFilePath != null) {
        // File is from server - need to fetch it via HTTP
        motivePrint(
            'Downloading file from server: ${fileWithTimestamp.serverFilePath}');

        // Ensure proper URL construction - serverFilePath should start with /
        String filePath = fileWithTimestamp.serverFilePath!;
        motivePrint('Original file path: $filePath');
        if (!filePath.startsWith('/')) {
          filePath = '/$filePath';
          motivePrint('Added leading slash: $filePath');
        }
        final String serverUrl = '${Constants.DOMAIN_URL}$filePath';
        motivePrint('Domain URL: ${Constants.DOMAIN_URL}');
        motivePrint('Final URL: $serverUrl');

        final response = await http.get(Uri.parse(serverUrl));

        if (response.statusCode == 200) {
          fileBytes = response.bodyBytes;
          motivePrint('File downloaded from server: ${fileBytes.length} bytes');
        } else {
          throw Exception(
              'Failed to download file from server. Status: ${response.statusCode}');
        }
      } else if (fileWithTimestamp.file.bytes != null) {
        // File is newly added - bytes are already in memory
        fileBytes = fileWithTimestamp.file.bytes!;
        motivePrint('Using bytes from memory: ${fileBytes.length} bytes');
      }

      if (fileBytes != null) {
        await download_helper.downloadFile(fileBytes, fileName);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('บันทึกไฟล์ "$fileName" สำเร็จ'),
                  ),
                ],
              ),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    } catch (e) {
      motivePrint('Error downloading file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('ไม่สามารถบันทึกไฟล์ได้: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
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
