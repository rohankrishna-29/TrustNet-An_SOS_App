import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trustnet/pages/home_page.dart';    // Your main app screen
import 'package:trustnet/pages/login_page.dart';  // Your login screen

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
   
    return StreamBuilder<User?>(
      
      
      stream: FirebaseAuth.instance.authStateChanges(),
      
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          
          return const HomePage(); 
        } 
        
        
        else {
          
          return const LoginPage();
        }
      },
    );
  }
}