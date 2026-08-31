import 'package:soulsync/core/errors/exceptions.dart';
import 'package:soulsync/core/errors/failures.dart';

/// Abstract base repository providing consistent error-to-failure mapping helper.
abstract class BaseRepository {
  Future<Failure?> handleException(Future<void> Function() action) async {
    try {
      await action();
      return null;
    } on ServerException catch (e) {
      return ServerFailure(message: e.message, code: e.statusCode?.toString());
    } on NetworkException catch (e) {
      return NetworkFailure(message: e.message);
    } on UnauthorizedException catch (e) {
      return AuthFailure(message: e.message);
    } catch (e) {
      return UnknownFailure(message: e.toString());
    }
  }
}
