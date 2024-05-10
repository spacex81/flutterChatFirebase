import 'package:client/core/domain/entities/failures/failure.dart';

class InvalidEmailFailure extends Failure {
  InvalidEmailFailure() : super("Oops! This email is not registered yet");
}
