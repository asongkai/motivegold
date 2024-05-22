
import 'package:flutter/material.dart';
import 'package:motivegold/screen/products/product_list_screen.dart';
import 'package:motivegold/screen/settings/branch/branch_list_screen.dart';
import 'package:motivegold/screen/settings/company/company_list_screen.dart';
import 'package:motivegold/screen/settings/master/productCategory/product_category_list_screen.dart';
import 'package:motivegold/screen/settings/master/productType/product_type_list_screen.dart';
import 'package:motivegold/screen/settings/master/warehouse/location_list_screen.dart';
import 'package:motivegold/screen/settings/user/user_list_screen.dart';

import '../../utils/global.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('จัดการข้อมูลหลัก'),),
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text("สินค้า", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w400)),
                    const SizedBox(height: 8),
                    _buildListTile('ประเภทสินค้า', Icons.list, '', Colors.orange, theme, onTab: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ProductTypeListScreen()));
                    }),
                    const SizedBox(height: 8),
                    _buildListTile('หมวดหมู่สินค้า', Icons.line_style_outlined, '', Colors.blue, theme, onTab: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ProductCategoryListScreen()));
                    }),
                    const SizedBox(height: 8),
                    _buildListTile('สินค้า', Icons.line_style_outlined, '', Colors.teal, theme, onTab: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const ProductListScreen()));
                    }),
                    const SizedBox(height: 32),
                    // Text("ผู้ใช้", style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w400)),
                    // const SizedBox(height: 8),
                    // _buildListTile('ผู้ใช้', Icons.supervised_user_circle_sharp, '', Colors.blue, theme, onTab: () {
                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) =>
                    //           const UserListScreen()));
                    // }),
                  ],
                ),
                // Text("Version 1.0.0", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500)),
              ],
            ),
          )
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, String trailing, Color color, ThemeData theme, {onTab}) {
    return ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(30)
          ),
          child: Center(
            child: Icon(icon, color: color,),
          ),
        ),
        title: Text(title, style: theme.textTheme.titleLarge),
        trailing: SizedBox(
          width: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trailing, style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey.shade600)),
              const Icon(Icons.arrow_forward_ios, size: 16,),
            ],
          ),
        ),
        onTap: onTab
    );
  }
}