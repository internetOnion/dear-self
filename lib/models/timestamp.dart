DateTime normalizeTimestamp(DateTime d) =>
    DateTime.fromMillisecondsSinceEpoch(d.millisecondsSinceEpoch, isUtc: true);
