import 'package:flutter/cupertino.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/auth_service.dart';
import 'package:vocabhub/services/services/service_base.dart';

class AuthController extends ChangeNotifier implements ServiceBase {
  late AuthService _authService;
  late UserModel _user;

  @override
  Future<void> disposeService() async {}

  UserModel get user => _user;

  /// stores user locally
  Future<void> setUser(UserModel user) async {
    _user = user;
    await _authService.setUser(user);
  }

  Future<void> logout(BuildContext context) async {
    await _authService.logOut(context, user);
    _user = _user.copyWith(isLoggedIn: false);
    await _authService.setUser(_user);
    notifyListeners();
  }

  @override
  Future<void> initService() async {
    _authService = AuthService();
    await _authService.initService();
    _user = await _authService.getUser();
  }
}
