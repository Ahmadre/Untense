import 'package:flutter/material.dart';
import 'package:i18next/i18next.dart';

import 'package:untense/core/services/pdf_report_service.dart';

/// Dialog that collects options for the therapeutic PDF report:
/// - anonymous vs. named patient
/// - date range
///
/// Returns `null` if cancelled, otherwise [PdfReportOptions].
class PdfReportDialog extends StatefulWidget {
  const PdfReportDialog({super.key});

  /// Convenience method to show the dialog and return the chosen options.
  static Future<PdfReportOptions?> show(BuildContext context) {
    return showDialog<PdfReportOptions>(
      context: context,
      builder: (_) => const PdfReportDialog(),
    );
  }

  @override
  State<PdfReportDialog> createState() => _PdfReportDialogState();
}

class _PdfReportDialogState extends State<PdfReportDialog> {
  bool _isAnonymous = true;
  final _nameController = TextEditingController();
  late DateTime _from;
  late DateTime _to;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default: last 7 days
    _to = DateTime(now.year, now.month, now.day);
    _from = _to.subtract(const Duration(days: 6));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18Next.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.picture_as_pdf, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              i18n?.t('report.title') ?? 'Therapeutic Report',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Anonymous toggle ──
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(i18n?.t('report.anonymous') ?? 'Anonymous Report'),
                subtitle: Text(
                  i18n?.t('report.anonymousHint') ??
                      'No patient name on the report',
                  style: theme.textTheme.bodySmall,
                ),
                value: _isAnonymous,
                onChanged: (v) => setState(() => _isAnonymous = v),
              ),

              // ── Patient name field ──
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: _isAnonymous
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText:
                                i18n?.t('report.patientName') ?? 'Patient Name',
                            prefixIcon: const Icon(Icons.person_outline),
                          ),
                          textCapitalization: TextCapitalization.words,
                        ),
                      ),
              ),

              const SizedBox(height: 8),

              // ── Date range ──
              Text(
                i18n?.t('report.period') ?? 'Reporting Period',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isFrom: true),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_formatDate(_from, locale)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('–'),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickDate(isFrom: false),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(_formatDate(_to, locale)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Preset chips ──
              Wrap(
                spacing: 8,
                children: [
                  _presetChip(i18n?.t('report.last7days') ?? 'Last 7 days', 6),
                  _presetChip(
                    i18n?.t('report.last14days') ?? 'Last 14 days',
                    13,
                  ),
                  _presetChip(
                    i18n?.t('report.last30days') ?? 'Last 30 days',
                    29,
                  ),
                  _presetChip(
                    i18n?.t('report.last90days') ?? 'Last 90 days',
                    89,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isGenerating ? null : () => Navigator.of(context).pop(),
          child: Text(i18n?.t('common.cancel') ?? 'Cancel'),
        ),
        FilledButton.icon(
          onPressed: _isGenerating ? null : () => _generate(locale),
          icon: _isGenerating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(i18n?.t('report.generate') ?? 'Generate PDF'),
        ),
      ],
    );
  }

  Widget _presetChip(String label, int daysBack) {
    final now = DateTime.now();
    final presetTo = DateTime(now.year, now.month, now.day);
    final presetFrom = presetTo.subtract(Duration(days: daysBack));
    final isSelected = _from == presetFrom && _to == presetTo;
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      onPressed: () => setState(() {
        _from = presetFrom;
        _to = presetTo;
      }),
    );
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
          if (_from.isAfter(_to)) _to = _from;
        } else {
          _to = picked;
          if (_to.isBefore(_from)) _from = _to;
        }
      });
    }
  }

  Future<void> _generate(String locale) async {
    setState(() => _isGenerating = true);

    final options = PdfReportOptions(
      patientName: _isAnonymous ? null : _nameController.text.trim(),
      from: _from,
      to: _to,
      locale: locale,
    );

    try {
      await PdfReportService().shareReport(options);
      if (mounted) Navigator.of(context).pop(options);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _formatDate(DateTime date, String locale) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
