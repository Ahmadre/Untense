import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18next/i18next.dart';
import 'package:uuid/uuid.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import 'package:untense/core/constants/tension_zones.dart';
import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/di/service_locator.dart';
import 'package:untense/domain/entities/tension_entry.dart';
import 'package:untense/domain/repositories/tension_repository.dart';
import 'package:untense/presentation/bloc/tension/tension_bloc.dart';
import 'package:untense/presentation/bloc/tension/tension_event.dart';
import 'package:untense/presentation/widgets/tension_slider.dart';
import 'package:untense/presentation/widgets/zone_indicator.dart';

/// Shows a WoltModalSheet to add or edit a tension entry.
///
/// - On mobile (<600 dp): bottom sheet
/// - On desktop (≥600 dp): centred dialog
///
/// Pattern lifted from [Pollino](https://github.com/Ahmadre/Pollino).
class EntryModalSheet {
  EntryModalSheet._();

  // ───────────────── public API ─────────────────

  /// Opens the sheet for **creating** a new entry.
  static Future<void> showAdd(
    BuildContext context, {
    DateTime? presetTimestamp,
  }) {
    return _show(context, presetTimestamp: presetTimestamp);
  }

  /// Opens the sheet for **editing** an existing entry.
  static Future<void> showEdit(
    BuildContext context, {
    required String entryId,
  }) {
    return _show(context, editEntryId: entryId);
  }

  // ───────────────── internal ─────────────────

  static Future<void> _show(
    BuildContext context, {
    String? editEntryId,
    DateTime? presetTimestamp,
  }) {
    // We need the outer TensionBloc so the form can dispatch events.
    final tensionBloc = context.read<TensionBloc>();

    return WoltModalSheet.show<void>(
      context: context,
      pageListBuilder: (modalSheetContext) {
        return [
          _buildFormPage(
            modalSheetContext,
            tensionBloc: tensionBloc,
            editEntryId: editEntryId,
            presetTimestamp: presetTimestamp,
          ),
        ];
      },
      modalTypeBuilder: (context) {
        final width = MediaQuery.sizeOf(context).width;
        if (width < 600) {
          return WoltModalType.bottomSheet();
        }
        return WoltModalType.dialog();
      },
      onModalDismissedWithBarrierTap: () {
        Navigator.of(context).pop();
      },
    );
  }

  // ───────────────── page builder ─────────────────

  static WoltModalSheetPage _buildFormPage(
    BuildContext context, {
    required TensionBloc tensionBloc,
    String? editEntryId,
    DateTime? presetTimestamp,
  }) {
    return WoltModalSheetPage(
      hasSabGradient: false,
      isTopBarLayerAlwaysVisible: true,
      topBarTitle: _TopBarTitle(editEntryId: editEntryId),
      trailingNavBarWidget: Container(
        margin: const EdgeInsets.all(8).copyWith(right: 16),
        child: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // The scrollable form content
      child: BlocProvider.value(
        value: tensionBloc,
        child: _EntryFormContent(
          editEntryId: editEntryId,
          presetTimestamp: presetTimestamp,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Top Bar Title (simple stateless widget)
// ═══════════════════════════════════════════════════════════════

class _TopBarTitle extends StatelessWidget {
  final String? editEntryId;
  const _TopBarTitle({this.editEntryId});

  @override
  Widget build(BuildContext context) {
    final i18n = I18Next.of(context);
    final isEditing = editEntryId != null;
    return Text(
      isEditing
          ? (i18n?.t('entry.editTitle') ?? 'Edit Entry')
          : (i18n?.t('entry.title') ?? 'New Entry'),
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  Form Content (StatefulWidget — contains all form state)
// ═══════════════════════════════════════════════════════════════

class _EntryFormContent extends StatefulWidget {
  final String? editEntryId;
  final DateTime? presetTimestamp;

  const _EntryFormContent({this.editEntryId, this.presetTimestamp});

  @override
  State<_EntryFormContent> createState() => _EntryFormContentState();
}

class _EntryFormContentState extends State<_EntryFormContent> {
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
  bool _isLoading = false;

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

    if (widget.editEntryId != null) {
      _isEditing = true;
      _isLoading = true;
      _loadExistingEntry();
    }
  }

  Future<void> _loadExistingEntry() async {
    final repo = sl<TensionRepository>();
    final entry = await repo.getEntryById(widget.editEntryId!);
    if (entry != null && mounted) {
      setState(() {
        _existingEntry = entry;
        _tensionLevel = entry.tensionLevel;
        _selectedTime = TimeOfDay.fromDateTime(entry.timestamp);
        _selectedDate = entry.date;
        _situationController.text = entry.situation ?? '';
        _feelingController.text = entry.feeling ?? '';
        _notesController.text = entry.notes ?? '';
        _selectedEmotions.addAll(entry.emotions);
        _isPastEntry = entry.timestamp.isBefore(DateTime.now());
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _situationController.dispose();
    _feelingController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ───────────────── build ─────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final i18n = I18Next.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Past-entry warning
          if (_isPastEntry) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
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
            const SizedBox(height: 16),
          ],

          // ── Date & Time ──
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

          // ── Tension Level ──
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
                    onChanged: (v) => setState(() => _tensionLevel = v),
                  ),
                  const SizedBox(height: 12),
                  ZoneIndicator(tensionLevel: _tensionLevel),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Situation ──
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
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
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

          // ── Feelings ──
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
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
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

          // ── Emotion Chips ──
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
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

          // ── Additional Notes ──
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
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                      hintText:
                          i18n?.t('entry.notesHint') ?? 'Further thoughts...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Action buttons ──
          Row(
            children: [
              // Delete button (only when editing)
              if (_isEditing) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      color: theme.colorScheme.error,
                    ),
                    label: Text(
                      i18n?.t('common.delete') ?? 'Delete',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: theme.colorScheme.error),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              // Save button
              Expanded(
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: Text(i18n?.t('entry.save') ?? 'Save'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ───────────────── pickers ─────────────────

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

  // ───────────────── save ─────────────────

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

    Navigator.of(context).pop();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18Next.of(context)?.t('entry.saved') ?? 'Entry saved'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ───────────────── delete ─────────────────

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
              Navigator.of(context).pop(); // close modal sheet
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
