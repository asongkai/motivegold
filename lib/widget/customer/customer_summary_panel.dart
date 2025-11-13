import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomerSummaryPanel extends StatelessWidget {
  final String? idCard;
  final String? titleName;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? email;
  final String? phone;
  final DateTime? dateOfBirth;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? building;
  final String? roomNo;
  final String? floor;
  final String? address;
  final String? village;
  final String? moo;
  final String? soi;
  final String? road;
  final String? tambon;
  final String? amphure;
  final String? province;
  final String? postalCode;
  final String? remark;
  final String? occupation;

  const CustomerSummaryPanel({
    super.key,
    this.idCard,
    this.titleName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.issueDate,
    this.expiryDate,
    this.building,
    this.roomNo,
    this.floor,
    this.address,
    this.village,
    this.moo,
    this.soi,
    this.road,
    this.tambon,
    this.amphure,
    this.province,
    this.postalCode,
    this.remark,
    this.occupation,
  });

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _buildFullName() {
    final parts = <String>[];
    if (titleName?.isNotEmpty == true) parts.add(titleName!);
    if (firstName?.isNotEmpty == true) parts.add(firstName!);
    if (middleName?.isNotEmpty == true) parts.add(middleName!);
    if (lastName?.isNotEmpty == true) parts.add(lastName!);
    return parts.isEmpty ? '-' : parts.join(' ');
  }

  String _buildFullAddress() {
    final parts = <String>[];

    if (building?.isNotEmpty == true) parts.add('อาคาร $building');
    if (roomNo?.isNotEmpty == true) parts.add('เลขที่ห้อง $roomNo');
    if (floor?.isNotEmpty == true) parts.add('ชั้นที่ $floor');
    if (address?.isNotEmpty == true) parts.add('บ้านเลขที่ $address');
    if (village?.isNotEmpty == true) parts.add('หมู่บ้าน $village');
    if (moo?.isNotEmpty == true) parts.add('หมู่ที่ $moo');
    if (soi?.isNotEmpty == true) parts.add('ตรอก/ซอย $soi');
    if (road?.isNotEmpty == true) parts.add('ถนน $road');
    if (tambon?.isNotEmpty == true) parts.add('ตำบล/แขวง $tambon');
    if (amphure?.isNotEmpty == true) parts.add('อำเภอ/เขต $amphure');
    if (province?.isNotEmpty == true) parts.add('จังหวัด $province');
    if (postalCode?.isNotEmpty == true) parts.add(postalCode!);

    return parts.isEmpty ? '-' : parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), // Teal 50
        border: Border.all(
          color: const Color(0xFF80CBC4), // Teal 200
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.person,
                color: Color(0xFF00897B), // Teal 600
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'สรุปข้อมูลลูกค้า',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00695C), // Teal 700
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFF80CBC4), thickness: 1),
          const SizedBox(height: 12),

          // Summary fields
          _buildSummaryRow('เลขบัตรประชาชน:', idCard),
          _buildSummaryRow('ชื่อ:', _buildFullName()),
          _buildSummaryRow('อีเมล:', email),
          _buildSummaryRow('โทร:', phone),
          _buildSummaryRow('เกิด:', _formatDate(dateOfBirth)),
          _buildSummaryRow('วันที่ออกบัตร:', _formatDate(issueDate)),
          _buildSummaryRow('วันที่หมดอายุ:', _formatDate(expiryDate)),
          _buildSummaryRow('ที่อยู่:', _buildFullAddress(), maxLines: 5),
          _buildSummaryRow('หมายเหตุ:', remark),
          _buildSummaryRow('อาชีพ:', occupation),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String? value, {int maxLines = 2}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00695C), // Teal 700
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.isNotEmpty == true ? value! : '-',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
