sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        Failure() => null,
      };

  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(errorMessage: final msg) => msg,
      };
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final String errorMessage;
  final Object? error;
  final StackTrace? stackTrace;

  const Failure(this.errorMessage, [this.error, this.stackTrace]);
}
