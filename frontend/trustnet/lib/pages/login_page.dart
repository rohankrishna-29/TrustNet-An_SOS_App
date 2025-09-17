import 'package:flutter/material.dart';
import 'package:trustnet/pages/home_screen.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              // trustnet logo
              Icon(
                Icons.lock,
                size: 50,  
              ),


              SizedBox(
                height: 50,
              ),
          
              //welcome back text
              Text("Welcome Back!",),


              SizedBox(
                height: 50,
              ),
          
              // email id/phone no textfield
              TextField(),


              SizedBox(
                height: 20,
              ),



              //password textfield
              TextField(),


              SizedBox(
                height: 20,
              ),


          
              //forgot password? text
              Text("Forgot your password? Click here"),

              SizedBox(
                height: 50,
              ),


          
              //login button
              ElevatedButton(onPressed: () => HomeScreen(), 
              child: Row(
                children: [
                  Icon(Icons.login),
                  Text("Login"),
                ],
              ),
              ),


              
              //Dont have an account?
              Text("Don't have an account?"),

              SizedBox(
                height: 20,
              ),
          
          
              //signup button
              ElevatedButton(onPressed: () {
                
              }, 
              child: Row(
                children: [
                  Icon(Icons.login),
                  Text("Signup"),
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}