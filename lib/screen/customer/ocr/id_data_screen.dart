import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motivegold/widget/button/kcl_button.dart';

class IDCardOCRScreen extends StatefulWidget {
  const IDCardOCRScreen({super.key});

  @override
  IDCardOCRScreenState createState() => IDCardOCRScreenState();
}

class IDCardOCRScreenState extends State<IDCardOCRScreen> {
  XFile? _image;
  final picker = ImagePicker();
  Map<String, dynamic>? ocrResult;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // Validate if it's a valid image
      final validFormat = ['jpg', 'jpeg', 'png']
          .map((e) => e.toLowerCase())
          .contains(pickedFile.name.split('.').last.toLowerCase());

      if (!validFormat) {
        setState(() {
          errorMessage = 'Invalid file format. Please select an image.';
        });
        return;
      }

      setState(() {
        _image = pickedFile;
        errorMessage = '';
      });
    }
  }

  Future<void> uploadImageToOCR() async {
    if (_image == null) return;

    setState(() {
      isLoading = true;
      ocrResult = null;
      errorMessage = '';
    });

    final apiUrl =
    Uri.parse('https://api.iapp.co.th/thai-national-id-card/v3.5/front');
    const apiKey = '4dJUaFqHvazYFqgRu0VL0eEQyakcR29i'; // Replace with your actual API key

    final request = http.MultipartRequest('POST', apiUrl)
      ..headers['apikey'] = apiKey
      ..files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        setState(() {
          ocrResult = json.decode(responseBody);
          isLoading = false;
        });
      } else {
        setState(() {
          ocrResult = null;
          errorMessage = 'Failed to fetch data: $responseBody';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        ocrResult = null;
        errorMessage = 'Exception: $e';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultRow(Icons.badge, 'ID Number', ocrResult?['id_number']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.person, 'Name (TH)', ocrResult?['th_name']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.person_outline, 'Name (EN)', ocrResult?['en_name']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.cake, 'Date of Birth', ocrResult?['th_dob']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.home, 'Address', ocrResult?['address']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.calendar_month, 'Issue Date', ocrResult?['th_issue']),
                const Divider(height: 16, thickness: 1),
                _buildResultRow(Icons.calendar_today, 'Expire Date', ocrResult?['th_expire']),
              ],
            ),
          ),
        ),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text("เลือกจากคลังรูปภาพ", style: TextStyle(fontSize: 25),),
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("ถ่ายภาพด้วยกล้องถ่ายรูป", style: TextStyle(fontSize: 25),),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_image != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("ภาพที่เลือก: ${_image!.name}"),
                  ),
                if (_image != null)
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
                      child: Image.file(File(_image!.path), fit: BoxFit.cover),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: uploadImageToOCR,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("อัพโหลด & OCR", style: TextStyle(fontSize: 25),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
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
        // KclButton(text: "Confirm", icon: Icons.check_box, onTap: () {  }, fullWidth: true,)
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.check_box, size: 45,),
          label: const Text("Confirm"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
          ),
        ),
      ],
    );
  }
}