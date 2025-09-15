import 'package:flutter/material.dart';

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.favorite),
        title: Text("hello"),
        centerTitle: true,
        actions: [
          Icon(Icons.menu)
        ],
      ),
      
    );
  }
}