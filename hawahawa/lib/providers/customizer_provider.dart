import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:hawahawa/models/customizer_model.dart';
import 'package:hawahawa/services/firebase_presets_service.dart';

class CustomizerNotifier extends StateNotifier<CustomPreset> {
  final FirebasePresetsService _presetsService;

  CustomizerNotifier(this._presetsService) : super(const CustomPreset());

  void resetToDefault() => state = const CustomPreset();

  void setCloudDensity(double v) => state = state.copyWith(cloudDensity: v);
  void setRainIntensity(double v) => state = state.copyWith(rainIntensity: v);
  void setWindSpeed(double v) => state = state.copyWith(windSpeedOverride: v);
  void setParticleCount(double v) => state = state.copyWith(particleCount: v);
  void setAnimationSpeed(double v) => state = state.copyWith(animationSpeed: v);
  void setSkyGradientTop(Color c) => state = state.copyWith(skyGradientTop: c);
  void setSkyGradientBottom(Color c) => state = state.copyWith(skyGradientBottom: c);

  // Load preset
  void loadPreset(CustomPreset preset) {
    state = preset;
  }

  // Save preset locally (stub - for future local storage)
  void savePreset() {
    // Minimal local save stub - can implement with SharedPreferences later
    print('Preset saved locally');
  }

  // Save preset to Firebase
  Future<void> savePresetToFirebase(String presetName) async {
    await _presetsService.savePreset(state, presetName);
  }
}

final customizerProvider =
    StateNotifierProvider<CustomizerNotifier, CustomPreset>((ref) {
  final presetsService = ref.watch(firebasePresetsServiceProvider);
  return CustomizerNotifier(presetsService);
});
