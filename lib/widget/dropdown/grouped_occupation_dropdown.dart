import 'package:flutter/material.dart';
import 'package:motivegold/model/occupation.dart';
import 'package:sizer/sizer.dart';

class GroupedOccupationDropdown extends StatefulWidget {
  final List<OccupationModel> occupations;
  final OccupationModel? selectedOccupation;
  final ValueChanged<OccupationModel> onChanged;
  final String emptyMessage;

  const GroupedOccupationDropdown({
    Key? key,
    required this.occupations,
    required this.selectedOccupation,
    required this.onChanged,
    this.emptyMessage = 'ไม่มีข้อมูล',
  }) : super(key: key);

  @override
  State<GroupedOccupationDropdown> createState() => _GroupedOccupationDropdownState();
}

class _GroupedOccupationDropdownState extends State<GroupedOccupationDropdown> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  List<OccupationModel> _filteredOccupations = [];

  // Track which categories are expanded (all expanded by default)
  final Map<String, bool> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _filteredOccupations = widget.occupations;
    _initializeExpandedCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    removeOverlay();
    super.dispose();
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showDropdown() {
    _filteredOccupations = widget.occupations;
    _searchController.clear();

    // Re-initialize expansion state when dropdown opens
    _initializeExpandedCategories();

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _initializeExpandedCategories() {
    final groups = OccupationGroup.groupByCategory(widget.occupations);

    // Find which group contains the selected occupation
    String? selectedCategory;
    if (widget.selectedOccupation != null) {
      for (var group in groups) {
        if (group.items.any((item) => item.id == widget.selectedOccupation!.id)) {
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

  void _filterOccupations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredOccupations = widget.occupations;
      } else {
        _filteredOccupations = widget.occupations
            .where((occupation) =>
                occupation.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      }
    });
    // Rebuild overlay
    _overlayEntry?.markNeedsBuild();
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
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 300),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Search field
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterOccupations,
                            decoration: InputDecoration(
                              hintText: 'ค้นหา...',
                              hintStyle: TextStyle(fontSize: 13.sp),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
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
                                borderSide: const BorderSide(color: Colors.blue),
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        // Grouped items
                        Flexible(
                          child: _filteredOccupations.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    widget.emptyMessage,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  children: _buildGroupedItems(),
                                ),
                        ),
                      ],
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

  List<Widget> _buildGroupedItems() {
    final groups = OccupationGroup.groupByCategory(_filteredOccupations);
    List<Widget> widgets = [];

    for (var i = 0; i < groups.length; i++) {
      final group = groups[i];
      // If category not in map, default to true for first group, false for others
      final isExpanded = _expandedCategories[group.category] ?? (i == 0);

      // Category header - clickable to collapse/expand
      widgets.add(
        InkWell(
          onTap: () {
            setState(() {
              _expandedCategories[group.category] = !isExpanded;
            });
            _overlayEntry?.markNeedsBuild();
          },
          child: Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
            child: Row(
              children: [
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                  size: 20,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    group.category,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Category items (indented) - only show when expanded
      if (isExpanded) {
        for (var occupation in group.items) {
          widgets.add(
            InkWell(
              onTap: () {
                widget.onChanged(occupation);
                removeOverlay();
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.only(left: 44, right: 24, top: 12, bottom: 12),
                color: widget.selectedOccupation?.id == occupation.id
                    ? Colors.blue.withValues(alpha: 0.1)
                    : Colors.transparent,
                child: Text(
                  occupation.name ?? '',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[800],
                    fontWeight: widget.selectedOccupation?.id == occupation.id
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: () {
          if (_overlayEntry == null) {
            _showDropdown();
          } else {
            removeOverlay();
          }
          setState(() {});
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.selectedOccupation?.name ?? 'เลือกอาชีพ',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: widget.selectedOccupation == null
                        ? Colors.grey[600]
                        : Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _overlayEntry == null ? Icons.arrow_drop_down : Icons.arrow_drop_up,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
