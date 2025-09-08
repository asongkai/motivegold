// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:file_picker/file_picker.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart'; // Add this dependency
// import 'package:motivegold/api/api_services.dart';
// import 'package:motivegold/model/location/amphure.dart';
// import 'package:motivegold/model/location/province.dart';
// import 'package:motivegold/model/location/tambon.dart';
// import 'package:motivegold/utils/alert.dart';
// import 'package:motivegold/utils/global.dart';
// import 'package:motivegold/utils/helps/common_function.dart';
// import 'package:motivegold/utils/util.dart';
// import 'package:motivegold/widget/appbar/appbar.dart';
// import 'package:motivegold/widget/appbar/title_content.dart';
// import 'package:motivegold/widget/button/kcl_button.dart';
// import 'package:sizer/sizer.dart';
//
// class TesseractOCRScreen extends StatefulWidget {
//   const TesseractOCRScreen({super.key});
//
//   @override
//   TesseractOCRScreenState createState() => TesseractOCRScreenState();
// }
//
// class TesseractOCRScreenState extends State<TesseractOCRScreen>
//     with TickerProviderStateMixin {
//   PlatformFile? _selectedFile;
//   XFile? _pickedImage;
//   final ImagePicker _imagePicker = ImagePicker();
//   Map<String, dynamic>? ocrResult;
//   bool isLoading = false;
//   String errorMessage = '';
//   String rawOcrText = '';
//
//   AnimationController? _animationController;
//   Animation<double>? _slideAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _slideAnimation = Tween<double>(
//       begin: 50.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _animationController!,
//       curve: Curves.easeOut,
//     ));
//     _animationController!.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController?.dispose();
//     super.dispose();
//   }
//
//   bool get useFilePicker =>
//       kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
//
//   Future<void> pickImageFile() async {
//     try {
//       if (useFilePicker) {
//         FilePickerResult? result = await FilePicker.platform.pickFiles(
//           type: FileType.image,
//           allowMultiple: false,
//           withData: kIsWeb,
//         );
//
//         if (result != null && result.files.isNotEmpty) {
//           final file = result.files.single;
//
//           if (file.size > 10 * 1024 * 1024) {
//             setState(() {
//               errorMessage =
//               'File size too large. Please select a smaller image.';
//             });
//             return;
//           }
//
//           setState(() {
//             _selectedFile = file;
//             _pickedImage = null;
//             errorMessage = '';
//           });
//         }
//       } else {
//         await _showImageSourceDialog();
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error picking file: $e';
//       });
//     }
//   }
//
//   Future<void> _showImageSourceDialog() async {
//     return showDialog<void>(
//       context: context,
//       barrierDismissible: true,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: Colors.white,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(
//                   Icons.camera_alt,
//                   size: 48,
//                   color: Colors.blue,
//                 ),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'เลือกแหล่งที่มาของภาพ',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 _buildDialogOption(
//                   icon: Icons.photo_library,
//                   title: 'แกลเลอรี่',
//                   onTap: () {
//                     Navigator.of(context).pop();
//                     _pickImageFromSource(ImageSource.gallery);
//                   },
//                 ),
//                 if (!kIsWeb) ...[
//                   const SizedBox(height: 12),
//                   _buildDialogOption(
//                     icon: Icons.camera_alt,
//                     title: 'กล้องถ่ายรูป',
//                     onTap: () {
//                       Navigator.of(context).pop();
//                       _pickImageFromSource(ImageSource.camera);
//                     },
//                   ),
//                 ],
//                 const SizedBox(height: 12),
//                 _buildDialogOption(
//                   icon: Icons.close,
//                   title: 'ยกเลิก',
//                   color: Colors.red,
//                   onTap: () => Navigator.of(context).pop(),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildDialogOption({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//     Color color = Colors.blue,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: color.withOpacity(0.2)),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: color),
//             const SizedBox(width: 16),
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _pickImageFromSource(ImageSource source) async {
//     try {
//       final XFile? image = await _imagePicker.pickImage(source: source);
//       if (image != null) {
//         setState(() {
//           _pickedImage = image;
//           _selectedFile = null;
//           errorMessage = '';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Error picking image: $e';
//       });
//     }
//   }
//
//   // Process OCR using Tesseract with enhanced settings
//   Future<void> processImageWithTesseract() async {
//     if (_selectedFile == null && _pickedImage == null) return;
//
//     setState(() {
//       isLoading = true;
//       ocrResult = null;
//       errorMessage = '';
//       rawOcrText = '';
//     });
//
//     try {
//       String imagePath;
//
//       // Get the image path based on platform
//       if (_pickedImage != null) {
//         imagePath = _pickedImage!.path;
//       } else if (_selectedFile != null && _selectedFile!.path != null) {
//         imagePath = _selectedFile!.path!;
//       } else {
//         throw Exception('No valid image path found');
//       }
//
//       // Perform OCR with optimized settings for Thai ID cards
//       String extractedText = await FlutterTesseractOcr.extractText(
//         imagePath,
//         language: 'tha+eng', // Thai + English support
//         args: {
//           "psm": "6", // Uniform block of text - good for ID cards
//           "preserve_interword_spaces": "1",
//           "tessedit_char_whitelist": "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzก-๙./- :()ำาิีึืุูเแโใไ็่้๊๋์ฯ", // Extended Thai characters
//           "tessedit_pageseg_mode": "6",
//           "tessedit_ocr_engine_mode": "1", // Use LSTM OCR engine
//         },
//       );
//
//       setState(() {
//         rawOcrText = extractedText;
//       });
//
//       motivePrint('Tesseract Raw OCR Text: $extractedText');
//
//       // Parse the extracted text to structured data
//       Map<String, dynamic> parsedData = _parseThaiIDCardText(extractedText);
//
//       // Process location data if address fields are found
//       await _processLocationData(parsedData);
//
//       setState(() {
//         ocrResult = parsedData;
//         isLoading = false;
//       });
//
//     } catch (e) {
//       setState(() {
//         errorMessage = 'OCR Error: $e';
//         isLoading = false;
//       });
//       motivePrint('Tesseract OCR Error: $e');
//     }
//   }
//
//   // Enhanced parsing for Thai ID cards
//   Map<String, dynamic> _parseThaiIDCardText(String text) {
//     Map<String, dynamic> result = {};
//
//     // Clean up the text
//     String cleanText = text.replaceAll('\n\n', '\n').replaceAll('  ', ' ').trim();
//     List<String> lines = cleanText.split('\n');
//
//     motivePrint('Cleaned OCR Text: $cleanText');
//
//     // Extract ID number (13 digits) - various formats
//     RegExp idPattern = RegExp(r'(?:Identification Number\s*)?(\d{1}\s*\d{4}\s*\d{5}\s*\d{2}\s*\d{1})');
//     Match? idMatch = idPattern.firstMatch(text);
//     if (idMatch != null) {
//       result['id_number'] = idMatch.group(1)?.replaceAll(' ', '') ?? '';
//     } else {
//       // Try alternative patterns
//       RegExp altIdPattern = RegExp(r'\b(\d{13})\b');
//       Match? altIdMatch = altIdPattern.firstMatch(text);
//       if (altIdMatch != null) {
//         result['id_number'] = altIdMatch.group(1) ?? '';
//       }
//     }
//
//     // Extract Thai name - improved pattern
//     RegExp thaiNamePattern = RegExp(r'(?:ชื่อตัวและชื่อสกุล|นาย|นาง|นางสาว)?\s*([ก-๙\s]+)(?=\s*Name|Mr\.|Mrs\.|Miss|$)', multiLine: true);
//     Match? thaiNameMatch = thaiNamePattern.firstMatch(text);
//     if (thaiNameMatch != null) {
//       String thaiName = thaiNameMatch.group(1)?.trim() ?? '';
//       thaiName = thaiName.replaceAll(RegExp(r'\s+'), ' ');
//       if (thaiName.isNotEmpty && thaiName.length > 2) {
//         result['th_name'] = thaiName;
//       }
//     }
//
//     // Extract English name
//     RegExp engNamePattern = RegExp(r'Name\s+(?:Mr\.|Mrs\.|Miss)?\s*([A-Za-z]+)(?:\s+Last\s+name\s+([A-Za-z]+))?', multiLine: true);
//     Match? engNameMatch = engNamePattern.firstMatch(text);
//     if (engNameMatch != null) {
//       String firstName = engNameMatch.group(1)?.trim() ?? '';
//       String lastName = engNameMatch.group(2)?.trim() ?? '';
//       if (firstName.isNotEmpty) {
//         result['en_name'] = lastName.isNotEmpty ? '$firstName $lastName' : firstName;
//       }
//     }
//
//     // Extract birth date with multiple formats
//     List<RegExp> dobPatterns = [
//       RegExp(r'(?:Date of Birth|เกิดวันที่)\s*(\d{1,2}\s*[A-Za-z]{3,}\s*\d{4})', multiLine: true),
//       RegExp(r'(?:Date of Birth|เกิดวันที่)\s*(\d{1,2}\s*[ก-๙\.]+\s*\d{4})', multiLine: true),
//       RegExp(r'(?:Date of Birth|เกิดวันที่)\s*(\d{1,2}/\d{1,2}/\d{4})', multiLine: true),
//     ];
//
//     for (RegExp pattern in dobPatterns) {
//       Match? match = pattern.firstMatch(text);
//       if (match != null) {
//         result['th_dob'] = match.group(1)?.trim() ?? '';
//         break;
//       }
//     }
//
//     // Extract issue date
//     List<RegExp> issuePatterns = [
//       RegExp(r'(?:Date of Issue|วันออกบัตร)\s*(\d{1,2}\s*[A-Za-z]{3,}\s*\d{4})', multiLine: true),
//       RegExp(r'(?:Date of Issue|วันออกบัตร)\s*(\d{1,2}\s*[ก-๙\.]+\s*\d{4})', multiLine: true),
//       RegExp(r'(?:Date of Issue|วันออกบัตร)\s*(\d{1,2}/\d{1,2}/\d{4})', multiLine: true),
//     ];
//
//     for (RegExp pattern in issuePatterns) {
//       Match? match = pattern.firstMatch(text);
//       if (match != null) {
//         result['th_issue'] = match.group(1)?.trim() ?? '';
//         break;
//       }
//     }
//
//     // Extract expiry date
//     List<RegExp> expiryPatterns = [
//       RegExp(r'(?:Date of Expiry|วันหมดอายุ)\s*(\d{1,2}\s*[A-Za-z]{3,}\s*\d{4})', multiLine: true),
//       RegExp(r'(?:Date of Expiry|วันหมดอายุ)\s*(\d{1,2}\s*[ก-๙\.]+\s*\d{4})', multiLine: true),
//       RegExp(r'(?:Date of Expiry|วันหมดอายุ)\s*(\d{1,2}/\d{1,2}/\d{4})', multiLine: true),
//     ];
//
//     for (RegExp pattern in expiryPatterns) {
//       Match? match = pattern.firstMatch(text);
//       if (match != null) {
//         result['th_expire'] = match.group(1)?.trim() ?? '';
//         break;
//       }
//     }
//
//     // Enhanced address extraction
//     List<String> addressLines = [];
//
//     for (int i = 0; i < lines.length; i++) {
//       String line = lines[i].trim();
//
//       // Look for address indicators
//       if (line.contains('ที่อยู่') ||
//           line.contains('หมู่ที่') ||
//           line.contains('ตำบล') ||
//           line.contains('อำเภอ') ||
//           line.contains('จังหวัด') ||
//           RegExp(r'\d+/\d+').hasMatch(line)) {
//
//         addressLines.add(line);
//
//         // Check next few lines for continuation
//         for (int j = i + 1; j < lines.length && j < i + 4; j++) {
//           String nextLine = lines[j].trim();
//           if (nextLine.contains('ตำบล') ||
//               nextLine.contains('อำเภอ') ||
//               nextLine.contains('จังหวัด') ||
//               RegExp(r'[ก-๙]').hasMatch(nextLine)) {
//             addressLines.add(nextLine);
//           } else if (nextLine.length < 5) {
//             continue; // Skip very short lines
//           } else {
//             break;
//           }
//         }
//         break;
//       }
//     }
//
//     if (addressLines.isNotEmpty) {
//       result['address'] = addressLines.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
//
//       String fullAddress = result['address'];
//
//       // Extract district (อำเภอ)
//       RegExp districtPattern = RegExp(r'(?:อำเภอ|อ\.)\s*([ก-๙\s]+?)(?:\s*(?:จังหวัด|จ\.|$))', multiLine: true);
//       Match? districtMatch = districtPattern.firstMatch(fullAddress);
//       if (districtMatch != null) {
//         result['district'] = districtMatch.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
//       }
//
//       // Extract sub_district (ตำบล)
//       RegExp subDistrictPattern = RegExp(r'(?:ตำบล|ต\.)\s*([ก-๙\s]+?)(?:\s*(?:อำเภอ|อ\.|จังหวัด|จ\.))', multiLine: true);
//       Match? subDistrictMatch = subDistrictPattern.firstMatch(fullAddress);
//       if (subDistrictMatch != null) {
//         result['sub_district'] = subDistrictMatch.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
//       }
//
//       // Extract province (จังหวัด)
//       RegExp provincePattern = RegExp(r'(?:จังหวัด|จ\.)\s*([ก-๙\s]+?)(?:\s*$)', multiLine: true);
//       Match? provinceMatch = provincePattern.firstMatch(fullAddress);
//       if (provinceMatch != null) {
//         result['province'] = provinceMatch.group(1)?.trim().replaceAll(RegExp(r'\s+'), ' ') ?? '';
//       }
//     }
//
//     motivePrint('Parsed result: $result');
//     return result;
//   }
//
//   // Process location data (same as original)
//   Future<void> _processLocationData(Map<String, dynamic> parsedData) async {
//     String? amphure = parsedData["district"];
//     String? tambon = parsedData["sub_district"];
//
//     if (amphure != null && amphure.isNotEmpty) {
//       var result = await ApiServices.get('/location/amphure/search/$amphure');
//       if (result?.status == "success") {
//         Global.amphureModel = AmphureModel.fromJson(result?.data);
//       }
//     }
//
//     if (tambon != null && tambon.isNotEmpty) {
//       var result2 = await ApiServices.get('/location/tambon/search/$tambon');
//       if (result2?.status == "success") {
//         Global.tambonModel = TambonModel.fromJson(result2?.data);
//       }
//     }
//
//     var provinces = Global.provinceList
//         .where((e) => e.id == Global.amphureModel?.provinceId);
//     if (provinces.isNotEmpty) {
//       Global.provinceModel = provinces.first;
//     }
//
//     await loadAmphureByProvince(Global.provinceModel?.id);
//     await loadTambonByAmphure(Global.amphureModel?.id);
//
//     Global.provinceNotifier = ValueNotifier<ProvinceModel>(
//         Global.provinceModel ??
//             ProvinceModel(id: 0, nameTh: 'เลือกจังหวัด'));
//     Global.amphureNotifier = ValueNotifier<AmphureModel>(
//         Global.amphureModel ?? AmphureModel(id: 0, nameTh: 'เลือกอำเภอ'));
//     Global.tambonNotifier = ValueNotifier<TambonModel>(
//         Global.tambonModel ?? TambonModel(id: 0, nameTh: 'เลือกตำบล'));
//   }
//
//   Widget displayOCRResult() {
//     if (isLoading) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(strokeWidth: 3),
//             SizedBox(height: 16),
//             Text(
//               'กำลังประมวลผลข้อมูล...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (ocrResult == null && errorMessage.isEmpty) {
//       return const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.credit_card,
//               size: 64,
//               color: Colors.grey,
//             ),
//             SizedBox(height: 16),
//             Text(
//               'ยังไม่มีผลลัพธ์',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     if (errorMessage.isNotEmpty) {
//       return Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.red.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.error, color: Colors.red.shade700),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Text(
//                       errorMessage,
//                       style: TextStyle(
//                         color: Colors.red.shade700,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             if (rawOcrText.isNotEmpty) ...[
//               const SizedBox(height: 16),
//               ExpansionTile(
//                 title: const Text('Raw OCR Text (Debug)'),
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade100,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       rawOcrText,
//                       style: const TextStyle(fontFamily: 'monospace'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//         ),
//       );
//     }
//
//     // Display results
//     final keyFields = {
//       'id_number': 'เลขบัตรประชาชน',
//       'th_name': 'ชื่อ (ไทย)',
//       'en_name': 'ชื่อ (อังกฤษ)',
//       'th_dob': 'วันเกิด',
//       'address': 'ที่อยู่',
//       'th_issue': 'วันออกบัตร',
//       'th_expire': 'วันหมดอายุ',
//     };
//
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.green.shade200),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.check_circle, color: Colors.green.shade700),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'ประมวลผลสำเร็จ',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           ...keyFields.entries.map((field) {
//             final value = ocrResult![field.key];
//             if (value == null || value.toString().isEmpty) return const SizedBox.shrink();
//
//             return Container(
//               margin: const EdgeInsets.only(bottom: 8),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.grey.shade200),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 5,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Icon(
//                       _getIconForField(field.key),
//                       color: Colors.blue.shade700,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           field.value,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           value.toString(),
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }).toList(),
//
//           if (rawOcrText.isNotEmpty) ...[
//             const SizedBox(height: 16),
//             ExpansionTile(
//               title: const Text('Raw OCR Text (Debug)'),
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade100,
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     rawOcrText,
//                     style: const TextStyle(fontFamily: 'monospace'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   IconData _getIconForField(String field) {
//     switch (field) {
//       case 'id_number':
//         return Icons.badge;
//       case 'th_name':
//       case 'en_name':
//         return Icons.person;
//       case 'th_dob':
//         return Icons.cake;
//       case 'address':
//         return Icons.home;
//       case 'th_issue':
//       case 'th_expire':
//         return Icons.calendar_today;
//       default:
//         return Icons.info;
//     }
//   }
//
//   Widget _buildImageWidget() {
//     if (_selectedFile != null) {
//       if (kIsWeb && _selectedFile!.bytes != null) {
//         return Image.memory(
//           _selectedFile!.bytes!,
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return const Center(
//               child: Icon(
//                 Icons.error,
//                 color: Colors.red,
//                 size: 50,
//               ),
//             );
//           },
//         );
//       } else if (_selectedFile!.path!.isNotEmpty) {
//         return Image.file(
//           File(_selectedFile!.path!),
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) {
//             return const Center(
//               child: Icon(
//                 Icons.error,
//                 color: Colors.red,
//                 size: 50,
//               ),
//             );
//           },
//         );
//       }
//     } else if (_pickedImage != null) {
//       return Image.file(
//         File(_pickedImage!.path),
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return const Center(
//             child: Icon(
//               Icons.error,
//               color: Colors.red,
//               size: 50,
//             ),
//           );
//         },
//       );
//     }
//     return const Center(
//       child: Icon(
//         Icons.image_not_supported,
//         color: Colors.grey,
//         size: 50,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: CustomAppBar(
//         height: 300,
//         child: TitleContent(
//           backButton: true,
//           title: Padding(
//             padding: const EdgeInsets.only(left: 18.0, right: 20),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Thai ID Card OCR",
//                     style: TextStyle(
//                         fontSize: 30,
//                         color: Colors.white,
//                         fontWeight: FontWeight.w900)),
//               ],
//             ),
//           ),
//         ),
//       ),
//       body: AnimatedBuilder(
//         animation: _slideAnimation ?? const AlwaysStoppedAnimation(0.0),
//         builder: (context, child) {
//           return Transform.translate(
//             offset: Offset(0, _slideAnimation?.value ?? 0),
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton.icon(
//                           onPressed: pickImageFile,
//                           icon: const Icon(Icons.add_photo_alternate, size: 24),
//                           label: const Text(
//                             'เลือกรูปบัตรประชาชน',
//                             style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue.shade600,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 2,
//                           ),
//                         ),
//                       ),
//
//                       if (_selectedFile != null || _pickedImage != null) ...[
//                         const SizedBox(height: 16),
//                         Container(
//                           padding: const EdgeInsets.all(12),
//                           decoration: BoxDecoration(
//                             color: Colors.green.shade50,
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.green.shade200),
//                           ),
//                           child: Row(
//                             children: [
//                               Icon(Icons.check_circle, color: Colors.green.shade700),
//                               const SizedBox(width: 8),
//                               Expanded(
//                                 child: Text(
//                                   _selectedFile != null
//                                       ? 'ไฟล์: ${_selectedFile!.name}'
//                                       : 'รูปภาพ: ${_pickedImage!.name}',
//                                   style: TextStyle(
//                                     color: Colors.green.shade700,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//
//                       if (_selectedFile != null || _pickedImage != null) ...[
//                         const SizedBox(height: 16),
//                         Container(
//                           height: 180,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: _buildImageWidget(),
//                           ),
//                         ),
//                       ],
//
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         width: double.infinity,
//                         height: 56,
//                         child: ElevatedButton.icon(
//                           onPressed: (_selectedFile != null || _pickedImage != null)
//                               ? processImageWithTesseract
//                               : null,
//                           icon: isLoading
//                               ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                               : const Icon(Icons.upload_file, size: 24),
//                           label: Text(
//                             isLoading ? 'กำลังประมวลผล...' : 'ประมวลผลข้อมูล',
//                             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.orange.shade600,
//                             foregroundColor: Colors.white,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 2,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 Expanded(
//                   child: Container(
//                     width: double.infinity,
//                     decoration: const BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(24),
//                         topRight: Radius.circular(24),
//                       ),
//                     ),
//                     child: displayOCRResult(),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           child: SizedBox(
//             width: double.infinity,
//             height: 56,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 if (ocrResult == null || ocrResult!.isEmpty) {
//                   Alert.warning(context, 'Warning'.tr(),
//                       'กรุณาแนบบัตรประจำตัวประชาชนก่อน', 'OK'.tr(),
//                       action: () {});
//                   return;
//                 }
//                 if (ocrResult!['id_number'] == null ||
//                     ocrResult!['id_number'].toString().length < 13) {
//                   Alert.info(
//                     context,
//                     'Warning'.tr(),
//                     'หมายเลขบัตรประจำตัวไม่ถูกต้องหรือไม่ครบ 13 หลัก: ${ocrResult!['id_number'] ?? 'ไม่พบ'} \nคุณแน่ใจว่าจะดำเนินการต่อ?',
//                     'OK'.tr(),
//                     action: () {
//                       Navigator.of(context).pop(ocrResult);
//                     },
//                   );
//                 } else {
//                   Navigator.of(context).pop(ocrResult);
//                 }
//               },
//               icon: const Icon(Icons.check, size: 24),
//               label: const Text(
//                 'ยืนยันข้อมูล',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.teal.shade600,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 2,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }