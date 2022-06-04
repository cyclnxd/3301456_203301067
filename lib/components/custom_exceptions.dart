class CustomException implements Exception {
  final String? err;

  CustomException({this.err = "Something went wrong"});

  @override
  String toString() => '$err';
}
