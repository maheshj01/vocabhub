import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase/supabase.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/services/user_service.dart';

@riverpod
class UserStateNotifier extends AsyncNotifier<UserModel> {
  late SharedPreferences sharedPreferences;
  late UserService userService;
  late SupabaseClient supabaseClient;
  String kUserKey = 'kUser';
  @override
  Future<UserModel> build() async {
    print("building user");
    state = AsyncValue.loading();
    sharedPreferences = ref.watch(sharedPreferencesProvider);
    supabaseClient = ref.watch(supabaseClientProvider);
    userService = UserService(supabaseClient);
    final user = await findUserByEmail();
    return user;
  }

  Future<UserModel> findUserByEmail({String? email}) async {
    print("fetching user");
    state = AsyncValue.loading();
    try {
      if (email == null) {
        final userJson = sharedPreferences.getString(kUserKey);
        if (userJson != null) {
          final user = UserModel.fromJson(userJson);
          print('user found ${user.toJson()}');
          setUser(user);
          return user;
        } else {
          setUser(UserModel.init());
          return UserModel.init();
        }
      } else {
        final user = await userService.findUserByEmail(email: email);
        setUser(user);
        return user;
      }
    } catch (e, y) {
      state = AsyncValue.error(e, y);
      rethrow;
    }
  }

  Future<bool> isUserNameValid(String username) async {
    try {
      final isValid = await userService.isUsernameValid(username);
      return isValid;
    } catch (e, y) {
      rethrow;
    }
  }

  void setLogin(bool isLoggedIn) {
    final user = state.value!.copyWith(
      isLoggedIn: isLoggedIn,
    );
    setUser(user);
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      final isUpdated = await userService.updateUser(user);
      return isUpdated;
    } catch (e, y) {
      rethrow;
    }
  }

  Future<bool> deleteUser(UserModel user) async {
    try {
      final deleted = await userService.deleteUser(user);
      if (deleted) {
        removeUser();
        setUser(UserModel.init());
      }
      return deleted;
    } catch (e, y) {
      rethrow;
    }
  }

  void setUser(UserModel value) {
    state = AsyncValue.data(value);
    print("user set ${value.toJson()}");
    final String user = value.toJson();
    sharedPreferences.setString(kUserKey, user);
  }

  Future<void> logout() async {
    state = AsyncValue.loading();
    try {
      removeUser();
      setUser(UserModel.init());
    } catch (e, y) {
      state = AsyncValue.error(e, y);
      rethrow;
    }
  }

  void removeUser() {
    sharedPreferences.remove(kUserKey);
  }
}
