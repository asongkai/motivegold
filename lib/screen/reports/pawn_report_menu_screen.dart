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

class PawnReportMenuScreen extends StatefulWidget {
  const PawnReportMenuScreen({super.key});

  @override
  State<PawnReportMenuScreen> createState() => _PawnReportMenuScreenState();
}

class _PawnReportMenuScreenState extends State<PawnReportMenuScreen> {
  @override
  Widget build(BuildContext context) {
    // return Container();
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายงานขายฝาก",
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
              settingsGroupTitle: "รายงาน",
              items: [
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
                  title: 'รายงานภาษีขายตามสัญญาขายฝากทองคำรูปพรรณใหม่ 96.5% ',
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
            // You can add a settings title
          ],
        ),
      ),
    );
  }
}
