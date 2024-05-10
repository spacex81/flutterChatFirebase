import 'package:client/core/domain/entities/failures/failure.dart';

class InvalidCredentialsFailure extends Failure {
  InvalidCredentialsFailure() : super("Ops! Incorrect email and/or password");
}
