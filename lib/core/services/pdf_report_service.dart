import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:untense/core/constants/tension_zones.dart';
import 'package:untense/di/service_locator.dart';
import 'package:untense/domain/entities/tension_entry.dart';
import 'package:untense/domain/repositories/tension_repository.dart';

/// Holds the user-configurable options for generating a report.
class PdfReportOptions {
  /// `null` → anonymous report.
  final String? patientName;

  /// Start of the reporting period (inclusive).
  final DateTime from;

  /// End of the reporting period (inclusive).
  final DateTime to;

  /// The locale to use for formatting (`de` or `en`).
  final String locale;

  const PdfReportOptions({
    this.patientName,
    required this.from,
    required this.to,
    this.locale = 'de',
  });

  bool get isAnonymous => patientName == null || patientName!.trim().isEmpty;
}

// ═══════════════════════════════════════════════════════════════
//  PDF Report Service
// ═══════════════════════════════════════════════════════════════

class PdfReportService {
  // ── colour constants (matching TensionZone colours) ──
  static const _primaryColor = PdfColor.fromInt(0xFF0B4C78);
  static const _green = PdfColor.fromInt(0xFF4CAF50);
  static const _orange = PdfColor.fromInt(0xFFFFA726);
  static const _red = PdfColor.fromInt(0xFFEF5350);
  static const _grey = PdfColor.fromInt(0xFF757575);
  static const _lightGrey = PdfColor.fromInt(0xFFF5F5F5);

  // ── localised strings ──
  static Map<String, String> _strings(String locale) {
    if (locale.startsWith('de')) {
      return const {
        'title': 'Therapeutischer Anspannungsbericht',
        'anonymous': 'Anonymer Bericht',
        'patient': 'Patient*in',
        'period': 'Berichtszeitraum',
        'generated': 'Erstellt am',
        'summary': 'Zusammenfassung',
        'totalEntries': 'Anzahl der Einträge',
        'avgTension': 'Ø Anspannungsniveau',
        'maxTension': 'Höchste Anspannung',
        'minTension': 'Niedrigste Anspannung',
        'daysTracked': 'Erfasste Tage',
        'entriesPerDay': 'Ø Einträge / Tag',
        'zoneDistribution': 'Verteilung der Anspannungszonen',
        'zone': 'Zone',
        'range': 'Bereich',
        'count': 'Anzahl',
        'percent': 'Anteil',
        'avgLevel': 'Ø Niveau',
        'mindfulness': 'Achtsamkeit',
        'emotionRegulation': 'Emotionsregulation',
        'stressTolerance': 'Stresstoleranz',
        'emotionProfile': 'Emotionsprofil',
        'emotion': 'Emotion',
        'frequency': 'Häufigkeit',
        'dailyOverview': 'Tagesübersicht',
        'date': 'Datum',
        'entries': 'Einträge',
        'avg': 'Ø',
        'max': 'Max',
        'min': 'Min',
        'detailedEntries': 'Detaillierte Einträge',
        'time': 'Uhrzeit',
        'tension': 'Ansp.',
        'situation': 'Situation',
        'feeling': 'Gefühl',
        'emotions': 'Emotionen',
        'notes': 'Notizen',
        'noEntries': 'Keine Einträge im gewählten Zeitraum.',
        'page': 'Seite',
        'of': 'von',
        'confidential': 'Vertraulich - Nur f\u00fcr therapeutische Zwecke',
        'disclaimer':
            'Dieser Bericht wurde automatisch aus dem Anspannungstagebuch "Untense" generiert und ersetzt keine fachliche Beurteilung.',
        // emotion labels
        'anger': 'Wut',
        'fear': 'Angst',
        'sadness': 'Traurigkeit',
        'joy': 'Freude',
        'disgust': 'Ekel',
        'surprise': 'Überraschung',
        'shame': 'Scham',
        'guilt': 'Schuld',
        'loneliness': 'Einsamkeit',
        'frustration': 'Frustration',
        'anxiety': 'Sorge',
        'contentment': 'Zufriedenheit',
        'love': 'Liebe',
        'hope': 'Hoffnung',
        'gratitude': 'Dankbarkeit',
        'overwhelm': 'Überforderung',
        'numbness': 'Taubheit',
        'restlessness': 'Unruhe',
      };
    }
    return const {
      'title': 'Therapeutic Tension Report',
      'anonymous': 'Anonymous Report',
      'patient': 'Patient',
      'period': 'Reporting Period',
      'generated': 'Generated on',
      'summary': 'Summary',
      'totalEntries': 'Total Entries',
      'avgTension': 'Avg. Tension Level',
      'maxTension': 'Highest Tension',
      'minTension': 'Lowest Tension',
      'daysTracked': 'Days Tracked',
      'entriesPerDay': 'Avg. Entries / Day',
      'zoneDistribution': 'Tension Zone Distribution',
      'zone': 'Zone',
      'range': 'Range',
      'count': 'Count',
      'percent': 'Share',
      'avgLevel': 'Avg. Level',
      'mindfulness': 'Mindfulness',
      'emotionRegulation': 'Emotion Regulation',
      'stressTolerance': 'Stress Tolerance',
      'emotionProfile': 'Emotion Profile',
      'emotion': 'Emotion',
      'frequency': 'Frequency',
      'dailyOverview': 'Daily Overview',
      'date': 'Date',
      'entries': 'Entries',
      'avg': 'Avg',
      'max': 'Max',
      'min': 'Min',
      'detailedEntries': 'Detailed Entries',
      'time': 'Time',
      'tension': 'Tens.',
      'situation': 'Situation',
      'feeling': 'Feeling',
      'emotions': 'Emotions',
      'notes': 'Notes',
      'noEntries': 'No entries in the selected period.',
      'page': 'Page',
      'of': 'of',
      'confidential': 'Confidential - For therapeutic use only',
      'disclaimer':
          'This report was automatically generated from the "Untense" tension diary and does not replace professional assessment.',
      // emotion labels
      'anger': 'Anger',
      'fear': 'Fear',
      'sadness': 'Sadness',
      'joy': 'Joy',
      'disgust': 'Disgust',
      'surprise': 'Surprise',
      'shame': 'Shame',
      'guilt': 'Guilt',
      'loneliness': 'Loneliness',
      'frustration': 'Frustration',
      'anxiety': 'Anxiety',
      'contentment': 'Contentment',
      'love': 'Love',
      'hope': 'Hope',
      'gratitude': 'Gratitude',
      'overwhelm': 'Overwhelm',
      'numbness': 'Numbness',
      'restlessness': 'Restlessness',
    };
  }

