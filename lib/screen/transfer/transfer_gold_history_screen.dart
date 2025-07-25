import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/transfer.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:sizer/sizer.dart';

class TransferGoldHistoryScreen extends StatefulWidget {
  const TransferGoldHistoryScreen({super.key});

  @override
  State<TransferGoldHistoryScreen> createState() =>
      _TransferGoldHistoryScreenState();
}

class _TransferGoldHistoryScreenState extends State<TransferGoldHistoryScreen> {
  bool loading = false;
  List<TransferModel>? list = [];
  Screen? size;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      var result =
      await ApiServices.post('/transfer/all', Global.reportRequestObj(null));
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
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายการประวัติการโอนทอง",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const LoadingProgress()
            : list!.isEmpty
            ? const Center(child: NoDataFoundWidget())
            : Container(
          padding: const EdgeInsets.all(16.0),
          child: ListView.separated(
            itemCount: list!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              return modernTransferCard(list![index], index);
            },
          ),
        ),
      ),
    );
  }

  Widget modernTransferCard(TransferModel transfer, int index) {
    final isInterBranch = transfer.toBranchId != null && transfer.toBranchId != 0;
    final canCancel = transfer.toBranchId != null &&
        transfer.toBranchId != 0 &&
        transfer.status == 'PENDING' &&
        transfer.toBranchId != Global.user!.branchId;

    return Container(
      decoration: BoxDecoration(
        color: transfer.status == 'PENDING' ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: transfer.status == 'PENDING'
            ? Border.all(color: Colors.orange[200]!, width: 1)
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header with Status Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isInterBranch
                        ? Colors.teal.withOpacity(0.1)
                        : Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isInterBranch
                        ? Icons.swap_horiz_rounded
                        : Icons.transform_rounded,
                    color: isInterBranch ? Colors.teal : Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${transfer.transferId.toString()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatThaiDate(transfer.transferDate.toString()),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status and Type Badges
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Status Badge
                    if (transfer.status == 'PENDING' ||
                        transfer.status == 'CANCEL' ||
                        transfer.status == 'REJECT')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transfer.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getStatusColor(transfer.status),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getStatusIcon(transfer.status),
                              size: 12,
                              color: _getStatusColor(transfer.status),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              transfer.status ?? 'N/A',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _getStatusColor(transfer.status),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Transfer Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isInterBranch
                            ? Colors.teal.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isInterBranch ? 'โอนระหว่างสาขา' : 'โอนภายใน',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isInterBranch ? Colors.teal[700] : Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Transfer Details
            if (transfer.details != null && transfer.details!.isNotEmpty) ...[
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildTableHeader('สินค้า', Icons.inventory_2_rounded),
                          ),
                          Expanded(
                            flex: 2,
                            child: _buildTableHeader('น้ำหนัก', Icons.scale_rounded),
                          ),
                          Expanded(
                            flex: 4,
                            child: _buildTableHeader('เส้นทางการโอน', Icons.route_rounded),
                          ),
                        ],
                      ),
                    ),

                    // Transfer Detail Rows
                    ...transfer.details!.asMap().entries.map((entry) {
                      int idx = entry.key;
                      var detail = entry.value;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: idx % 2 == 0 ? Colors.white : Colors.grey[25],
                          borderRadius: idx == transfer.details!.length - 1
                              ? const BorderRadius.only(
                            bottomLeft: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          )
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Product Name
                            Expanded(
                              flex: 3,
                              child: Text(
                                detail.product?.name ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            // Weight
                            Expanded(
                              flex: 2,
                              child: Text(
                                formatter.format(detail.weight ?? 0),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ),

                            // Transfer Route
                            Expanded(
                              flex: 4,
                              child: _buildTransferRoute(transfer),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],

            // Action Button
            if (canCancel) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => cancel(transfer),
                  icon: const Icon(Icons.cancel_rounded, size: 18),
                  label: const Text(
                    'ยกเลิกการโอน',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransferRoute(TransferModel transfer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source
        _buildRouteInfo(
          'ต้นทาง',
          '${transfer.toBranchId != null && transfer.toBranchId != 0 ? 'สาขา ${transfer.toBranchName ?? 'N/A'}' : ''} คลัง ${transfer.fromBinLocation?.name ?? 'N/A'}',
          Colors.orange,
          Icons.location_on_rounded,
        ),
        const SizedBox(height: 8),
        // Destination
        _buildRouteInfo(
          'ปลายทาง',
          '${transfer.toBranchId != null && transfer.toBranchId != 0 ? 'สาขา ${transfer.toBranchName ?? 'N/A'}' : ''} คลัง ${transfer.toBinLocation?.name ?? 'N/A'}',
          Colors.green,
          Icons.flag_rounded,
        ),
      ],
    );
  }

  Widget _buildRouteInfo(String label, String location, Color color, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 12,
            color: color,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$label:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              Text(
                location,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCEL':
      case 'REJECT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toUpperCase()) {
      case 'PENDING':
        return Icons.pending_actions_rounded;
      case 'COMPLETED':
        return Icons.check_circle_rounded;
      case 'CANCEL':
      case 'REJECT':
        return Icons.cancel_rounded;
      default:
        return Icons.help_rounded;
    }
  }

  void removeProduct(int id, int i) async {
    final ProgressDialog pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    await pr.show();
    pr.update(message: 'processing'.tr());
    try {
      var result = await ApiServices.delete('/product', id);
      await pr.hide();
      if (result?.status == "success") {
        list!.removeAt(i);
        setState(() {});
      } else {
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
              action: () {});
        }
      }
    } catch (e) {
      await pr.hide();
      if (mounted) {
        Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
            action: () {});
      }
    }
  }

  void cancel(TransferModel transfer) async {
    try {
      Alert.info(
          context, 'คุณแน่ใจที่จะยกเลิกการทำธุรกรรมนี้หรือไม่?', '', 'ตกลง',
          action: () async {
            final ProgressDialog pr = ProgressDialog(context,
                type: ProgressDialogType.normal,
                isDismissible: true,
                showLogs: true);
            await pr.show();
            pr.update(message: 'processing'.tr());
            var result = await ApiServices.post(
                '/transfer/between-branch-cancel', Global.requestObj(transfer));
            await pr.hide();
            if (result?.status == "success") {
              loadData();
            } else {
              if (mounted) {}
            }
          });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // Helper method to format Thai date
  String _formatThaiDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      String day = date.day.toString().padLeft(2, '0');
      String monthName = _getThaiMonthName(date.month);
      String year = (date.year + 543).toString(); // Convert to Buddhist year
      String time = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

      return '$day $monthName $year เวลา $time น.';
    } catch (e) {
      return Global.formatDate(dateString); // Fallback to original format
    }
  }

  // Helper method to get Thai month names
  String _getThaiMonthName(int month) {
    const thaiMonths = [
      '', // Index 0 (not used)
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return month > 0 && month <= 12 ? thaiMonths[month] : 'ไม่ระบุ';
  }
}