import 'package:flutter/material.dart';
import 'package:motivegold/screen/products/product_list_screen.dart';
import 'package:motivegold/screen/settings/master/bank/bank_screen.dart';
import 'package:motivegold/screen/settings/master/bankAccount/bank_account_screen.dart';
import 'package:motivegold/screen/settings/master/location/amphure/amphure_screen.dart';
import 'package:motivegold/screen/settings/master/location/province/province_screen.dart';
import 'package:motivegold/screen/settings/master/location/tambon/tambon_screen.dart';
import 'package:motivegold/screen/settings/master/productCategory/product_category_list_screen.dart';
import 'package:motivegold/screen/settings/master/productType/product_type_list_screen.dart';
import 'package:motivegold/screen/settings/pawn/rateint/rate_int_list_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Text("จัดการข้อมูลหลัก",
              style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.w600)),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // Products Section
                    _buildSectionHeader(
                      icon: Icons.inventory_2_rounded,
                      title: "สินค้า",
                      color: Colors.blue,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _buildModernCard([
                      _buildModernListTile(
                        'ประเภทสินค้า',
                        Icons.category_rounded,
                        Colors.orange,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ProductTypeListScreen()));
                        },
                      ),
                      _buildModernListTile(
                        'หมวดหมู่สินค้า',
                        Icons.view_module_rounded,
                        Colors.purple,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ProductCategoryListScreen()));
                        },
                      ),
                      _buildModernListTile(
                        'สินค้า',
                        Icons.shopping_bag_rounded,
                        Colors.teal,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ProductListScreen()));
                        },
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // Banking Section
                    _buildSectionHeader(
                      icon: Icons.account_balance_rounded,
                      title: "ธนาคาร",
                      color: Colors.green,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _buildModernCard([
                      _buildModernListTile(
                        'ธนาคาร',
                        Icons.account_balance_rounded,
                        Colors.green,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const BankListScreen()));
                        },
                      ),
                      _buildModernListTile(
                        'บัญชีธนาคาร',
                        Icons.credit_card_rounded,
                        Colors.blue,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const BankAccountListScreen()));
                        },
                      ),
                    ]),

                    const SizedBox(height: 32),

                    // Location Section
                    _buildSectionHeader(
                      icon: Icons.location_on_rounded,
                      title: "ที่อยู่",
                      color: Colors.red,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _buildModernCard([
                      _buildModernListTile(
                        'จังหวัด',
                        Icons.map_rounded,
                        Colors.red,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const ProvinceScreen()));
                        },
                      ),
                      _buildModernListTile(
                        'อำเภอ',
                        Icons.location_city_rounded,
                        Colors.orange,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const AmphureScreen()));
                        },
                      ),
                      _buildModernListTile(
                        'ตำบล',
                        Icons.place_rounded,
                        Colors.purple,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const TambonScreen()));
                        },
                      ),
                    ]),

                    const SizedBox(height: 24),

                    _buildSectionHeader(
                      icon: Icons.percent,
                      title: "อัตราดอกเบี้ย",
                      color: Colors.purple,
                      theme: theme,
                    ),
                    const SizedBox(height: 12),
                    _buildModernCard([
                      _buildModernListTile(
                        'อัตราดอกเบี้ย',
                        Icons.map_rounded,
                        Colors.purple,
                        theme,
                        onTab: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const RateIntListScreen()));
                        },
                      ),
                    ]),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color color,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildModernCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int index = entry.key;
          Widget child = entry.value;

          return Column(
            children: [
              child,
              if (index < children.length - 1)
                Divider(
                  height: 1,
                  color: Colors.grey[200],
                  indent: 70,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernListTile(
      String title,
      IconData icon,
      Color color,
      ThemeData theme, {
        VoidCallback? onTab,
      }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
        ),
        child: Center(
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: const Color(0xFF2D3748),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[600],
        ),
      ),
      onTap: onTab,
    );
  }
}