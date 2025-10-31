import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trustnet/pages/login_page.dart';
import 'package:trustnet/pages/home_screen.dart';

class UserLoggedInCheck extends StatelessWidget {
  const UserLoggedInCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user == null) {
            return LoginPage();
          } else {
            return HomeScreen();
          }
        }
        // Loading indicator while checking auth state
        return CircularProgressIndicator();
      },
    );
  }
}