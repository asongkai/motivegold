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
import 'package:motivegold/screen/reports/theng/buy-new-theng-gold-reports/buy_theng_report_screen.dart';
import 'package:motivegold/screen/reports/theng/buy-used-theng-gold-reports/buy_used_theng_report_screen.dart';
import 'package:motivegold/screen/reports/theng/sell-new-theng-gold-reports/sell_theng_report_screen.dart';
import 'package:motivegold/screen/reports/theng/sell-used-theng-gold-reports/sell_used_theng_gold_report_screen.dart';
import 'package:motivegold/screen/reports/theng/theng-money-movement-reports/theng_money_movement_reports.dart';
import 'package:motivegold/screen/reports/vat-reports/papun/buy-new-gold/buy_vat_report_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/papun/sell-new-gold/sell_vat_report_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/theng/buy-gold/buy_theng_vat_report_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/theng/sell-gold/sell_theng_vat_report_screen.dart';
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
                    // Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const BuyUsedThengGoldReportScreen()));
                  },
                  icons: Icons.shopping_cart, // Better for buying
                  iconStyle: IconStyle(
                    backgroundColor: Colors.red[600]!, // Red for buying
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
                    // Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const SellThengReportScreen()));
                  },
                  icons: Icons.sell, // Better for selling
                  iconStyle: IconStyle(
                    backgroundColor: Colors.teal[600]!, // Teal for selling
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
                    // Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const SellUsedThengGoldReportScreen()));
                  },
                  icons: Icons.sell, // Selling icon
                  iconStyle: IconStyle(
                    backgroundColor: Colors.deepOrange[600]!, // Deep orange for wholesale
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
                    //Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const BuyThengReportScreen()));
                  },
                  icons: Icons.shopping_cart, // Buying icon
                  iconStyle: IconStyle(
                    backgroundColor: Colors.brown[600]!, // Brown for wholesale buying
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
                    // Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const ThengMoneyMovementReportScreen()));
                  },
                  icons: Icons.account_balance_wallet, // Better for financial flow
                  iconStyle: IconStyle(
                    backgroundColor: Colors.purple[600]!, // Purple for financial reports
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
                    // Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const SellThengVatReportScreen()));
                  },
                  icons: Icons.receipt_long, // Better for tax reports
                  iconStyle: IconStyle(
                    backgroundColor: Colors.indigo[600]!, // Indigo for tax reports
                  ),
                  title: 'รายงานภาษีขายทองคำแท่ง',
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
                    // Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const BuyThengVatReportScreen()));
                  },
                  icons: Icons.receipt_long, // Tax reports
                  iconStyle: IconStyle(
                    backgroundColor: Colors.indigo[600]!, // Same color for tax consistency
                  ),
                  title: 'รายงานภาษีซื้อทองคำแท่ง',
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
          ],
        ),
      ),
    );
  }
}