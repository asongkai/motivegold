import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

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

  // Additional fields for non-Thai general customers
  final String? taxId;
  final String? workPermit;
  final String? passport;

  // Additional fields for company customers
  final String? companyName;
  final String? establishmentName;
  final String? taxNumber;
  final String? branchCode;
  final DateTime? registrationDate;
  final String? nationality;
  final String? country;

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
    this.taxId,
    this.workPermit,
    this.passport,
    this.companyName,
    this.establishmentName,
    this.taxNumber,
    this.branchCode,
    this.registrationDate,
    this.nationality,
    this.country,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // White background like in the 3rd image
        border: Border.all(
          color: Colors.grey[300]!, // Light gray border
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with icon
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.teal[700],
                size: 14.sp,
              ),
              const SizedBox(width: 8),
              Text(
                'สรุปข้อมูลลูกค้า',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Summary text - dark blue color like in the 3rd image
          Text(
            _buildSummaryText(),
            style: TextStyle(
              fontSize: 12.sp,
              color:
                  Color(0xFF1565C0), // Dark blue color matching the 3rd image
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _buildSummaryText() {
    final parts = <String>[];

    // Follow exact order from screenshots
    // ID Card / Tax Number (show Tax Number for company, ID Card for general)
    if (taxNumber?.isNotEmpty == true) {
      parts.add('เลขประจำตัวผู้เสียภาษี : $taxNumber');
    } else if (idCard?.isNotEmpty == true) {
      parts.add('เลขบัตรประชาชน : $idCard');
    }

    // Company name (for company customers)
    if (companyName?.isNotEmpty == true) parts.add('ชื่อผู้ประกอบการ : $companyName');

    // Establishment name (for company customers)
    if (establishmentName?.isNotEmpty == true) parts.add('ชื่อสถานประกอบการ : $establishmentName');

    // Name (for general customers)
    final fullName = _buildFullName();
    if (fullName != '-') parts.add('ชื่อ : $fullName');

    // Branch code (for company only)
    if (branchCode?.isNotEmpty == true) parts.add('รหัสสาขา : $branchCode');

    // Registration date (for company only)
    final regDate = _formatDate(registrationDate);
    if (regDate != '-') parts.add('วันที่จดทะเบียน : $regDate');

    // Email and Phone
    if (email?.isNotEmpty == true) parts.add('อีเมล : $email');
    if (phone?.isNotEmpty == true) parts.add('โทร : $phone');

    // Dates (for general customers)
    final dob = _formatDate(dateOfBirth);
    if (dob != '-') parts.add('เกิด : $dob');
    final issue = _formatDate(issueDate);
    if (issue != '-') parts.add('วันที่ออกบัตร : $issue');
    final expiry = _formatDate(expiryDate);
    if (expiry != '-') parts.add('วันที่หมดอายุ : $expiry');

    // Foreign customer documents
    if (taxId?.isNotEmpty == true) parts.add('Tax ID : $taxId');
    if (workPermit?.isNotEmpty == true) parts.add('Work Permit : $workPermit');
    if (passport?.isNotEmpty == true) parts.add('Passport : $passport');

    // Nationality and Country
    if (nationality?.isNotEmpty == true) parts.add('สัญชาติ : $nationality');
    if (country?.isNotEmpty == true) parts.add('ประเทศ : $country');

    // Address
    final address = _buildFullAddress();
    if (address != '-') parts.add('ที่อยู่ : $address');

    // Occupation
    if (occupation?.isNotEmpty == true) {
      parts.add('อาชีพ : $occupation');
    }

    // Remark (always last)
    if (remark?.isNotEmpty == true) {
      parts.add('หมายเหตุ : $remark');
    }

    // Join all parts with 3-4 spaces for readability (matching the image style)
    return parts.isEmpty ? '-' : parts.join('   ');
  }
}
