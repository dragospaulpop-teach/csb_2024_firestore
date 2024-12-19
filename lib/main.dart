import 'package:csb_firebase/chat.dart';
import 'package:csb_firebase/signin.dart';
import 'package:csb_firebase/signup.dart';
import 'package:csb_firebase/verify_email.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        if (!user.emailVerified) {
          _navigatorKey.currentState?.pushNamed('verifyEmail');
        } else {
          _navigatorKey.currentState?.pushNamed('/');
        }
      } else {
        _navigatorKey.currentState?.pushNamed('signIn');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Chat(),
        'signIn': (context) => const SignInPage(),
        'signUp': (context) => const SignUpPage(),
        'verifyEmail': (context) => VerifyEmailPage(),
      },
    );
  }
}
