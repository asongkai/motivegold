import 'package:flutter/material.dart';
import 'package:motivegold/model/occupation.dart';
import 'package:sizer/sizer.dart';

class GroupedDropdownWidget extends StatelessWidget {
  final List<OccupationModel> items;
  final OccupationModel? selectedItem;
  final Function(OccupationModel) onChanged;
  final String label;
  final double? height;

  const GroupedDropdownWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.label,
    this.height,
  });

  Map<String, List<OccupationModel>> _groupByCategory() {
    Map<String, List<OccupationModel>> grouped = {};
    for (var item in items) {
      String category = item.category ?? 'อื่นๆ';
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () => _showGroupedDialog(context),
          child: Container(
            height: height ?? 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(
                color: const Color(0xFFECECEC),
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItem?.name ?? 'เลือก$label',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: selectedItem != null ? Colors.black87 : Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[700],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showGroupedDialog(BuildContext context) {
    final grouped = _groupByCategory();
    final searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Filter items based on search
            Map<String, List<OccupationModel>> filteredGroups = {};
            String searchQuery = searchController.text.toLowerCase();

            if (searchQuery.isEmpty) {
              filteredGroups = grouped;
            } else {
              for (var entry in grouped.entries) {
                var filtered = entry.value.where((item) =>
                  (item.name ?? '').toLowerCase().contains(searchQuery) ||
                  (item.category ?? '').toLowerCase().contains(searchQuery)
                ).toList();
                if (filtered.isNotEmpty) {
                  filteredGroups[entry.key] = filtered;
                }
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'เลือก$label',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search field
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'ค้นหา...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // Grouped list
                    Expanded(
                      child: filteredGroups.isEmpty
                          ? Center(
                              child: Text(
                                'ไม่พบข้อมูล',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14.sp,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredGroups.length,
                              itemBuilder: (context, groupIndex) {
                                String category = filteredGroups.keys.elementAt(groupIndex);
                                List<OccupationModel> groupItems = filteredGroups[category]!;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Category header
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal[50],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal[800],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Category items
                                    ...groupItems.map((item) {
                                      bool isSelected = selectedItem?.id == item.id;
                                      return InkWell(
                                        onTap: () {
                                          onChanged(item);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Colors.teal[100]
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            children: [
                                              if (isSelected)
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.teal[700],
                                                  size: 18,
                                                ),
                                              if (isSelected) const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  item.name ?? '',
                                                  style: TextStyle(
                                                    fontSize: 13.sp,
                                                    color: isSelected
                                                        ? Colors.teal[900]
                                                        : Colors.black87,
                                                    fontWeight: isSelected
                                                        ? FontWeight.w600
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                    const SizedBox(height: 12),
                                  ],
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
