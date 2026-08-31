import 'package:soulsync/core/network/api_exception.dart';

abstract class ApiResult<T> {
  const ApiResult();

  factory ApiResult.success(T data) = ApiSuccess<T>;
  factory ApiResult.failure(ApiException exception) = ApiFailure<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException exception) failure,
  }) {
    if (this is ApiSuccess<T>) {
      return success((this as ApiSuccess<T>).data);
    } else if (this is ApiFailure<T>) {
      return failure((this as ApiFailure<T>).exception);
    }
    throw StateError('Invalid ApiResult subclass');
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final ApiException exception;
  const ApiFailure(this.exception);
}
