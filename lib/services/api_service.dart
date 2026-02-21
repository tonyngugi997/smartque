import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use local backend during development.
  // - For Android emulator use 10.0.2.2 (emulator -> host machine).
  // - Alternatively, run `adb reverse tcp:3000 tcp:3000` and use http://localhost:3000
  // - Ensure your backend binds to 0.0.0.0 so the emulator can reach it.
  static const String _baseUrl = 'http://10.194.251.185:5000/api';
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Login API call to: $_baseUrl/auth/login');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('✅ Response status: ${response.statusCode}');

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'user': data['user'],
            'message': data['message'] ?? 'Login successful',
            'token': data['token'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Login failed',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
    } on http.ClientException catch (e) {
      print('🔥 ClientException: $e');
      return {
        'success': false,
        'error': 'Cannot connect to server. Please ensure backend is running.',
      };
    } catch (e) {
      print('🔥 Unexpected error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Generate OTP
  static Future<Map<String, dynamic>> generateOtp(String email) async {
    try {
      print('📱 Generate OTP API call for: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/generate-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      print('✅ OTP Response status: ${response.statusCode}');
      print('📄 OTP Response body: ${response.body}');

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': data['message'] ?? 'OTP sent',
            'otp': data['otp'], // to remove later
            'expiresIn': data['expiresIn'] ?? 300,
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to send OTP',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
    } on http.ClientException catch (e) {
      print('🔥 OTP ClientException: $e');
      return {
        'success': false,
        'error': 'Cannot connect to server. Please ensure backend is running.',
      };
    } catch (e) {
      print('🔥 OTP Unexpected error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      print('🔍 Verify OTP API call for: $email, OTP: $otp');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'otp': otp,
        }),
      );

      print('✅ Verify OTP Response status: ${response.statusCode}');
      print('📄 Verify OTP Response body: ${response.body}');

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': data['message'] ?? 'OTP verified',
            'verified': data['verified'] ?? false,
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Invalid OTP',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
    } on http.ClientException catch (e) {
      print('🔥 Verify OTP ClientException: $e');
      return {
        'success': false,
        'error': 'Cannot connect to server. Please ensure backend is running.',
      };
    } catch (e) {
      print('🔥 Verify OTP Unexpected error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Register with OTP
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    String? otp,
  }) async {
    try {
      print('📝 Register API call for: $email');

      final Map<String, dynamic> body = {
        'email': email,
        'password': password,
        'name': name,
      };

      // Add OTP
      if (otp != null && otp.isNotEmpty) {
        body['otp'] = otp;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('✅ Register Response status: ${response.statusCode}');
      print('📄 Register Response body: ${response.body}');

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 201 || response.statusCode == 200) {
          return {
            'success': true,
            'user': data['user'],
            'message': data['message'] ?? 'Registration successful',
            'token': data['token'],
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Registration failed',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
    } on http.ClientException catch (e) {
      print('🔥 Register ClientException: $e');
      return {
        'success': false,
        'error': 'Cannot connect to server. Please ensure backend is running.',
      };
    } catch (e) {
      print('🔥 Register Unexpected error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Check OTP status
  static Future<Map<String, dynamic>> checkOtpStatus(String email) async {
    try {
      print('📊 Check OTP status for: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/check-otp-status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      print('✅ OTP Status Response status: ${response.statusCode}');

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'hasVerifiedOtp': data['hasVerifiedOtp'] ?? false,
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to check OTP status',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
    } on http.ClientException catch (e) {
      print('🔥 OTP Status ClientException: $e');
      return {
        'success': false,
        'error': 'Cannot connect to server.',
      };
    } catch (e) {
      print('🔥 OTP Status Unexpected error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      print('🔑 Forgot password API call for: $email');

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/forgot-password'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      print('✅ Forgot password Response status: ${response.statusCode}');

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          return {
            'success': true,
            'message': data['message'] ?? 'Reset email sent',
          };
        } else {
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to send reset email',
          };
        }
      } else {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }
    } on http.ClientException catch (e) {
      print('🔥 Forgot password ClientException: $e');
      return {
        'success': false,
        'error': 'Cannot connect to server.',
      };
    } catch (e) {
      print('🔥 Forgot password Unexpected error: $e');
      return {
        'success': false,
        'error': 'An unexpected error occurred: $e',
      };
    }
  }

  // Test connection
  static Future<Map<String, dynamic>> testConnection() async {
    try {
      print('🌐 Testing connection to: $_baseUrl/health');

      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Connection successful',
        };
      } else {
        return {
          'success': false,
          'error': 'Server returned ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Cannot connect to server: $e',
      };
    }
  }

  // Appointment endpoints
  static Future<Map<String, dynamic>> bookAppointment({
    required String userId,
    required String doctorName,
    required String departmentName,
    required DateTime dateTime,
    required String queueNumber,
    required double consultationFee,
    required String token,
  }) async {
    try {
      print('📚 Booking appointment with data:');
      print('  - userId: $userId');
      print('  - doctorName: $doctorName');
      print('  - departmentName: $departmentName');
      print('  - dateTime: ${dateTime.toIso8601String()}');
      print('  - queueNumber: $queueNumber');
      print('  - token: ${token.substring(0, 20)}...');

      final client = http.Client();
      try {
        final response = await client
            .post(
          Uri.parse('$_baseUrl/appointments/book'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'userId': userId,
            'doctorName': doctorName,
            'departmentName': departmentName,
            'dateTime': dateTime.toIso8601String(),
            'queueNumber': queueNumber,
            'consultationFee': consultationFee,
          }),
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException(
                'Booking request timed out after 30 seconds');
          },
        );

        print('📡 Booking response status: ${response.statusCode}');
        print('📡 Booking response body: ${response.body}');

        if (response.body.isEmpty) {
          print('❌ Empty response from server');
          return {
            'success': false,
            'error': 'Empty response from server',
          };
        }

        final data = jsonDecode(response.body);
        if (response.statusCode == 201 || response.statusCode == 200) {
          print('✅ Appointment booked successfully');
          return {
            'success': true,
            'appointment': data['appointment'],
          };
        } else {
          print('❌ Booking failed: ${data['error']}');
          return {
            'success': false,
            'error': data['error'] ?? 'Failed to book appointment',
          };
        }
      } finally {
        client.close();
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Cannot connect to server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getUserAppointments({
    required String userId,
    required String token,
  }) async {
    try {
      print('📋 Fetching appointments for user: $userId');

      final response = await http.get(
        Uri.parse('$_baseUrl/appointments/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📋 Appointments response status: ${response.statusCode}');
      print('📋 Appointments response body: ${response.body}');

      if (response.body.isEmpty) {
        print('❌ Empty appointments response');
        return {
          'success': false,
          'appointments': [],
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('✅ Appointments fetched successfully');
        return {
          'success': true,
          'appointments': data['appointments'] ?? [],
        };
      } else {
        print('❌ Failed to fetch appointments: ${data['error']}');
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to fetch appointments',
          'appointments': [],
        };
      }
    } catch (e) {
      print('🔥 Error fetching appointments: $e');
      return {
        'success': false,
        'error': 'Cannot connect to server: $e',
        'appointments': [],
      };
    }
  }

  static Future<Map<String, dynamic>> cancelAppointment({
    required String appointmentId,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments/cancel/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Appointment cancelled successfully',
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to cancel appointment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Cannot connect to server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDateTime,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/appointments/reschedule/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'dateTime': newDateTime.toIso8601String(),
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'appointment': data['appointment'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to reschedule appointment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Cannot connect to server: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getNextQueueNumber({
    required String departmentName,
    required DateTime dateTime,
    required String token,
  }) async {
    try {
      final url =
          '$_baseUrl/appointments/next-queue?department=$departmentName&date=${dateTime.toIso8601String()}';
      print('🔢 Getting queue number from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('🔢 Queue response status: ${response.statusCode}');
      print('🔢 Queue response body: ${response.body}');

      if (response.body.isEmpty) {
        print('❌ Empty queue response');
        return {
          'success': false,
          'queueNumber': '1',
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('✅ Got queue number: ${data['queueNumber']}');
        return {
          'success': true,
          'queueNumber': data['queueNumber'],
        };
      } else {
        print('⚠️ Queue request failed, using default');
        return {
          'success': false,
          'queueNumber': '1',
        };
      }
    } catch (e) {
      print('🔥 Queue error: $e');
      return {
        'success': false,
        'queueNumber': '1',
      };
    }
  }

  static Future<Map<String, dynamic>> getQueuePosition({
    required String appointmentId,
    required String token,
  }) async {
    try {
      final url = '$_baseUrl/appointments/queue-position/$appointmentId';
      print('🔁 Getting queue position from: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.body.isEmpty) return {'success': false};

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.contains('application/json')) {
        print('⚠️ Queue position returned non-JSON (status ${response.statusCode}): ${response.body}');
        return {'success': false, 'raw': response.body, 'statusCode': response.statusCode};
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'success': true,
          'currentQueuePosition': data['currentQueuePosition'],
          'status': data['status'],
        };
      }
      return {'success': false, 'error': data['error'] ?? 'Unknown'};
    } catch (e) {
      print('🔥 Queue position error: $e');
      return {'success': false};
    }
  }

  // ------------------ Admin API Calls ------------------
  static Future<Map<String, dynamic>> getAdminUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.body.isEmpty) return {'success': false, 'users': []};
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'users': data['users'] ?? []};
      }
      return {'success': false, 'error': data['error'] ?? 'Failed to fetch users'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUserRole({
    required String userId,
    required String role,
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/admin/users/$userId/role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'role': role}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'error': data['error'] ?? 'Failed to update role'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAdminAppointments({
    String? status,
    String? date,
    required String token,
  }) async {
    try {
      var url = '$_baseUrl/admin/appointments';
      final params = <String>[];
      if (status != null) params.add('status=$status');
      if (date != null) params.add('date=$date');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.body.isEmpty) return {'success': false, 'appointments': []};
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'appointments': data['appointments'] ?? []};
      }
      return {'success': false, 'error': data['error'] ?? 'Failed to fetch appointments'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    required String token,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/admin/appointments/$appointmentId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'appointment': data['appointment']};
      }
      return {'success': false, 'error': data['error'] ?? 'Failed to update appointment'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> initiateMpesaPayment({
    required String phoneNumber,
    required double amount,
    String? accountReference,
    String? transactionDesc,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/payments/mpesa/stkpush'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'amount': amount,
          'accountReference': accountReference,
          'transactionDesc': transactionDesc,
        }),
      );

      if (response.body.isEmpty) return {'success': false, 'error': 'Empty response'};
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      }
      return {'success': false, 'error': data['error'] ?? 'Payment initiation failed', 'data': data};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAdminStats(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.body.isEmpty) return {'success': false};
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'stats': data['stats'] ?? {}};
      }
      return {'success': false, 'error': data['error'] ?? 'Failed to fetch stats'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Admin services (departments)
  static Future<Map<String, dynamic>> getAdminServices(String token) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/services'), headers: {'Content-Type':'application/json','Authorization':'Bearer $token'});
      if (response.body.isEmpty) return {'success': false, 'services': []};
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true, 'services': data['services'] ?? []};
      return {'success': false, 'error': data['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createAdminService(String name, String description, String token) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/admin/services'), headers: {'Content-Type':'application/json','Authorization':'Bearer $token'}, body: jsonEncode({'name': name, 'description': description}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) return {'success': true, 'service': data['service']};
      return {'success': false, 'error': data['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteAdminService(String id, String token) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/admin/services/$id'), headers: {'Content-Type':'application/json','Authorization':'Bearer $token'});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true};
      return {'success': false, 'error': data['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Admin counters
  static Future<Map<String, dynamic>> getAdminCounters(String token) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/counters'), headers: {'Content-Type':'application/json','Authorization':'Bearer $token'});
      if (response.body.isEmpty) return {'success': false, 'counters': []};
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true, 'counters': data['counters'] ?? []};
      return {'success': false, 'error': data['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createAdminCounter(String name, String? departmentId, bool isActive, String token) async {
    try {
      final response = await http.post(Uri.parse('$_baseUrl/admin/counters'), headers: {'Content-Type':'application/json','Authorization':'Bearer $token'}, body: jsonEncode({'name': name, 'departmentId': departmentId, 'isActive': isActive}));
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) return {'success': true, 'counter': data['counter']};
      return {'success': false, 'error': data['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateAdminCounter(String id, Map<String, dynamic> body, String token) async {
    try {
      final response = await http.patch(Uri.parse('$_baseUrl/admin/counters/$id'), headers: {'Content-Type':'application/json','Authorization':'Bearer $token'}, body: jsonEncode(body));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true, 'counter': data['counter']};
      return {'success': false, 'error': data['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getAdminDailyReport(String token) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/admin/reports/daily'), headers: {'Content-Type':'application/json','Authorization':'Bearer $token'});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) return {'success': true, 'report': data['report']};
      return {'success': false, 'error': data['error'] ?? 'Failed'};
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // ==================== M-PESA DARAJA (STK PUSH) ====================
  static Future<Map<String, dynamic>> initiateMpesaStkPush({
    required String phoneNumber,
    required double amount,
    String accountReference = 'SmarTQue Appointment',
    String transactionDesc = 'Appointment Payment',
  }) async {
    try {
      final url = '$_baseUrl/payments/mpesa/stkpush';
      print('📲 Initiating M-Pesa STK push to: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'amount': amount.toInt(), // M-Pesa expects integer amount
          'accountReference': accountReference,
          'transactionDesc': transactionDesc,
        }),
      );

      print('📲 STK response status: ${response.statusCode}');
      print('📲 STK response body: ${response.body}');

      if (response.body.isEmpty) {
        return {
          'success': false,
          'error': 'Empty response from server',
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Failed to initiate M-Pesa payment',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Cannot connect to server: $e',
      };
    }
  }
}
