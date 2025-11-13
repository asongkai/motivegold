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

  @override
  void initState() {
    super.initState();
    _filteredOccupations = widget.occupations;
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

    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
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
                    constraints: const BoxConstraints(maxHeight: 400),
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

    for (var group in groups) {
      // Category header
      widgets.add(
        Container(
          padding: const EdgeInsets.only(left: 16, right: 24, top: 12, bottom: 8),
          child: Text(
            group.category,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ),
      );

      // Category items (indented)
      for (var occupation in group.items) {
        widgets.add(
          InkWell(
            onTap: () {
              widget.onChanged(occupation);
              removeOverlay();
              setState(() {});
            },
            child: Container(
              padding: const EdgeInsets.only(left: 32, right: 24, top: 12, bottom: 12),
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
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    fontSize: 14.sp,
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
