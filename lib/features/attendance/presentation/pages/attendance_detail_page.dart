// Part of: Attendance - Presentation

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format_id.dart';
import '../../domain/entities/attendance_entity.dart';
import '../widgets/attendance_status_badge.dart';
import '../widgets/selfie_image.dart';

/// Detail satu catatan absensi: selfie, status, jam masuk/pulang, durasi, dan
/// koordinat. Dibuka dari halaman Riwayat.
class AttendanceDetailPage extends StatelessWidget {
  final AttendanceEntity record;
  const AttendanceDetailPage({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    if (record.isLeave) return _buildLeaveDetail(context);

    final timeFmt = DateFormat('HH:mm');
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.detailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 1,
              child: SelfieImage(selfieUrl: record.selfieUrl),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(formatTanggalLengkap(record.clockIn),
                    style: AppTextStyles.title),
              ),
              AttendanceStatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: 16),
          _InfoCard(rows: [
            _InfoRow(AppStrings.labelClockIn, timeFmt.format(record.clockIn)),
            _InfoRow(
              AppStrings.labelClockOut,
              record.hasClockedOut
                  ? timeFmt.format(record.clockOut!)
                  : AppStrings.notClockedOutYet,
            ),
            _InfoRow(
                AppStrings.labelDuration, _durationText(record.workDurationMinutes)),
            _InfoRow(
              AppStrings.labelLocationStatus,
              record.isInRadius ? AppStrings.inRadiusYes : AppStrings.inRadiusNo,
              valueColor:
                  record.isInRadius ? AppColors.success : AppColors.warning,
            ),
          ]),
          const SizedBox(height: 12),
          _InfoCard(rows: [
            _InfoRow(AppStrings.labelCoordIn,
                _coord(record.clockInLat, record.clockInLon)),
            if (record.clockOutLat != null && record.clockOutLon != null)
              _InfoRow(AppStrings.labelCoordOut,
                  _coord(record.clockOutLat!, record.clockOutLon!)),
          ]),
        ],
      ),
    );
  }

  String _coord(double lat, double lon) =>
      '${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}';

  /// Detail untuk catatan izin: tanggal + badge + alasan (tanpa selfie/jam/koordinat).
  Widget _buildLeaveDetail(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.detailTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(formatTanggalLengkap(record.clockIn),
                    style: AppTextStyles.title),
              ),
              AttendanceStatusBadge(status: record.status),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.labelReason, style: AppTextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text(
                    (record.reason?.trim().isNotEmpty ?? false)
                        ? record.reason!.trim()
                        : '-',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _durationText(int? minutes) {
  if (minutes == null) return '-';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return AppStrings.durationMinutes(m);
  return AppStrings.durationHourMinute(h, m);
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) Divider(height: 1, color: AppColors.divider),
              rows[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: AppTextStyles.subtitle)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyBold.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
