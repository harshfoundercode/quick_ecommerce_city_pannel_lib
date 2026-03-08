class AppException implements Exception {
  final String? message;
  final String? prefix;

  AppException([this.message, this.prefix]);

  @override
  String toString() {
    return "$prefix$message";
  }
}

/// 🔹 Server / Network Exceptions
class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class RequestTimeoutException extends AppException {
  RequestTimeoutException([String? message])
      : super(message, "Request Timeout: ");
}

class TooManyRequestsException extends AppException {
  TooManyRequestsException([String? message])
      : super(message, "Too Many Requests: ");
}

/// 🔹 Client Exceptions
class BadRequestException extends AppException {
  BadRequestException([String? message])
      : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([String? message])
      : super(message, "Unauthorised: ");
}

class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(message, "Resource Not Found: ");
}

class ConflictException extends AppException {
  ConflictException([String? message])
      : super(message, "Conflict: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message])
      : super(message, "Invalid Input: ");
}

/// 🔹 Server Internal Errors
class InternalServerException extends AppException {
  InternalServerException([String? message])
      : super(message, "Internal Server Error: ");
}

class BadGatewayException extends AppException {
  BadGatewayException([String? message])
      : super(message, "Bad Gateway: ");
}

class ServiceUnavailableException extends AppException {
  ServiceUnavailableException([String? message])
      : super(message, "Service Unavailable: ");
}

class GatewayTimeoutException extends AppException {
  GatewayTimeoutException([String? message])
      : super(message, "Gateway Timeout: ");
}
