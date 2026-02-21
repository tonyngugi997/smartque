class Appointment {
  final String id;
  final String userId;
  final String doctorName;
  final String departmentName;
  final DateTime dateTime;
  final String queueNumber;
  final String status;
  final double consultationFee;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.userId,
    required this.doctorName,
    required this.departmentName,
    required this.dateTime,
    required this.queueNumber,
    required this.status,
    required this.consultationFee,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'].toString(),
      userId: json['userId']?.toString() ?? '',
      doctorName: json['doctorName'] as String,
      departmentName: json['departmentName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      queueNumber: json['queueNumber'] as String,
      status: json['status'] as String,
      consultationFee: (json['consultationFee'] as num).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'doctorName': doctorName,
      'departmentName': departmentName,
      'dateTime': dateTime.toIso8601String(),
      'queueNumber': queueNumber,
      'status': status,
      'consultationFee': consultationFee,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
