import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../providers/reflection_provider.dart';
import '../providers/workspace_provider.dart';
import '../widgets/neuron_card.dart';

class ReflectionScreen extends StatefulWidget {
  const ReflectionScreen({super.key});

  @override
  State<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends State<ReflectionScreen> {
  final TextEditingController _breakthroughController = TextEditingController();
  final TextEditingController _improvementController = TextEditingController();

  String _selectedEnergy = 'Flow State';
  int _focusRating = 5;
  bool _isSaving = false;

  final List<String> _energyLevels = ['Flow State ⚡', 'High Focus 🎯', 'Steady 🔋', 'Low Energy 💤'];

  @override
  void dispose() {
    _breakthroughController.dispose();
    _improvementController.dispose();
    super.dispose();
  }

  Future<void> _submitReflection() async {
    final breakthrough = _breakthroughController.text.trim();
    final improvement = _improvementController.text.trim();

    if (breakthrough.isEmpty && improvement.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please share at least one reflection note or breakthrough.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final refProv = context.read<ReflectionProvider>();
    final wsProv = context.read<WorkspaceProvider>();

    await refProv.saveReflection(
      energyLevel: _selectedEnergy.replaceAll(RegExp(r'[^a-zA-Z ]'), '').trim(),
      focusRating: _focusRating,
      breakthrough: breakthrough,
      improvementArea: improvement,
      workspaceName: wsProv.activeWorkspace.name,
    );

    setState(() {
      _isSaving = false;
      _breakthroughController.clear();
      _improvementController.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily reflection synthesized and saved to your Second Brain!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final refProv = context.watch<ReflectionProvider>();
    final wsProv = context.watch<WorkspaceProvider>();
    final reflections = refProv.reflections;
    final padding = Responsive.screenPadding(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daily Reflection & Synthesis',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: wsProv.activeWorkspace.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: wsProv.activeWorkspace.color.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(wsProv.activeWorkspace.icon, size: 14, color: wsProv.activeWorkspace.color),
                const SizedBox(width: 6),
                Text(
                  wsProv.activeWorkspace.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: wsProv.activeWorkspace.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: padding,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            Icon(Icons.psychology, color: Colors.white, size: 24),
                            Text(
                              'Cognitive Reflection Journal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Synthesize today\'s learnings, evaluate your cognitive flow state, and optimize your mental bandwidth for tomorrow.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Today's Form Card
                  NeuronCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s State of Mind',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Energy / Flow Chips
                        const Text(
                          'Energy & Focus Level',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _energyLevels.map((lvl) {
                              final isSelected = _selectedEnergy == lvl;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(lvl),
                                  selected: isSelected,
                                  onSelected: (_) => setState(() => _selectedEnergy = lvl),
                                  backgroundColor: AppTheme.card(context),
                                  selectedColor: AppColors.primary.withValues(alpha: 0.25),
                                  labelStyle: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? AppColors.primaryLight : AppTheme.secondaryText(context),
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? AppColors.primary : AppTheme.border(context),
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Focus Rating (1-5)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            const Text(
                              'Focus Quality (1-5):',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 8),
                            ...List.generate(5, (index) {
                              final rating = index + 1;
                              final isFilled = rating <= _focusRating;
                              return IconButton(
                                icon: Icon(
                                  isFilled ? Icons.star : Icons.star_border,
                                  color: isFilled ? Colors.amber : Colors.grey,
                                  size: 24,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                constraints: const BoxConstraints(),
                                onPressed: () => setState(() => _focusRating = rating),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Breakthrough Input
                        TextFormField(
                          controller: _breakthroughController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Main Breakthrough or Insight',
                            hintText: 'What key concept, task, or realization happened today?',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Improvement Input
                        TextFormField(
                          controller: _improvementController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Area for Optimization Tomorrow',
                            hintText: 'What distracted you or could be streamlined tomorrow?',
                            alignLabelWithHint: true,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _submitReflection,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.auto_awesome, size: 18),
                            label: Text(
                              _isSaving ? 'Synthesizing with AI...' : 'Synthesize & Save Reflection',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Reflection History
                  Text(
                    'Previous Syntheses & Reflection History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryText(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (reflections.isEmpty)
                    NeuronCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No reflection entries yet. Complete today\'s reflection above.',
                          style: TextStyle(color: AppTheme.secondaryText(context), fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...reflections.map((ref) => _buildReflectionCard(context, ref)),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionCard(BuildContext context, dynamic ref) {
    final dateStr = DateFormat('EEE, MMM d, y • h:mm a').format(ref.date as DateTime);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeuronCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ref.energyLevel as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        ref.focusRating as int,
                        (_) => const Icon(Icons.star, size: 12, color: Colors.amber),
                      ),
                    ),
                  ],
                ),
                Text(
                  dateStr,
                  style: TextStyle(fontSize: 11, color: AppTheme.secondaryText(context)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if ((ref.breakthrough as String).isNotEmpty) ...[
              Text(
                'Breakthrough:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ref.breakthrough as String,
                style: TextStyle(fontSize: 13, color: AppTheme.primaryText(context)),
              ),
              const SizedBox(height: 8),
            ],
            if ((ref.improvementArea as String).isNotEmpty) ...[
              Text(
                'Tomorrow\'s Focus:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.secondaryText(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ref.improvementArea as String,
                style: TextStyle(fontSize: 13, color: AppTheme.secondaryText(context)),
              ),
              const SizedBox(height: 10),
            ],
            // AI Synthesis Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardElevated(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      ref.aiSynthesis as String,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppTheme.primaryText(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
