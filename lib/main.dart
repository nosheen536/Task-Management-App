import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/viewModels/user_viewmodel.dart';
import 'package:task_management_app/views/auth/forgot_password.dart';
import 'package:task_management_app/views/splash_screen.dart';
import 'package:task_management_app/views/tasks/tasks_screen.dart';

import 'firebase_options.dart';

// ViewModels
import 'viewmodels/auth_viewmodel.dart';
import 'viewModels/task_viewmodel.dart';

// Auth Screens
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';

// Main App Screens
import 'views/home/home_screen.dart';
import 'views/profile/profile_screen.dart';

import 'views/tasks/add_task_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => UserViewModel()),
        ChangeNotifierProvider(create: (_) => TaskViewModel()),
      ],
      child: MaterialApp(
        title: 'Taskify',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFF19485C),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          "/":(context)=>const SplashScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/tasks': (context) => const TasksScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/addTask': (context) => const AddTaskScreen(),
          '/forgot': (context)=>const ForgotPasswordScreen()
        },
      ),
    );
  }
}
