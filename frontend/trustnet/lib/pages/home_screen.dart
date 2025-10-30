import 'package:flutter/material.dart';
import 'package:trustnet/pages/contacts_page.dart';
import 'package:trustnet/pages/home_page.dart';
import 'package:trustnet/pages/map_page.dart';
import 'package:trustnet/pages/profile_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:trustnet/utils/file_utils.dart';




class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final String currentUid; 

  late final List<Widget> _pages; 

  final List<String> _titles = [
    "TrustNet",
    "Trusted Contacts",
    "Map",
    "Profile"
  ];


  @override
  void initState() {
    super.initState();

    // Fetch current Firebase user UID
    final user = FirebaseAuth.instance.currentUser;
    currentUid = user?.uid ?? '';

    // Initialize pages with currentUid passed to ContactsPage
    _pages = [
      HomePage(),
      ContactsPage(currentUid: currentUid), 
      SOSMapPage(currentUserId: currentUid,),
      ProfilePage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        toolbarHeight:58,
        leadingWidth:44,
      
        leading: Padding(padding: const EdgeInsets.only(top:8.0, bottom:3.0, left:16.0,),
          child: SvgPicture.asset('lib/assets/icons/TrustNet-logo-only.svg',
          height: 40,
          width: 40,
          ),
        ),
        title: AnimatedSwitcher(
    duration: const Duration(milliseconds: 100),
    child: Text(
      _titles[_selectedIndex],
      key: ValueKey(_titles[_selectedIndex]),
    ),
  ),
        centerTitle: true,
        elevation: 4,
        actions: [
          PopupMenuButton(
            onSelected: (value) async {
              if(value ==  'recording_dir'){
                await FileUtils.openRecordingsFolder();
              }
            },
            itemBuilder: (context) =>  [
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
              value: 'recording_dir', 
              child: Row(
                children: [
                  Icon(Icons.record_voice_over),
                  Text("Recorded evidence"),
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
        ],
      ),
    );
  }
}



