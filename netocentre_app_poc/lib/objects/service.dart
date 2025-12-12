class Service {
  final int id;
  final String text;
  final String serviceUri;
  final String iconUri;
  bool isFavorite;
  final bool isNew = false;
  String? fname;
  late final bool isAuthByUPortal;

  Service.UPortalBased({
    required this.id,
    required this.text,
    required this.serviceUri,
    required this.iconUri,
    required this.isFavorite,
    required this.fname,
  }) {
    isAuthByUPortal = true;
  }

  Service.CASBased({
    required this.id,
    required this.text,
    required this.serviceUri,
    required this.iconUri,
    required this.isFavorite,
    required this.fname,
  }) {
    isAuthByUPortal = false;
  }
}
