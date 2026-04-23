class ApiConstants {
  // Override dengan --dart-define=API_BASE_URL=...
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: "https://pam-2026-p9-ifs23021.marshalll.fun:8080",
  );

  // Auth
  static const String login = "$baseUrl/auth/login";
  static const String me = "$baseUrl/auth/me";

  // Recommendations
  static const String recommendations = "$baseUrl/recommendations";
  static const String generate = "$baseUrl/recommendations/generate";
}
