import '../core/utils/date_formatter.dart';

class StatusHistory {
  final String id;
  final String requestId;
  final String? oldStatus;
  final String newStatus;
  final String? changedBy;
  final String? note;
  final DateTime? createdAt;
  final String? changerName;
  final String? changerRole;

  StatusHistory({
    required this.id,
    required this.requestId,
    this.oldStatus,
    required this.newStatus,
    this.changedBy,
    this.note,
    this.createdAt,
    this.changerName,
    this.changerRole,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    String? changerName;
    String? changerRole;
    if (json['changer'] != null && json['changer'] is Map<String, dynamic>) {
      changerName = json['changer']['full_name'] as String?;
      changerRole = json['changer']['role'] as String?;
    }

    return StatusHistory(
      id: json['id'] as String,
      requestId: json['request_id'] as String,
      oldStatus: json['old_status'] as String?,
      newStatus: json['new_status'] as String? ?? 'CREATED',
      changedBy: json['changed_by'] as String?,
      note: json['note'] as String?,
      createdAt: DateFormatter.parseDate(json['created_at']),
      changerName: changerName,
      changerRole: changerRole,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'old_status': oldStatus,
      'new_status': newStatus,
      'changed_by': changedBy,
      'note': note,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
