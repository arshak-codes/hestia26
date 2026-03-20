import 'package:flutter/material.dart';
import 'discover_screen.dart';
import 'schedule_screen.dart';
import 'highlights_screen.dart';
import 'map_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DiscoverScreen(),
    const HighlightsScreen(),
    const MapScreen(),
    const ScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _pages.length) {
      _currentIndex = 0;
    }
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF161618),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: [
              _buildBottomNavItem(Icons.home_outlined, 0),
              _buildBottomNavItem(Icons.star_border, 1),
              _buildBottomNavItem(Icons.explore_outlined, 2),
              _buildBottomNavItem(Icons.calendar_month_outlined, 3),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return BottomNavigationBarItem(
      icon: ShaderMask(
        shaderCallback: (bounds) {
          if (!isSelected) {
            return const LinearGradient(
              colors: [Colors.white54, Colors.white54],
            ).createShader(bounds);
          }
          return const LinearGradient(
            colors: [Color(0xFFE28B9B), Color(0xFF9070E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Icon(icon, size: 30, color: Colors.white),
      ),
      label: '',
    );
  }
}
