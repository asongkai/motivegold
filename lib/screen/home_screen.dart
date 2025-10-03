import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/dummy/dummy.dart';
import 'package:motivegold/model/order.dart';
import 'package:motivegold/screen/dashboard/pawn_menu.dart';
import 'package:motivegold/screen/pos/history_screen.dart';
import 'package:motivegold/screen/pos/redeem/ui/single_redeem_history.dart';
import 'package:motivegold/screen/pos/storefront/broker/menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/paphun/menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/matching_menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/menu_screen.dart';
import 'package:motivegold/screen/pos/storefront/theng/ui-matching/matching_pending_screen.dart';
import 'package:motivegold/screen/pos/wholesale/menu_paphun_screen.dart';
import 'package:motivegold/screen/pos/wholesale/menu_theng_screen.dart';
import 'package:motivegold/screen/reports/paphun_report_menu_screen.dart';
import 'package:motivegold/screen/reports/pawn_report_menu_screen.dart';
import 'package:motivegold/screen/reports/theng_matching_report_menu_screen.dart';
import 'package:motivegold/screen/reports/theng_report_menu_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_menu_screen.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:sizer/sizer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ApiServices api = ApiServices();
  bool loading = false;
  List<OrderModel>? list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }

  void init() async {
    setState(() {
      loading = true;
    });

    Global.goldDataModel = await api.getGoldPrice(context);

    var result = await ApiServices.post(
        '/order/matching/PENDING/clear', Global.requestObj(null));
    if (result?.status == "success") {
      var data = jsonEncode(result?.data);
      List<OrderModel> products = orderListModelFromJson(data);
      setState(() {
        list = products;
      });
    } else {
      list = [];
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const CustomAppBar(
        height: 250,
        hasChild: false,
        child: TitleContent(
          backButton: false,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First section - ทองรูปพรรณ
            _buildSectionHeader('ทองรูปพรรณ'),
            SizedBox(height: 16),
            _buildMenuGrid([
              MenuItemData(
                icon: Icons.store, // Better for storefront sales
                label: 'ซื้อขายทองรูป\nพรรณหน้าร้าน',
                color: Colors.amber[600]!, // Gold color for gold jewelry
                pageBuilder: (_) =>
                const PosMenuScreen(title: 'ซื้อขายทองรูปพรรณหน้าร้าน'),
              ),
              MenuItemData(
                icon: Icons.business, // Better for wholesale business
                label: 'ซื้อขายทองกับร้าน\nขายส่ง(ทองรูปพรรณ)',
                color: Colors.orange[700]!, // Orange for wholesale
                pageBuilder: (_) =>
                const WholeSalePaphunMenuScreen(
                    title: 'ซื้อขายทองกับร้านขายส่ง(ทองรูปพรรณ)'),
              ),
              MenuItemData(
                icon: Icons.transfer_within_a_station, // Better for transfers
                label: 'โอนทอง',
                color: Colors.blue[600]!, // Blue for transfers/movement
                pageBuilder: (_) => const TransferGoldMenuScreen(),
              ),
              MenuItemData(
                icon: Icons.assessment, // Better for reports/analytics
                label: 'รายงาน\nทองรูปพรรณ',
                color: Colors.green[600]!, // Green for reports/analytics
                pageBuilder: (_) => PaphunReportMenuScreen(),
              ),
              MenuItemData(
                icon: Icons.history, // Better for transaction history
                label: 'ประวัติการ\nทำธุรกรรม',
                color: Colors.grey[600]!, // Grey for history
                pageBuilder: (_) =>
                    HistoryScreen(
                      productType: orderTypes()[0],
                    ),
              ),
            ]),

            SizedBox(height: 32),

            // Second section - ขายฝาก
            _buildSectionHeader('ขายฝาก'),
            SizedBox(height: 16),
            _buildMenuGrid([
              MenuItemData(
                icon: Icons.security, // Better for pawn/security services
                label: 'ขายฝาก',
                color: Colors.purple[600]!, // Purple for pawn services
                pageBuilder: (_) => const PawnMenuScreen(),
              ),
              MenuItemData(
                icon: Icons.gavel, // Auction/lost items
                label: 'ของหลุด',
                color: Colors.red[600]!, // Red for lost/auction items
                pageBuilder: null,
              ),
              MenuItemData(
                icon: Icons.assessment, // Reports
                label: 'รายงาน\nขายฝาก',
                color: Colors.green[600]!, // Green for reports
                pageBuilder: (_) => PawnReportMenuScreen(),
              ),
              MenuItemData(
                icon: Icons.history, // Transaction history
                label: 'ประวัติการ\nทำธุรกรรม',
                color: Colors.grey[600]!, // Grey for history
                pageBuilder: (_) => SingleRedeemHistoryScreen(
                  productType: redeemTypes()[0],
                ),
              ),
            ]),

            SizedBox(height: 32),

            // Third section - ทองคำแท่ง
            _buildSectionHeader('ทองคำแท่ง'),
            SizedBox(height: 16),
            _buildMenuGrid([
              MenuItemData(
                icon: Icons.diamond, // Gold bars - diamond represents precious items
                label: 'ซื้อขายทองแท่ง\nหน้าร้าน',
                color: Colors.amber[700]!, // Gold/amber for gold bars
                pageBuilder: (_) => const ThengSaleMenuScreen(title: 'Real'),
              ),
              MenuItemData(
                icon: Icons.business, // Wholesale business
                label: 'ซื้อขายทองกับร้าน\nขายส่ง(ทองแท่ง)',
                color: Colors.orange[700]!, // Orange for wholesale
                pageBuilder: (_) =>
                const WholeSaleThengMenuScreen(title: 'POS'),
              ),
              MenuItemData(
                icon: Icons.transfer_within_a_station, // Transfer
                label: 'โอนทอง',
                color: Colors.blue[600]!, // Blue for transfers
                pageBuilder: (_) => TransferGoldMenuScreen(),
              ),
              MenuItemData(
                icon: Icons.assessment, // Reports
                label: 'รายงาน\nทองคำแท่ง',
                color: Colors.green[600]!, // Green for reports
                pageBuilder: (_) => ThengReportMenuScreen(),
              ),
              MenuItemData(
                icon: Icons.history, // History
                label: 'ประวัติการ\nทำธุรกรรม',
                color: Colors.grey[600]!, // Grey for history
                pageBuilder: (_) =>
                    HistoryScreen(
                      productType: orderTypes()[4],
                    ),
              ),
            ]),

            SizedBox(height: 32),

            // Fourth section - ทองคำแท่ง(จับคู่)
            _buildSectionHeader('ทองคำแท่ง(จับคู่)'),
            SizedBox(height: 16),
            _buildMenuGrid([
              MenuItemData(
                icon: Icons.link, // Better for matching/pairing
                label: 'ซื้อขายทองแท่ง\n(จับคู่)',
                color: Colors.indigo[600]!, // Indigo for matching services
                pageBuilder: (_) =>
                const ThengSaleMatchingMenuScreen(title: 'Matching'),
              ),
              MenuItemData(
                icon: Icons.pending, // Pending actions
                label: 'รายการที่รอ\nดำเนินการ',
                color: Colors.orange[500]!, // Orange for pending/waiting
                pageBuilder: (_) =>
                const MatchingPendingScreen(),
              ),
              MenuItemData(
                icon: Icons.handshake, // Better for broker relations
                label: 'ซื้อขายทองแท่ง\nกับโบรกเกอร์',
                color: Colors.brown[600]!, // Brown for broker business
                pageBuilder: (_) =>
                const ThengBrokerMenuScreen(title: 'ทองคำแท่งกับโบรกเกอร์'),
              ),
              MenuItemData(
                icon: Icons.assessment, // Reports
                label: 'รายงานทอง\nคำแท่ง(จับคู่)',
                color: Colors.green[600]!, // Green for reports
                pageBuilder: (_) => ThengMatchingReportMenuScreen(),
              ),
              MenuItemData(
                icon: Icons.history, // History
                label: 'ประวัติการ\nทำธุรกรรม',
                color: Colors.grey[600]!, // Grey for history
                pageBuilder: (_) =>
                    HistoryScreen(
                      productType: orderTypes()[2],
                    ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.orange[600],
      ),
    );
  }

  Widget _buildMenuGrid(List<MenuItemData> items) {
    return Column(
      children: [
        for (int i = 0; i < items.length; i += 4)
          Padding(
            padding: EdgeInsets.only(bottom: i + 4 < items.length ? 12 : 0),
            child: IntrinsicHeight( // This is the key change!
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // Stretch children to fill vertical space
                children: [
                  for (int j = i; j < i + 4 && j < items.length; j++)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: _buildMenuItem(items[j], context),
                      ),
                    ),
                  // Fill empty spaces if less than 4 items in the row
                  for (int k = 0; k < 4 - (items.length - i).clamp(0, 4); k++)
                    Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemData item, BuildContext context) {
    return InkWell(
      onTap: () {
        if (item.pageBuilder != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => item.pageBuilder!(context),
            ),
          );
        } else {
          Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
        }
      },
      child: Container(
        // Removed the fixed height: 'height: 180'
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12), // Add some space
            // Text widget with flexible height
            Text(
              item.label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: item.color,
              ),
              textAlign: TextAlign.center,
              // Allow text to wrap without overflow
              overflow: TextOverflow.clip, // Or ellipsis, based on preference
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final Widget Function(BuildContext)? pageBuilder; // Dynamic screen builder

  MenuItemData({
    required this.icon,
    required this.label,
    required this.color,
    required this.pageBuilder,
  });
}