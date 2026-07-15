/// Basit `Result` tipi — istisna fırlatmadan başarı/başarısızlık taşımak için.
library;

sealed class Result<T, E> {
  const Result();

  bool get isOk => this is Ok<T, E>;
  bool get isErr => this is Err<T, E>;

  T get value => (this as Ok<T, E>).data;
  E get error => (this as Err<T, E>).cause;

  T? get valueOrNull => switch (this) {
    Ok<T, E>(:final data) => data,
    Err<T, E>() => null,
  };
}

class Ok<T, E> extends Result<T, E> {
  const Ok(this.data);
  final T data;
}

class Err<T, E> extends Result<T, E> {
  const Err(this.cause);
  final E cause;
}
