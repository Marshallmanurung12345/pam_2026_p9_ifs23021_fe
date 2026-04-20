class ApiConstants {
  // Ganti dengan URL deploy kamu saat production
  static const String baseUrl = "http://127.0.0.1:5000";

  // Auth
  static const String login = "$baseUrl/auth/login";
  static const String me = "$baseUrl/auth/me";

  // Spots
  static const String spots = "$baseUrl/spots";
  static const String spotCategories = "$baseUrl/spots/categories";

  // Recommendations
  static const String recommendations = "$baseUrl/recommendations";
  static const String recommendationsGenerate = "$baseUrl/recommendations/generate";

  // Itineraries
  static const String itineraries = "$baseUrl/itineraries";
  static const String itinerariesGenerate = "$baseUrl/itineraries/generate";
}