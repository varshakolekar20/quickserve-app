import '../core/utils/date_formatter.dart';
import 'service_item.dart';
import 'user_profile.dart';

class ServiceRequest {
  final String id;
  final String requestId;
  final String customerId;
  final String serviceId;
  final String? agentId;
  final String description;
  final DateTime preferredDate;
  final String preferredTime;
  final String address;
  final String priority; // 'LOW', 'MEDIUM', 'HIGH'
  final String status;   // 'CREATED', 'ASSIGNED', 'ACCEPTED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined/Populated relations
  final ServiceItem? service;
  final UserProfile? customer;
  final UserProfile? agent;

  ServiceRequest({
    required this.id,
    required this.requestId,
    required this.customerId,
    required this.serviceId,
    this.agentId,
    required this.description,
    required this.preferredDate,
    required this.preferredTime,
    required this.address,
    this.priority = 'MEDIUM',
    this.status = 'CREATED',
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.service,
    this.customer,
    this.agent,
  });

  bool get canCancel => status == 'CREATED' || status == 'ASSIGNED';

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      requestId: json['request_id'] as String? ?? 'REQ-PENDING',
      customerId: json['customer_id'] as String,
      serviceId: json['service_id'] as String,
      agentId: json['agent_id'] as String?,
      description: json['description'] as String? ?? '',
      preferredDate: DateFormatter.parseDate(json['preferred_date']) ?? DateTime.now(),
      preferredTime: json['preferred_time'] as String? ?? 'Anytime',
      address: json['address'] as String? ?? '',
      priority: (json['priority'] as String? ?? 'MEDIUM').toUpperCase(),
      status: (json['status'] as String? ?? 'CREATED').toUpperCase(),
      notes: json['notes'] as String?,
      createdAt: DateFormatter.parseDate(json['created_at']),
      updatedAt: DateFormatter.parseDate(json['updated_at']),
      service: json['service'] != null ? ServiceItem.fromJson(json['service'] as Map<String, dynamic>) : null,
      customer: json['customer'] != null ? UserProfile.fromJson(json['customer'] as Map<String, dynamic>) : null,
      agent: json['agent'] != null ? UserProfile.fromJson(json['agent'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'request_id': requestId,
      'customer_id': customerId,
      'service_id': serviceId,
      'agent_id': agentId,
      'description': description,
      'preferred_date': DateFormatter.formatIsoDate(preferredDate),
      'preferred_time': preferredTime,
      'address': address,
      'priority': priority,
      'status': status,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  ServiceRequest copyWith({
    String? status,
    String? agentId,
    String? notes,
    UserProfile? agent,
    DateTime? updatedAt,
  }) {
    return ServiceRequest(
      id: id,
      requestId: requestId,
      customerId: customerId,
      serviceId: serviceId,
      agentId: agentId ?? this.agentId,
      description: description,
      preferredDate: preferredDate,
      preferredTime: preferredTime,
      address: address,
      priority: priority,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      service: service,
      customer: customer,
      agent: agent ?? this.agent,
    );
  }
}
