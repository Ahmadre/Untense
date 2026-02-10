import 'package:flutter/material.dart';

/// Utility helpers for date/time operations in Untense
class AppDateTimeUtils {
  AppDateTimeUtils._();

  /// Returns a [DateTime] for today at the given hour and minute
  static DateTime todayAt(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Returns a [DateTime] for a specific date at the given hour and minute
  static DateTime dateAt(DateTime date, int hour, int minute) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Converts a [TimeOfDay] to total minutes since midnight
  static int timeOfDayToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  /// Converts total minutes since midnight to a [TimeOfDay]
  static TimeOfDay minutesToTimeOfDay(int totalMinutes) {
    return TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60);
  }

  /// Generates time slots between [start] and [end] with [intervalMinutes] spacing
  static List<TimeOfDay> generateTimeSlots({
    required TimeOfDay start,
    required TimeOfDay end,
    required int intervalMinutes,
  }) {
    final slots = <TimeOfDay>[];
    int currentMinutes = timeOfDayToMinutes(start);
    final endMinutes = timeOfDayToMinutes(end);

    while (currentMinutes <= endMinutes) {
      slots.add(minutesToTimeOfDay(currentMinutes));
      currentMinutes += intervalMinutes;
    }

    return slots;
  }

  /// Formats a [TimeOfDay] as HH:mm
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats a [DateTime] as HH:mm
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats a [DateTime] as dd.MM.yyyy
  static String formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    return '$day.$month.$year';
  }

  /// Formats a [DateTime] as dd.MM.yyyy HH:mm
  static String formatDateTime(DateTime dateTime) {
    return '${formatDate(dateTime)} ${formatTime(dateTime)}';
  }

  /// Returns true if [date] is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Returns true if [date] is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Returns the start of the day (00:00:00) for a given date
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Returns the end of the day (23:59:59) for a given date
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Converts a [DateTime] hour/minute to a double for chart positioning
  /// E.g., 14:30 -> 14.5
  static double timeToDouble(DateTime dateTime) {
    return dateTime.hour + dateTime.minute / 60.0;
  }

  /// Converts a [TimeOfDay] to a double for chart positioning
  static double timeOfDayToDouble(TimeOfDay time) {
    return time.hour + time.minute / 60.0;
  }

  /// Returns the next scheduled time slot from now
  static DateTime? nextTimeSlot({
    required TimeOfDay dayStart,
    required TimeOfDay dayEnd,
    required int intervalMinutes,
  }) {
    final now = DateTime.now();
    final slots = generateTimeSlots(
      start: dayStart,
      end: dayEnd,
      intervalMinutes: intervalMinutes,
    );

    for (final slot in slots) {
      final slotDateTime = todayAt(slot.hour, slot.minute);
      if (slotDateTime.isAfter(now)) {
        return slotDateTime;
      }
    }

    return null; // No more slots today
  }
}
