class DatabaseValidationException implements Exception {
  final String message;

  DatabaseValidationException(this.message);

  @override
  String toString() => message;
}
