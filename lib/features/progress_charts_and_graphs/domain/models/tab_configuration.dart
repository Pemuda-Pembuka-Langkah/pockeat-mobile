class TabConfiguration {
  final int mainTabCount;
  final int progressTabCount;
  final List<String> progressTabLabels;
  final int logHistoryTabCount;
  final List<String> logHistoryTabLabels;

  TabConfiguration({
    required this.mainTabCount,
    required this.progressTabCount,
    required this.progressTabLabels,
    required this.logHistoryTabCount,
    required this.logHistoryTabLabels,
  });
}