  // ────────────────────── public API ──────────────────────

  /// Generates the PDF bytes for the therapeutic report.
  Future<Uint8List> generate(PdfReportOptions options) async {
    final repo = sl<TensionRepository>();
    final entries = await repo.getEntriesBetween(options.from, options.to);
    entries.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final s = _strings(options.locale);
    final dateFmt = DateFormat('dd.MM.yyyy');
    final timeFmt = DateFormat('HH:mm');

    // Load logo
    pw.MemoryImage? logo;
    try {
      final logoBytes = await rootBundle.load('assets/logo.png');
      logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    } catch (_) {
      // logo not available — that's OK
    }

    final pdf = pw.Document(
      author: 'Untense',
      title: s['title']!,
      creator: 'Untense - Therapeutic Tension Diary',
    );

    // ── pre-compute statistics ──
    final totalEntries = entries.length;
    final avgTension = totalEntries > 0
        ? entries.map((e) => e.tensionLevel).reduce((a, b) => a + b) /
              totalEntries
        : 0.0;
    final maxTension = totalEntries > 0
        ? entries.map((e) => e.tensionLevel).reduce((a, b) => a > b ? a : b)
        : 0.0;
    final minTension = totalEntries > 0
        ? entries.map((e) => e.tensionLevel).reduce((a, b) => a < b ? a : b)
        : 0.0;

    final uniqueDays = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet();
    final daysTracked = uniqueDays.length;
    final entriesPerDay = daysTracked > 0 ? (totalEntries / daysTracked) : 0.0;

    // Zone distribution
    int zMind = 0, zEmo = 0, zStress = 0;
    double sumMind = 0, sumEmo = 0, sumStress = 0;
    for (final e in entries) {
      final zone = TensionZoneExtension.fromValue(e.tensionLevel);
      switch (zone) {
        case TensionZone.mindfulness:
          zMind++;
          sumMind += e.tensionLevel;
        case TensionZone.emotionRegulation:
          zEmo++;
          sumEmo += e.tensionLevel;
        case TensionZone.stressTolerance:
          zStress++;
          sumStress += e.tensionLevel;
      }
    }

    // Emotion frequency
    final emotionFrequency = <String, int>{};
    for (final e in entries) {
      for (final emo in e.emotions) {
        emotionFrequency[emo] = (emotionFrequency[emo] ?? 0) + 1;
      }
    }
    final sortedEmotions = emotionFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Daily aggregates
    final dailyMap = <DateTime, List<TensionEntry>>{};
    for (final e in entries) {
      final day = DateTime(e.date.year, e.date.month, e.date.day);
      dailyMap.putIfAbsent(day, () => []).add(e);
    }
    final sortedDays = dailyMap.keys.toList()..sort();

    // ────────── build pages ──────────

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(context, s, options, dateFmt, logo),
        footer: (context) => _buildFooter(context, s),
        build: (context) {
          final widgets = <pw.Widget>[];

          if (entries.isEmpty) {
            widgets.add(
              pw.Center(
                child: pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 40),
                  child: pw.Text(
                    s['noEntries']!,
                    style: const pw.TextStyle(fontSize: 14, color: _grey),
                  ),
                ),
              ),
            );
            return widgets;
          }

