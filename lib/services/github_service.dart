import 'dart:convert';

import 'package:ciaraos/models/github_activity.dart';
import 'package:ciaraos/services/ai_service.dart';
import 'package:http/http.dart' as http;

class GitHubService {
  GitHubService({String? baseUrl})
      : _baseUrl = baseUrl ?? AiServiceConfig.baseUrl;

  final String _baseUrl;

  Future<GitHubActivity> fetchActivity({
    String? username,
    bool force = false,
  }) async {
    final params = <String, String>{};
    if (username != null && username.isNotEmpty) {
      params['username'] = username;
    }
    if (force) {
      params['force'] = 'true';
    }
    final uri = Uri.parse('$_baseUrl/api/github/activity').replace(
      queryParameters: params.isEmpty ? null : params,
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        return GitHubActivity.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }

      final detail = _responseDetail(response.body);
      if (response.statusCode == 404) {
        throw GitHubUserNotFoundException(username ?? 'unknown');
      }
      if (response.statusCode == 429) {
        throw GitHubRateLimitException();
      }
      if (response.statusCode == 503 || response.statusCode == 502) {
        throw GitHubFetchException(
          'Backend or GitHub API unavailable ($detail)',
        );
      }

      throw GitHubFetchException(
        'GitHub sync failed (${response.statusCode}): $detail',
      );
    } on GitHubFetchException {
      rethrow;
    } catch (error) {
      throw GitHubFetchException(
        'Could not reach backend at $_baseUrl — is uvicorn running?',
        cause: error,
      );
    }
  }

  String _responseDetail(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return json['detail'] as String? ?? body;
    } catch (_) {
      return body.isEmpty ? 'unknown error' : body;
    }
  }
}

class GitHubFetchException implements Exception {
  GitHubFetchException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

class GitHubUserNotFoundException extends GitHubFetchException {
  GitHubUserNotFoundException(String username)
      : super("GitHub user '$username' not found — check Settings > GitHub Username");
}

class GitHubRateLimitException extends GitHubFetchException {
  GitHubRateLimitException()
      : super(
          'GitHub rate limit hit. Add GITHUB_TOKEN to the backend .env and restart.',
        );
}
