import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mirai_dropdown_menu/mirai_dropdown_menu.dart';
import 'package:motivegold/model/branch.dart';
import 'package:motivegold/model/pawn/default_pawn.dart';
import 'package:motivegold/utils/helps/common_function.dart';
import 'package:motivegold/utils/util.dart';
import 'package:motivegold/widget/appbar/appbar.dart';
import 'package:motivegold/widget/appbar/title_content.dart';
import 'package:motivegold/widget/loading/loading_progress.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:motivegold/api/api_services.dart';
import 'package:motivegold/utils/alert.dart';
import 'package:motivegold/utils/global.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:motivegold/widget/dropdown/DropDownItemWidget.dart';
import 'package:motivegold/widget/dropdown/DropDownObjectChildWidget.dart';
import 'package:sizer/sizer.dart';

class ConfigDefaultPawnScreen extends StatefulWidget {
  const ConfigDefaultPawnScreen({super.key, this.defaultPawnModel});

  final DefaultPawnModel? defaultPawnModel;

  @override
  State<ConfigDefaultPawnScreen> createState() => _ConfigDefaultPawnScreenState();
}

class _ConfigDefaultPawnScreenState extends State<ConfigDefaultPawnScreen> {
  final TextEditingController branchCtrl = TextEditingController();
  final TextEditingController taxTypeNameCtrl = TextEditingController();
  final TextEditingController taxPointNameCtrl = TextEditingController();

  bool loading = false;
  List<BranchModel>? branches;
  List<TaxTypeModel>? taxTypes;
  List<TaxPointModel>? taxPoints;

  BranchModel? selectedBranch;
  TaxTypeModel? selectedTaxType;
  TaxPointModel? selectedTaxPoint;

  ValueNotifier<dynamic>? branchNotifier;
  ValueNotifier<dynamic>? taxTypeNotifier;
  ValueNotifier<dynamic>? taxPointNotifier;

  @override
  void initState() {
    super.initState();

    // Initialize branch selection
    if (widget.defaultPawnModel?.branchId != null) {
      selectedBranch = Global.branchList
          .where((e) => e.id == widget.defaultPawnModel?.branchId)
          .first;
    } else {
      selectedBranch =
          Global.branchList.where((e) => e.id == Global.user?.branchId).first;
    }

    branchNotifier = ValueNotifier<BranchModel>(
        selectedBranch ?? BranchModel(id: 0, name: 'เลือกสาขา'));

    // Initialize tax type if editing
    if (widget.defaultPawnModel?.taxTypeId != null) {
      selectedTaxType = TaxTypeModel(
        id: widget.defaultPawnModel!.taxTypeId!,
        name: widget.defaultPawnModel!.taxTypeName ?? '',
      );
      taxTypeNotifier = ValueNotifier<TaxTypeModel>(selectedTaxType!);
      if (kDebugMode) {
        print('Editing mode - selectedTaxType: ${selectedTaxType!.name}');
      }
    } else {
      var placeholderTaxType = TaxTypeModel(id: 0, name: 'เลือกประเภทภาษี');
      taxTypeNotifier = ValueNotifier<TaxTypeModel>(placeholderTaxType);
      if (kDebugMode) {
        print('New mode - placeholderTaxType: ${placeholderTaxType.name}');
      }
    }

    // Initialize tax point if editing
    if (widget.defaultPawnModel?.taxPointId != null) {
      selectedTaxPoint = TaxPointModel(
        id: widget.defaultPawnModel!.taxPointId!,
        name: widget.defaultPawnModel!.taxPointName ?? '',
        taxTypeId: widget.defaultPawnModel!.taxTypeId ?? 0,
      );
      taxPointNotifier = ValueNotifier<TaxPointModel>(selectedTaxPoint!);
    } else {
      taxPointNotifier = ValueNotifier<TaxPointModel>(TaxPointModel(id: 0, name: 'เลือกจุดภาษี', taxTypeId: 0));
    }

    // Pre-fill form if editing
    taxTypeNameCtrl.text = widget.defaultPawnModel?.taxTypeName ?? '';
    taxPointNameCtrl.text = widget.defaultPawnModel?.taxPointName ?? '';

    loadData();
  }

