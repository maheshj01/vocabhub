class CustomException implements Exception {
  final _message;
  final _prefix;

  CustomException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class BadRequestException extends CustomException {
  BadRequestException([String? message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException([message]) : super(message, "Unauthorised:");
}

class FetchDataException extends CustomException {
  FetchDataException([String? message]) : super(message, "Invalid Input: ");
}

class ParseDataException extends CustomException {
  ParseDataException([String? message])
      : super(message, "Failed to parse the Data");
}

class ConnectivityException extends CustomException {
  ConnectivityException([String? message])
      : super(message, "Check your internet connectivity");
}

class ResourceNotFoundException extends CustomException {
  ResourceNotFoundException([String? message]) : super(message, "Not Found ");
}
