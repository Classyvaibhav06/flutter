import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'No internet connection. Please check your network and try again.',
  ]);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Session expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'Product not found.',
  ]) : super(statusCode: 404);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Unable to access local storage.',
  ]);
}
