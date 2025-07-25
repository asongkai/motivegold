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
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // Check if we should use file_picker or image_picker
  bool get useFilePicker =>
      kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  Future<void> pickImageFile() async {
    try {
      if (useFilePicker) {
        // Use file_picker for web/desktop
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: kIsWeb, // Load bytes for web
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.single;

          if (file.size > 10 * 1024 * 1024) {
            setState(() {
              errorMessage =
              'File size too large. Please select a smaller image.';
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
        // Use image_picker for mobile
        await _showImageSourceDialog();
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _showImageSourceDialog() async {
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
                _buildDialogOption(
                  icon: Icons.photo_library,
                  title: 'แกลเลอรี่',
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImageFromSource(ImageSource.gallery);
                  },
                ),
                if (!kIsWeb) ...[
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
      final XFile? image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _pickedImage = image;
          _selectedFile = null;
          errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> uploadImageToOCR() async {
    if (_selectedFile == null && _pickedImage == null) return;
    setState(() {
      isLoading = true;
      ocrResult = null;
      errorMessage = '';
    });

    final apiUrl =
    Uri.parse('https://api.iapp.co.th/thai-national-id-card/v3.5/front');
    const apiKey =
        '4dJUaFqHvazYFqgRu0VL0eEQyakcR29i'; // Replace with your actual API key
    final request = http.MultipartRequest('POST', apiUrl)
      ..headers['apikey'] = apiKey;

    try {
      if (_selectedFile != null) {
        if (kIsWeb && _selectedFile!.bytes != null) {
          // ✅ Web: Use bytes directly
          request.files.add(http.MultipartFile.fromBytes(
            'file',
            _selectedFile!.bytes!,
            filename: _selectedFile!.name,
          ));
        } else if (_selectedFile!.path != null &&
            _selectedFile!.path!.isNotEmpty) {
          // 💻 Desktop: Use file path
          request.files.add(
              await http.MultipartFile.fromPath('file', _selectedFile!.path!));
        }
      } else if (_pickedImage != null) {
        // 📱 Mobile: Use image_picker path
        request.files
            .add(await http.MultipartFile.fromPath('file', _pickedImage!.path));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // Handle success
        ocrResult = json.decode(responseBody);
        String? amphure = ocrResult?["district"];
        String? tambon = ocrResult?["sub_district"];

        // Process OCR result and update global models
        var result = await ApiServices.get('/location/amphure/search/$amphure');
        if (result?.status == "success") {
          Global.amphureModel = AmphureModel.fromJson(result?.data);
        }
        var result2 = await ApiServices.get('/location/tambon/search/$tambon');
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

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to fetch data: $responseBody';
        });
        motivePrint(responseBody);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Exception: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
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
    if (_selectedFile != null) {
      if (kIsWeb && _selectedFile!.bytes != null) {
        // Web - use bytes
        return Image.memory(
          _selectedFile!.bytes!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
            );
          },
        );
      } else if (_selectedFile!.path!.isNotEmpty) {
        // Desktop - use file path
        return Image.file(
          File(_selectedFile!.path!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
                size: 50,
              ),
            );
          },
        );
      }
    } else if (_pickedImage != null) {
      // Mobile - use image_picker
      return Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.error,
              color: Colors.red,
              size: 50,
            ),
          );
        },
      );
    }
    return const Center(
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 50,
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