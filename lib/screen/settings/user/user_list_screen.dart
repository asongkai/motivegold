import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/user.dart';
import 'package:motivegold/screen/settings/user/edit_user_screen.dart';
import 'package:motivegold/screen/settings/user/new_user_screen.dart';
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

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  List<UserModel>? list = [];
  List<UserModel>? filteredList = [];
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

  // ORIGINAL loadProducts functionality preserved exactly
  void loadProducts() async {
    setState(() {
      loading = true;
    });
    try {
      var result = Global.user!.userType == 'ADMIN'
          ? await ApiServices.get('/user')
          : await ApiServices.get('/user/by-company/${Global.user!.companyId}');
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<UserModel> products = userListModelFromJson(data);
        setState(() {
          list = products;
          filteredList = products;
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

  void _filterUsers(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        filteredList = list;
      } else {
        filteredList = list
            ?.where((user) =>
                '${user.firstName} ${user.lastName}'
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                (user.email != null &&
                    user.email!.toLowerCase().contains(query.toLowerCase())) ||
                (user.username != null &&
                    user.username!
                        .toLowerCase()
                        .contains(query.toLowerCase())) ||
                (user.phoneNumber != null &&
                    user.phoneNumber!
                        .toLowerCase()
                        .contains(query.toLowerCase())))
            .toList();
      }
    });
  }

  String _getUserRoleDisplayName(String? userRole) {
    switch (userRole) {
      case 'Administrator':
        return 'ผู้ดูแลระบบ';
      case 'Manager':
        return 'ผู้จัดการ';
      case 'Employee':
        return 'พนักงาน';
      case 'Cashier':
        return 'แคชเชียร์';
      default:
        return userRole ?? '';
    }
  }

  Color _getUserRoleColor(String? userRole) {
    switch (userRole) {
      case 'Administrator':
        return Colors.red;
      case 'Manager':
        return Colors.purple;
      case 'Employee':
        return Colors.blue;
      case 'Cashier':
        return Colors.green;
      default:
        return Colors.grey;
    }
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
                  child: Text("ผู้ใช้",
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
                        if (Global.user!.userRole == 'Administrator')
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const NewUserScreen(
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
                                      'เพิ่มผู้ใช้',
                                      style: TextStyle(
                                          fontSize: 14.sp, color: Colors.white),
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
                      onChanged: _filterUsers,
                      decoration: InputDecoration(
                        hintText: 'ค้นหาผู้ใช้...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  if (mounted) {
                                    _searchController.clear();
                                    _filterUsers('');
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
                  // User Count
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          'พบ ${filteredList?.length ?? 0} ผู้ใช้',
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
                  // User List
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
                                    return _buildModernUserCard(
                                        filteredList![index], index);
                                  },
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: filteredList!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return _buildModernUserCard(
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
            Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบข้อมูลผู้ใช้',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองค้นหาด้วยคำอื่น หรือเพิ่มผู้ใช้ใหม่',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernUserCard(UserModel user, int index) {
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
              // Add user details navigation if needed
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/default_profile.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            color: Colors.blue[600],
                            size: 30,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${user.firstName} ${user.lastName}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            // Role Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getUserRoleColor(user.userRole)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getUserRoleColor(user.userRole)
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _getUserRoleDisplayName(user.userRole),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: _getUserRoleColor(user.userRole),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (user.email != null && user.email!.isNotEmpty)
                          Text(
                            user.email!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        // Username and Phone Row
                        Row(
                          children: [
                            // Username
                            if (user.username != null &&
                                user.username!.isNotEmpty)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.account_circle,
                                        size: 14,
                                        color: Colors.green[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          user.username!,
                                          style: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12.sp,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (user.username != null &&
                                user.username!.isNotEmpty &&
                                user.phoneNumber != null &&
                                user.phoneNumber!.isNotEmpty)
                              const SizedBox(width: 8),
                            // Phone
                            if (user.phoneNumber != null &&
                                user.phoneNumber!.isNotEmpty)
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 14,
                                        color: Colors.orange[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          user.phoneNumber!,
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12.sp,
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
                  // Action Buttons
                  if (user.username != 'admin' &&
                      Global.user!.userRole == 'Administrator')
                    _buildActionButtons(user, index),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(UserModel user, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.edit_outlined,
          color: Colors.blue,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditUserScreen(
                  showBackButton: true,
                  user: user,
                  index: index,
                ),
                fullscreenDialog: true,
              ),
            ).whenComplete(() {
              loadProducts();
            });
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          onTap: () {
            removeProduct(user.id!, index);
          },
        ),
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

  // ORIGINAL removeProduct functionality preserved exactly
  void removeProduct(String id, int i) async {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
      final ProgressDialog pr = ProgressDialog(context,
          type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
      await pr.show();
      pr.update(message: 'processing'.tr());
      try {
        var result = await ApiServices.delete('/user', id);
        await pr.hide();
        if (result?.status == "success") {
          list!.removeAt(i);
          filteredList = List.from(list!);
          setState(() {});
        } else {
          if (mounted) {
            Alert.warning(context, 'Warning'.tr(), result!.message!, 'OK'.tr(),
                action: () {});
          }
        }
      } catch (e) {
        await pr.hide();
        if (mounted) {
          Alert.warning(context, 'Warning'.tr(), e.toString(), 'OK'.tr(),
              action: () {});
        }
      }
    });
  }
}
