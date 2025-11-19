import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/screen/reports/buy-new-gold-reports/buy_new_gold_reports.dart';
import 'package:motivegold/screen/reports/buy-used-gold-gov-reports/buy_used_gold_gov_report_screen.dart';
import 'package:motivegold/screen/reports/buy-used-gold-reports/buy_used_gold_report_screen.dart';
import 'package:motivegold/screen/reports/money-movement-reports/money_movement_reports.dart';
import 'package:motivegold/screen/reports/sell-new-gold-reports/sell_new_gold_report_screen.dart';
import 'package:motivegold/screen/reports/sell-used-gold-reports/sell_used_gold_report_screen.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/stock_card_report_screen.dart';
import 'package:motivegold/screen/reports/stock-movement-reports/stock_movement_report_list_screen.dart';
import 'package:motivegold/screen/reports/stock-reports/stock_report_list_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/papun/buy-new-gold/buy_vat_report_screen.dart';
import 'package:motivegold/screen/reports/vat-reports/papun/sell-new-gold/sell_vat_report_screen.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class PaphunReportMenuScreen extends StatefulWidget {
  const PaphunReportMenuScreen({super.key});

  @override
  State<PaphunReportMenuScreen> createState() => _PaphunReportMenuScreenState();
}

class _PaphunReportMenuScreenState extends State<PaphunReportMenuScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.94),
      appBar: const CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("รายงานทองรูปพรรณ",
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
            // Two-column grid layout
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    children: [
                      // Section 1: รายงานทองรูปพรรณใหม่(หน้าร้าน)
                      SettingsGroup(
                        settingsGroupTitle: "รายงานทองรูปพรรณใหม่(หน้าร้าน)",
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
                                          const BuyVatReportScreen()));
                            },
                            icons: Icons.receipt_long,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.blue[600]!,
                            ),
                            title: 'รายงานภาษีซื้อทองรูปพรรณใหม่(เติมทอง)',
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
                                          const SellVatReportScreen()));
                            },
                            icons: Icons.receipt_long,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.teal[600]!,
                            ),
                            title: 'รายงานภาษีขายทองคำรูปพรรณใหม่(หน้าร้าน)',
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
                                          const BuyNewGoldReportScreen()));
                            },
                            icons: Icons.shopping_cart, // Better for buying
                            iconStyle: IconStyle(
                              backgroundColor:
                                  Colors.red[600]!, // Red for buying
                            ),
                            title: 'รายงานซื้อทองรูปพรรณใหม่(เติมทอง)',
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
                                          const SellNewGoldReportScreen()));
                            },
                            icons: Icons.sell,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.green[600]!,
                            ),
                            title: 'รายงานขายทองรูปพรรณใหม่(หน้าร้าน)',
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
                        settingsGroupTitle: "รายงานทองรูปพรรณเก่า(ร้านค้าส่ง)",
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
                                          const BuyUsedGoldReportScreen()));
                            },
                            icons: Icons.shopping_bag,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.brown[600]!,
                            ),
                            title: 'รายงานซื้อทองรูปพรรณเก่า(หน้าร้าน)',
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
                                          const SellUsedGoldReportScreen()));
                            },
                            icons: Icons.local_offer,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.deepOrange[600]!,
                            ),
                            title: 'รายงานขายทองรูปพรรณเก่า(ร้านขายส่ง)',
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
                                          const BuyUsedGoldGovReportScreen()));
                            },
                            icons: Icons.account_balance,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.cyan[600]!,
                            ),
                            title: 'รายงานบัญชีสำหรับผู้ทำการค้าของเก่า',
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
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const MoneyMovementReportScreen()));
                            },
                            icons: Icons.account_balance_wallet,
                            iconStyle: IconStyle(
                              backgroundColor: Colors.purple[600]!,
                            ),
                            title: 'รายงานเส้นทางการเงินทองรูปพรรณ',
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
