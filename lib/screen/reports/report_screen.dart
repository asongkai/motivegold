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
import 'package:motivegold/screen/reports/vat-reports/papun/buy-new-gold/buy_vat_report_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/papun/sell-new-gold/sell_vat_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/accounting_books_menu_screen.dart';
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
                    backgroundColor:
                        Colors.amber[600]!, // Gold color for gold refill
                  ),
                  title: 'ประวัติการเติมทอง',
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
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
                    backgroundColor:
                        Colors.orange[600]!, // Orange for selling used gold
                  ),
                  title: 'ปรับน้ำหนักสูญเสียทองรูปพรรณ',
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
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
                  icons:
                      Icons.transfer_within_a_station, // Better for transfers
                  iconStyle: IconStyle(
                    backgroundColor: Colors.blue[600]!, // Blue for transfers
                  ),
                  title: 'ประวัติการโอนทอง',
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
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
