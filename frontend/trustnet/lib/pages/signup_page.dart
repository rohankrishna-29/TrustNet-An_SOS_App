import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),

              // Placeholder Logo
              const Icon(
                Icons.public, // Replace with your TrustNet logo
                size: 100,
                color: Color(0xFF9D4EDD),
              ),
              const SizedBox(height: 8),

              const Text(
                "TRUSTNET",
                style: TextStyle(
                  color: Color(0xFF9D4EDD),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),

              const SizedBox(height: 50),

              // Name
              _buildInputField("Name"),
              const SizedBox(height: 16),

              // Phone
              _buildInputField("Phone no"),
              const SizedBox(height: 16),

              // Email
              _buildInputField("Email address"),
              const SizedBox(height: 16),

              // Sex
              _buildInputField("Sex"),
              const SizedBox(height: 16),

              // Date of Birth
              _buildInputField("Date of Birth"),
              const SizedBox(height: 30),

              // Create Account Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9D4EDD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Login Redirect
              Column(
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Go back to login
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9D4EDD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Input Field Widget
  static Widget _buildInputField(String hint) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
