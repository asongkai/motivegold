import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/company.dart';
import 'package:motivegold/screen/settings/company/edit_company_screen.dart';
import 'package:motivegold/screen/settings/company/new_company_screen.dart';
import 'package:motivegold/utils/constants.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';

class CompanyListScreen extends StatefulWidget {
  const CompanyListScreen({super.key});

  @override
  State<CompanyListScreen> createState() => _CompanyListScreenState();
}

class _CompanyListScreenState extends State<CompanyListScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  List<CompanyModel>? list = [];
  List<CompanyModel>? filteredList = [];
  Screen? size;
  final TextEditingController _searchController = TextEditingController();
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    loadProducts();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = Global.user!.userType == 'ADMIN'
          ? await ApiServices.get('/company')
          : await ApiServices.get('/company/${Global.user!.companyId}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<CompanyModel> products = Global.user!.userType == 'ADMIN'
            ? companyListModelFromJson(data)
            : [CompanyModel.fromJson(result!.data)];
        setState(() {
          list = products;
          filteredList = products;
          Global.companyList = products;
        });
        _animationController?.forward();
      } else {
        list = [];
        filteredList = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    setState(() {
      loading = false;
    });
  }

  void _filterCompanies(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        filteredList = list;
      } else {
        filteredList = list
            ?.where((company) =>
        company.name.toLowerCase().contains(query.toLowerCase()) ||
            (company.phone != null && company.phone!.toLowerCase().contains(query.toLowerCase())) ||
            _getFullAddress(company).toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _getFullAddress(CompanyModel company) {
    List<String> addressParts = [];

    if (company.address != null && company.address!.isNotEmpty) {
      addressParts.add(company.address!);
    }
    if (company.village != null && company.village!.isNotEmpty) {
      addressParts.add(company.village!);
    }
    if (company.district != null && company.district!.isNotEmpty) {
      addressParts.add(company.district!);
    }
    if (company.province != null && company.province!.isNotEmpty) {
      addressParts.add(company.province!);
    }

    return addressParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  flex: 4,
                  child: Text("บริษัท",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (Global.user!.userType == 'ADMIN')
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const NewCompanyScreen(
                                        showBackButton: true,
                                      ),
                                      fullscreenDialog: true))
                                  .whenComplete(() {
                                loadProducts();
                              });
                            },
                            child: Container(
                              color: Colors.teal[900],
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'เพิ่มบริษัทใหม่',
                                      style: TextStyle(
                                          fontSize: 14.sp, //16.sp,
                                          color: Colors.white),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ))
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: loading
            ? const Center(child: LoadingProgress())
            : Column(
          children: [
            // Search Bar
            if (Global.user!.userType == 'ADMIN')
              Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterCompanies,
                  decoration: InputDecoration(
                    hintText: 'ค้นหาบริษัท...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon:
                    Icon(Icons.search, color: Colors.grey[400]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (mounted) {
                          _searchController.clear();
                          _filterCompanies('');
                        }
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            // Company Count
            if (Global.user!.userType == 'ADMIN')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'พบ ${filteredList?.length ?? 0} บริษัท',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            // Company List
            Expanded(
              child: filteredList!.isEmpty
                  ? _buildEmptyState()
                  : _fadeAnimation != null
                  ? FadeTransition(
                opacity: _fadeAnimation!,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  itemCount: filteredList!.length,
                  itemBuilder:
                      (BuildContext context, int index) {
                    return _buildModernCompanyCard(
                        filteredList![index], index);
                  },
                ),
              )
                  : ListView.builder(
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildModernCompanyCard(
                      filteredList![index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบข้อมูลบริษัท',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองค้นหาด้วยคำอื่น หรือเพิ่มบริษัทใหม่',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCompanyCard(CompanyModel company, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Add company details navigation if needed
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Company Logo
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            '${Constants.DOMAIN_URL}/images/${company.logo}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.teal[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.business,
                                  color: Colors.teal[300],
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Company Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getFullAddress(company),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Action Buttons
                      if (Global.user!.userType == 'ADMIN' ||
                          Global.user!.userRole == 'Administrator')
                        _buildActionButtons(company, index),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Contact Info
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.green[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          company.phone ?? '',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(CompanyModel company, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (Global.user!.userRole == 'Administrator')
          _buildActionButton(
            icon: Icons.edit_outlined,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCompanyScreen(
                    showBackButton: true,
                    company: company,
                    index: index,
                  ),
                  fullscreenDialog: true,
                ),
              ).whenComplete(() {
                loadProducts();
              });
            },
          ),
        if (Global.user!.userType == 'ADMIN') ...[
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.delete_outline,
            color: Colors.red,
            onTap: () {
              _showDeleteConfirmation(company.id!, index);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(int id, int index) {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          removeProduct(id, index);
        });
  }

  void removeProduct(int id, int index) async {
    final ProgressDialog pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
      isDismissible: true,
      showLogs: true,
    );
    await pr.show();
    pr.update(message: 'processing'.tr());

    try {
      var result = await ApiServices.delete('/company', id);
      await pr.hide();

      if (result?.status == "success") {
        setState(() {
          list!.removeAt(index);
          filteredList = List.from(list!);
        });

        // Show success snackbar
        if (mounted) {
          loadProducts();
          Alert.success(
              context, 'Success', 'ลบข้อมูลสาขาเรียบร้อยแล้ว', 'OK'.tr(),
              action: () {});
          setState(() {});
        }
      } else {
        if (mounted) {
          Alert.error(context, 'Error',
              result?.message ?? result?.data ?? 'เกิดข้อผิดพลาด', 'OK'.tr(),
              action: () {});
        }
      }
    } catch (e) {
      await pr.hide();
      if (mounted) {
        Alert.error(
            context, 'Error', 'เกิดข้อผิดพลาด: ${e.toString()}', 'OK'.tr(),
            action: () {});
      }
    }
  }
}