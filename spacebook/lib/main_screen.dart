import 'package:flutter/material.dart';
import 'package:spacebook/Homepage.dart';
import 'package:spacebook/profile_pages/profile_page.dart';
import 'package:spacebook/my_spaces_page.dart';
import 'package:spacebook/mybookings.dart';
import 'package:spacebook/widgets/nav_bar_widget.dart';
import 'package:spacebook/services/api_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    MyBookingsPage(),
    MySpacesPage(),
    ProfileScreen(),
  ];

  void onItemTapped(int index) {
    // Block My Spaces tab for buyers
    if (index == 2 && !ApiService.isOwner) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('My Spaces is only available for Owner accounts.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        isOwner: ApiService.isOwner,
      ),
    );
  }
}