class BuildInfo {
  static const String appVersion = 'UNSET_VERSION';
  static const int buildNumber = -80085;
  static const ReleaseType releaseType = ReleaseType.inDev;
  static const String branch = 'UNSET_BRANCH';
}

enum ReleaseType {
  stable,
  beta,
  personalTest,
  inDev,
}
