import 'package:flutter/material.dart';
import '../data/models/motivation_model.dart';
import '../data/services/motivation_service.dart';

class MotivationProvider extends ChangeNotifier {
  List<Motivation> motivations = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? errorMessage;

  // 🔥 NEW
  bool isGenerating = false;

  Future<void> fetchMotivations() async {
    if (isLoading || !hasMore) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await MotivationService.getMotivations(page);
      final List data = result["data"] ?? [];

      if (data.isEmpty) {
        hasMore = false;
      } else {
        motivations.addAll(
          data.map((e) => Motivation.fromJson(e)).toList(),
        );
        page++;
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generate(String theme, int total) async {
    isGenerating = true;
    errorMessage = null;
    notifyListeners();

    try {
      await MotivationService.generateMotivation(theme, total);

      motivations.clear();
      page = 1;
      hasMore = true;

      await fetchMotivations();
      return errorMessage == null;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}
