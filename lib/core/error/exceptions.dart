/// A data-layer error in project terms.
///
/// Data sources translate external SDK errors (e.g. `FirebaseException`)
/// into these, so nothing above the data sources depends on SDK error types.
/// Repositories then translate them into `Failure`s. Shared exceptions live
/// here; feature-specific families (e.g. `AuthException`) extend this class
/// in their own feature's data layer.
abstract class AppException implements Exception {
  const AppException();
}

/// The backend could not be reached (e.g. no internet connection).
final class NetworkException extends AppException {
  const NetworkException();
}
