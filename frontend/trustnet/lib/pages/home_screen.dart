import 'package:flutter/material.dart';
import 'package:trustnet/pages/contacts_page.dart';
import 'package:trustnet/pages/home_page.dart';
import 'package:trustnet/pages/profile_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    TrustedContactsPage(),
    Center(child: Text("Maps page"),),
    ProfilePage()
  ];

  final List<String> _titles = [
    "TrustNet",
    "Trusted Contacts",
    "Maps",
    "Profile"
  ];

  /*void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.favorite),
        title: Text("TrustNet"),
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
      body: _pages[_selectedIndex],
      /*bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.green,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'Contacts'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'You'),
        ]
      ),*/
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.contacts), label: 'Contacts'),
          NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.person), label: 'You'),
        ]),
    );
  }
}