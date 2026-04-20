import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/theme/theme_notifier.dart';
import '../../providers/motivation_provider.dart';

class MotivationScreen extends StatefulWidget {
  const MotivationScreen({super.key});

  @override
  State<MotivationScreen> createState() => _MotivationScreenState();
}

class _MotivationScreenState extends State<MotivationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final provider = context.read<MotivationProvider>();
    provider.fetchMotivations();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        provider.fetchMotivations();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat("dd MMM yyyy, HH:mm").format(parsed);
    } catch (_) {
      return date;
    }
  }

  void showGenerateDialog() {
    final themeController = TextEditingController();
    final totalController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Consumer<MotivationProvider>(
          builder: (context, provider, _) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: const [
                  Text("Generate Motivasi"),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: themeController,
                    decoration: InputDecoration(
                      labelText: "Theme",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: totalController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Total",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: provider.isGenerating
                      ? null
                      : () async {
                          final theme = themeController.text.trim();
                          final total =
                              int.tryParse(totalController.text.trim());

                          if (theme.isEmpty) {
                            _showMessage("Theme wajib diisi.");
                            return;
                          }

                          if (total == null || total <= 0) {
                            _showMessage(
                              "Total harus berupa angka lebih dari 0.",
                            );
                            return;
                          }

                          final success = await provider.generate(
                            theme,
                            total,
                          );

                          if (!dialogContext.mounted) return;

                          if (success) {
                            Navigator.pop(dialogContext);
                          } else if (provider.errorMessage != null) {
                            _showMessage(provider.errorMessage!);
                          }
                        },
                  child: provider.isGenerating
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text("Generating..."),
                          ],
                        )
                      : const Text("Generate"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MotivationProvider>();
    final theme = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Delcom Motivation",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showGenerateDialog,
        icon: const Icon(Icons.auto_awesome),
        label: const Text("Generate"),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          if (provider.errorMessage != null && provider.motivations.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Gagal memuat data",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: provider.fetchMotivations,
                      child: const Text("Coba lagi"),
                    ),
                  ],
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 120),
                itemCount: provider.motivations.length + 1,
                itemBuilder: (context, index) {
                  if (index < provider.motivations.length) {
                    final item = provider.motivations[index];
                    final number = index + 1;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6366F1),
                            Color(0xFF8B5CF6),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "#$number",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                formatDate(item.createdAt),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return provider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 8),
                              Text("Loading..."),
                            ],
                          ),
                        )
                      : const SizedBox();
                },
              ),
            ),
          if (provider.isGenerating)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
