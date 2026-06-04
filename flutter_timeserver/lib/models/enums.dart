// User-selectable display/standard options, ported from the original spinners.

enum TimeStandard { utc, local, decimal, swatch }

enum MeasurementSystem { metric, imperial }

enum CoordinateType { wgs84, utm, mgrs, olc }

extension TimeStandardX on TimeStandard {
  String get prefKey => name;
  static TimeStandard fromName(String? n) =>
      TimeStandard.values.firstWhere((e) => e.name == n, orElse: () => TimeStandard.utc);
}

extension MeasurementSystemX on MeasurementSystem {
  String get prefKey => name;
  static MeasurementSystem fromName(String? n) => MeasurementSystem.values
      .firstWhere((e) => e.name == n, orElse: () => MeasurementSystem.metric);
}

extension CoordinateTypeX on CoordinateType {
  String get prefKey => name;
  static CoordinateType fromName(String? n) =>
      CoordinateType.values.firstWhere((e) => e.name == n, orElse: () => CoordinateType.wgs84);
}
