import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:prioro/auth/repository/auth_providers.dart';
import 'package:prioro/auth/repository/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  AuthController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? authRepositoryInstance;

  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotEmailController = TextEditingController();

  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    super.onClose();
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> login() async {
    Get.snackbar(
      'Google Sign-In Only',
      'Please continue using Google login.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> sendForgotPasswordEmail() async {
    Get.snackbar(
      'Unavailable',
      'Password reset is disabled in Google-only auth mode.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  Future<void> signInWithGoogle({required BuildContext context}) async {
    isGoogleLoading.value = true;
    try {
      await _authRepository.signInWithGoogle(context: context);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      final message = e.message ?? 'Google sign-in failed. Please try again.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign-in failed. Please try again.'),
        ),
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }
}
