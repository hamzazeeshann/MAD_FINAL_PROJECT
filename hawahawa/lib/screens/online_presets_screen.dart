import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/providers/auth_provider.dart';
import 'package:hawahawa/services/firebase_presets_service.dart';
import 'package:hawahawa/providers/customizer_provider.dart';
import 'package:hawahawa/widgets/scene_panel.dart';

class OnlinePresetsScreen extends ConsumerWidget {
  const OnlinePresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isAuthenticated;

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('MY CLOUD PRESETS'),
        backgroundColor: kDarkPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: isLoggedIn
              ? _buildPresetsView(context, ref)
              : _buildLoginRequired(context),
        ),
      ),
    );
  }

  Widget _buildLoginRequired(BuildContext context) {
    return ScenePanel(
      minWidth: 200,
      minHeight: 200,
      showBorder: true,
      borderWidth: 1,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock, color: kDarkAccent, size: 64),
            const SizedBox(height: 16),
            const Text(
              'LOGIN REQUIRED',
              style: TextStyle(
                color: kDarkText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please login to view and upload online presets',
              style: TextStyle(color: kDarkText.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkAccent,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              ),
              child: const Text('GO BACK'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetsView(BuildContext context, WidgetRef ref) {
    final presetsService = ref.watch(firebasePresetsServiceProvider);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: presetsService.getUserPresets(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: kDarkAccent),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: ScenePanel(
              minWidth: 200,
              minHeight: 100,
              showBorder: true,
              borderWidth: 1,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: kDarkText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final presets = snapshot.data ?? [];

        if (presets.isEmpty) {
          return Center(
            child: ScenePanel(
              minWidth: 200,
              minHeight: 200,
              showBorder: true,
              borderWidth: 1,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_off, color: kDarkText.withOpacity(0.3), size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'No presets saved yet',
                      style: TextStyle(color: kDarkText, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create one in the Customizer!',
                      style: TextStyle(color: kDarkText.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: presets.length,
          itemBuilder: (context, index) {
            final data = presets[index];
            final preset = presetsService.mapToPreset(data);
            final presetName = data['presetName'] ?? 'Unnamed Preset';
            final presetId = data['id'];

            return Card(
              color: kDarkSecondary,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [preset.skyGradientTop, preset.skyGradientBottom],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kDarkAccent.withOpacity(0.3)),
                  ),
                ),
                title: Text(
                  presetName,
                  style: const TextStyle(color: kDarkText, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Cloud: ${preset.cloudDensity.toStringAsFixed(2)} | Rain: ${preset.rainIntensity.toStringAsFixed(2)} | Wind: ${preset.windSpeedOverride.toStringAsFixed(0)}',
                  style: TextStyle(color: kDarkText.withOpacity(0.6), fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download, color: kDarkAccent),
                      tooltip: 'Load Preset',
                      onPressed: () {
                        ref.read(customizerProvider.notifier).loadPreset(preset);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Loaded "$presetName"')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Delete Preset',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: kDarkSecondary,
                            title: const Text('Delete Preset?', style: TextStyle(color: kDarkText)),
                            content: Text(
                              'Are you sure you want to delete "$presetName"?',
                              style: const TextStyle(color: kDarkText),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('CANCEL', style: TextStyle(color: kDarkText)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('DELETE', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await presetsService.deletePreset(presetId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Preset deleted')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}