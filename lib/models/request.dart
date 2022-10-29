enum RequestState { active, done, error, none }

class Request {
  final RequestState state;
  final Object? data;
  final String? message;

  Request(this.state, {this.data, this.message});
}
