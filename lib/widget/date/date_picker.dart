import 'package:flutter/material.dart';
import 'package:motivegold/utils/responsive_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SfDatePickerDialog extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime selectedDate) onDateSelected;

  const SfDatePickerDialog({
    super.key,
    required this.onDateSelected,
    this.initialDate,
  });

  @override
  State<SfDatePickerDialog> createState() => _SfDatePickerDialogState();
}

class _SfDatePickerDialogState extends State<SfDatePickerDialog> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    Screen size = Screen(MediaQuery.of(context).size);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 400, // <-- FIXED WIDTH TO PREVENT INFINITE CONSTRAINT
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'เลือกวันที่',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SfDateRangePicker(
                initialSelectedDate: _selectedDate,
                showNavigationArrow: true,
                selectionMode: DateRangePickerSelectionMode.single,
                onSelectionChanged: (args) {
                  if (args.value is DateTime) {
                    setState(() {
                      _selectedDate = args.value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      textStyle: TextStyle(fontSize: 16.sp),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('ยกเลิก'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: TextStyle(fontSize: 16.sp),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (_selectedDate != null) {
                        widget.onDateSelected(_selectedDate!);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('ตกลง'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
