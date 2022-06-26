import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:vocabhub/services/api/exception.dart';
import 'package:http/http.dart' as http;
import 'package:vocabhub/constants/constants.dart' show BASE_URL;

enum HttpMethod { GET, POST, PUT, DELETE, PATCH }

class ApiProvider {
  static String baseUrl = BASE_URL;
  static Duration timeoutDuration = Duration(seconds: 5);

  FutureOr<void> retryOnTimeOut({required http.Response response}) async {
    try {
      final res = await response.request!.send();
      final newResponse = await http.Response.fromStream(res);
      handleResponse(newResponse);
    } catch (_) {}
  }

  Object? handleResponse(http.Response res) {
    switch (res.statusCode) {
      case 200:
        return json.decode(res.body);
      case 400:
        return BadRequestException();
      case 404:
        return ResourceNotFoundException();
      case 500:
        break;
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${res.statusCode}');
    }
    return null;
  }

  Future<http.Response> getRequest(String endPoint,
      {Map<String, String>? headers}) async {
    var responseJson;
    try {
      final response = await http
          .get(Uri.parse(BASE_URL + endPoint), headers: headers)
          .timeout(timeoutDuration);
      responseJson = handleResponse(response);
    } on SocketException catch (_) {
      throw ConnectivityException('No Internet connection');
    } on TimeoutException catch (_) {
      // TODO: how to pass the response object on Timeout
      // retryOnTimeOut(response: http.);
    } catch (_) {}
    return responseJson;
  }

  Future<http.Response> postRequest(String endPoint,
      {Map<String, Object>? body, Map<String, String>? headers}) async {
    var responseJson;
    try {
      final response = await http
          .post(Uri.parse(BASE_URL + endPoint), body: body, headers: headers)
          .timeout(timeoutDuration);
      responseJson = handleResponse(response);
    } on SocketException catch (_) {
      throw ConnectivityException('No Internet connection');
    } on TimeoutException catch (_) {
      // retryOnTimeOut(response: http.);
    } catch (_) {}
    return responseJson;
  }

  Future<http.Response> putRequest(String endPoint,
      {Map<String, Object>? body, Map<String, String>? headers}) async {
    var responseJson;
    try {
      final response = await http
          .put(Uri.parse(BASE_URL + endPoint), body: body, headers: headers)
          .timeout(timeoutDuration);
      responseJson = handleResponse(response);
    } on SocketException catch (_) {
      throw ConnectivityException('No Internet connection');
    } on TimeoutException catch (_) {
      // retryOnTimeOut(response: http.);
    } catch (_) {}
    return responseJson;
  }

  Future<http.Response> deleteRequest(String endPoint,
      {Map<String, Object>? body, Map<String, String>? headers}) async {
    var responseJson;
    try {
      final response = await http
          .delete(Uri.parse(BASE_URL + endPoint), headers: headers)
          .timeout(timeoutDuration);
      responseJson = handleResponse(response);
    } on SocketException catch (_) {
      throw ConnectivityException('No Internet connection');
    } on TimeoutException catch (_) {
      // retryOnTimeOut(response: http.);
    } catch (_) {}
    return responseJson;
  }

  Future<http.Response> patchRequest(String endPoint,
      {Map<String, Object>? body, Map<String, String>? headers}) async {
    var responseJson;
    try {
      final response = await http
          .patch(Uri.parse(BASE_URL + endPoint), body: body, headers: headers)
          .timeout(timeoutDuration);
      responseJson = handleResponse(response);
    } on SocketException catch (_) {
      throw ConnectivityException('No Internet connection');
    } on TimeoutException catch (_) {
      // retryOnTimeOut(response: http.);
    } catch (_) {}
    return responseJson;
  }
}
