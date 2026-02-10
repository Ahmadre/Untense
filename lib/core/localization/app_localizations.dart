import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:i18next/i18next.dart';

/// Custom [LocalizationDataSource] that loads JSON translation files from assets.
///
/// Wraps the parsed JSON under the default (empty-string) namespace so that
/// [ResourceStore] can resolve keys like `t('home.greeting')` via the path
/// `[locale, '', 'home', 'greeting']`.
class JsonAssetDataSource implements LocalizationDataSource {
  @override
  Future<Map<Locale, Map<String, dynamic>>> load(List<Locale> locales) async {
    final result = <Locale, Map<String, dynamic>>{};
    for (final locale in locales) {
      final tag = AppLocalizations.localeToString(locale);
      try {
        final jsonString = await rootBundle.loadString(
          'localization/$tag.json',
        );
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        // Wrap under empty-string namespace (default when no ':' in key)
        result[locale] = {'': jsonMap};
      } catch (_) {
        result[locale] = {};
      }
    }
    return result;
  }
}

/// Localization setup and helpers for i18next integration
class AppLocalizations {
  AppLocalizations._();

  static const supportedLocales = [Locale('de', 'DE'), Locale('en', 'GB')];

  static const Locale defaultLocale = Locale('de', 'DE');

  /// The shared data source instance for loading translations
  static final JsonAssetDataSource dataSource = JsonAssetDataSource();

  /// Converts a locale string like 'de-DE' to a [Locale] object
  static Locale localeFromString(String localeString) {
    final parts = localeString.split('-');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }

  /// Converts a [Locale] to a string like 'de-DE'
  static String localeToString(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}-${locale.countryCode}';
    }
    return locale.languageCode;
  }
}
