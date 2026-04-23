import 'dart:convert';

class Motivation {
  final int id;
  final String placeName;
  final String description;
  final String reason;
  final String text;
  final String createdAt;

  Motivation({
    required this.id,
    required this.placeName,
    required this.description,
    required this.reason,
    required this.text,
    required this.createdAt,
  });

  factory Motivation.fromJson(Map<String, dynamic> json) {
    final rawText = (json['text'] ?? '').toString();
    final textJson = _parseJsonText(rawText);
    final placeName = _readString(json, const [
      'place_name',
      'placeName',
      'name',
      'title',
      'nama_tempat',
      'namaTempat',
    ]);
    final description = _readString(json, const ['description', 'deskripsi']);
    final reason = _readString(json, const ['reason', 'alasan']);
    final parsed = _parseTextFallback(rawText);
    final parsedPlaceName = _readString(textJson, const [
      'place_name',
      'placeName',
      'name',
      'title',
      'nama_tempat',
      'namaTempat',
    ]);
    final parsedDescription = _readString(textJson, const [
      'description',
      'deskripsi',
    ]);
    final parsedReason = _readString(textJson, const ['reason', 'alasan']);

    return Motivation(
      id: json['id'],
      placeName: placeName.isNotEmpty
          ? placeName
          : (parsedPlaceName.isNotEmpty ? parsedPlaceName : parsed.$1),
      description: description.isNotEmpty
          ? description
          : (parsedDescription.isNotEmpty ? parsedDescription : parsed.$2),
      reason: reason.isNotEmpty
          ? reason
          : (parsedReason.isNotEmpty ? parsedReason : parsed.$3),
      text: rawText,
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }

  static Map<String, dynamic> _parseJsonText(String text) {
    final trimmed = text.trim();
    if (!trimmed.startsWith('{') || !trimmed.endsWith('}')) {
      return const {};
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return const {};
    }

    return const {};
  }

  static String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  static (String, String, String) _parseTextFallback(String text) {
    if (text.trim().isEmpty) {
      return ('Tempat wisata', '-', '-');
    }

    final lines = text
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String placeName = '';
    String description = '';
    String reason = '';

    for (final line in lines) {
      final normalized = line.toLowerCase();
      if (placeName.isEmpty &&
          (normalized.startsWith('nama tempat:') ||
              normalized.startsWith('tempat:') ||
              normalized.startsWith('judul:') ||
              normalized.startsWith('name:'))) {
        placeName = _valueAfterColon(line);
      } else if (description.isEmpty &&
          (normalized.startsWith('deskripsi:') ||
              normalized.startsWith('description:'))) {
        description = _valueAfterColon(line);
      } else if (reason.isEmpty &&
          (normalized.startsWith('alasan:') ||
              normalized.startsWith('reason:'))) {
        reason = _valueAfterColon(line);
      }
    }

    if (placeName.isEmpty && lines.isNotEmpty) {
      placeName = lines.first;
    }
    if (description.isEmpty && lines.length > 1) {
      description = lines[1];
    }
    if (reason.isEmpty && lines.length > 2) {
      reason = lines.sublist(2).join(' ');
    }

    return (
      placeName.isNotEmpty ? placeName : 'Tempat wisata',
      description.isNotEmpty ? description : '-',
      reason.isNotEmpty ? reason : '-',
    );
  }

  static String _valueAfterColon(String value) {
    final parts = value.split(':');
    if (parts.length < 2) {
      return value.trim();
    }
    return parts.sublist(1).join(':').trim();
  }
}
