// lib/models/department_model.dart
import 'package:flutter/material.dart';

class HospitalDepartment {
  final String id;
  final String name;
  final String description;
  final String iconCode;
  final Color primaryColor;
  final Color secondaryColor;
  final List<String> specializations;
  final int doctorCount;
  final double avgRating;
  final String imageAsset;
  final List<String> commonProcedures;
  final int avgWaitTime; // in minutes
  final bool telemedicineAvailable;
  final bool emergencyService;

  HospitalDepartment({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCode,
    required this.primaryColor,
    required this.secondaryColor,
    required this.specializations,
    required this.doctorCount,
    required this.avgRating,
    required this.imageAsset,
    required this.commonProcedures,
    required this.avgWaitTime,
    required this.telemedicineAvailable,
    required this.emergencyService,
  });

  IconData get iconData {
    final icons = {
      'gynecology': Icons.female_outlined,
      'dentist': Icons.sentiment_satisfied,
      'psychology': Icons.psychology_outlined,
      'cardiology': Icons.favorite_outlined,
      'orthopedics': Icons.accessibility_outlined,
      'pediatrics': Icons.child_care_outlined,
      'neurology': Icons.memory_outlined,
      'dermatology': Icons.spa_outlined,
      'ophthalmology': Icons.remove_red_eye_outlined,
      'ent': Icons.hearing_outlined,
      'urology': Icons.water_drop_outlined,
      'gastroenterology': Icons.medical_services_outlined,
      'oncology': Icons.local_hospital_outlined,
      'endocrinology': Icons.monitor_heart_outlined,
      'nephrology': Icons.healing_outlined,
      'pulmonology': Icons.air_outlined,
      'rheumatology': Icons.accessible_outlined,
      'hematology': Icons.bloodtype_outlined,
      'radiology': Icons.scanner_outlined,
      'pathology': Icons.science_outlined,
    };
    return icons[iconCode] ?? Icons.medical_services_outlined;
  }

  factory HospitalDepartment.fromJson(Map<String, dynamic> json) {
    return HospitalDepartment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconCode: json['iconCode'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      specializations: List<String>.from(json['specializations']),
      doctorCount: json['doctorCount'],
      avgRating: json['avgRating'].toDouble(),
      imageAsset: json['imageAsset'],
      commonProcedures: List<String>.from(json['commonProcedures']),
      avgWaitTime: json['avgWaitTime'],
      telemedicineAvailable: json['telemedicineAvailable'],
      emergencyService: json['emergencyService'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
      'specializations': specializations,
      'doctorCount': doctorCount,
      'avgRating': avgRating,
      'imageAsset': imageAsset,
      'commonProcedures': commonProcedures,
      'avgWaitTime': avgWaitTime,
      'telemedicineAvailable': telemedicineAvailable,
      'emergencyService': emergencyService,
    };
  }
}
