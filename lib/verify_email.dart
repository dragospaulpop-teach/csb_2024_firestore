import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatelessWidget {
  VerifyEmailPage({super.key});

  final FirebaseAuth auth = FirebaseAuth.instance;

  void resendEmail() {
    final user = auth.currentUser;
    if (user != null) {
      user.sendEmailVerification();
    }
  }

  void signOut() {
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Your account is not verified',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      'Please verify your email by clicking the link sent to your email address.'),
                  const SizedBox(height: 10),
                  const Text(
                      'If you did not receive the email, please check your spam folder or click the button below to resend the email.'),
                  const SizedBox(height: 10),
                  const Text('You can also sign out.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () => resendEmail(),
                      child: const Text('Resend email')),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: () => signOut(),
                      child: const Text('Sign out')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
