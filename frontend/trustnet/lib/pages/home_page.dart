import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String status = "OFF";

  final Map<String, Color> statusColors = {
    "OFF": Colors.grey,
    "GREEN": Colors.green,
    "RED": Colors.red,
  };

  void toggleStatus() {
    setState(() {
      if (status == "OFF") {
        status = "GREEN";
      } else if (status == "GREEN") {
        status = "RED";
      } else if (status == "RED") {
        status = "OFF";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = statusColors[status]!;

    return Scaffold(
      backgroundColor: Colors.black,
      

      // Body
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: toggleStatus, // tap to toggle
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2.5),
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(Icons.golf_course_rounded), //placeholder logo
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: toggleStatus, // tap text also toggles
              child: Text(
                "Status: $status",
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
