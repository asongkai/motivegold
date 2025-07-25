import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/image/profile_image.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/util.dart';

// Platform-specific imports
import 'package:motivegold/widget/payment/web_file_picker.dart'
    if (dart.library.io) 'package:motivegold/widget/payment/mobile_file_picker.dart';
import 'package:sizer/sizer.dart';

class NewCompanyScreen extends StatefulWidget {
  final bool showBackButton;

  const NewCompanyScreen({super.key, required this.showBackButton});

  @override
  State<NewCompanyScreen> createState() => _NewCompanyScreenState();
}

class _NewCompanyScreenState extends State<NewCompanyScreen> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController taxNumberCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController addressCtrl = TextEditingController();
  final TextEditingController villageCtrl = TextEditingController();
  final TextEditingController districtCtrl = TextEditingController();
  final TextEditingController provinceCtrl = TextEditingController();

  bool nonStock = false;

  String? logo;
  File? file;
  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: widget.showBackButton,
          title: Text("เพิ่มบริษัทใหม่",
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Section
                  _buildLogoSection(),

                  const SizedBox(height: 24),

                  // Company Information Card
                  _buildInfoCard(
                    title: 'ข้อมูลบริษัท',
                    icon: Icons.business,
                    children: [
                      _buildModernTextField(
                        controller: nameCtrl,
                        label: 'ชื่อบริษัท',
                        icon: Icons.business_outlined,
                        required: true,
                      ),
                      const SizedBox(height: 16),
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
                          const SizedBox(width: 16),
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
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: taxNumberCtrl,
                        label: 'หมายเลขประจำตัวผู้เสียภาษี',
                        icon: Icons.assignment_outlined,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Address Information Card
                  _buildInfoCard(
                    title: 'ที่อยู่',
                    icon: Icons.location_on,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: provinceCtrl,
                              label: 'จังหวัด',
                              icon: Icons.map_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildModernTextField(
                              controller: districtCtrl,
                              label: 'เขต',
                              icon: Icons.location_city_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildModernTextField(
                              controller: villageCtrl,
                              label: 'บ้าน',
                              icon: Icons.home_outlined,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildModernTextField(
                              controller: addressCtrl,
                              label: 'ที่อยู่',
                              icon: Icons.place_outlined,
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
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            subtitle: const Text(
                              "เปิดใช้งานโหมด Non Stock",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            value: nonStock,
                            visualDensity: VisualDensity.compact,
                            activeColor: Colors.teal,
                            onChanged: (newValue) {
                              setState(() {
                                nonStock = newValue!;
                              });
                            },
                            controlAffinity: ListTileControlAffinity.leading,
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
          onPressed: _saveCompany,
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
                      child: SizedBox(
                        width: 115,
                        height: 115,
                        child: logo != null
                            ? (!kIsWeb && file != null)
                                ? Image.file(file!, fit: BoxFit.cover)
                                : (kIsWeb && logo != null)
                                    ? Image.memory(
                                        base64Decode(
                                          logo!.contains(',')
                                              ? logo!.split(',').last
                                              : logo!,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.business,
                                        size: 40,
                                        color: Colors.grey[400],
                                      )
                            : Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: Colors.grey[400],
                              ),
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
            logo != null ? 'แตะเพื่อเปลี่ยนรูป' : 'แตะเพื่อเพิ่มโลโก้',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
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

  void _saveCompany() async {
    if (nameCtrl.text.trim() == "") {
      Alert.warning(context, 'กรุณากรอกชื่อบริษัท', '', 'ตกลง');
      return;
    }

    // Clean and validate the logo base64 string before sending
    String? cleanedLogo;
    if (logo != null) {
      try {
        // Remove data URL prefix if present
        String base64String = logo!;
        if (base64String.startsWith('data:')) {
          base64String = base64String.split(',').last;
        }

        // Validate base64 string by trying to decode it
        base64Decode(base64String);

        // If successful, use the cleaned string
        cleanedLogo = base64String;

      } catch (e) {
        print('Invalid base64 logo data: $e');
        // Set to null if invalid, or show an error to user
        Alert.warning(context, 'รูปภาพไม่ถูกต้อง กรุณาเลือกรูปภาพใหม่', '', 'ตกลง');
        return;
      }
    }

    var object = Global.requestObj({
      "name": nameCtrl.text,
      "email": emailCtrl.text,
      "phone": phoneCtrl.text,
      "address": addressCtrl.text,
      "village": villageCtrl.text,
      "district": districtCtrl.text,
      "province": provinceCtrl.text,
      "taxNumber": taxNumberCtrl.text,
      "logo": cleanedLogo, // Use cleaned logo instead of raw logo
      "stock": nonStock ? 0 : 1
    });

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.post('/company', object);
        await pr.hide();
        if (result?.status == "success") {
          if (mounted) {
            Alert.success(context, 'บันทึกข้อมูลเรียบร้อยแล้ว', '', 'ตกลง',
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
                const SizedBox(height: 20),
              ],
            ),
          );
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
        Alert.warning(context, 'การถ่ายภาพจากกล้องบนเว็บยังไม่พร้อมใช้งาน', '', 'ตกลง');
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
              Alert.warning(context, 'รูปภาพไม่ถูกต้อง กรุณาเลือกรูปภาพใหม่', '', 'ตกลง');
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
