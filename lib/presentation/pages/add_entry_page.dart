import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i18next/i18next.dart';
import 'package:uuid/uuid.dart';
import 'package:untense/core/constants/tension_zones.dart';
import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/domain/entities/tension_entry.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';
import 'package:untense/presentation/bloc/tension/tension_event.dart';
import 'package:untense/presentation/bloc/tension/tension_state.dart';
import 'package:untense/presentation/widgets/tension_slider.dart';
import 'package:untense/presentation/widgets/zone_indicator.dart';

/// Page for adding or editing a tension entry
class AddEntryPage extends StatefulWidget {
  /// If non-null, we are editing an existing entry
  final String? editEntryId;

  /// Optional pre-set timestamp for retroactive entries
  final DateTime? presetTimestamp;

  const AddEntryPage({super.key, this.editEntryId, this.presetTimestamp});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  late double _tensionLevel;
  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;
  final _situationController = TextEditingController();
  final _feelingController = TextEditingController();
  final _notesController = TextEditingController();
  final _selectedEmotions = <String>[];
  bool _isEditing = false;
  TensionEntry? _existingEntry;
  bool _isPastEntry = false;

  static const _availableEmotions = [
    'anger',
    'fear',
    'sadness',
    'joy',
    'disgust',
    'surprise',
    'shame',
    'guilt',
    'loneliness',
    'frustration',
    'anxiety',
    'contentment',
    'love',
    'hope',
    'gratitude',
    'overwhelm',
    'numbness',
    'restlessness',
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    _selectedDate = widget.presetTimestamp ?? now;
    _selectedTime = widget.presetTimestamp != null
        ? TimeOfDay.fromDateTime(widget.presetTimestamp!)
        : TimeOfDay.fromDateTime(now);
    _tensionLevel = 50;

    if (widget.presetTimestamp != null) {
      _isPastEntry = widget.presetTimestamp!.isBefore(now);
    }

    // If editing, load existing data
    if (widget.editEntryId != null) {
      _isEditing = true;
      _loadExistingEntry();
    }
  }

  void _loadExistingEntry() {
    final state = context.read<TensionBloc>().state;
    if (state is TensionLoaded) {
      try {
        _existingEntry = state.entries.firstWhere(
          (e) => e.id == widget.editEntryId,
        );
        _tensionLevel = _existingEntry!.tensionLevel;
        _selectedTime = TimeOfDay.fromDateTime(_existingEntry!.timestamp);
        _selectedDate = _existingEntry!.date;
        _situationController.text = _existingEntry!.situation ?? '';
        _feelingController.text = _existingEntry!.feeling ?? '';
        _notesController.text = _existingEntry!.notes ?? '';
        _selectedEmotions.addAll(_existingEntry!.emotions);
      } catch (_) {
        // Entry not found in current state
      }
    }
  }

  @override
  void dispose() {
    _situationController.dispose();
    _feelingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18Next.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? (i18n?.t('entry.editTitle') ?? 'Edit Entry')
              : (i18n?.t('entry.title') ?? 'New Entry'),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Past entry warning
            if (_isPastEntry)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        i18n?.t('entry.pastEntryHint') ??
                            'You are adding a past entry.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Date & Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n?.t('entry.time') ?? 'Time',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDate,
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              AppDateTimeUtils.formatDate(_selectedDate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickTime,
                            icon: const Icon(Icons.access_time, size: 18),
                            label: Text(
                              AppDateTimeUtils.formatTimeOfDay(_selectedTime),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tension Level
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n?.t('entry.tensionLevel') ?? 'Tension Level',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    TensionSlider(
                      value: _tensionLevel,
                      onChanged: (value) {
                        setState(() => _tensionLevel = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    ZoneIndicator(tensionLevel: _tensionLevel),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Situation
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n?.t('entry.whatHappened') ?? 'What happened?',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _situationController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            i18n?.t('entry.whatHappenedHint') ??
                            'Describe the situation...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Feelings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n?.t('entry.howDoYouFeel') ?? 'How do you feel?',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _feelingController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            i18n?.t('entry.howDoYouFeelHint') ??
                            'Describe your feelings...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Emotions chips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n?.t('entry.emotions') ?? 'Responsible Emotions',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      i18n?.t('entry.emotionsHint') ??
                          'Which emotions are responsible?',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableEmotions.map((emotion) {
                        final isSelected = _selectedEmotions.contains(emotion);
                        final zone = TensionZoneExtension.fromValue(
                          _tensionLevel,
                        );
                        return FilterChip(
                          label: Text(i18n?.t('emotions.$emotion') ?? emotion),
                          selected: isSelected,
                          selectedColor: zone.color.withValues(alpha: 0.2),
                          checkmarkColor: zone.color,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedEmotions.add(emotion);
                              } else {
                                _selectedEmotions.remove(emotion);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Additional notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i18n?.t('entry.notes') ?? 'Additional Notes',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            i18n?.t('entry.notesHint') ?? 'Further thoughts...',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(i18n?.t('entry.save') ?? 'Save'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isPastEntry = !AppDateTimeUtils.isToday(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        final timestamp = AppDateTimeUtils.dateAt(
          _selectedDate,
          picked.hour,
          picked.minute,
        );
        _isPastEntry = timestamp.isBefore(DateTime.now());
      });
    }
  }

  void _save() {
    final timestamp = AppDateTimeUtils.dateAt(
      _selectedDate,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final now = DateTime.now();

    if (_isEditing && _existingEntry != null) {
      final updated = _existingEntry!.copyWith(
        timestamp: timestamp,
        tensionLevel: _tensionLevel,
        situation: _situationController.text.trim(),
        feeling: _feelingController.text.trim(),
        emotions: List<String>.from(_selectedEmotions),
        notes: _notesController.text.trim(),
        updatedAt: now,
      );
      context.read<TensionBloc>().add(UpdateTensionEntry(updated));
    } else {
      final entry = TensionEntry(
        id: const Uuid().v4(),
        date: AppDateTimeUtils.startOfDay(_selectedDate),
        timestamp: timestamp,
        tensionLevel: _tensionLevel,
        situation: _situationController.text.trim(),
        feeling: _feelingController.text.trim(),
        emotions: List<String>.from(_selectedEmotions),
        notes: _notesController.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      context.read<TensionBloc>().add(AddTensionEntry(entry));
    }

    context.pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18Next.of(context)?.t('entry.saved') ?? 'Entry saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete() {
    final i18n = I18Next.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(i18n?.t('entry.deleteConfirmTitle') ?? 'Delete Entry'),
        content: Text(
          i18n?.t('entry.deleteConfirm') ??
              'Do you really want to delete this entry?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(i18n?.t('common.cancel') ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              if (_existingEntry != null) {
                context.read<TensionBloc>().add(
                  DeleteTensionEntry(_existingEntry!.id),
                );
              }
              context.pop(); // navigate back
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(i18n?.t('entry.deleted') ?? 'Entry deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(
              i18n?.t('common.delete') ?? 'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
