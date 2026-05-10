import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'ui/sign_in_page.dart';
import 'ui/kanban_page.dart';
import 'sign_up.dart';

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  HttpOverrides.global = _DevHttpOverrides();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kanban',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SignInPage()),
        GetPage(name: '/signup', page: () => const SignUpPage()),
        GetPage(name: '/kanban', page: () => const KanbanPage()),
      ],
    );
  }
}
