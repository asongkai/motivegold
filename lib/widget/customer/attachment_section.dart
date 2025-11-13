import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:motivegold/utils/constants.dart';

class CustomerAttachment {
  final int id;
  final String fileName;
  final int fileSize;
  final String? mimeType;
  final DateTime? attachmentDate;
  final DateTime uploadedDate;

  CustomerAttachment({
    required this.id,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    this.attachmentDate,
    required this.uploadedDate,
  });

  factory CustomerAttachment.fromJson(Map<String, dynamic> json) {
    return CustomerAttachment(
      id: json['id'],
      fileName: json['fileName'],
      fileSize: json['fileSize'],
      mimeType: json['mimeType'],
      attachmentDate: json['attachmentDate'] != null
          ? DateTime.parse(json['attachmentDate'])
          : null,
      uploadedDate: DateTime.parse(json['uploadedDate']),
    );
  }
}

class AttachmentSection extends StatefulWidget {
  final String title;
  final String attachmentType; // 'Occupation', 'RiskAssessment', 'Photo'
  final int? customerId;
  final Function(List<CustomerAttachment>)? onAttachmentsChanged;

  const AttachmentSection({
    Key? key,
    required this.title,
    required this.attachmentType,
    this.customerId,
    this.onAttachmentsChanged,
  }) : super(key: key);

  @override
  State<AttachmentSection> createState() => _AttachmentSectionState();
}

class _AttachmentSectionState extends State<AttachmentSection> {
  List<CustomerAttachment> _attachments = [];
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadAttachments();
    }
  }

  Future<void> _loadAttachments() async {
    if (widget.customerId == null) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse(
            '${Constants.BACKEND_URL}/api/customer/attachment/${widget.customerId}?type=${widget.attachmentType}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _attachments = (data['data'] as List)
                .map((json) => CustomerAttachment.fromJson(json))
                .toList();
          });
          widget.onAttachmentsChanged?.call(_attachments);
        }
      }
    } catch (e) {
      print('Error loading attachments: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: widget.attachmentType == 'Photo'
          ? FileType.image
          : FileType.custom,
      allowedExtensions: widget.attachmentType == 'Photo'
          ? null
          : ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      await _uploadFile(result.files.first);
    }
  }

  Future<void> _uploadFile(PlatformFile file) async {
    if (widget.customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาบันทึกข้อมูลลูกค้าก่อนอัปโหลดไฟล์'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${Constants.BACKEND_URL}/api/customer/attachment/${widget.customerId}'),
      );

      // Add file
      if (file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', file.path!),
        );
      }

      // Add fields
      request.fields['attachmentType'] = widget.attachmentType;
      request.fields['attachmentDate'] =
          (_selectedDate ?? DateTime.now()).toIso8601String();

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('อัปโหลดไฟล์สำเร็จ'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadAttachments();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAttachment(int attachmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: const Text('คุณต้องการลบไฟล์นี้หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.delete(
        Uri.parse('${Constants.BACKEND_URL}/api/customer/attachment/$attachmentId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ลบไฟล์สำเร็จ'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadAttachments();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF424242),
          ),
        ),
        const SizedBox(height: 12),

        // Attachment list
        if (_attachments.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: _attachments.map((attachment) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      // File icon
                      Icon(
                        attachment.mimeType?.startsWith('image/') == true
                            ? Icons.image
                            : Icons.insert_drive_file,
                        color: Colors.blue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),

                      // File name and date
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              attachment.fileName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${DateFormat('dd/MM/yyyy').format(attachment.attachmentDate ?? attachment.uploadedDate)} • ${_formatFileSize(attachment.fileSize)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        color: Colors.red,
                        onPressed: () => _deleteAttachment(attachment.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Add file row
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Date picker
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'วันที่ Attachment',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedDate != null
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Add button
            Flexible(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add, size: 18),
                label: const Text('เพิ่ม'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00897B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Help text
        Text(
          widget.attachmentType == 'Photo'
              ? 'รองรับไฟล์: JPG, PNG (ขนาดไม่เกิน 10 MB)'
              : 'รองรับไฟล์: PDF, DOC, DOCX, JPG, PNG (ขนาดไม่เกิน 10 MB)',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
