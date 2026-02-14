/// Reason for a [Failure].
enum FailureType {
  duplicate,
  other,
}

/// Result type for operations that can succeed or fail.
/// Treats empty values as failure.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull =>
      switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  String get failureMessage =>
      switch (this) {
        Success() => '',
        Failure(:final message) => message,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(String message) failure,
  }) =>
      switch (this) {
        Success(:final value) => success(value),
        Failure(:final message) => failure(message),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message, {this.type = FailureType.other});
  final String message;
  final FailureType type;
}
