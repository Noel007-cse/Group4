import 'package:flutter/material.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isOwner;

  const AppNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.isOwner = false,
  }) : super(key: key);

  static const Color green = Color(0xFF3F6B00);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: green,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: "Bookings",
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.store,
            color: isOwner ? null : Colors.grey.shade300,
          ),
          label: "My Spaces",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}