const profileTaglinePreferenceKey = 'profile_tagline';
const profileDisplayNamePreferenceKey = 'profile_display_name';
const profileNameConfiguredPreferenceKey = 'profile_name_configured';
const githubUsernamePreferenceKey = 'github_username';

const defaultProfileTagline = 'Software Engineer · Security Researcher';
const defaultProfileDisplayName = '';
const defaultGithubUsername = 'Ciara237';

/// Derives two-letter avatar initials from a display name.
String avatarInitialsFromName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) {
    return '?';
  }

  final parts =
      trimmed.split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  final word = parts.first;
  if (word.length >= 2) {
    return word.substring(0, 2).toUpperCase();
  }
  return word[0].toUpperCase();
}

String normalizeGithubUsername(String value) {
  return value.trim().replaceAll('@', '');
}

bool isValidGithubUsername(String value) {
  final normalized = normalizeGithubUsername(value);
  return normalized.isNotEmpty && !normalized.contains(RegExp(r'\s'));
}
