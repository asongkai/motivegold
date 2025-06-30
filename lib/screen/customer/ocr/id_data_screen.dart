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
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/button/kcl_button.dart';

class IDCardOCRScreen extends StatefulWidget {
  const IDCardOCRScreen({super.key});

  @override
  IDCardOCRScreenState createState() => IDCardOCRScreenState();
}

class IDCardOCRScreenState extends State<IDCardOCRScreen> {
  PlatformFile? _selectedFile;
  XFile? _pickedImage; // For mobile fallback
  final ImagePicker _imagePicker = ImagePicker();
  Map<String, dynamic>? ocrResult;
  bool isLoading = false;
  String errorMessage = '';

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
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เลือกแหล่งที่มาของภาพ'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromSource(ImageSource.gallery);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.photo_library, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('แกลเลอรี่'),
                ],
              ),
            ),
            if (!kIsWeb)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _pickImageFromSource(ImageSource.camera);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Icon(Icons.camera_alt, color: Colors.green),
                    SizedBox(width: 8),
                    Text('กล้องถ่ายรูป'),
                  ],
                ),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: const [
                  Icon(Icons.cancel, color: Colors.red),
                  SizedBox(width: 8),
                  Text('ยกเลิก', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        );
      },
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
      return const Center(child: CircularProgressIndicator());
    }

    if (ocrResult == null && errorMessage.isEmpty) {
      return const Text("No result yet.");
    }

    if (errorMessage.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          errorMessage,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow(
                    Icons.badge, 'ID Number', ocrResult?['id_number']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(
                    Icons.person, 'Name (TH)', ocrResult?['th_name']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(
                    Icons.person_outline, 'Name (EN)', ocrResult?['en_name']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(
                    Icons.cake, 'Date of Birth', ocrResult?['th_dob']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.home, 'Address', ocrResult?['address']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(
                    Icons.calendar_month, 'Issue Date', ocrResult?['th_issue']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.calendar_today, 'Expire Date',
                    ocrResult?['th_expire']),
              ],
            ),
          ),
        ),
      ),
    );
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

  Widget _buildResultRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value?.toString() ?? '-',
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thai ID Card OCR")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: pickImageFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text(
                      "เลือกไฟล์รูปภาพ",
                      style: TextStyle(fontSize: 25),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("ไฟล์ที่เลือก: ${_selectedFile!.name}"),
                        Text(
                            "ขนาด: ${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB"),
                      ],
                    ),
                  ),
                if (_pickedImage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("ภาพที่เลือก: ${_pickedImage!.name}"),
                  ),
                if (_selectedFile != null || _pickedImage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: MediaQuery.of(context).size.height * 2 / 6,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildImageWidget(),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: (_selectedFile != null || _pickedImage != null)
                      ? uploadImageToOCR
                      : null,
                  icon: const Icon(Icons.upload_file),
                  label: const Text(
                    "อัพโหลด & OCR",
                    style: TextStyle(fontSize: 25),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(child: displayOCRResult()),
              ],
            ),
          ),
        ),
      ),
      persistentFooterButtons: [
        ElevatedButton.icon(
          onPressed: () {
            // Global.printLongString(ocrResult.toString());
            Navigator.of(context).pop(ocrResult);
          },
          icon: const Icon(
            Icons.check_box,
            size: 45,
          ),
          label: const Text("Confirm"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
          ),
        ),
      ],
    );
  }
}
