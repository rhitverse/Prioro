import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';
import 'package:prioro/auth/repository/auth_providers.dart';
import 'package:prioro/auth/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? authRepositoryInstance;

  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final forgotEmailController = TextEditingController();

  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    forgotEmailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password required';
    if (value.length < 6) return 'Min 6 characters';
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name required';
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirm password required';
    if (value != passwordController.text) return 'Passwords do not match';
    return null;
  }

  Future<void> login(BuildContext context) async {
    if (!(loginFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    try {
      await _authRepository.signInWithEmail(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Login Failed", e.message ?? "Error");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signup(BuildContext context) async {
    if (!(signupFormKey.currentState?.validate() ?? false)) return;

    isLoading.value = true;

    try {
      await _authRepository.signUpWithEmail(
        email: emailController.text,
        password: passwordController.text,
        context: context,
        name: nameController.text,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Signup Failed", e.message ?? "Error");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle({required BuildContext context}) async {
    isGoogleLoading.value = true;

    try {
      await _authRepository.signInWithGoogle(context: context);
    } catch (e) {
      Get.snackbar("Error", "Google sign-in failed");
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> sendForgotPasswordEmail({required BuildContext context}) async {
    final email = forgotEmailController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar("Error", "Enter valid email");
      return;
    }

    isLoading.value = true;

    try {
      await _authRepository.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        Navigator.pop(context);
      }
      Get.snackbar("Success", "Reset link sent to $email");
    } on FirebaseAuthException catch (e) {
      final code = e.code.toLowerCase();
      final message = switch (code) {
        'invalid-email' => 'Enter a valid email address',
        'missing-android-pkg-name' =>
          'Reset config missing for Android package',
        'missing-continue-uri' => 'Reset link configuration missing',
        'unauthorized-continue-uri' =>
          'Reset link domain is not authorized in Firebase',
        'user-not-found' => 'No account found with this email',
        'too-many-requests' => 'Too many attempts. Try again after some time',
        _ => e.message ?? 'Failed to send reset link',
      };
      Get.snackbar("Reset Failed", message);
    } catch (_) {
      Get.snackbar("Reset Failed", "Failed to send reset link");
    } finally {
      isLoading.value = false;
    }
  }
}
