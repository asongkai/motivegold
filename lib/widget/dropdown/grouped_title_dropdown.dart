import 'package:flutter/material.dart';
import 'package:motivegold/constants/colors.dart';
import 'package:motivegold/model/title_name.dart';
import 'package:sizer/sizer.dart';

class GroupedTitleDropdown extends StatefulWidget {
  final List<TitleNameModel> titleNames;
  final TitleNameModel? selectedTitle;
  final ValueChanged<TitleNameModel> onChanged;
  final String emptyMessage;
  final String? nationality;

  const GroupedTitleDropdown({
    super.key,
    required this.titleNames,
    required this.selectedTitle,
    required this.onChanged,
    this.emptyMessage = 'ไม่มีข้อมูล',
    this.nationality,
  });

  @override
  State<GroupedTitleDropdown> createState() => _GroupedTitleDropdownState();
}

class _GroupedTitleDropdownState extends State<GroupedTitleDropdown> {
  bool isExpanded = false;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  OverlayEntry? overlayEntry;
  final LayerLink layerLink = LayerLink();
  final FocusNode focusNode = FocusNode();

  // Track which categories are expanded (all expanded by default)
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _initializeExpandedCategories();
  }

  @override
  void didUpdateWidget(GroupedTitleDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If nationality changed, rebuild the overlay if it's open
    if (oldWidget.nationality != widget.nationality && overlayEntry != null) {
      overlayEntry?.markNeedsBuild();
    }
  }

  void _initializeExpandedCategories() {
    // Initialize categories: expand the one containing selected item, or first if none selected
    final groups = TitleNameGroup.groupByCategory(widget.titleNames);

    // Find which group contains the selected title
    String? selectedCategory;
    if (widget.selectedTitle != null) {
      for (var group in groups) {
        if (group.items.any((item) => item.id == widget.selectedTitle!.id)) {
          selectedCategory = group.category;
          break;
        }
      }
    }

    // Expand the selected category, or first category if no selection
    _expandedCategories.clear();
    for (var i = 0; i < groups.length; i++) {
      if (selectedCategory != null) {
        _expandedCategories[groups[i].category] = groups[i].category == selectedCategory;
      } else {
        _expandedCategories[groups[i].category] = i == 0;
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    removeOverlay();
    super.dispose();
  }

  void removeOverlay() {
    overlayEntry?.remove();
    overlayEntry = null;
    isExpanded = false;
  }

  void showOverlay() {
    if (overlayEntry != null) return;

    // Re-initialize expansion state when dropdown opens
    _initializeExpandedCategories();

    overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(overlayEntry!);
    setState(() {
      isExpanded = true;
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          removeOverlay();
          setState(() {});
        },
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: GestureDetector(
                  onTap: () {}, // Prevent tap from bubbling to parent
                  child: Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 300),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'ค้นหา...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                        overlayEntry?.markNeedsBuild();
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  // Grouped list
                  Flexible(
                    child: _buildGroupedList(),
                  ),
                ],
              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList() {
    // Check if no data is available at all
    if (widget.titleNames.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 12),
              Text(
                'กำลังโหลดข้อมูล...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
              ),
            ],
          ),
        ),
      );
    }

    // Filter titles based on search
    List<TitleNameModel> filteredTitles = widget.titleNames.where((title) {
      if (searchQuery.isEmpty) return true;
      return (title.name?.toLowerCase().contains(searchQuery) ?? false) ||
          (title.category?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();

    // Filter titles based on nationality
    if (widget.nationality == 'Thai') {
      // For Thai nationality: hide English titles (MR, MRS, MS, MISS)
      filteredTitles = filteredTitles.where((title) {
        final name = title.name?.toUpperCase() ?? '';
        return name != 'MR' && name != 'MRS' && name != 'MS' && name != 'MISS';
      }).toList();
    } else if (widget.nationality == 'Foreigner') {
      // For Foreigner nationality: show ONLY English titles (MR, MRS, MS, MISS)
      filteredTitles = filteredTitles.where((title) {
        final name = title.name?.toUpperCase() ?? '';
        return name == 'MR' || name == 'MRS' || name == 'MS' || name == 'MISS';
      }).toList();
    }

    if (filteredTitles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            searchQuery.isEmpty ? widget.emptyMessage : 'ไม่พบข้อมูลที่ค้นหา',
            style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
          ),
        ),
      );
    }

    // Group by category
    List<TitleNameGroup> groups = TitleNameGroup.groupByCategory(filteredTitles);

    // Build list manually with collapse/expand support
    List<Widget> widgets = [];
    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      // If category not in map, default to true for first group, false for others
      final isCategoryExpanded = _expandedCategories[group.category] ?? (i == 0);

      // Category header - clickable to collapse/expand
      widgets.add(
        InkWell(
          onTap: () {
            setState(() {
              _expandedCategories[group.category] = !isCategoryExpanded;
            });
            overlayEntry?.markNeedsBuild();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Icon(
                  isCategoryExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.category,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Items in this group - only show when expanded
      if (isCategoryExpanded) {
        for (var title in group.items) {
          final isSelected = widget.selectedTitle?.id == title.id;

          widgets.add(
            InkWell(
              onTap: () {
                widget.onChanged(title);
                removeOverlay();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.only(left: 44, right: 24, top: 12, bottom: 12),
                color: isSelected ? Colors.blue.withValues(alpha: 0.1) : Colors.transparent,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title.name ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.blue : textColor,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        color: Colors.blue,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: layerLink,
      child: GestureDetector(
        onTap: () {
          if (isExpanded) {
            removeOverlay();
          } else {
            showOverlay();
          }
          setState(() {});
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isExpanded ? Colors.blue : Colors.grey[300]!,
              width: isExpanded ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.titleNames.isEmpty && widget.selectedTitle == null
                    ? Row(
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'กำลังโหลด...',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.selectedTitle?.name ?? 'เลือกคำนำหน้า',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: widget.selectedTitle != null ? textColor : Colors.grey[600],
                        ),
                      ),
              ),
              Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
