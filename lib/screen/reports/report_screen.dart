// ReportScreen.dart
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
import 'package:motivegold/utils/global.dart';
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
                  icons: Icons.add_circle, // Better for adding/refilling
                  iconStyle: IconStyle(
                    backgroundColor: Colors.amber[600]!, // Gold color for gold refill
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
                  icons: Icons.sell, // Better for selling
                  iconStyle: IconStyle(
                    backgroundColor: Colors.orange[600]!, // Orange for selling used gold
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
                  icons: Icons.transfer_within_a_station, // Better for transfers
                  iconStyle: IconStyle(
                    backgroundColor: Colors.blue[600]!, // Blue for transfers
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
                if (Global.company?.stock == 1)
                  SettingsItem(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const StockReportListScreen()));
                    },
                    icons: Icons.inventory, // Better for stock/inventory
                    iconStyle: IconStyle(
                      backgroundColor: Colors.green[600]!, // Green for stock reports
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
                if (Global.company?.stock == 1)
                  SettingsItem(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const StockMovementReportListScreen()));
                    },
                    icons: Icons.trending_up, // Better for movement/trends
                    iconStyle: IconStyle(
                      backgroundColor: Colors.orange[600]!, // Orange for movement
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
                  icons: Icons.account_balance_wallet, // Better for financial flow
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple[600]!, // Purple for financial reports
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
                  icons: Icons.shopping_cart, // Better for buying
                  iconStyle: IconStyle(
                    backgroundColor: Colors.red[600]!, // Red for buying
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
                  icons: Icons.sell, // Better for selling
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal[600]!, // Teal for selling new
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
                  icons: Icons.sell, // Selling icon
                  iconStyle: IconStyle(
                    backgroundColor: Colors.deepOrange[600]!, // Deep orange for used items
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
                  icons: Icons.shopping_cart, // Buying icon
                  iconStyle: IconStyle(
                    backgroundColor: Colors.brown[600]!, // Brown for used items
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
                  icons: Icons.receipt_long, // Better for tax reports
                  iconStyle: IconStyle(
                    backgroundColor: Colors.indigo[600]!, // Indigo for tax reports
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
                  icons: Icons.receipt_long, // Tax reports
                  iconStyle: IconStyle(
                    backgroundColor: Colors.indigo[600]!, // Same color for tax consistency
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
                  icons: Icons.account_balance, // Government/official reports
                  iconStyle: IconStyle(
                    backgroundColor: Colors.cyan[600]!, // Cyan for government reports
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
                  icons: Icons.redeem, // Perfect for redeem/pawn reports
                  iconStyle: IconStyle(
                    backgroundColor: Colors.deepPurple[600]!, // Deep purple for pawn/redeem
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}