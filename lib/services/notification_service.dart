// lib/services/notification_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String apiBase;

  NotificationService({required this.apiBase});

  Future<bool> sendParentAlert({
    required String studentId,
    required String email,
    required String phone,
    required String subject,
    required String htmlBody,
    required String whatsappMessage,
  }) async {
    final uri = Uri.parse('$apiBase/send_parent_alert');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'email': email,
        'phone': phone,
        'subject': subject,
        'htmlBody': htmlBody,
        'whatsappMessage': whatsappMessage,
      }),
    );

    if (res.statusCode == 200) {
      final j = jsonDecode(res.body);
      return j['ok'] == true;
    }

    return false;
  }
}
