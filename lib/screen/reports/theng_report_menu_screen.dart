import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/buy-retail-theng/buy_retail_theng_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/refill-wholesale-theng/refill_wholesale_theng_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/sell-new-retail-theng/sell_new_retail_theng_report_screen.dart';
import 'package:motivegold/screen/reports/accounting-books/theng/sell-wholesale-theng/sell_wholesale_theng_report_screen.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/stock_card_report_screen.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/stock_movement_report_list_screen.dart';
import 'package:motivegold/screen/reports/stock-reports/stock_report_list_screen.dart';
import 'package:motivegold/screen/reports/theng/buy-new-theng-gold-reports/buy_theng_report_screen.dart';
import 'package:motivegold/screen/reports/theng/buy-used-theng-gold-reports/buy_used_theng_report_screen.dart';
import 'package:motivegold/screen/reports/theng/sell-new-theng-gold-reports/sell_theng_report_screen.dart';
import 'package:motivegold/screen/reports/theng/sell-used-theng-gold-reports/sell_used_theng_gold_report_screen.dart';
import 'package:motivegold/screen/reports/theng/theng-money-movement-reports/theng_money_movement_reports.dart';
import 'package:motivegold/screen/reports/vat-reports/theng/buy-gold/buy_theng_vat_report_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/theng/sell-gold/sell_theng_vat_report_screen.dart';
import 'package:motivegold/screen/transfer/transfer_gold_history_screen.dart';
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: [
                      // Section 1: รายงานทองรูปพรรณใหม่(หน้าร้าน)
                      SettingsGroup(
                        settingsGroupTitle: "รายงานทองคำแท่ง(หน้าร้าน)",
                        settingsGroupTitleStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        items: [
                          SettingsItem(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const BuyThengVatReportScreen()));
                            },
                            icons: Icons.receipt_long, // Tax reports
                            iconStyle: IconStyle(
                              backgroundColor: Colors.indigo[
                                  600]!, // Same color for tax consistency
                            ),
                            title: 'รายงานภาษีซื้อทองคำแท่ง(เติมทอง)',
                            titleStyle: Theme.of(context)
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
                                          const SellThengVatReportScreen()));
                            },
                            icons: Icons.receipt_long, // Better for tax reports
                            iconStyle: IconStyle(
                              backgroundColor:
                                  Colors.indigo[600]!, // Indigo for tax reports
                            ),
                            title: 'รายงานภาษีขายทองคำแท่ง(หน้าร้าน)',
                            titleStyle: Theme.of(context)
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
                                          const BuyThengReportScreen()));
                            },
                            icons: Icons.shopping_cart, // Better for buying
                            iconStyle: IconStyle(
                              backgroundColor:
                                  Colors.red[600]!, // Red for buying
                            ),
                            title: 'รายงานซื้อทองคำแท่ง(เติมทอง)',
                            titleStyle: Theme.of(context)
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
                                          const SellThengReportScreen()));
                            },
                            icons: Icons.sell,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.green[600]!,
                            ),
                            title: 'รายงานขายทองคำแท่ง(หน้าร้าน)',
                            titleStyle: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right Column
                Expanded(
                  child: Column(
                    children: [
                      // Section 2: รายงานทองรูปพรรณเก่า(ร้านค้าส่ง)
                      SettingsGroup(
                        settingsGroupTitle: "รายงานทองคำแท่ง(ร้านค้าส่ง)",
                        settingsGroupTitleStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        items: [
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
                              backgroundColor:
                                  Colors.red[600]!, // Red for buying
                            ),
                            title: 'รายงานซื้อทองคำแท่ง (หน้าร้าน)',
                            titleStyle: Theme.of(context)
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
                              backgroundColor: Colors.deepOrange[
                                  600]!, // Deep orange for wholesale
                            ),
                            title: 'รายงานขายทองคำแท่ง (ร้านขายส่ง)',
                            titleStyle: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: [
                      // Section 3: รายงานเส้นทางการเงิน
                      SettingsGroup(
                        settingsGroupTitle: "รายงานเส้นทางการเงิน",
                        settingsGroupTitleStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        items: [
                          SettingsItem(
                            onTap: () {
                              // Alert.info(context, 'Warning'.tr(), 'จะนำมาใช้งานเร็วๆ นี้', 'OK');
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ThengMoneyMovementReportScreen()));
                            },
                            icons: Icons
                                .account_balance_wallet, // Better for financial flow
                            iconStyle: IconStyle(
                              backgroundColor: Colors
                                  .purple[600]!, // Purple for financial reports
                            ),
                            title: 'รายงานเส้นทางการเงินทองคำแท่ง',
                            titleStyle: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Right Column
                Expanded(
                  child: Column(
                    children: [
                      // Section 4: รายงานบัญชีสินค้า (Full Width)
                      if (Global.company?.stock == 1)
                        SettingsGroup(
                          settingsGroupTitle: "รายงานบัญชีสินค้า",
                          settingsGroupTitleStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          items: [
                            SettingsItem(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const StockReportListScreen()));
                              },
                              icons: Icons.inventory_2,
                              iconStyle: IconStyle(
                                backgroundColor: Colors.green[600]!,
                              ),
                              title: 'รายงานบัญชีสินค้าคงเหลือ',
                              titleStyle: Theme.of(context)
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
                                            const StockCardReportScreen()));
                              },
                              icons: Icons.trending_up,
                              iconStyle: IconStyle(
                                backgroundColor: Colors.orange[600]!,
                              ),
                              title: 'สมุดบัญชีสินค้าคงเหลือ',
                              titleStyle: Theme.of(context)
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
                              icons: Icons.receipt,
                              iconStyle: IconStyle(
                                backgroundColor: Colors.pink[400]!,
                              ),
                              title:
                                  'รายงานความเคลื่อนไหวสต๊อกสินค้า(รับ-จ่าย)',
                              titleStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
