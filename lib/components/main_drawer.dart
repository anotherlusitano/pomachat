import 'package:flutter/material.dart';
import 'package:my_pap/components/navlist.dart';

class MainDrawer extends StatelessWidget {
  final void Function() onProfileTap;
  final void Function() onLogoutTap;
  const MainDrawer({
    super.key,
    required this.onProfileTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey[900],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const DrawerHeader(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              NavList(
                icon: Icons.home,
                text: 'H O M E',
                onTap: () => Navigator.pop(context),
              ),
              NavList(
                icon: Icons.person,
                text: 'P R O F I L E',
                onTap: onProfileTap,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: NavList(
              icon: Icons.logout,
              text: 'L O G O U T',
              onTap: onLogoutTap,
            ),
          ),
        ],
      ),
    );
  }
}
