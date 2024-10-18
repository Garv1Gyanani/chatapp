import 'package:chatapp/Auth_screens/login.dart';
import 'package:chatapp/Auth_screens/signup.dart';
import 'package:chatapp/home.dart'; // Add the .dart extension
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print("Error initializing Firebase: $e"); // Optional: log errors
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/signup': (context) => const SignUp(),
        '/home': (context) =>  HomeScreen(),
      },
    );
  }
}
