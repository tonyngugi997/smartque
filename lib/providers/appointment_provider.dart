import 'package:flutter/foundation.dart';
import 'package:advanced_login_app/models/appointment_model.dart';
import 'package:advanced_login_app/services/api_service.dart';

class AppointmentProvider extends ChangeNotifier {
  List<Appointment> _appointments = [];
  String? _userId;
  String? _authToken;
  final Map<String, int> _queuePositions = {};

  List<Appointment> get appointments {
    _ensureAppointmentListType();
    return _appointments;
  }

  List<Appointment> get upcomingAppointments {
    _ensureAppointmentListType();
    final now = DateTime.now();
    return _appointments
        .where((apt) => apt.dateTime.isAfter(now) && ['upcoming', 'pending', 'approved', 'in_progress'].contains(apt.status))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> get userAppointments {
    _ensureAppointmentListType();
    if (_userId == null) return [];
    return _appointments.where((apt) => apt.userId == _userId).toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  void setUserContext(String userId, String authToken) {
    _userId = userId;
    _authToken = authToken;
  }

  void _ensureAppointmentListType() {
    try {
      final List<dynamic> dynamicList = _appointments as dynamic;
      _appointments = dynamicList
          .map((item) {
            if (item is Map<String, dynamic>) {
              return Appointment.fromJson(item);
            }
            return item as Appointment;
          })
          .cast<Appointment>()
          .toList();
    } catch (e) {
      _appointments = [];
    }
  }

  Future<void> loadAppointments() async {
    if (_userId == null || _authToken == null) {
      _appointments = [];
      notifyListeners();
      return;
    }

    try {
      final result = await ApiService.getUserAppointments(
        userId: _userId!,
        token: _authToken!,
      );

      if (result['success']) {
        final List<dynamic> appointments = result['appointments'] ?? [];
        _appointments = appointments
            .map((apt) => Appointment.fromJson(apt as Map<String, dynamic>))
            .toList();
      } else {
        _appointments = [];
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading appointments: $e');
      }
      _appointments = [];
      notifyListeners();
    }
  }

  int? queuePositionFor(String appointmentId) => _queuePositions[appointmentId];

  Future<void> refreshQueuePosition(String appointmentId) async {
    if (_authToken == null) return;
    try {
      final res = await ApiService.getQueuePosition(appointmentId: appointmentId, token: _authToken!);
      if (res['success'] == true && res['currentQueuePosition'] != null) {
        final pos = int.tryParse(res['currentQueuePosition'].toString()) ?? 0;
        _queuePositions[appointmentId] = pos;
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) print('Error refreshing queue position: $e');
    }
  }

  Future<void> refreshAllQueuePositions() async {
    final ids = _appointments.map((a) => a.id).toList();
    for (final id in ids) {
      await refreshQueuePosition(id);
    }
  }

  Future<bool> bookAppointment({
    required String doctorName,
    required String departmentName,
    required DateTime dateTime,
    required double consultationFee,
  }) async {
    if (_userId == null || _authToken == null) {
      if (kDebugMode) {
        print('User not authenticated');
      }
      return false;
    }

    try {
      // Get next queue number
      final queueResult = await ApiService.getNextQueueNumber(
        departmentName: departmentName,
        dateTime: dateTime,
        token: _authToken!,
      );

      final queueNumber = queueResult['queueNumber']?.toString() ?? '1';

      // Book appointment
      final result = await ApiService.bookAppointment(
        userId: _userId!,
        doctorName: doctorName,
        departmentName: departmentName,
        dateTime: dateTime,
        queueNumber: queueNumber,
        consultationFee: consultationFee,
        token: _authToken!,
      );

      if (result['success']) {
        final appointment = Appointment.fromJson(result['appointment']);
        _appointments = List<Appointment>.from(_appointments)..add(appointment);
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          print('Error booking appointment: ${result['error']}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error booking appointment: $e');
      }
      return false;
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    if (_authToken == null) {
      return false;
    }

    try {
      final result = await ApiService.cancelAppointment(
        appointmentId: appointmentId,
        token: _authToken!,
      );

      if (result['success']) {
        _appointments.removeWhere((apt) => apt.id == appointmentId);
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error canceling appointment: $e');
      }
      return false;
    }
  }

  Future<bool> rescheduleAppointment(
    String appointmentId,
    DateTime newDateTime,
  ) async {
    if (_authToken == null) {
      return false;
    }

    try {
      final result = await ApiService.rescheduleAppointment(
        appointmentId: appointmentId,
        newDateTime: newDateTime,
        token: _authToken!,
      );

      if (result['success']) {
        final updatedAppointment = Appointment.fromJson(result['appointment']);
        final index =
            _appointments.indexWhere((apt) => apt.id == appointmentId);
        if (index != -1) {
          _appointments[index] = updatedAppointment;
        }
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error rescheduling appointment: $e');
      }
      return false;
    }
  }
}
