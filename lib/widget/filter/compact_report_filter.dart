import 'package:flutter/material.dart';
import 'package:motivegold/widget/date/date_picker.dart';

/// Compact report filter widget for all report screens
/// Features:
/// - Collapsible filter section with summary
/// - Date range picker fields
/// - Optional custom filter fields
/// - Search and Reset buttons
/// - Reduced padding and margins for compact display
class CompactReportFilter extends StatefulWidget {
  final TextEditingController fromDateController;
  final TextEditingController toDateController;
  final VoidCallback onSearch;
  final VoidCallback onReset;
  final String? filterSummary;
  final List<Widget>? additionalFilters;
  final bool initiallyExpanded;
  final bool autoCollapseOnSearch;

  const CompactReportFilter({
    Key? key,
    required this.fromDateController,
    required this.toDateController,
    required this.onSearch,
    required this.onReset,
    this.filterSummary,
    this.additionalFilters,
    this.initiallyExpanded = false,
    this.autoCollapseOnSearch = true,
  }) : super(key: key);

  @override
  State<CompactReportFilter> createState() => _CompactReportFilterState();
}

class _CompactReportFilterState extends State<CompactReportFilter> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with toggle
          InkWell(
            onTap: () => setState(() => isExpanded = !isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.filter_alt_rounded,
                        color: Colors.indigo[600], size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ตัวกรองข้อมูล',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        if (widget.filterSummary != null &&
                            widget.filterSummary!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.filterSummary!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[600], size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Filter content
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: isExpanded
                ? Column(
                    children: [
                      Divider(height: 1, color: Colors.grey[200]),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            // Additional filters if provided (month/year dropdowns first)
                            if (widget.additionalFilters != null &&
                                widget.additionalFilters!.isNotEmpty) ...[
                              ...widget.additionalFilters!,
                              const SizedBox(height: 12),
                            ],

                            // Date range row
                            Row(
                              children: [
                                Expanded(
                                  child: _CompactDateField(
                                    label: 'จากวันที่',
                                    controller: widget.fromDateController,
                                    onClear: () {
                                      setState(() {
                                        widget.fromDateController.clear();
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _CompactDateField(
                                    label: 'ถึงวันที่',
                                    controller: widget.toDateController,
                                    onClear: () {
                                      setState(() {
                                        widget.toDateController.clear();
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: SizedBox(
                                    height: 42,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        elevation: 1,
                                      ),
                                      onPressed: () {
                                        if (widget.autoCollapseOnSearch) {
                                          setState(() => isExpanded = false);
                                        }
                                        widget.onSearch();
                                      },
                                      icon: const Icon(Icons.search_rounded,
                                          size: 18),
                                      label: const Text(
                                        'ค้นหา',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    height: 42,
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                            color: Colors.red[400]!, width: 1.5),
                                        foregroundColor: Colors.red[400],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: widget.onReset,
                                      icon: const Icon(Icons.clear_rounded,
                                          size: 18),
                                      label: const Text(
                                        'Reset',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Compact date field component with reduced padding
class _CompactDateField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onClear;

  const _CompactDateField({
    Key? key,
    required this.label,
    required this.controller,
    required this.onClear,
  }) : super(key: key);

  @override
  State<_CompactDateField> createState() => _CompactDateFieldState();
}

class _CompactDateFieldState extends State<_CompactDateField> {
  @override
  void initState() {
    super.initState();
    // Listen to controller changes to rebuild when text changes
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    // Rebuild when controller text changes
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 13, color: Colors.grey[600]),
              const SizedBox(width: 5),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 42,
          child: TextField(
            key: ValueKey(widget.controller.text),
            controller: widget.controller,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.event, size: 16),
              suffixIcon: widget.controller.text.isNotEmpty
                  ? GestureDetector(
                      onTap: widget.onClear,
                      child: const Icon(Icons.clear, size: 16),
                    )
                  : null,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              hintText: widget.label,
              hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
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
                borderSide: BorderSide(color: Colors.indigo[600]!, width: 1.5),
              ),
            ),
            readOnly: true,
            onTap: () async {
              showDialog(
                context: context,
                builder: (_) => SfDatePickerDialog(
                  initialDate: DateTime.now(),
                  onDateSelected: (date) {
                    widget.controller.text = date.toString().split(' ')[0];
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
