/// Route path constants to avoid magic strings
class RoutePaths {
  RoutePaths._();

  static const String home = '/';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String addEntry = '/entry/add';
  static const String editEntry = '/entry/edit/:entryId';

  /// Builds the edit entry path with the actual ID
  static String editEntryPath(String entryId) => '/entry/edit/$entryId';
}
