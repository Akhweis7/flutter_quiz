import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SignInPage extends StatelessWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEAF2FF), Color(0xFFF7F9FF)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.storefront,
                        color: Colors.black,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black.withValues(alpha: 0.5),
                          size: 20,
                        ),
                        border: const OutlineInputBorder(),
                        labelText: 'Username or Email',
                        hintText: 'john@example.com',
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Obx rebuilds only this field when visibility toggles
                    Obx(
                      () => TextField(
                        controller: passwordController,
                        obscureText: auth.isPasswordObscured.value,
                        autocorrect: false,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.password,
                            color: Colors.black.withValues(alpha: 0.5),
                            size: 20,
                          ),
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              auth.isPasswordObscured.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.black.withValues(alpha: 0.5),
                              size: 20,
                            ),
                            onPressed: auth.togglePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Obx rebuilds only the button row when isLoading changes
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: auth.isLoading.value
                                ? null
                                : () => auth.login(
                                      nameController.text.trim(),
                                      passwordController.text,
                                    ),
                            child: auth.isLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Sign in'),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => Get.toNamed('/signup'),
                            child: const Text('Sign up'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
