import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class KycFileAttachment extends StatefulWidget {
  final String label;
  final List<PlatformFile> files;
  final PlatformFile? selectedFile;
  final Function(PlatformFile) onFileAdded;
  final Function(PlatformFile) onFileDeleted;
  final Function(PlatformFile?) onFileSelected;

  const KycFileAttachment({
    Key? key,
    required this.label,
    required this.files,
    this.selectedFile,
    required this.onFileAdded,
    required this.onFileDeleted,
    required this.onFileSelected,
  }) : super(key: key);

  @override
  State<KycFileAttachment> createState() => _KycFileAttachmentState();
}

class _KycFileAttachmentState extends State<KycFileAttachment> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    removeOverlay();
    super.dispose();
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        PlatformFile file = result.files.first;
        widget.onFileAdded(file);
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  void _showDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          removeOverlay();
          setState(() {});
        },
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
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
                    child: widget.files.isEmpty
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
                            itemCount: widget.files.length,
                            itemBuilder: (context, index) {
                              final file = widget.files[index];
                              final isSelected =
                                  widget.selectedFile?.name == file.name;

                              return InkWell(
                                onTap: () {
                                  widget.onFileSelected(file);
                                  removeOverlay();
                                  setState(() {});
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

                                      // File info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
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
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())} • ${_formatFileSize(file.size)}',
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
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown for file selection
        Expanded(
          child: CompositedTransformTarget(
            link: _layerLink,
            child: InkWell(
              onTap: widget.files.isEmpty
                  ? null
                  : () {
                      if (_overlayEntry == null) {
                        _showDropdown();
                      } else {
                        removeOverlay();
                      }
                      setState(() {});
                    },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      child: widget.selectedFile != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedFile!.name,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[800],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                Text(
                                  '${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              widget.label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                    ),
                    if (widget.files.isNotEmpty)
                      Icon(
                        _overlayEntry == null
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up,
                        color: Colors.grey[600],
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Add button
        ElevatedButton(
          onPressed: _pickFile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00897B),
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save, size: 18),
              const SizedBox(width: 6),
              Text('เพิ่ม', style: TextStyle(fontSize: 12.sp)),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Delete button
        ElevatedButton(
          onPressed: widget.selectedFile != null
              ? () {
                  widget.onFileDeleted(widget.selectedFile!);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[400],
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[300],
            minimumSize: const Size(0, 48),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete, size: 18),
              const SizedBox(width: 6),
              Text('ลบ', style: TextStyle(fontSize: 12.sp)),
            ],
          ),
        ),
      ],
    );
  }
}
