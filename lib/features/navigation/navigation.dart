import 'package:flutter/material.dart';
import '../home/home.dart';
import '../jobs/jobs.dart';
import '../work/work.dart';
import '../profile/profile.dart';


class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentIndex = 0;
  late final List<Widget> _pages = [
    HomePage(onTapeChange: (index){
      setState(() {
        _currentIndex = index;
      });
    }
    ),
    const JobsPage(),
    const WorkPage(),
    const ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: _pages[_currentIndex]
      ),
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF1D4ED8),
        unselectedItemColor: Colors.grey[600],
        showUnselectedLabels: true,
        onTap: (index){
            setState(() {
              _currentIndex = index;
            });
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Arbeit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),

        ],

      ),
    );
  }
}
