import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user settings via SharedPreferences
class SettingsState {
  final bool predictiveAi;
  final bool cognitiveLoad;
  final bool smartReminders;
  final bool anonymizedTraining;
  final int accentIndex;

  const SettingsState({
    this.predictiveAi = true,
    this.cognitiveLoad = true,
    this.smartReminders = true,
    this.anonymizedTraining = false,
    this.accentIndex = 0,
  });

  SettingsState copyWith({
    bool? predictiveAi,
    bool? cognitiveLoad,
    bool? smartReminders,
    bool? anonymizedTraining,
    int? accentIndex,
  }) =>
      SettingsState(
        predictiveAi: predictiveAi ?? this.predictiveAi,
        cognitiveLoad: cognitiveLoad ?? this.cognitiveLoad,
        smartReminders: smartReminders ?? this.smartReminders,
        anonymizedTraining: anonymizedTraining ?? this.anonymizedTraining,
        accentIndex: accentIndex ?? this.accentIndex,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      predictiveAi: prefs.getBool('predictiveAi') ?? true,
      cognitiveLoad: prefs.getBool('cognitiveLoad') ?? true,
      smartReminders: prefs.getBool('smartReminders') ?? true,
      anonymizedTraining: prefs.getBool('anonymizedTraining') ?? false,
      accentIndex: prefs.getInt('accentIndex') ?? 0,
    );
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('predictiveAi', state.predictiveAi);
    await prefs.setBool('cognitiveLoad', state.cognitiveLoad);
    await prefs.setBool('smartReminders', state.smartReminders);
    await prefs.setBool('anonymizedTraining', state.anonymizedTraining);
    await prefs.setInt('accentIndex', state.accentIndex);
  }

  void setPredictiveAi(bool v) {
    state = state.copyWith(predictiveAi: v);
    _save();
  }

  void setCognitiveLoad(bool v) {
    state = state.copyWith(cognitiveLoad: v);
    _save();
  }

  void setSmartReminders(bool v) {
    state = state.copyWith(smartReminders: v);
    _save();
  }

  void setAnonymizedTraining(bool v) {
    state = state.copyWith(anonymizedTraining: v);
    _save();
  }

  void setAccentIndex(int i) {
    state = state.copyWith(accentIndex: i);
    _save();
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
