import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/refill/refill_gold_history_screen.dart';
import 'package:motivegold/screen/reports/auth-history/auth_history_screen.dart';
import 'package:motivegold/screen/reports/buy-new-gold-reports/buy_new_gold_reports.dart';
import 'package:motivegold/screen/reports/buy-used-gold-gov-reports/buy_used_gold_gov_report_screen.dart';
import 'package:motivegold/screen/reports/buy-used-gold-reports/buy_used_gold_report_screen.dart';
import 'package:motivegold/screen/reports/money-movement-reports/money_movement_reports.dart';
import 'package:motivegold/screen/reports/redeem-reports/redeem_single_reports_screen.dart';
import 'package:motivegold/screen/reports/sell-new-gold-reports/sell_new_gold_report_screen.dart';
import 'package:motivegold/screen/reports/sell-used-gold-reports/sell_used_gold_report_screen.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/stock_movement_report_list_screen.dart';
import 'package:motivegold/screen/reports/stock-reports/stock_report_list_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/buy-new-gold/buy_vat_report_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/sell-new-gold/sell_vat_report_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_history_screen.dart';
import 'package:motivegold/screen/pos/wholesale/paphun/used/sell_used_gold_history_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    // return Container();
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: false,
          title: Text("รายงาน",
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            // user card
            // SimpleUserCard(
            //   imageRadius: 10,
            //   userName: Global.user!.username!,
            //   userProfilePic: const AssetImage("assets/images/sample_profile.jpg"),
            // ),
            SettingsGroup(
              settingsGroupTitle: "ประวัติการทำรายการ",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const RefillGoldHistoryScreen()));
                  },
                  icons: Icons.view_list,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal,
                  ),
                  title: 'เติมทอง',
                  subtitle: "ประวัติการเติมทอง",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SellUsedGoldHistoryScreen()));
                  },
                  icons: Icons.view_list,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.orange,
                  ),
                  title: 'ขายทองเก่า',
                  subtitle: "ประวัติการขายทองเก่า",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const TransferGoldHistoryScreen()));
                  },
                  icons: Icons.view_list,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'โอนทอง',
                  subtitle: "ประวัติการโอนทอง",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),

            SettingsGroup(
              settingsGroupTitle: "รายงาน",
              items: [
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthHistoryScreen()));
                  },
                  icons: Icons.featured_play_list_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.blue[500],
                  ),
                  title: 'บันทึกการเข้าถึงระบบ',
                  subtitle: "ประวัติการเข้าใช้ระบบ",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StockReportListScreen()));
                  },
                  icons: Icons.pie_chart,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงานสต็อก',
                  subtitle: "รายงานสต็อคคลังสินค้า",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const StockMovementReportListScreen()));
                  },
                  icons: Icons.pie_chart,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.orange,
                  ),
                  title: 'รายงานความเคลื่อนไหว',
                  subtitle: "รายงานความเคลื่อนไหวสต๊อกสินค้า",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const MoneyMovementReportScreen()));
                  },
                  icons: Icons.pie_chart,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'รายงานเส้นทางการเงิน',
                  subtitle: "รายงานเส้นทางการเงินทองรูปพรรณ",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const BuyNewGoldReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.red,
                  ),
                  title: 'ซื้อทองใหม่',
                  subtitle: "รายงานการซื้อทองคำใหม่",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SellNewGoldReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal,
                  ),
                  title: 'ขายทองใหม่',
                  subtitle: "รายงานการขายทองคำใหม่",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const SellUsedGoldReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  title: 'ขายทองเก่า',
                  subtitle: "รายงานการขายทองคำเก่า",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const BuyUsedGoldReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.brown,
                  ),
                  title: 'ซื้อทองเก่า',
                  subtitle: "รายงานการซื้อทองคำเก่า",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SellVatReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงานภาษีขาย',
                  subtitle: "ขายทองคำรูปพรรณใหม่ 96.5%",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BuyVatReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงานภาษีซื้อ',
                  subtitle: "ซื้อทองคำรูปพรรณใหม่ 96.5%",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const BuyUsedGoldGovReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'บัญชีสำหรับผู้ทำการค้าของเก่า',
                  subtitle: "รายงานบัญชีสำหรับผู้ทำการค้าของเก่า",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                SettingsItem(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const RedeemSingleReportScreen()));
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.deepPurple,
                  ),
                  title: 'รายงานภาษีขายตามสัญญาขายฝาก ',
                  subtitle: "รายงานภาษีขายตามสัญญาขายฝากทองคำรูปพรรณใหม่ 96.5%",
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.grey.shade600),
                  subtitleStyle: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.grey.shade600),
                ),
                // SettingsItem(
                //   onTap: () {
                //
                //   },
                //   icons: Icons.checklist_rtl_outlined,
                //   iconStyle: IconStyle(
                //     backgroundColor: Colors.green,
                //   ),
                //   title: 'รายงาน 003',
                //   subtitle: "รายงาน 003",
                //   titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                //   subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                // ),
                // SettingsItem(
                //   onTap: () {
                //
                //   },
                //   icons: Icons.checklist_rtl_outlined,
                //   iconStyle: IconStyle(
                //     backgroundColor: Colors.green,
                //   ),
                //   title: 'รายงาน 004',
                //   subtitle: "รายงาน 004",
                //   titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                //   subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                // ),
                // SettingsItem(
                //   onTap: () {
                //
                //   },
                //   icons: Icons.checklist_rtl_outlined,
                //   iconStyle: IconStyle(
                //     backgroundColor: Colors.green,
                //   ),
                //   title: 'รายงาน 005',
                //   subtitle: "รายงาน 005",
                //   titleStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
                //   subtitleStyle: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                // ),
              ],
            ),
            // You can add a settings title
          ],
        ),
      ),
    );
  }
}
