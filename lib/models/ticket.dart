class Ticket {
  final String id;
  final String customerName;
  final String customerEmail;
  final String subject;
  final String issueType; // technical | billing | general | product | other
  final String description;
  final String priority; // low | medium | high | urgent
  final String status; // open | in_progress | resolved | closed
  final List<String>? attachments;
  final String? adminNotes;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? closedAt;

  const Ticket({
    required this.id,
    required this.customerName,
    required this.customerEmail,
    required this.subject,
    required this.issueType,
    required this.description,
    required this.priority,
    required this.status,
    this.attachments,
    this.adminNotes,
    this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.closedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      subject: json['subject'] as String,
      issueType: json['issueType'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      attachments: (json['attachments'] as List?)?.cast<String>(),
      adminNotes: json['adminNotes'] as String?,
      assignedTo: json['assignedTo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
      closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'subject': subject,
      'issueType': issueType,
      'description': description,
      'priority': priority,
      'status': status,
      if (attachments != null) 'attachments': attachments,
      if (adminNotes != null) 'adminNotes': adminNotes,
      if (assignedTo != null) 'assignedTo': assignedTo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
      if (closedAt != null) 'closedAt': closedAt!.toIso8601String(),
    };
  }
}


