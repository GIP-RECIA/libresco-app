class BaseUrl {
  static final BaseUrl _instance = BaseUrl._internal();

  final String _casBaseURL = "auth.test.recia.dev";
  final String _serviceURL = "https://auth.test.recia.dev/appMobile";
  final String _uPortalBaseURL = "lycees.test.recia.dev";

  factory BaseUrl() {
    return _instance;
  }

  BaseUrl._internal();

  String get casBaseURL => _casBaseURL;
  String get serviceURL => _serviceURL;
  String get uPortalBaseURL => _uPortalBaseURL;
}