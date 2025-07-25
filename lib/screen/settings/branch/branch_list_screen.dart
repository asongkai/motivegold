import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/screen/settings/branch/edit_branch_screen.dart';
import 'package:motivegold/screen/settings/branch/new_branch_screen.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/empty_data.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  List<BranchModel>? list = [];
  List<BranchModel>? filteredList = [];
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
          ? await ApiServices.post('/branch/all', Global.requestObj(null))
          : await ApiServices.get(
          '/branch/by-company/${Global.user!.companyId}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<BranchModel> products = branchListModelFromJson(data);
        setState(() {
          list = products;
          filteredList = products;
          Global.branchList = products;
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

  void _filterBranches(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        filteredList = list;
      } else {
        filteredList = list
            ?.where((branch) =>
        branch.name.toLowerCase().contains(query.toLowerCase()) ||
            (branch.phone != null && branch.phone!.toLowerCase().contains(query.toLowerCase())) ||
            (branch.branchCode != null && branch.branchCode!.toLowerCase().contains(query.toLowerCase())) ||
            _getFullAddress(branch).toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  String _getFullAddress(BranchModel branch) {
    List<String> addressParts = [];

    if (branch.address != null && branch.address!.isNotEmpty) {
      addressParts.add(branch.address!);
    }
    if (branch.village != null && branch.village!.isNotEmpty) {
      addressParts.add(branch.village!);
    }
    if (branch.district != null && branch.district!.isNotEmpty) {
      addressParts.add(branch.district!);
    }
    if (branch.province != null && branch.province!.isNotEmpty) {
      addressParts.add(branch.province!);
    }

    return addressParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        height: 300,
        child: TitleContent(
          backButton: true,
          title: Padding(
            padding: const EdgeInsets.only(left: 18.0, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 4,
                  child: Text("สาขา",
                      style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w900)),
                ),
                Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const NewBranchScreen(
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
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    size: 16.sp,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'เพิ่มสาขา',
                                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
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
                onChanged: _filterBranches,
                decoration: InputDecoration(
                  hintText: 'ค้นหาสาขา...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      if (mounted) {
                        _searchController.clear();
                        _filterBranches('');
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
            // Branch Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'พบ ${filteredList?.length ?? 0} สาขา',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Branch List
            Expanded(
              child: filteredList!.isEmpty
                  ? _buildEmptyState()
                  : _fadeAnimation != null
                  ? FadeTransition(
                opacity: _fadeAnimation!,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildModernBranchCard(
                        filteredList![index], index);
                  },
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildModernBranchCard(
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
            Icons.store_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบข้อมูลสาขา',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองค้นหาด้วยคำอื่น หรือเพิ่มสาขาใหม่',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBranchCard(BranchModel branch, int index) {
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
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Add branch details navigation if needed
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Branch Icon
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.orange[50],
                            ),
                            child: Icon(
                              Icons.store,
                              color: Colors.orange[600],
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Branch Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  branch.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFullAddress(branch),
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
                            _buildActionButtons(branch, index),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Contact Info Row
                      Row(
                        children: [
                          // Phone
                          if (branch.phone != null && branch.phone!.isNotEmpty)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
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
                                    Expanded(
                                      child: Text(
                                        branch.phone!,
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (branch.phone != null &&
                              branch.phone!.isNotEmpty &&
                              branch.email != null &&
                              branch.email!.isNotEmpty)
                            const SizedBox(width: 12),
                          // Email
                          if (branch.email != null && branch.email!.isNotEmpty)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.email,
                                      size: 16,
                                      color: Colors.blue[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        branch.email!,
                                        style: TextStyle(
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Floating badge in top-right
          if (branch.branchCode != null && branch.branchCode!.isNotEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getBadgeColor(branch.branchCode!),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  branch.branchCode!.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getBadgeColor(String branchCode) {
    // Generate dynamic colors based on branch code hash
    // This ensures consistent colors for the same branch code
    int hash = branchCode.hashCode;

    // Create a list of nice, readable colors
    List<Color> colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.amber,
      Colors.pink,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
      Colors.lightBlue,
      Colors.deepPurple,
      Colors.brown,
    ];

    // Use hash to pick a consistent color for this branch code
    int colorIndex = hash.abs() % colors.length;
    return colors[colorIndex];
  }

  Widget _buildActionButtons(BranchModel branch, int index) {
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
                  builder: (context) => EditBranchScreen(
                    showBackButton: true,
                    branch: branch,
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
              _showDeleteConfirmation(branch.id!, index);
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
      var result = await ApiServices.delete('/branch', id);
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