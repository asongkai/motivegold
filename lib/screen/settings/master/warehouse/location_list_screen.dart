import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motivegold/model/warehouseModel.dart';
import 'package:motivegold/screen/settings/master/warehouse/edit_location_screen.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:sizer/sizer.dart';
import 'add_location_screen.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen>
    with TickerProviderStateMixin {
  bool loading = false;
  List<WarehouseModel>? locationList = [];
  List<WarehouseModel>? filteredLocationList = [];
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
    loadData();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ORIGINAL loadData functionality preserved exactly
  void loadData() async {
    setState(() {
      loading = true;
    });
    try {
      // motivePrint(Global.requestObj(null));
      var result = await ApiServices.post(
          Global.user?.userRole == 'Administrator'
              ? '/binlocation/all'
              : '/binlocation/branch',
          Global.requestObj({"branchId": Global.branch?.id}));
      // print(result!.data);
      if (result?.status == "success") {
        var data = jsonEncode(result?.data);
        List<WarehouseModel> products = warehouseListModelFromJson(data);
        setState(() {
          locationList = products;
          filteredLocationList = products;
        });
        _animationController?.forward();
      } else {
        locationList = [];
        filteredLocationList = [];
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

  void _filterLocations(String query) {
    if (!mounted) return;
    setState(() {
      if (query.isEmpty) {
        filteredLocationList = locationList;
      } else {
        filteredLocationList = locationList
            ?.where((location) =>
        location.name.toLowerCase().contains(query.toLowerCase()) ||
            (location.address != null &&
                location.address!.toLowerCase().contains(query.toLowerCase())))
            .toList();
      }
    });
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
                  child: Text("คลังสินค้า",
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
                                      const AddLocationScreen(),
                                      fullscreenDialog: true))
                                  .whenComplete(() {
                                loadData();
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
                                      'เพิ่มคลังสินค้า',
                                      style: TextStyle(
                                          fontSize: 14.sp,
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
                onChanged: _filterLocations,
                decoration: InputDecoration(
                  hintText: 'ค้นหาคลังสินค้า...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      if (mounted) {
                        _searchController.clear();
                        _filterLocations('');
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
            // Location Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'พบ ${filteredLocationList?.length ?? 0} คลังสินค้า',
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
            // Location List
            Expanded(
              child: filteredLocationList!.isEmpty
                  ? _buildEmptyState()
                  : _fadeAnimation != null
                  ? FadeTransition(
                opacity: _fadeAnimation!,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredLocationList!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildModernLocationCard(
                        filteredLocationList![index], index);
                  },
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredLocationList!.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildModernLocationCard(
                      filteredLocationList![index], index);
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
            Icons.warehouse_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'ไม่พบข้อมูลคลังสินค้า',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ลองค้นหาด้วยคำอื่น หรือเพิ่มคลังสินค้าใหม่',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernLocationCard(WarehouseModel location, int index) {
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
              // Add location details navigation if needed
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Location Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.orange[50],
                    ),
                    child: Icon(
                      Icons.warehouse,
                      color: Colors.orange[600],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Location Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (location.address != null && location.address!.isNotEmpty)
                          Text(
                            location.address!,
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
                  if (Global.user!.userRole == 'Administrator')
                    _buildActionButtons(location, index),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(WarehouseModel location, int index) {
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
                builder: (context) => EditLocationScreen(
                  location: location,
                  index: index,
                ),
                fullscreenDialog: true,
              ),
            ).whenComplete(() {
              loadData();
            });
          },
        ),
        const SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.delete_outline,
          color: Colors.red,
          onTap: () {
            removeProduct(location.id!, index);
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
  void removeProduct(int id, int i) async {
    Alert.info(context, 'ต้องการลบข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());
          try {
            var result =
            await ApiServices.post('/binlocation/$id', Global.requestObj(null));
            await pr.hide();
            if (result?.status == "success") {
              locationList!.removeAt(i);
              filteredLocationList = List.from(locationList!);
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