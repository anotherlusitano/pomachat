import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_pap/components/main_drawer.dart';
import 'package:my_pap/pages/friends_page.dart';
import 'package:my_pap/pages/groups_page.dart';
import 'package:my_pap/pages/invites_page.dart';
import 'package:my_pap/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void goToProfilePage() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );
  }

  void goToFriendsPage() {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FriendsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // set default unselected
    int selectedIndex = -1;

    final List<Widget> pages = [
      const InvitesPage(),
      const GroupsPage(),
      const FriendsPage(),
    ];

    void onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });
      // Navigate to the selected page
      Navigator.push(context, MaterialPageRoute(builder: (context) => pages[index]));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Colors.grey[900],
      ),
      drawer: MainDrawer(
        onProfileTap: goToProfilePage,
        onLogoutTap: signOut,
        onFriendsTap: goToFriendsPage,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        unselectedItemColor: Colors.white,
        // if unselected change color to unselectedItemColor
        selectedItemColor: (selectedIndex != -1) ? Colors.grey[900] : Colors.white,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.email),
            label: 'Convites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Amigos',
          ),
        ],
        // if unselected change select index to 0, else you will get error
        currentIndex: (selectedIndex != -1) ? selectedIndex : 0,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          onItemTapped(selectedIndex);
        },
      ),
    );
  }
}
