// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../domain/entities/attendance_entity.dart';
import '../pages/attendance_detail_page.dart';
import 'attendance_status_badge.dart';

/// Kartu satu baris riwayat absensi (tanggal, jam masuk/pulang, badge status).
/// Dipakai di riwayat karyawan sendiri maupun detail karyawan oleh admin.
class AttendanceHistoryTile extends StatelessWidget {
  final AttendanceEntity record;
  const AttendanceHistoryTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('HH:mm');
    final pulang = record.hasClockedOut ? timeFmt.format(record.clockOut!) : '–';
    // Izin tak punya jam masuk/pulang — tampilkan alasannya sebagai ganti.
    final subtitle = record.isLeave
        ? ((record.reason?.trim().isNotEmpty ?? false)
            ? record.reason!.trim()
            : AppStrings.leaveTitle)
        : AppStrings.historyTileTimes(timeFmt.format(record.clockIn), pulang);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AttendanceDetailPage(record: record),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(formatTanggalLengkap(record.clockIn),
                        style: AppTextStyles.bodyBold),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AttendanceStatusBadge(status: record.status),
              Icon(Icons.chevron_right, color: AppColors.textHint),
            ],
          ),
        ),
      ),
    );
  }
}
