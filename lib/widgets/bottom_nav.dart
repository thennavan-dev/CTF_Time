import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/applied_screen.dart';
import '../screens/settings_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    AppliedScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.1, 0.1),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,      
          highlightColor: Colors.transparent,         
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFF1E1E1E),
          selectedItemColor: Colors.tealAccent,
          unselectedItemColor: Colors.grey.shade500,
          type: BottomNavigationBarType.fixed,
          elevation: 10,
          items: [
            _buildAnimatedNavItem(Icons.home, 'Home', 0),
            _buildAnimatedNavItem(Icons.check_circle, 'Applied', 1),
            _buildAnimatedNavItem(Icons.settings, 'Settings', 2),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildAnimatedNavItem(
      IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;

    return BottomNavigationBarItem(
      icon: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Icon(icon),
      ),
      label: label,
    );
  }
}
