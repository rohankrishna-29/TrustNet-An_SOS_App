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
        elevation: 4,
        
        actions: [
          PopupMenuButton(itemBuilder: (context) =>  [
            PopupMenuItem(
              value: 1, 
              child: Row(
                children: [
                  Icon(Icons.settings),
                  Text("Settings"),
                ],
              )
            ),
            PopupMenuItem(
              value: 2, 
              child: Row(
                children: [
                  Icon(Icons.upload),
                  Text("Uploaded media"),
                ],
              )
            ),
            PopupMenuItem(
              value: 3, 
              child: Row(
                children: [
                  Icon(Icons.history),
                  Text("History")
                ],
              )
            ),
          ],
          )
        ],
      ),
      
    );
  }
}