  void loadData() async {
    setState(() {
      loading = true;
    });

    try {
      // Load branches
      var branchResult = await ApiServices.get('/branch/by-company/${Global.user!.companyId}');
      if (branchResult?.status == "success") {
        var data = jsonEncode(branchResult?.data);
        List<BranchModel> branchList = branchListModelFromJson(data);
        setState(() {
          branches = branchList;
        });

        if (Global.user!.userType == 'COMPANY') {
          selectedBranch = branches!
              .where((element) => element.id == Global.user!.branchId)
              .first;
          branchCtrl.text = selectedBranch!.name;
        }
      }

      // Load tax types
      var taxTypeResult = await ApiServices.post('/defaultpawn/tax-types', Global.requestObj(null));
      if (taxTypeResult?.status == "success") {
        List<dynamic> taxTypeData = taxTypeResult?.data ?? [];
        if (kDebugMode) {
          print('Raw tax type data: $taxTypeData');
        }
        setState(() {
          taxTypes = taxTypeData.map((e) {
            var taxType = TaxTypeModel.fromJson(e);
            if (kDebugMode) {
              print('Created TaxTypeModel: id=${taxType.id}, name="${taxType.name}"');
            }
            return taxType;
          }).toList();
        });

        if (kDebugMode) {
          print('Total tax types loaded: ${taxTypes!.length}');
          if (taxTypes!.isNotEmpty) {
            print('First tax type: ${taxTypes![0].name}');
          }
        }

        // Update the notifier if we have a pre-selected tax type
        if (selectedTaxType != null && taxTypes!.isNotEmpty) {
          var foundTaxType = taxTypes!.firstWhere(
                  (type) => type.id == selectedTaxType!.id,
              orElse: () => selectedTaxType!
          );
          taxTypeNotifier!.value = foundTaxType;
          if (kDebugMode) {
            print('Updated notifier with: ${foundTaxType.name}');
          }
        }
      }

      // Load tax points for selected tax type if editing existing record
      if (widget.defaultPawnModel?.taxTypeId != null) {
        await loadTaxPointsByType(widget.defaultPawnModel!.taxTypeId!);
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

  Future<void> loadTaxPointsByType(int taxTypeId) async {
    try {
      var taxPointResult = await ApiServices.post('/defaultpawn/tax-points/$taxTypeId', Global.requestObj(null));
      if (taxPointResult?.status == "success") {
        List<dynamic> taxPointData = taxPointResult?.data ?? [];
        setState(() {
          taxPoints = taxPointData.map((e) => TaxPointModel.fromJson(e)).toList();
        });

        // Update the notifier if we have a pre-selected tax point
        if (selectedTaxPoint != null && taxPoints!.isNotEmpty) {
          var foundTaxPoint = taxPoints!.firstWhere(
                  (point) => point.id == selectedTaxPoint!.id,
              orElse: () => selectedTaxPoint!
          );
          taxPointNotifier!.value = foundTaxPoint;
        }
      } else {
        setState(() {
          taxPoints = [];
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tax points: ${e.toString()}');
      }
      setState(() {
        taxPoints = [];
      });
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
          title: Text(
            widget.defaultPawnModel == null ? "ตั้งค่าจำนำเริ่มต้น" : "แก้ไขการตั้งค่าจำนำเริ่มต้น",
            style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                fontWeight: FontWeight.w900),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: loading
              ? const Center(child: LoadingProgress())
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Branch Selection Card (Admin only)
                  if (Global.user!.userRole == 'Administrator')
                    _buildInfoCard(
                      title: 'เลือกสาขา',
                      icon: Icons.store,
                      children: [
                        _buildDropdownField<BranchModel>(
                          label: 'สาขา',
                          icon: Icons.store_outlined,
                          notifier: branchNotifier!,
                          items: branches ?? [],
                          onChanged: (BranchModel value) {
                            branchCtrl.text = value.name;
                            selectedBranch = value;
                            branchNotifier!.value = value;
                          },
                        ),
                      ],
                    ),

                  // Branch Display (Non-Admin)
                  if (Global.user!.userRole != 'Administrator')
                    _buildInfoCard(
                      title: 'สาขา',
                      icon: Icons.store,
                      children: [
                        _buildModernTextField(
                          controller: branchCtrl,
                          label: 'สาขา',
                          icon: Icons.store_outlined,
                          enabled: false,
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  // Tax Configuration Card
                  _buildInfoCard(
                    title: 'การตั้งค่าภาษี',
                    icon: Icons.account_balance,
                    children: [
                      // Tax Type Dropdown
                      _buildDropdownField<TaxTypeModel>(
                        label: 'ประเภทภาษี *',
                        icon: Icons.account_balance_outlined,
                        notifier: taxTypeNotifier!,
                        items: taxTypes ?? [],
                        onChanged: (TaxTypeModel value) async {
                          setState(() {
                            selectedTaxType = value;
                            taxTypeNameCtrl.text = value.name;
                          });
                          taxTypeNotifier!.value = value;

                          // Reset tax point selection
                          setState(() {
                            selectedTaxPoint = null;
                            taxPointNameCtrl.text = '';
                          });
                          taxPointNotifier!.value = TaxPointModel(id: 0, name: 'เลือกจุดภาษี', taxTypeId: 0);

                          // Load tax points for selected tax type
                          await loadTaxPointsByType(value.id);
                        },
                      ),

                      const SizedBox(height: 16),

                      // Tax Point Dropdown - Conditional based on tax type selection
                      if (selectedTaxType != null)
                        _buildDropdownField<TaxPointModel>(
                          label: 'จุดภาษี *',
                          icon: Icons.location_on_outlined,
                          notifier: taxPointNotifier!,
                          items: taxPoints ?? [],
                          onChanged: (TaxPointModel value) {
                            setState(() {
                              selectedTaxPoint = value;
                              taxPointNameCtrl.text = value.name;
                            });
                            taxPointNotifier!.value = value;
                          },
                        )
                      else
                        _buildDisabledField(
                          label: 'จุดภาษี *',
                          icon: Icons.location_on_outlined,
                          placeholder: 'กรุณาเลือกประเภทภาษีก่อน',
                        ),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: _saveDefaultPawnConfiguration,
          backgroundColor: Colors.teal[700],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.save, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                "บันทึกการตั้งค่า".tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required IconData icon,
    required ValueNotifier notifier,
    required List<T> items,
    required Function(T) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: MiraiDropDownMenu<T>(
            key: UniqueKey(),
            children: items,
            space: 4,
            maxHeight: 360,
            showSearchTextField: true,
            selectedItemBackgroundColor: Colors.transparent,
            emptyListMessage: 'ไม่มีข้อมูล',
            showSelectedItemBackgroundColor: true,
            itemWidgetBuilder: (
                int index,
                T? project, {
                  bool isItemSelected = false,
                }) {
              return DropDownItemWidget(
                project: project,
                isItemSelected: isItemSelected,
                firstSpace: 10,
                fontSize: 16.sp,
              );
            },
            onChanged: onChanged,
            child: DropDownObjectChildWidget(
              key: GlobalKey(),
              fontSize: 16.sp,
              projectValueNotifier: notifier,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledField({
    required String label,
    required IconData icon,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal[600], size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    bool enabled = true,
    String? helperText,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (required)
          RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              children: const [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          )
        else
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: enabled ? Colors.grey[50] : Colors.grey[100],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: enabled ? Colors.grey[500] : Colors.grey[400],
                size: 20,
              ),
              hintText: 'กรอก$label',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: TextStyle(
              fontSize: 16,
              color: enabled ? Colors.black87 : Colors.grey[600],
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  void _saveDefaultPawnConfiguration() async {
    // Validation
    if (selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณาเลือกสาขา'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (selectedTaxType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณาเลือกประเภทภาษี'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (selectedTaxType!.name == 'VAT' && selectedTaxPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณาเลือกจุดภาษี'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Prepare data object matching database schema
    var object = Global.requestObj({
      "companyId": Global.user!.companyId.toString(),
      "branchId": selectedBranch!.id.toString(),
      "taxTypeId": selectedTaxType!.id.toString(),
      "taxTypeName": selectedTaxType!.name,
      "taxPointId": selectedTaxType!.name == 'SBT' ? 0 : selectedTaxPoint?.id.toString(),
      "taxPointName": selectedTaxType!.name == 'SBT' ? "" : selectedTaxPoint?.name,
    });

    Alert.info(context, 'ต้องการบันทึกข้อมูลหรือไม่?', '', 'ตกลง',
        action: () async {
          final ProgressDialog pr = ProgressDialog(context,
              type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
          await pr.show();
          pr.update(message: 'processing'.tr());

          try {
            var result = await ApiServices.post('/defaultpawn/create', object);

            motivePrint(result?.toJson());
            await pr.hide();

            if (result?.status == "success") {
              if (mounted) {
                Alert.success(
                    context,
                    'Success',
                    widget.defaultPawnModel == null
                        ? 'ตั้งค่าจำนำเริ่มต้นเรียบร้อยแล้ว'
                        : 'อัปเดตการตั้งค่าจำนำเริ่มต้นเรียบร้อยแล้ว',
                    'OK'.tr(), action: () {
                  Navigator.of(context).pop();
                });
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
        });
  }
}