import 'package:flutter/material.dart';
import '../models/reflection_model.dart';
import '../services/storage_service.dart';
import 'activity_provider.dart';

class ReflectionProvider extends ChangeNotifier {
  static const String _storageKey = 'neuron_reflections_history';

  List<ReflectionModel> _reflections = [];
  ActivityProvider? _activityProvider;

  ReflectionProvider() {
    _reflections = _seedDefaultReflections();
    _init();
  }

  List<ReflectionModel> get reflections => List.unmodifiable(_reflections);

  void updateActivityProvider(ActivityProvider activity) {
    _activityProvider = activity;
  }

  Future<void> _init() async {
    final savedJson = await StorageService.getString(_storageKey);
    if (savedJson != null && savedJson.isNotEmpty) {
      final decoded = ReflectionModel.decodeList(savedJson);
      if (decoded.isNotEmpty) {
        _reflections = decoded;
        notifyListeners();
      }
    }
  }

  Future<void> saveReflection({
    required String energyLevel,
    required int focusRating,
    required String breakthrough,
    required String improvementArea,
    required String workspaceName,
  }) async {
    final synthesis = _generateSynthesis(
      energyLevel: energyLevel,
      focusRating: focusRating,
      breakthrough: breakthrough,
      improvementArea: improvementArea,
    );

    final newReflection = ReflectionModel(
      id: 'ref_${DateTime.now().millisecondsSinceEpoch}',
      date: DateTime.now(),
      energyLevel: energyLevel,
      focusRating: focusRating,
      breakthrough: breakthrough,
      improvementArea: improvementArea,
      aiSynthesis: synthesis,
      workspaceName: workspaceName,
    );

    _reflections.insert(0, newReflection);
    await StorageService.setString(_storageKey, ReflectionModel.encodeList(_reflections));
    notifyListeners();

    _activityProvider?.logActivity(
      title: 'Daily Reflection Logged',
      source: 'Reflection',
      category: 'Reflection',
      actionType: 'Synthesized',
      iconCodePoint: Icons.psychology.codePoint,
      colorValue: 0xFF7955F5,
      details: 'Cognitive synthesis complete. Energy: $energyLevel ($focusRating/5).',
    );
  }

  String _generateSynthesis({
    required String energyLevel,
    required int focusRating,
    required String breakthrough,
    required String improvementArea,
  }) {
    return 'Cognitive pattern analysis indicates a $energyLevel session ($focusRating/5 focus). '
        'Key milestone achieved: "${breakthrough.isNotEmpty ? breakthrough : "Focused deep work"}". '
        'Recommended adjustment for tomorrow: Address "${improvementArea.isNotEmpty ? improvementArea : "Context switching"}" '
        'by scheduling uninterrupted 45-minute sprint blocks in your active workspace.';
  }

  List<ReflectionModel> _seedDefaultReflections() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return [
      ReflectionModel(
        id: 'ref_seed_1',
        date: yesterday,
        energyLevel: 'Flow State',
        focusRating: 5,
        breakthrough: 'Solved Flutter responsive layout constraints and completed riverpod models.',
        improvementArea: 'Need to balance code time with taking hydration breaks.',
        aiSynthesis: 'Outstanding productivity! High focus duration coupled with technical problem solving. Continue time-blocking high-cognitive tasks in morning hours.',
        workspaceName: 'Projects',
      ),
    ];
  }
}
