// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:quizz/sign-up.dart';

// class _DevHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback = (cert, host, port) => true;
//   }
// }

// void main() {
//   HttpOverrides.global = _DevHttpOverrides();
//   runApp(const MyApp());
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _obscureText = true;

//   void _toggleObscureText() {
//     setState(() {
//       _obscureText = !_obscureText;
//     });
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context_) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         body: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: NetworkImage(
//                 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5cMTnHdN7qqJhUw1hyyUjl8rUbQUpXPfoEw&s',
//               ),
//               fit: BoxFit.cover,
//             ),
//           ),
//           child: Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 380),
//                 child: Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey.shade300),
//                     boxShadow: const [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 10,
//                         offset: Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         color: const Color.fromARGB(255, 255, 255, 255),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.storefront,
//                         color: Color.fromARGB(255, 0, 0, 0),
//                         size: 40,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     TextField(
//                       controller: nameController,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(
//                           Icons.person,
//                           color:
//                               const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
//                           size: 20,
//                         ),
//                         border: const OutlineInputBorder(),
//                         labelText: 'Enter your name',
//                         hintText: 'John Doe',
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     TextField(
//                       controller: passwordController,
//                       obscureText: _obscureText,
//                       autocorrect: false,
//                       enableSuggestions: false,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(
//                           Icons.password,
//                           color:
//                               const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
//                           size: 20,
//                         ),
//                         labelText: 'Password',
//                         border: const OutlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscureText
//                                 ? Icons.visibility_off
//                                 : Icons.visibility,
//                             color:
//                                 const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
//                             size: 20,
//                           ),
//                           onPressed: _toggleObscureText,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             print('Sign in button pressed');
//                           },
//                           child: const Text('Sign in'),
//                         ),
//                         const SizedBox(width: 12),
//                         Builder(
//                           builder: (buttonContext) => TextButton(
//                             onPressed: () {
//                               Navigator.push(
//                                 buttonContext,
//                                 MaterialPageRoute(
//                                   builder: (context) => const SignUpPage(),
//                                 ),
//                               );
//                             },
//                             child: const Text('Sign up'),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

