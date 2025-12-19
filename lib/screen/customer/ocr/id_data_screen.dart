import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/model/location/amphure.dart';
import 'package:motivegold/model/location/province.dart';
import 'package:motivegold/model/location/tambon.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/button/kcl_button.dart';
import 'package:sizer/sizer.dart';
import 'package:device_info_plus/device_info_plus.dart';

class IDCardOCRScreen extends StatefulWidget {
  const IDCardOCRScreen({super.key});

  @override
  IDCardOCRScreenState createState() => IDCardOCRScreenState();
}

class IDCardOCRScreenState extends State<IDCardOCRScreen>
    with TickerProviderStateMixin {
  PlatformFile? _selectedFile;
  XFile? _pickedImage; // For mobile fallback
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic>? ocrResult;
  bool isLoading = false;
  String errorMessage = '';

  AnimationController? _animationController;
  Animation<double>? _slideAnimation;

  // Add debouncing variables
  bool _isDialogShowing = false;
  DateTime? _lastTapTime;

  // Add device info variables
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();
  bool? _isMobileDevice;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));
    _animationController!.forward();

    // Initialize device detection
    _initializeDeviceInfo();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // Initialize device detection using device_info_plus
  Future<void> _initializeDeviceInfo() async {
    try {
      if (kIsWeb) {
        final webBrowserInfo = await _deviceInfoPlugin.webBrowserInfo;
        final userAgent = webBrowserInfo.userAgent?.toLowerCase() ?? '';

        // Debug: Print user agent to console
        print('User Agent: $userAgent');

        // More strict mobile/tablet detection for web
        bool isMobile = userAgent.contains('mobile') && !userAgent.contains('tablet');
        bool isAndroid = userAgent.contains('android');
        bool isIPhone = userAgent.contains('iphone');
        bool isIPad = userAgent.contains('ipad');
        bool isIPod = userAgent.contains('ipod');

        // iPad Safari special case - reports as Macintosh but has Safari
        // More strict: must have both 'macintosh' AND 'safari' AND NOT contain 'chrome'
        bool isIPadSafari = userAgent.contains('macintosh') &&
            userAgent.contains('safari') &&
            !userAgent.contains('chrome') &&
            !userAgent.contains('firefox');

        // Desktop browsers typically contain: chrome, firefox, edge, opera
        // AND do not contain mobile indicators
        bool isDesktop = (userAgent.contains('chrome') ||
            userAgent.contains('firefox') ||
            userAgent.contains('edge') ||
            userAgent.contains('opera')) &&
            !userAgent.contains('mobile') &&
            !userAgent.contains('android') &&
            !userAgent.contains('iphone') &&
            !userAgent.contains('ipad') &&
            !isIPadSafari;

        _isMobileDevice = (isMobile || isAndroid || isIPhone || isIPad || isIPod || isIPadSafari) && !isDesktop;

        // Debug: Print detection result
        print('Detection Results:');
        print('- isMobile: $isMobile');
        print('- isAndroid: $isAndroid');
        print('- isIPhone: $isIPhone');
        print('- isIPad: $isIPad');
        print('- isIPadSafari: $isIPadSafari');
        print('- isDesktop: $isDesktop');
        print('- Final _isMobileDevice: $_isMobileDevice');

      } else {
        // For native apps
        _isMobileDevice = Platform.isIOS || Platform.isAndroid;
        print('Native platform - _isMobileDevice: $_isMobileDevice');
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Device detection error: $e');
      // Fallback: assume desktop if detection fails
      _isMobileDevice = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Platform detection using device_info_plus for accurate results
  bool get shouldShowCameraOption {
    if (_isMobileDevice == null) {
      // Still initializing, show conservative option
      return kIsWeb ? false : (Platform.isIOS || Platform.isAndroid);
    }
    return _isMobileDevice!;
  }

  bool get shouldUseImagePicker {
    if (_isMobileDevice == null) {
      // Still initializing, show conservative option
      return kIsWeb ? false : (Platform.isIOS || Platform.isAndroid);
    }
    return _isMobileDevice!;
  }

  bool get useFilePicker {
    // Only use file picker for desktop native apps
    return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  }

  Future<void> pickImageFile() async {
    // Prevent multiple rapid taps
    final now = DateTime.now();
    if (_lastTapTime != null && now.difference(_lastTapTime!).inMilliseconds < 1000) {
      return;
    }
    _lastTapTime = now;

    if (_isDialogShowing) return;

    try {
      if (useFilePicker) {
        // Desktop native apps only - use file picker directly
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.single;

          if (file.size > 10 * 1024 * 1024) {
            setState(() {
              errorMessage = 'File size too large. Please select a smaller image.';
            });
            return;
          }

          setState(() {
            _selectedFile = file;
            _pickedImage = null;
            errorMessage = '';
          });
        }
      } else {
        // All other platforms (web browsers, mobile apps) - show dialog
        await _showImageSourceDialog();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
    if (_isDialogShowing) return;

    _isDialogShowing = true;

    try {
      return showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'เลือกแหล่งที่มาของภาพ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gallery/File Browser Option
                  _buildDialogOption(
                    icon: Icons.photo_library,
                    title: 'เลือกจากแกลเลอรี่',
                    onTap: () {
                      Navigator.of(context).pop();
                      // For iPad and mobile browsers, use image picker instead of file picker
                      if (shouldUseImagePicker) {
                        _pickImageFromSource(ImageSource.gallery);
                      } else {
                        _pickFromFileBrowser();
                      }
                    },
                  ),

                  // Camera Option - Show for mobile browsers
                  if (shouldShowCameraOption) ...[
                    const SizedBox(height: 12),
                    _buildDialogOption(
                      icon: Icons.camera_alt,
                      title: 'กล้องถ่ายรูป',
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImageFromSource(ImageSource.camera);
                      },
                    ),
                  ],

                  // Cancel Option
                  const SizedBox(height: 12),
                  _buildDialogOption(
                    icon: Icons.close,
                    title: 'ยกเลิก',
                    color: Colors.red,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } finally {
      _isDialogShowing = false;
    }
  }

  Future<void> _pickFromFileBrowser() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        allowMultiple: false,
        withData: true, // Load bytes for web
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        if (file.size > 10 * 1024 * 1024) {
          setState(() {
            errorMessage = 'ขนาดไฟล์ใหญ่เกินไป กรุณาเลือกรูปที่มีขนาดเล็กกว่า 10MB';
          });
          return;
        }

        setState(() {
          _selectedFile = file;
          _pickedImage = null;
          errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาดในการเลือกไฟล์: $e';
      });
    }
  }

  Widget _buildDialogOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      setState(() {
        errorMessage = '';
      });

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );

      if (image != null) {
        // Validate the image file
        final bytes = await image.readAsBytes();
        if (bytes.isEmpty) {
          throw Exception('Unable to read image data');
        }

        setState(() {
          _pickedImage = image;
          _selectedFile = null;
          errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาดในการเลือกรูป: $e';
      });
      print('Image picker error: $e');
    }
  }

  Future<void> uploadImageToOCR() async {
    if (_selectedFile == null && _pickedImage == null) return;

    setState(() {
      isLoading = true;
      ocrResult = null;
      errorMessage = '';
    });

    final apiUrl = Uri.parse('https://api.iapp.co.th/thai-national-id-card/v3.5/front');
    const apiKey = '4dJUaFqHvazYFqgRu0VL0eEQyakcR29i';
    final request = http.MultipartRequest('POST', apiUrl)
      ..headers['apikey'] = apiKey;

    try {
      if (_selectedFile != null) {
        if (kIsWeb) {
          // Web: Always use bytes
          if (_selectedFile!.bytes != null && _selectedFile!.bytes!.isNotEmpty) {
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              _selectedFile!.bytes!,
              filename: _selectedFile!.name,
            ));
          } else {
            throw Exception('No image data available');
          }
        } else if (_selectedFile!.path != null && _selectedFile!.path!.isNotEmpty) {
          // Desktop: Use file path
          request.files.add(
              await http.MultipartFile.fromPath('file', _selectedFile!.path!));
        }
      } else if (_pickedImage != null) {
        // Mobile or web with image_picker
        if (kIsWeb) {
          // On web, read bytes from XFile
          final bytes = await _pickedImage!.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: _pickedImage!.name,
          ));
        } else {
          // Native mobile: Use file path
          request.files.add(
              await http.MultipartFile.fromPath('file', _pickedImage!.path));
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Your existing success handling code...
        motivePrint(responseBody);
        ocrResult = json.decode(responseBody);
        String? amphure = ocrResult?["district"];
        String? tambon = ocrResult?["sub_district"];
        motivePrint(amphure);
        motivePrint(tambon);
        // Process OCR result and update global models
        var result = await ApiServices.get('/location/amphure/search/${ocrResult?["district"]}');
        if (result?.status == "success") {
          Global.amphureModel = AmphureModel.fromJson(result?.data);
        }
        var result2 = await ApiServices.get('/location/tambon/search/${ocrResult?["sub_district"]}');
        if (result2?.status == "success") {
          Global.tambonModel = TambonModel.fromJson(result2?.data);
        }
        var provinces = Global.provinceList
            .where((e) => e.id == Global.amphureModel?.provinceId);
        if (provinces.isNotEmpty) {
          Global.provinceModel = provinces.first;
        }
        await loadAmphureByProvince(Global.provinceModel?.id);
        await loadTambonByAmphure(Global.amphureModel?.id);

        Global.provinceNotifier = ValueNotifier<ProvinceModel>(
            Global.provinceModel ??
                ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
        Global.amphureNotifier = ValueNotifier<AmphureModel>(
            Global.amphureModel ?? AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
        Global.tambonNotifier = ValueNotifier<TambonModel>(
            Global.tambonModel ?? TambonModel(id: 0, nameTh: 'เลือกตำบล'));

        // Auto-check for duplicate ID card after OCR
        await _checkDuplicateIdCard(ocrResult?["id_number"]);

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'การประมวลผลล้มเหลว: $responseBody';
        });
        motivePrint(responseBody);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'เกิดข้อผิดพลาด: $e';
      });
      print('Upload error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Check for duplicate ID card after OCR
  Future<void> _checkDuplicateIdCard(String? idNumber) async {
    if (idNumber == null || idNumber.isEmpty) return;

    String idCard = idNumber.replaceAll('-', '');
    if (idCard.length != 13) return; // Only check complete ID cards

    try {
      var result = await ApiServices.post('/customer/check-id-card',
          Global.requestObj({"idCard": idCard}));

      if (result?.status == "success" && result?.data != null) {
        // Duplicate found - show warning
        if (mounted) {
          var data = result!.data;
          String firstName = data['firstName'] ?? '';
          String lastName = data['lastName'] ?? '';
          Alert.warning(
            context,
            'เลขบัตรประชาชนซ้ำ',
            'พบข้อมูลลูกค้าที่มีเลขบัตรประชาชนนี้อยู่แล้ว:\n$firstName $lastName',
            'ตกลง',
            action: () {},
          );
        }
      }
    } catch (e) {
      print("Error checking duplicate ID card: $e");
    }
  }

  Widget displayOCRResult() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 3),
            SizedBox(height: 16),
            Text(
              'กำลังประมวลผลข้อมูล...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (ocrResult == null && errorMessage.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.credit_card,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'ยังไม่มีผลลัพธ์',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Only display key fields
    final keyFields = {
      'id_number': 'เลขบัตรประชาชน',
      'th_name': 'ชื่อ (ไทย)',
      'en_name': 'ชื่อ (อังกฤษ)',
      'th_dob': 'วันเกิด',
      'address': 'ที่อยู่',
      'th_issue': 'วันออกบัตร',
      'th_expire': 'วันหมดอายุ',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                const Text(
                  'ประมวลผลสำเร็จ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...keyFields.entries.map((field) {
            final value = ocrResult![field.key];
            if (value == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getIconForField(field.key),
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          field.value,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          value.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  IconData _getIconForField(String field) {
    switch (field) {
      case 'id_number':
        return Icons.badge;
      case 'th_name':
      case 'en_name':
        return Icons.person;
      case 'th_dob':
        return Icons.cake;
      case 'address':
        return Icons.home;
      case 'th_issue':
      case 'th_expire':
        return Icons.calendar_today;
      default:
        return Icons.info;
    }
  }

  String _getFieldLabel(String field) {
    switch (field) {
      case 'id_number':
        return 'เลขบัตรประชาชน';
      case 'th_name':
        return 'ชื่อ (ไทย)';
      case 'en_name':
        return 'ชื่อ (อังกฤษ)';
      case 'th_dob':
        return 'วันเกิด';
      case 'address':
        return 'ที่อยู่';
      case 'th_issue':
        return 'วันออกบัตร';
      case 'th_expire':
        return 'วันหมดอายุ';
      default:
        return field;
    }
  }

  Widget _buildImageWidget() {
    try {
      if (_selectedFile != null) {
        if (kIsWeb) {
          // Web - always use bytes for web platform
          if (_selectedFile!.bytes != null && _selectedFile!.bytes!.isNotEmpty) {
            return Image.memory(
              _selectedFile!.bytes!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Image.memory error: $error');
                return _buildErrorWidget('ไม่สามารถแสดงรูปภาพได้');
              },
            );
          } else {
            return _buildErrorWidget('ไม่มีข้อมูลรูปภาพ');
          }
        } else if (_selectedFile!.path != null && _selectedFile!.path!.isNotEmpty) {
          // Desktop - use file path
          return Image.file(
            File(_selectedFile!.path!),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image.file error: $error');
              return _buildErrorWidget('ไม่สามารถแสดงรูปภาพได้');
            },
          );
        }
      } else if (_pickedImage != null) {
        // Mobile - use image_picker with better error handling
        if (kIsWeb) {
          // On web, convert XFile to bytes
          return FutureBuilder<Uint8List>(
            future: _pickedImage!.readAsBytes(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('XFile readAsBytes error: ${snapshot.error}');
                return _buildErrorWidget('ไม่สามารถอ่านข้อมูลรูปภาพได้');
              }
              if (snapshot.hasData) {
                return Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Image.memory from XFile error: $error');
                    return _buildErrorWidget('ไม่สามารถแสดงรูปภาพได้');
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        } else {
          // Native mobile
          return Image.file(
            File(_pickedImage!.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Image.file from XFile error: $error');
              return _buildErrorWidget('ไม่สามารถแสดงรูปภาพได้');
            },
          );
        }
      }
    } catch (e) {
      print('_buildImageWidget exception: $e');
      return _buildErrorWidget('เกิดข้อผิดพลาดในการแสดงรูปภาพ');
    }

    return _buildErrorWidget('กรุณาเลือกรูปภาพ');
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.grey[600],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Thai ID Card OCR",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ),
      body: AnimatedBuilder(
        animation: _slideAnimation ?? const AlwaysStoppedAnimation(0.0),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation?.value ?? 0),
            child: Column(
              children: [
                // Top section with buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Select image button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: pickImageFile,
                          icon: const Icon(Icons.add_photo_alternate, size: 24),
                          label: const Text(
                            'เลือกรูปบัตรประชาชน',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),

                      // File info
                      if (_selectedFile != null || _pickedImage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _selectedFile != null
                                      ? 'ไฟล์: ${_selectedFile!.name}'
                                      : 'รูปภาพ: ${_pickedImage!.name}',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Image preview
                      if (_selectedFile != null || _pickedImage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImageWidget(),
                          ),
                        ),
                      ],

                      // Upload button
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: (_selectedFile != null || _pickedImage != null)
                              ? uploadImageToOCR
                              : null,
                          icon: isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                              : const Icon(Icons.upload_file, size: 24),
                          label: Text(
                            isLoading ? 'กำลังประมวลผล...' : 'ประมวลผลข้อมูล',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Results section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: displayOCRResult(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                if (ocrResult == null || ocrResult!.isEmpty) {
                  Alert.warning(context, 'Warning'.tr(),
                      'กรุณาแนบบัตรประจำตัวประชาชนก่อน', 'OK'.tr(),
                      action: () {});
                  return;
                }
                if (ocrResult!['id_number'].toString().length < 13) {
                  Alert.info(
                    context,
                    'Warning'.tr(),
                    'หมายเลขบัตรประจำตัวน้อยกว่า 13 หลัก: ${ocrResult!['id_number']} \nคุณแน่ใจว่าจะดำเนินการต่อ?',
                    'OK'.tr(),
                    action: () {
                      Navigator.of(context).pop(ocrResult);
                    },
                  );
                } else {
                  Navigator.of(context).pop(ocrResult);
                }
              },
              icon: const Icon(Icons.check, size: 24),
              label: const Text(
                'ยืนยันข้อมูล',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}