import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class ThengReportMenuScreen extends StatefulWidget {
  const ThengReportMenuScreen({super.key});

  @override
  State<ThengReportMenuScreen> createState() => _ThengReportMenuScreenState();
}

class _ThengReportMenuScreenState extends State<ThengReportMenuScreen> {
  @override
  Widget build(BuildContext context) {
    // return Container();
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายงานทองคำแท่ง",
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
                            const TransferGoldHistoryScreen()));
                  },
                  icons: Icons.view_list,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'ประวัติการโอนทอง',
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
                    icons: Icons.pie_chart,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.green,
                    ),
                    title: 'รายงานสต็อก',
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
                    icons: Icons.pie_chart,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.orange,
                    ),
                    title: 'รายงานความเคลื่อนไหวสต๊อกสินค้า',
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //         const MoneyMovementReportScreen()));
                    Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                  },
                  icons: Icons.pie_chart,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple,
                  ),
                  title: 'รายงานเส้นทางการเงินทองคำแท่ง',
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //         const BuyNewGoldReportScreen()));
                    Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.red,
                  ),
                  title: 'รายงานซื้อทองคำแท่ง (หน้าร้าน)',
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //         const SellNewGoldReportScreen()));
                    Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal,
                  ),
                  title: 'รายงานขายทองคำแท่ง (หน้าร้าน)',
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //         const SellUsedGoldReportScreen()));
                    Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  title: 'รายงานขายทองคำแท่ง (ร้านขายส่ง)',
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) =>
                    //         const BuyUsedGoldReportScreen()));
                    Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.brown,
                  ),
                  title: 'รายงานซื้อทองคำแท่ง (ร้านขายส่ง)',
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const SellVatReportScreen()));
                    Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงานภาษีขายทองคำแท่ง (บรรจุภัณฑ์)',
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
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => const BuyVatReportScreen()));
                    Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                  },
                  icons: Icons.checklist_rtl_outlined,
                  iconStyle: IconStyle(
                    backgroundColor: Colors.green,
                  ),
                  title: 'รายงานภาษีซื้อทองคำแท่ง (บรรจุภัณฑ์)',
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
