import 'package:flutter/material.dart';

import '../data/models/motivation_model.dart';
import '../data/services/motivation_service.dart';
import 'auth_provider.dart';

class MotivationProvider extends ChangeNotifier {
  AuthProvider? _authProvider;
  List<Motivation> motivations = [];
  int page = 1;
  bool isLoading = false;
  bool hasMore = true;
  String? errorMessage;
  bool isGenerating = false;

  void updateAuth(AuthProvider authProvider) {
    final wasAuthenticated = _authProvider?.isAuthenticated ?? false;
    _authProvider = authProvider;

    if (!authProvider.isAuthenticated && wasAuthenticated) {
      reset();
    }
  }

  void reset() {
    motivations = [];
    page = 1;
    isLoading = false;
    hasMore = true;
    errorMessage = null;
    isGenerating = false;
    notifyListeners();
  }

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
        motivations.addAll(data.map((e) => Motivation.fromJson(e)).toList());
        page++;
      }
    } on UnauthorizedException {
      errorMessage = 'Sesi berakhir. Silakan login kembali.';
      await _authProvider?.logout();
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
    } on UnauthorizedException {
      errorMessage = 'Sesi berakhir. Silakan login kembali.';
      await _authProvider?.logout();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isGenerating = false;
      notifyListeners();
    }
  }
}
