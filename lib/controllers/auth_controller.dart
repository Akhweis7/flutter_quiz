import 'dart:convert';
import 'package:get/get.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthController extends GetxController {
  final RxString token = ''.obs;
  final Rx<UserResponse?> currentUser = Rx<UserResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isPasswordObscured = true.obs;

  bool get isLoggedIn => token.value.isNotEmpty;

  void togglePassword() => isPasswordObscured.value = !isPasswordObscured.value;

  Future<void> login(String usernameOrEmail, String password) async {
    isLoading.value = true;
    try {
      final response = await ApiService.post('/Auth/login', {
        'usernameoremail': usernameOrEmail,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = AuthResponse.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        token.value = data.token ?? '';
        currentUser.value = data.user;
        Get.offAllNamed('/kanban');
      } else {
        Get.snackbar(
          'Login Failed',
          'Invalid credentials (${response.statusCode})',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Network Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void storeToken(String t, UserResponse? user) {
    token.value = t;
    currentUser.value = user;
  }

  void logout() {
    token.value = '';
    currentUser.value = null;
    Get.offAllNamed('/');
  }
}
