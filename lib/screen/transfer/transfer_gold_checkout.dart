import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/model/transfer_detail.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/screen_utils.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/list_tile_data.dart';
import 'package:motivegold/widget/price_breakdown.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:sizer/sizer.dart';

// Platform-specific imports
import 'package:motivegold/widget/payment/web_file_picker.dart' if (dart.library.io) 'package:motivegold/widget/payment/mobile_file_picker.dart';

class TransferGoldCheckOutScreen extends StatefulWidget {
  const TransferGoldCheckOutScreen({super.key});

  @override
  State<TransferGoldCheckOutScreen> createState() =>
      _TransferGoldCheckOutScreenState();
}

class _TransferGoldCheckOutScreenState extends State<TransferGoldCheckOutScreen>
    with SingleTickerProviderStateMixin {
  int currentIndex = 1;
  String actionText = 'change'.tr();
  TextEditingController discountCtrl = TextEditingController();
  File? _image;
  String? _imageWeb; // Local variable for web image
  final picker = ImagePicker();

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController?.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  //Image Picker function to get image from gallery
  Future getImageFromGallery() async {
    if (!kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      try {
        final result = await WebFilePicker.pickImage();
        if (result != null) {
          setState(() {
            _imageWeb = result;
          });
        }
      } catch (e) {
        if (mounted) {
          Alert.warning(context, "Error", "Failed to select image: $e", "OK",
              action: () {});
        }
      }
    }
  }

  //Image Picker function to get image from camera
  Future getImageFromCamera() async {
    if (!kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      Alert.warning(context, "ไม่รองรับ", "การถ่ายภาพจากกล้องบนเว็บยังไม่พร้อมใช้งาน", "OK",
          action: () {});
    }
  }

  Future showOptions() async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('คลังภาพ'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('ถ่ายรูป'),
            onPressed: () {
              Navigator.of(context).pop();
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Screen? size = Screen(MediaQuery.of(context).size);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 6,
                  child: Text(
                    "ยืนยันการโอน",
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ขั้นตอนสุดท้าย',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Global.transfer == null
              ? const ModernEmptyState()
              : _fadeAnimation != null
              ? FadeTransition(
            opacity: _fadeAnimation!,
            child: _buildContent(),
          )
              : _buildContent(),
        ),
      ),
      persistentFooterButtons: [
        _buildModernFooterButton(),
      ],
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: getProportionateScreenWidth(16.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTransferInfoSection(),
            const SizedBox(height: 16),
            _buildTransferItemsSection(),
            const SizedBox(height: 16),
            _buildSummarySection(),
            const SizedBox(height: 16),
            _buildAttachmentSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'ข้อมูลการโอน',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.inventory,
                  label: 'จาก',
                  value: Global.transfer?.fromBinLocationName ?? '',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.inventory_2,
                  label: 'ไป',
                  value: Global.transfer?.toBinLocationName ?? '',
                ),
                if (Global.transfer?.toBranchName?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.business,
                    label: 'สาขาปลายทาง',
                    value: Global.transfer?.toBranchName ?? '',
                  ),
                ],
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.category,
                  label: 'ประเภทการโอน',
                  value: Global.transfer?.transferType == 'BRANCH' ? 'โอนระหว่างสาขา' : 'โอนภายในสาขา',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferItemsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.list_alt,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'รายการสินค้า',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${Global.transfer?.details?.length ?? 0} รายการ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFF0F766E),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: Global.transfer?.details?.length ?? 0,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _itemOrderList(
                  transfer: Global.transfer!,
                  detail: Global.transfer!.details![index],
                  index: index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemOrderList({
    required TransferModel transfer,
    required TransferDetailModel detail,
    required int index,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.productName ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getTransferDisplayText(transfer),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildDetailChip(
                      '${formatter.format(detail.weight)} กรัม',
                      const Color(0xFF059669),
                    ),
                    const SizedBox(width: 8),
                    _buildDetailChip(
                      '${formatter.format(detail.weightBath)} บาททอง',
                      const Color(0xFFEA580C),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () => removeProduct(index),
              icon: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
              ),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'สรุปยอดรวม',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                PriceBreakdown(
                  title: 'น้ำหนักรวม',
                  price: '${formatter.format(Global.getTransferWeightTotalAmount())} กรัม',
                ),
                const SizedBox(height: 8),
                PriceBreakdown(
                  title: 'บาททองรวม',
                  price: '${formatter.format(Global.getTransferWeightTotalAmount() / getUnitWeightValue())} บาททอง',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_file,
                  color: Color(0xFF0F766E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'เอกสารที่แนบมา',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                _buildImageSelector(),
                const SizedBox(height: 16),
                _buildImagePreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelector() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: showOptions,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_a_photo_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'เลือกรูปภาพ',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    bool hasImage = _image != null || _imageWeb != null;

    if (!hasImage) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'ไม่ได้เลือกรูปภาพ',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              width: double.infinity,
              child: kIsWeb && _imageWeb != null
                  ? Image.memory(
                base64Decode(_imageWeb!.split(",").last),
                fit: BoxFit.cover,
              )
                  : _image != null
                  ? Image.file(
                _image!,
                fit: BoxFit.cover,
              )
                  : Container(),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _image = null;
                      _imageWeb = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
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

  Widget _buildModernFooterButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        height: 70,
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF0F766E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: const Color(0xFF0F766E).withOpacity(0.3),
          ),
          onPressed: _handleSaveTransfer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "บันทึก".tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.save_alt_outlined,
                color: Colors.white,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSaveTransfer() async {
    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          Global.transfer!.id = 0;
          Global.transfer!.createdDate = DateTime.now();
          Global.transfer!.updatedDate = DateTime.now();
          Global.transfer!.customerId =
          Global.customer == null ? 0 : Global.customer!.id!;
          Global.transfer!.attachement = getTransferAttachment();

          for (var j = 0; j < Global.transfer!.details!.length; j++) {
            Global.transfer!.details![j].id = 0;
            Global.transfer!.details![j].transferId = Global.transfer!.id;
            Global.transfer!.details![j].createdDate = DateTime.now();
            Global.transfer!.details![j].updatedDate = DateTime.now();
          }

          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal,
              isDismissible: true,
              showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            var result = await ApiServices.post(
                '/transfer', Global.requestObj(Global.transfer));

            if (result!.status == "success") {
              var transfer = transferModelFromJson(jsonEncode(result.data));
              int? transferId = transfer.id;
              await Future.forEach<TransferDetailModel>(
                  Global.transfer!.details!, (f) async {
                f.transferId = transferId;
                var detail = (transfer.transferType == 'INTERNAL')
                    ? await ApiServices.post(
                    '/transferdetail', Global.requestObj(f))
                    : await ApiServices.post('/transferdetail/between-branch',
                    Global.requestObj(f));
                if (detail?.status == "success") {
                  print("Order completed");
                }
              });
              await pr.hide();
              if (mounted) {
                Alert.success(context, 'Success'.tr(), "", 'OK'.tr(),
                    action: () {
                      Global.transfer!.details!.clear();
                      Global.transfer = null;
                      Global.transferDetail!.clear();
                      Global.customer = null;
                      _image = null;
                      _imageWeb = null;
                      setState(() {});
                      Navigator.of(context).pop();
                    });
              }
            } else {
              await pr.hide();
              Alert.warning(context, 'Warning'.tr(), result.message ?? '', 'OK'.tr(),
                  action: () {});
            }
          } catch (e) {
            await pr.hide();
            if (mounted) {
              Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
                  action: () {});
            }
            return;
          }
        });
  }

  String? getTransferAttachment() {
    if (!kIsWeb && _image != null) {
      return Global.imageToBase64(_image!);
    }

    if (kIsWeb && _imageWeb != null) {
      return _imageWeb;
    }

    return null;
  }

  String _getTransferDisplayText(TransferModel transfer) {
    // Debug: Check what transfer type and data we have
    print('Transfer Type: ${transfer.transferType}');
    print('To Branch Name: ${transfer.toBranchName}');
    print('From Location: ${transfer.fromBinLocationName}');
    print('To Location: ${transfer.toBinLocationName}');

    // For BRANCH transfers - show: From Location → Branch Name (To Location)
    if (transfer.transferType == 'BRANCH' &&
        transfer.toBranchName != null &&
        transfer.toBranchName!.isNotEmpty &&
        transfer.toBranchName != '') {
      return '${transfer.fromBinLocationName} → ${transfer.toBranchName} (${transfer.toBinLocationName})';
    }
    // For INTERNAL transfers - show: From Location → To Location
    else {
      return '${transfer.fromBinLocationName} → ${transfer.toBinLocationName}';
    }
  }

  void removeProduct(int i) async {
    Global.transfer!.details!.removeAt(i);
    if (Global.transfer!.details!.isEmpty) {
      Global.transfer = null;
    }
    Future.delayed(const Duration(milliseconds: 500), () async {
      setState(() {});
    });
  }
}

class ModernEmptyState extends StatelessWidget {
  const ModernEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.swap_horiz_outlined,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ไม่มีข้อมูลการโอน',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'กรุณาเพิ่มรายการสินค้าก่อนดำเนินการ',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}