          // ── Summary ──
          widgets.add(_sectionTitle(s['summary']!));
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
              },
              children: [
                _summaryRow(s['totalEntries']!, '$totalEntries'),
                _summaryRow(s['avgTension']!, avgTension.toStringAsFixed(1)),
                _summaryRow(s['maxTension']!, maxTension.toStringAsFixed(0)),
                _summaryRow(s['minTension']!, minTension.toStringAsFixed(0)),
                _summaryRow(s['daysTracked']!, '$daysTracked'),
                _summaryRow(
                  s['entriesPerDay']!,
                  entriesPerDay.toStringAsFixed(1),
                ),
              ],
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

          // ── Zone Distribution ──
          widgets.add(_sectionTitle(s['zoneDistribution']!));
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(0.3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
                5: const pw.FlexColumnWidth(1),
              },
              children: [
                // header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeader(''),
                    _tableHeader(s['zone']!),
                    _tableHeader(s['range']!),
                    _tableHeader(s['count']!),
                    _tableHeader(s['percent']!),
                    _tableHeader(s['avgLevel']!),
                  ],
                ),
                _zoneRow(
                  color: _green,
                  name: s['mindfulness']!,
                  range: '0 - 30',
                  count: zMind,
                  total: totalEntries,
                  avgSum: sumMind,
                ),
                _zoneRow(
                  color: _orange,
                  name: s['emotionRegulation']!,
                  range: '30 - 70',
                  count: zEmo,
                  total: totalEntries,
                  avgSum: sumEmo,
                ),
                _zoneRow(
                  color: _red,
                  name: s['stressTolerance']!,
                  range: '70 - 100',
                  count: zStress,
                  total: totalEntries,
                  avgSum: sumStress,
                ),
              ],
            ),
          );

          // ── Zone visual bar ──
          widgets.add(pw.SizedBox(height: 6));
          if (totalEntries > 0) {
            widgets.add(
              pw.ClipRRect(
                horizontalRadius: 4,
                verticalRadius: 4,
                child: pw.Row(
                  children: [
                    if (zMind > 0)
                      pw.Expanded(
                        flex: zMind,
                        child: pw.Container(height: 12, color: _green),
                      ),
                    if (zEmo > 0)
                      pw.Expanded(
                        flex: zEmo,
                        child: pw.Container(height: 12, color: _orange),
                      ),
                    if (zStress > 0)
                      pw.Expanded(
                        flex: zStress,
                        child: pw.Container(height: 12, color: _red),
                      ),
                  ],
                ),
              ),
            );
          }
          widgets.add(pw.SizedBox(height: 20));

          // ── Emotion Profile ──
          if (sortedEmotions.isNotEmpty) {
            widgets.add(_sectionTitle(s['emotionProfile']!));
            widgets.add(pw.SizedBox(height: 8));
            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(3),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _tableHeader(s['emotion']!),
                      _tableHeader(s['frequency']!),
                      _tableHeader(''),
                    ],
                  ),
                  ...sortedEmotions.take(10).map((e) {
                    final label = s[e.key] ?? e.key;
                    final pct = totalEntries > 0
                        ? (e.value / totalEntries * 100)
                        : 0.0;
                    return pw.TableRow(
                      children: [
                        _tableCell(label),
                        _tableCell('${e.value}'),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Stack(
                            children: [
                              pw.Container(
                                height: 10,
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                  borderRadius: pw.BorderRadius.circular(2),
                                ),
                              ),
                              pw.Container(
                                height: 10,
                                width: pct * 1.5, // px scale
                                decoration: pw.BoxDecoration(
                                  color: _primaryColor,
                                  borderRadius: pw.BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            );
            widgets.add(pw.SizedBox(height: 20));
          }

          // ── Daily Overview ──
          widgets.add(_sectionTitle(s['dailyOverview']!));
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(2),
                1: const pw.FlexColumnWidth(1),
                2: const pw.FlexColumnWidth(1),
                3: const pw.FlexColumnWidth(1),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _tableHeader(s['date']!),
                    _tableHeader(s['entries']!),
                    _tableHeader(s['avg']!),
                    _tableHeader(s['max']!),
                    _tableHeader(s['min']!),
                  ],
                ),
                ...sortedDays.map((day) {
                  final dayEntries = dailyMap[day]!;
                  final dAvg =
                      dayEntries
                          .map((e) => e.tensionLevel)
                          .reduce((a, b) => a + b) /
                      dayEntries.length;
                  final dMax = dayEntries
                      .map((e) => e.tensionLevel)
                      .reduce((a, b) => a > b ? a : b);
                  final dMin = dayEntries
                      .map((e) => e.tensionLevel)
                      .reduce((a, b) => a < b ? a : b);
                  return pw.TableRow(
                    children: [
                      _tableCell(dateFmt.format(day)),
                      _tableCell('${dayEntries.length}'),
                      _tableCellColored(dAvg.toStringAsFixed(1), dAvg),
                      _tableCellColored(dMax.toStringAsFixed(0), dMax),
                      _tableCellColored(dMin.toStringAsFixed(0), dMin),
                    ],
                  );
                }),
              ],
            ),
          );
          widgets.add(pw.SizedBox(height: 20));

          // ── Detailed Entries ──
          widgets.add(_sectionTitle(s['detailedEntries']!));
          widgets.add(pw.SizedBox(height: 8));

          for (final day in sortedDays) {
            final dayEntries = dailyMap[day]!;
            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 4, top: 8),
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: const pw.BoxDecoration(
                  color: _lightGrey,
                  borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
                ),
                child: pw.Text(
                  dateFmt.format(day),
                  style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ),
            );

            widgets.add(
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(0.8),
                  2: const pw.FlexColumnWidth(2.5),
                  3: const pw.FlexColumnWidth(2.5),
                  4: const pw.FlexColumnWidth(2),
                },
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200,
                    ),
                    children: [
                      _tableHeader(s['time']!),
                      _tableHeader(s['tension']!),
                      _tableHeader(s['situation']!),
                      _tableHeader(s['feeling']!),
                      _tableHeader(s['emotions']!),
                    ],
                  ),
                  ...dayEntries.map((entry) {
                    final emotionLabels = entry.emotions
                        .map((e) => s[e] ?? e)
                        .join(', ');
                    return pw.TableRow(
                      children: [
                        _tableCell(timeFmt.format(entry.timestamp)),
                        _tableCellColored(
                          entry.tensionLevel.toStringAsFixed(0),
                          entry.tensionLevel,
                        ),
                        _tableCell(entry.situation ?? '–'),
                        _tableCell(entry.feeling ?? '–'),
                        _tableCell(emotionLabels.isEmpty ? '–' : emotionLabels),
                      ],
                    );
                  }),
                ],
              ),
            );

            // notes per entry (only if any)
            for (final entry in dayEntries) {
              if (entry.notes != null && entry.notes!.trim().isNotEmpty) {
                widgets.add(
                  pw.Container(
                    margin: const pw.EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 2,
                    ),
                    padding: const pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        left: pw.BorderSide(color: _primaryColor, width: 2),
                      ),
                    ),
                    child: pw.RichText(
                      text: pw.TextSpan(
                        children: [
                          pw.TextSpan(
                            text:
                                '${timeFmt.format(entry.timestamp)} – ${s['notes']}: ',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: _grey,
                            ),
                          ),
                          pw.TextSpan(
                            text: entry.notes!,
                            style: const pw.TextStyle(
                              fontSize: 8,
                              color: _grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }
          }

          // ── Disclaimer ──
          widgets.add(pw.SizedBox(height: 24));
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                s['disclaimer']!,
                style: const pw.TextStyle(fontSize: 8, color: _grey),
                textAlign: pw.TextAlign.center,
              ),
            ),
          );

          return widgets;
        },
      ),
    );

    return pdf.save();
  }

  /// Opens the system print / share dialog with the PDF.
  Future<void> shareReport(PdfReportOptions options) async {
    final bytes = await generate(options);
    final dateFmt = DateFormat('yyyyMMdd');
    final name = options.isAnonymous
        ? 'anonym'
        : options.patientName!
              .trim()
              .replaceAll(RegExp(r'\s+'), '_')
              .toLowerCase();
    final fileName =
        'untense_bericht_${name}_${dateFmt.format(options.from)}_${dateFmt.format(options.to)}.pdf';

    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  // ────────────────── private helpers ──────────────────

  static pw.Widget _buildHeader(
    pw.Context context,
    Map<String, String> s,
    PdfReportOptions options,
    DateFormat dateFmt,
    pw.MemoryImage? logo,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                if (logo != null) pw.Image(logo, width: 28, height: 28),
                if (logo != null) pw.SizedBox(width: 8),
                pw.Text(
                  s['title']!,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
            pw.Text(
              s['confidential']!,
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
                color: _red,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              options.isAnonymous
                  ? s['anonymous']!
                  : '${s['patient']}: ${options.patientName}',
              style: const pw.TextStyle(fontSize: 10, color: _grey),
            ),
            pw.Text(
              '${s['period']}: ${dateFmt.format(options.from)} - ${dateFmt.format(options.to)}',
              style: const pw.TextStyle(fontSize: 10, color: _grey),
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          '${s['generated']}: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 8, color: _grey),
        ),
        pw.Divider(color: _primaryColor, thickness: 1.5),
        pw.SizedBox(height: 8),
      ],
    );
  }

  static pw.Widget _buildFooter(pw.Context context, Map<String, String> s) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Untense - Therapeutic Tension Diary',
          style: const pw.TextStyle(fontSize: 7, color: _grey),
        ),
        pw.Text(
          '${s['page']} ${context.pageNumber} ${s['of']} ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 7, color: _grey),
        ),
      ],
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: const pw.BoxDecoration(
        color: _primaryColor,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.TableRow _summaryRow(String label, String value) {
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(6),
          child: pw.Text(
            value,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    );
  }

  static pw.TableRow _zoneRow({
    required PdfColor color,
    required String name,
    required String range,
    required int count,
    required int total,
    required double avgSum,
  }) {
    final pct = total > 0 ? (count / total * 100) : 0.0;
    final avg = count > 0 ? (avgSum / count) : 0.0;
    return pw.TableRow(
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(4),
          child: pw.AspectRatio(
            aspectRatio: 1,
            child: pw.Container(
              width: 10,
              height: 10,
              decoration: pw.BoxDecoration(
                color: color,
                shape: pw.BoxShape.circle,
              ),
            ),
          ),
        ),
        _tableCell(name),
        _tableCell(range),
        _tableCell('$count'),
        _tableCell('${pct.toStringAsFixed(1)} %'),
        _tableCell(avg.toStringAsFixed(1)),
      ],
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  static pw.Widget _tableCellColored(String text, double value) {
    final zone = TensionZoneExtension.fromValue(value);
    PdfColor color;
    switch (zone) {
      case TensionZone.mindfulness:
        color = _green;
      case TensionZone.emotionRegulation:
        color = _orange;
      case TensionZone.stressTolerance:
        color = _red;
    }
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
