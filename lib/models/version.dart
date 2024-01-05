import 'dart:convert';

class AppVersion {
  Version version;
  Version oldVersion;

  AppVersion({
    required this.version,
    required this.oldVersion,
  });

  AppVersion copyWith({
    Version? version,
    Version? oldVersion,
  }) {
    return AppVersion(
      version: version ?? this.version,
      oldVersion: oldVersion ?? this.oldVersion,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'version': version.toMap()});
    result.addAll({'oldVersion': oldVersion.toMap()});

    return result;
  }

  factory AppVersion.fromMap(Map<String, dynamic> map) {
    return AppVersion(
      version: Version.fromMap(map['version']),
      oldVersion: Version.fromMap(map['oldVersion']),
    );
  }

  String toJson() => json.encode(toMap());

  factory AppVersion.fromJson(String source) => AppVersion.fromMap(json.decode(source));

  @override
  String toString() => 'AppVersion(version: $version, oldVersion: $oldVersion)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppVersion && other.version == version && other.oldVersion == oldVersion;
  }

  @override
  int get hashCode => version.hashCode ^ oldVersion.hashCode;
}

class Version {
  final String version;
  final int buildNumber;
  final DateTime? date;
  Version({
    this.version = '',
    this.buildNumber = 1,
    this.date = null,
  });

  Version copyWith({
    String? version,
    int? buildNumber,
    DateTime? date,
  }) {
    return Version(
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'version': version});
    result.addAll({'buildNumber': buildNumber});
    result.addAll({'date': date!.millisecondsSinceEpoch});

    return result;
  }

  factory Version.fromMap(Map<String, dynamic> map) {
    return Version(
      version: map['version'] ?? '',
      buildNumber: map['buildNumber']?.toInt() ?? 0,
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Version.fromJson(String source) => Version.fromMap(json.decode(source));

  @override
  String toString() => 'Version(version: $version, buildNumber: $buildNumber, date: $date)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Version &&
        other.version == version &&
        other.buildNumber == buildNumber &&
        other.date == date;
  }

  @override
  int get hashCode => version.hashCode ^ buildNumber.hashCode ^ date.hashCode;
}
