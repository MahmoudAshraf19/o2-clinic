class FirestoreResult<T> {
  final bool success;
  final T? data;
  final String? error;

  const FirestoreResult({required this.success, this.data, this.error});

  factory FirestoreResult.success(T data) {
    return FirestoreResult(success: true, data: data);
  }

  factory FirestoreResult.failure(String error) {
    return FirestoreResult(success: false, error: error);
  }
}
