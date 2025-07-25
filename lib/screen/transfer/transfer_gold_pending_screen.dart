import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';

class TransferGoldPendingScreen extends StatefulWidget {
  const TransferGoldPendingScreen({super.key});

  @override
  State<TransferGoldPendingScreen> createState() =>
      _TransferGoldPendingScreenState();
}

class _TransferGoldPendingScreenState extends State<TransferGoldPendingScreen>
    with SingleTickerProviderStateMixin {
  bool loading = false;
  List<TransferModel>? list = [];
  Screen? size;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    loadData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result = await ApiServices.post(
          '/transfer/other-branch/all', Global.requestObj(null));
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<TransferModel> products = transferListModelFromJson(data);
        setState(() {
          list = products;
        });
      } else {
        list = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = Screen(MediaQuery.of(context).size);
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
                    "รายการโอนทองรอรับ",
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
                          Icons.pending_actions,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${list?.length ?? 0} รายการ',
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
        child: loading
            ? const ModernLoadingWidget()
            : list!.isEmpty
            ? const ModernEmptyState()
            : FadeTransition(
          opacity: _fadeAnimation,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await loadData();
      },
      color: const Color(0xFF0F766E),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 20),
            _buildTransferList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    int pendingCount = list?.where((e) => e.status == 'PENDING' &&
        (e.transferType != 'INTERNAL' && (e.toBranchId != null && e.toBranchId != 0))).length ?? 0;
    int successCount = list?.where((e) => e.status == 'SUCCESS').length ?? 0;
    int internalCount = list?.where((e) => e.transferType == 'INTERNAL' ||
        (e.toBranchId == null || e.toBranchId == 0)).length ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F766E),
            const Color(0xFF14B8A6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.transfer_within_a_station,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'การโอนทองระหว่างสาขา',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'จัดการรายการที่ส่งมาจากสาขาอื่น',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.pending_actions,
                  title: 'รอดำเนินการ',
                  count: pendingCount,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.swap_horiz,
                  title: 'ภายในสาขา',
                  count: internalCount,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  icon: Icons.check_circle,
                  title: 'เสร็จสิ้น',
                  count: successCount,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransferList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list!.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return _buildModernTransferCard(list![index], index);
      },
    );
  }

  Widget _buildModernTransferCard(TransferModel transfer, int index) {
    bool isPending = transfer.status == 'PENDING';
    bool isSuccess = transfer.status == 'SUCCESS';
    bool isInternalTransfer = transfer.transferType == 'INTERNAL' ||
        (transfer.toBranchId == null || transfer.toBranchId == 0);

    return Container(
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
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isInternalTransfer
                  ? Colors.blue.withOpacity(0.05)
                  : isPending
                  ? Colors.orange.withOpacity(0.05)
                  : Colors.green.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isInternalTransfer
                        ? Colors.blue
                        : isPending ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isInternalTransfer
                        ? Icons.swap_horiz
                        : isPending ? Icons.pending_actions : Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${transfer.transferId}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isInternalTransfer)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Text(
                                'ภายในสาขา',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Global.formatDate(transfer.transferDate.toString()),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isInternalTransfer
                        ? Colors.blue
                        : isPending ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isInternalTransfer
                        ? 'โอนภายใน'
                        : isPending ? 'รอดำเนินการ' : 'เสร็จสิ้น',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transfer Route Info
          Container(
            padding: const EdgeInsets.all(20),
            child: _buildTransferRoute(transfer),
          ),

          // Items List
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'รายการสินค้า',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      // Header row
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isInternalTransfer ? Colors.blue : const Color(0xFF0F766E),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                'สินค้า',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                'น้ำหนัก',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                'คลังสินค้า',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Data rows
                      ...transfer.details!.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var detail = entry.value;
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: idx % 2 == 0 ? Colors.white : const Color(0xFFF8FAFC),
                            borderRadius: idx == transfer.details!.length - 1
                                ? const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            )
                                : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  detail.product?.name ?? '',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${formatter.format(detail.weight!)} กรัม',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: const Color(0xFF374151),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: _buildWarehouseInfo(transfer),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Section
          _buildActionSection(transfer, isInternalTransfer, isPending, isSuccess),
        ],
      ),
    );
  }

  Widget _buildActionSection(TransferModel transfer, bool isInternalTransfer, bool isPending, bool isSuccess) {
    if (isInternalTransfer) {
      // For internal transfers - show info message
      return Container(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'การโอนภายในสาขา',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'การโอนนี้เกิดขึ้นภายในสาขาเดียวกัน ไม่ต้องดำเนินการรับสินค้า',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // For branch transfers - show action buttons
      if (isPending) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => confirm(transfer),
              icon: const Icon(Icons.check_circle, size: 20),
              label: Text(
                'รับสินค้า',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF0F766E).withOpacity(0.3),
              ),
            ),
          ),
        );
      } else if (isSuccess) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'รับสินค้าเรียบร้อย',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildTransferRoute(TransferModel transfer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Color(0xFF0F766E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'เส้นทางการโอน',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLocationCard(
                  title: 'ต้นทาง',
                  branch: transfer.toBranchId != null && transfer.toBranchId != 0
                      ? 'สาขา ${transfer.toBranchName}'
                      : 'สาขาปัจจุบัน',
                  warehouse: 'คลัง ${transfer.fromBinLocation?.name}',
                  isSource: true,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF0F766E),
                  size: 24,
                ),
              ),
              Expanded(
                child: _buildLocationCard(
                  title: 'ปลายทาง',
                  branch: transfer.toBranchId != null && transfer.toBranchId != 0
                      ? 'สาขา ${transfer.toBranchName}'
                      : 'สาขาปัจจุบัน',
                  warehouse: 'คลัง ${transfer.toBinLocation?.name}',
                  isSource: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String branch,
    required String warehouse,
    required bool isSource,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSource ? Colors.orange.withOpacity(0.3) : const Color(0xFF0F766E).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            branch,
            style: TextStyle(
              fontSize: 14.sp,
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            warehouse,
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseInfo(TransferModel transfer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ต้นทาง → ปลายทาง',
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${transfer.fromBinLocation?.name} → ${transfer.toBinLocation?.name}',
          style: TextStyle(
            fontSize: 12.sp,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  void confirm(TransferModel transfer) async {
    try {
      Alert.info(context, 'ต้องการรับสินค้าหรือไม่?', 'การดำเนินการนี้ไม่สามารถยกเลิกได้', 'ตกลง',
          action: () async {
            final ProgressDialog pr = ProgressDialog(context,
                type: ProgressDialogType.normal,
                isDismissible: true,
                showLogs: true);
            await pr.show();
            pr.update(message: 'กำลังดำเนินการ...');

            var result = await ApiServices.post(
                '/transfer/between-branch-confirm', Global.requestObj(transfer));
            await pr.hide();

            if (result?.status == "success") {
              if (mounted) {
                Alert.success(context, 'สำเร็จ', 'รับสินค้าเรียบร้อยแล้ว', 'ตกลง',
                    action: () {
                      loadData();
                    });
              }
            } else {
              if (mounted) {
                Alert.warning(context, 'เกิดข้อผิดพลาด',
                    result?.message ?? 'ไม่สามารถดำเนินการได้', 'ตกลง');
              }
            }
          });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      if (mounted) {
        Alert.warning(context, 'เกิดข้อผิดพลาด', e.toString(), 'ตกลง');
      }
    }
  }
}

class ModernLoadingWidget extends StatelessWidget {
  const ModernLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'กำลังโหลดข้อมูล...',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
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
              Icons.transfer_within_a_station,
              size: 60,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ไม่มีรายการโอนรอดำเนินการ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'รายการโอนจากสาขาอื่นจะปรากฏที่นี่',
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