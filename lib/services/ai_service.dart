import 'dart:convert';

import 'package:ciaraos/models/executive_brief.dart';
import 'package:http/http.dart' as http;

/// Override at run time:
/// `flutter run --dart-define=CIARA_AI_BACKEND_URL=http://localhost:8001`
abstract final class AiServiceConfig {
  static const String baseUrl = String.fromEnvironment(
    'CIARA_AI_BACKEND_URL',
    defaultValue: 'http://localhost:8001',
  );
}

class AiFetchResult {
  const AiFetchResult._({
    this.brief,
    this.errorMessage,
    this.reachedBackend = false,
  });

  final ExecutiveBrief? brief;
  final String? errorMessage;
  final bool reachedBackend;

  bool get isSuccess => brief != null;

  factory AiFetchResult.success(ExecutiveBrief brief) {
    return AiFetchResult._(brief: brief, reachedBackend: true);
  }

  factory AiFetchResult.connectionFailure(String message) {
    return AiFetchResult._(errorMessage: message);
  }

  factory AiFetchResult.httpFailure({
    required int statusCode,
    required String body,
  }) {
    final lowerBody = body.toLowerCase();
    String message;

    if (statusCode == 500 && lowerBody.contains('groq_api_key')) {
      message =
          'Backend is running but GROQ_API_KEY is not set. Add it to ciara_os_backend/.env.';
    } else if (lowerBody.contains('invalid api key') ||
        lowerBody.contains('invalid_api_key')) {
      message =
          'Backend is running but Groq rejected the API key. Update GROQ_API_KEY in ciara_os_backend/.env.';
    } else if (statusCode == 502 &&
        lowerBody.contains('invalid_ai_response')) {
      message =
          'Backend reached Groq but the response was invalid. Try again.';
    } else if (statusCode == 502) {
      message =
          'Backend returned an AI error ($statusCode). Check the backend terminal logs.';
    } else {
      message =
          'Backend error ($statusCode). Check the backend terminal logs.';
    }

    return AiFetchResult._(
      errorMessage: message,
      reachedBackend: true,
    );
  }

  factory AiFetchResult.parseFailure() {
    return const AiFetchResult._(
      errorMessage:
          'Backend responded but the brief could not be parsed. Try again.',
      reachedBackend: true,
    );
  }
}

class AiService {
  AiService({String? baseUrl}) : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<AiFetchResult> fetchBrief(Map<String, dynamic> payload) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/brief'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final brief = ExecutiveBrief.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
          return AiFetchResult.success(brief);
        } catch (_) {
          return AiFetchResult.parseFailure();
        }
      }

      return AiFetchResult.httpFailure(
        statusCode: response.statusCode,
        body: response.body,
      );
    } on Exception catch (error) {
      return AiFetchResult.connectionFailure(
        'Could not reach AI backend at $_baseUrl. '
        'Is it running? (${error.runtimeType})',
      );
    }
  }

  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
