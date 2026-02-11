import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i18next/i18next.dart';
import 'package:untense/core/constants/history_view_mode.dart';
import 'package:untense/core/routing/route_paths.dart';
import 'package:untense/core/utils/date_time_utils.dart';
import 'package:untense/di/service_locator.dart';
import 'package:untense/domain/entities/tension_entry.dart';
import 'package:untense/domain/repositories/tension_repository.dart';
import 'package:untense/presentation/bloc/settings/settings_bloc.dart';
import 'package:untense/presentation/bloc/settings/settings_state.dart';
import 'package:untense/presentation/widgets/aggregated_tension_chart.dart';
import 'package:untense/presentation/widgets/entry_card.dart';
import 'package:untense/presentation/widgets/tension_chart.dart';

/// History page showing past tension entries by date, week, month or year.
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryViewMode _viewMode = HistoryViewMode.day;

  // Day view — managed locally, independent of TensionBloc
  late DateTime _selectedDay;
  List<TensionEntry> _dayEntries = [];
  bool _isLoadingDay = false;

  // For week/month/year navigation
  late DateTime _weekStart; // Monday of the selected week
  late DateTime _monthDate; // Any date in the selected month
  late int _yearValue; // The selected year

  // Aggregated data for week/month/year
  List<AggregatedDataPoint> _aggregatedData = [];
  List<TensionEntry> _periodEntries = [];
  bool _isLoadingAggregated = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = now;
    _weekStart = _mondayOf(now);
    _monthDate = DateTime(now.year, now.month);
    _yearValue = now.year;
    _loadDayEntries();
  }

  Future<void> _loadDayEntries() async {
    setState(() => _isLoadingDay = true);
    final repo = sl<TensionRepository>();
    final entries = await repo.getEntriesByDate(_selectedDay);
    if (mounted) {
      setState(() {
        _dayEntries = entries;
        _isLoadingDay = false;
      });
    }
  }

  // ====================== Date Helpers ======================

  DateTime _mondayOf(DateTime date) {
    final diff = date.weekday - DateTime.monday;
    return DateTime(date.year, date.month, date.day - diff);
  }

  DateTime _sundayOf(DateTime mondayDate) {
    return mondayDate.add(const Duration(days: 6));
  }

  int _isoWeekNumber(DateTime date) {
    // ISO 8601 week number
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    final weekNumber = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (weekNumber < 1) return _isoWeekNumber(DateTime(date.year - 1, 12, 31));
    if (weekNumber > 52) {
      final dec31 = DateTime(date.year, 12, 31);
      if (dec31.weekday < DateTime.thursday) return 1;
    }
    return weekNumber;
  }

  int _daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  // ====================== Aggregation ======================

  Future<void> _loadAggregatedData() async {
    setState(() => _isLoadingAggregated = true);

    final repo = sl<TensionRepository>();
    List<TensionEntry> entries;
    List<AggregatedDataPoint> points;

    switch (_viewMode) {
      case HistoryViewMode.week:
        final monday = _weekStart;
        final sunday = _sundayOf(monday);
        entries = await repo.getEntriesBetween(monday, sunday);
        points = _aggregateWeek(entries, monday);
        break;
      case HistoryViewMode.month:
        final firstDay = DateTime(_monthDate.year, _monthDate.month, 1);
        final lastDay = DateTime(
          _monthDate.year,
          _monthDate.month,
          _daysInMonth(_monthDate.year, _monthDate.month),
        );
        entries = await repo.getEntriesBetween(firstDay, lastDay);
        points = _aggregateMonth(entries, _monthDate.year, _monthDate.month);
        break;
      case HistoryViewMode.year:
        final firstDay = DateTime(_yearValue, 1, 1);
        final lastDay = DateTime(_yearValue, 12, 31);
        entries = await repo.getEntriesBetween(firstDay, lastDay);
        points = _aggregateYear(entries, _yearValue);
        break;
      case HistoryViewMode.day:
        entries = [];
        points = [];
        break;
    }

    if (mounted) {
      setState(() {
        _periodEntries = entries;
        _aggregatedData = points;
        _isLoadingAggregated = false;
      });
    }
  }

  List<AggregatedDataPoint> _aggregateWeek(
    List<TensionEntry> entries,
    DateTime monday,
  ) {
    final i18n = I18Next.of(context);
    final weekdayKeys = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

    return List.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      final dayEntries = entries.where(
        (e) =>
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day,
      );
      final avg = dayEntries.isEmpty
          ? 0.0
          : dayEntries.map((e) => e.tensionLevel).reduce((a, b) => a + b) /
                dayEntries.length;
      final label =
          i18n?.t('history.weekdays.${weekdayKeys[i]}') ?? weekdayKeys[i];
      return AggregatedDataPoint(
        x: i.toDouble(),
        avgTension: avg,
        label: label,
        entryCount: dayEntries.length,
      );
    });
  }

  List<AggregatedDataPoint> _aggregateMonth(
    List<TensionEntry> entries,
    int year,
    int month,
  ) {
    final days = _daysInMonth(year, month);
    return List.generate(days, (i) {
      final dayNum = i + 1;
      final dayEntries = entries.where(
        (e) =>
            e.date.year == year &&
            e.date.month == month &&
            e.date.day == dayNum,
      );
      final avg = dayEntries.isEmpty
          ? 0.0
          : dayEntries.map((e) => e.tensionLevel).reduce((a, b) => a + b) /
                dayEntries.length;
      return AggregatedDataPoint(
        x: i.toDouble(),
        avgTension: avg,
        label: '$dayNum',
        entryCount: dayEntries.length,
      );
    });
  }

  List<AggregatedDataPoint> _aggregateYear(
    List<TensionEntry> entries,
    int year,
  ) {
    final i18n = I18Next.of(context);
    final monthKeys = [
      'jan',
      'feb',
      'mar',
      'apr',
      'may',
      'jun',
      'jul',
      'aug',
      'sep',
      'oct',
      'nov',
      'dec',
    ];

    return List.generate(12, (i) {
      final monthNum = i + 1;
      final monthEntries = entries.where(
        (e) => e.date.year == year && e.date.month == monthNum,
      );
      final avg = monthEntries.isEmpty
          ? 0.0
          : monthEntries.map((e) => e.tensionLevel).reduce((a, b) => a + b) /
                monthEntries.length;
      final label = i18n?.t('history.months.${monthKeys[i]}') ?? monthKeys[i];
      return AggregatedDataPoint(
        x: i.toDouble(),
        avgTension: avg,
        label: label,
        entryCount: monthEntries.length,
      );
    });
  }

  // ====================== Navigation ======================

  void _onViewModeChanged(HistoryViewMode mode) {
    if (mode == _viewMode) return;
    setState(() => _viewMode = mode);
    if (mode == HistoryViewMode.day) {
      _loadDayEntries();
    } else {
      _loadAggregatedData();
    }
  }

  void _navigatePrevious() {
    switch (_viewMode) {
      case HistoryViewMode.day:
        // Handled by BLoC
        break;
      case HistoryViewMode.week:
        setState(() {
          _weekStart = _weekStart.subtract(const Duration(days: 7));
        });
        _loadAggregatedData();
        break;
      case HistoryViewMode.month:
        setState(() {
          final m = _monthDate.month == 1 ? 12 : _monthDate.month - 1;
          final y = _monthDate.month == 1
              ? _monthDate.year - 1
              : _monthDate.year;
          _monthDate = DateTime(y, m);
        });
        _loadAggregatedData();
        break;
      case HistoryViewMode.year:
        setState(() => _yearValue--);
        _loadAggregatedData();
        break;
    }
  }

  void _navigateNext() {
    switch (_viewMode) {
      case HistoryViewMode.day:
        // Handled by BLoC
        break;
      case HistoryViewMode.week:
        setState(() {
          _weekStart = _weekStart.add(const Duration(days: 7));
        });
        _loadAggregatedData();
        break;
      case HistoryViewMode.month:
        setState(() {
          final m = _monthDate.month == 12 ? 1 : _monthDate.month + 1;
          final y = _monthDate.month == 12
              ? _monthDate.year + 1
              : _monthDate.year;
          _monthDate = DateTime(y, m);
        });
        _loadAggregatedData();
        break;
      case HistoryViewMode.year:
        setState(() => _yearValue++);
        _loadAggregatedData();
        break;
    }
  }

  bool _isNextDisabled() {
    final now = DateTime.now();
    switch (_viewMode) {
      case HistoryViewMode.day:
        return false; // handled by BLoC state
      case HistoryViewMode.week:
        return !_sundayOf(_weekStart).isBefore(now);
      case HistoryViewMode.month:
        return _monthDate.year == now.year && _monthDate.month == now.month;
      case HistoryViewMode.year:
        return _yearValue >= now.year;
    }
  }

  // ====================== Build ======================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = I18Next.of(context);

    return Column(
      children: [
        // View mode switcher
        _buildViewModeSwitcher(theme, i18n),

        // Content based on mode
        Expanded(
          child: _viewMode == HistoryViewMode.day
              ? _buildDayView(context, theme, i18n)
              : _buildAggregatedView(context, theme, i18n),
        ),
      ],
    );
  }

  Widget _buildViewModeSwitcher(ThemeData theme, I18Next? i18n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SegmentedButton<HistoryViewMode>(
        segments: [
          ButtonSegment(
            value: HistoryViewMode.day,
            label: Text(i18n?.t('history.viewDay') ?? 'Day'),
          ),
          ButtonSegment(
            value: HistoryViewMode.week,
            label: Text(i18n?.t('history.viewWeek') ?? 'Week'),
          ),
          ButtonSegment(
            value: HistoryViewMode.month,
            label: Text(i18n?.t('history.viewMonth') ?? 'Month'),
          ),
          ButtonSegment(
            value: HistoryViewMode.year,
            label: Text(i18n?.t('history.viewYear') ?? 'Year'),
          ),
        ],
        selected: {_viewMode},
        onSelectionChanged: (selection) {
          _onViewModeChanged(selection.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(theme.textTheme.labelMedium),
        ),
      ),
    );
  }

  // ==================== Day View (existing) ====================

  Widget _buildDayView(BuildContext context, ThemeData theme, I18Next? i18n) {
    if (_isLoadingDay) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildDayContent(context, theme, i18n);
  }

  Widget _buildDayContent(
    BuildContext context,
    ThemeData theme,
    I18Next? i18n,
  ) {
    final settingsState = context.watch<SettingsBloc>().state;
    final dayStart = settingsState is SettingsLoaded
        ? settingsState.config.dayStart
        : const TimeOfDay(hour: 8, minute: 0);
    final dayEnd = settingsState is SettingsLoaded
        ? settingsState.config.dayEnd
        : const TimeOfDay(hour: 22, minute: 0);

    // Compute stats locally
    final avg = _dayEntries.isEmpty
        ? 0.0
        : _dayEntries.map((e) => e.tensionLevel).reduce((a, b) => a + b) /
              _dayEntries.length;
    final max = _dayEntries.isEmpty
        ? 0.0
        : _dayEntries
              .map((e) => e.tensionLevel)
              .reduce((a, b) => a > b ? a : b);
    final min = _dayEntries.isEmpty
        ? 0.0
        : _dayEntries
              .map((e) => e.tensionLevel)
              .reduce((a, b) => a < b ? a : b);

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ListView(
      padding: EdgeInsets.only(bottom: bottomInset + 16),
      children: [
        // Date navigation
        _buildNavigationRow(
          theme: theme,
          label: _formatDayLabel(_selectedDay, i18n),
          onPrevious: () {
            setState(() {
              _selectedDay = _selectedDay.subtract(const Duration(days: 1));
            });
            _loadDayEntries();
          },
          onNext: AppDateTimeUtils.isToday(_selectedDay)
              ? null
              : () {
                  setState(() {
                    _selectedDay = _selectedDay.add(const Duration(days: 1));
                  });
                  _loadDayEntries();
                },
          onTap: () => _selectDate(context, _selectedDay),
        ),

        // Chart
        if (_dayEntries.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TensionChart(
              entries: _dayEntries,
              dayStart: dayStart,
              dayEnd: dayEnd,
            ),
          ),

        // Stats
        if (_dayEntries.isNotEmpty)
          _buildStatsRow(
            theme: theme,
            i18n: i18n,
            avg: avg,
            max: max,
            min: min,
            entryCount: _dayEntries.length,
          ),

        // Entries list or empty state
        if (_dayEntries.isEmpty)
          _buildEmptyState(theme, i18n)
        else
          ..._dayEntries.map(
            (entry) => EntryCard(
              entry: entry,
              onTap: () {
                context.push(RoutePaths.editEntryPath(entry.id));
              },
            ),
          ),
      ],
    );
  }

  // ==================== Aggregated View (week/month/year) ====================

  Widget _buildAggregatedView(
    BuildContext context,
    ThemeData theme,
    I18Next? i18n,
  ) {
    return Column(
      children: [
        // Period navigation
        _buildNavigationRow(
          theme: theme,
          label: _formatPeriodLabel(i18n),
          onPrevious: _navigatePrevious,
          onNext: _isNextDisabled() ? null : _navigateNext,
          onTap: () => _selectPeriod(context),
        ),

        // Content
        Expanded(
          child: _isLoadingAggregated
              ? const Center(child: CircularProgressIndicator())
              : _buildAggregatedContent(theme, i18n),
        ),
      ],
    );
  }

  Widget _buildAggregatedContent(ThemeData theme, I18Next? i18n) {
    final pointsWithData = _aggregatedData
        .where((p) => p.entryCount > 0)
        .toList();

    // Compute overall stats from period entries
    final avg = _periodEntries.isEmpty
        ? 0.0
        : _periodEntries.map((e) => e.tensionLevel).reduce((a, b) => a + b) /
              _periodEntries.length;
    final max = _periodEntries.isEmpty
        ? 0.0
        : _periodEntries
              .map((e) => e.tensionLevel)
              .reduce((a, b) => a > b ? a : b);
    final min = _periodEntries.isEmpty
        ? 0.0
        : _periodEntries
              .map((e) => e.tensionLevel)
              .reduce((a, b) => a < b ? a : b);

    final bottomInset = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomInset + 16),
      child: Column(
        children: [
          // Chart
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AggregatedTensionChart(
              dataPoints: _aggregatedData,
              viewMode: _viewMode,
            ),
          ),

          // Stats
          if (pointsWithData.isNotEmpty)
            _buildStatsRow(
              theme: theme,
              i18n: i18n,
              avg: avg,
              max: max,
              min: min,
              entryCount: _periodEntries.length,
            ),

          // Empty state
          if (pointsWithData.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.event_note,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    i18n?.t('history.noDataForPeriod') ??
                        'No data for this period.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==================== Shared Widgets ====================

  Widget _buildNavigationRow({
    required ThemeData theme,
    required String label,
    required VoidCallback onPrevious,
    required VoidCallback? onNext,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: onPrevious,
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required ThemeData theme,
    required I18Next? i18n,
    required double avg,
    required double max,
    required double min,
    required int entryCount,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat(
            i18n?.t('history.averageTension') ?? 'Avg',
            avg.toStringAsFixed(0),
            theme,
          ),
          _buildStat(
            i18n?.t('history.maxTension') ?? 'Max',
            max.toStringAsFixed(0),
            theme,
          ),
          _buildStat(
            i18n?.t('history.minTension') ?? 'Min',
            min.toStringAsFixed(0),
            theme,
          ),
          _buildStat(
            i18n?.t(
                  'history.entries_other',
                  variables: {'count': entryCount.toString()},
                ) ??
                '$entryCount',
            entryCount.toString(),
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, I18Next? i18n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            i18n?.t('history.noEntries') ?? 'No entries available.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Label Formatting ====================

  String _formatDayLabel(DateTime date, I18Next? i18n) {
    if (AppDateTimeUtils.isToday(date)) {
      return i18n?.t('history.today') ?? 'Today';
    }
    if (AppDateTimeUtils.isYesterday(date)) {
      return i18n?.t('history.yesterday') ?? 'Yesterday';
    }
    return AppDateTimeUtils.formatDate(date);
  }

  String _formatPeriodLabel(I18Next? i18n) {
    switch (_viewMode) {
      case HistoryViewMode.week:
        final weekNum = _isoWeekNumber(_weekStart);
        return i18n?.t(
              'history.calendarWeek',
              variables: {
                'week': weekNum.toString(),
                'year': _weekStart.year.toString(),
              },
            ) ??
            'CW $weekNum, ${_weekStart.year}';
      case HistoryViewMode.month:
        final monthKeys = [
          'jan',
          'feb',
          'mar',
          'apr',
          'may',
          'jun',
          'jul',
          'aug',
          'sep',
          'oct',
          'nov',
          'dec',
        ];
        final mKey = monthKeys[_monthDate.month - 1];
        final monthName = i18n?.t('history.monthsFull.$mKey') ?? mKey;
        return i18n?.t(
              'history.monthYear',
              variables: {
                'month': monthName,
                'year': _monthDate.year.toString(),
              },
            ) ??
            '$monthName ${_monthDate.year}';
      case HistoryViewMode.year:
        return _yearValue.toString();
      case HistoryViewMode.day:
        return '';
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDay = picked);
      _loadDayEntries();
    }
  }

  /// Routes to the correct picker based on the current view mode.
  Future<void> _selectPeriod(BuildContext context) async {
    switch (_viewMode) {
      case HistoryViewMode.week:
        await _selectWeek(context);
        break;
      case HistoryViewMode.month:
        await _selectMonth(context);
        break;
      case HistoryViewMode.year:
        await _selectYear(context);
        break;
      case HistoryViewMode.day:
        break;
    }
  }

  /// Pick any date → jump to the calendar week containing that date.
  Future<void> _selectWeek(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      setState(() => _weekStart = _mondayOf(picked));
      _loadAggregatedData();
    }
  }

  /// Show a dialog to pick a month+year.
  Future<void> _selectMonth(BuildContext context) async {
    final now = DateTime.now();
    int selectedYear = _monthDate.year;
    int selectedMonth = _monthDate.month;

    final result = await showDialog<DateTime>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final i18n = I18Next.of(context);
            final monthKeys = [
              'jan',
              'feb',
              'mar',
              'apr',
              'may',
              'jun',
              'jul',
              'aug',
              'sep',
              'oct',
              'nov',
              'dec',
            ];

            return AlertDialog(
              title: Text(i18n?.t('history.pickMonth') ?? 'Pick Month'),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Year selector row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: () => setDialogState(() => selectedYear--),
                        ),
                        Text(
                          '$selectedYear',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: selectedYear < now.year
                              ? () => setDialogState(() => selectedYear++)
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Month grid
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      childAspectRatio: 2.0,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      children: List.generate(12, (i) {
                        final m = i + 1;
                        final isFuture =
                            selectedYear == now.year && m > now.month;
                        final isSelected =
                            m == selectedMonth &&
                            selectedYear == _monthDate.year;
                        final label =
                            i18n?.t('history.monthsFull.${monthKeys[i]}') ??
                            monthKeys[i];

                        return GestureDetector(
                          onTap: isFuture
                              ? null
                              : () => setDialogState(() => selectedMonth = m),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color:
                                  isSelected && selectedYear == _monthDate.year
                                  ? Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: selectedMonth == m
                                  ? Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selectedMonth == m
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isFuture
                                    ? Theme.of(context).colorScheme.onSurface
                                          .withValues(alpha: 0.3)
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(i18n?.t('common.cancel') ?? 'Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(
                    ctx,
                  ).pop(DateTime(selectedYear, selectedMonth)),
                  child: Text(i18n?.t('common.ok') ?? 'OK'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() => _monthDate = result);
      _loadAggregatedData();
    }
  }

  /// Show a dialog to pick a year.
  Future<void> _selectYear(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDialog<int>(
      context: context,
      builder: (ctx) {
        final i18n = I18Next.of(context);
        return AlertDialog(
          title: Text(i18n?.t('history.pickYear') ?? 'Pick Year'),
          content: SizedBox(
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(2020),
              lastDate: DateTime(now.year, 12, 31),
              selectedDate: DateTime(_yearValue),
              onChanged: (date) => Navigator.of(ctx).pop(date.year),
            ),
          ),
        );
      },
    );

    if (picked != null && mounted) {
      setState(() => _yearValue = picked);
      _loadAggregatedData();
    }
  }
}
