import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'price_signal_screen.dart';
import 'atlas_screen.dart';
import 'carbon_burden_screen.dart';
import 'resilience_credits_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _goToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
  final List<Widget> screens = [
      HomeScreen(onTabTap: _goToTab),
      PriceSignalScreen(),
      const AtlasScreen(),
      const CarbonBurdenScreen(),
      const ResilienceCreditsScreen(),
    ];

    final List<BottomNavigationBarItem> navItems = const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.electric_bolt_outlined),
        activeIcon: Icon(Icons.electric_bolt),
        label: 'Price',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map),
        label: 'Atlas',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.eco_outlined),
        activeIcon: Icon(Icons.eco),
        label: 'Carbon',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.stars_outlined),
        activeIcon: Icon(Icons.stars),
        label: 'Credits',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF111111),
          border: Border(
            top: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _goToTab,
          backgroundColor: const Color(0xFF111111),
          selectedItemColor: const Color(0xFF00C853),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: navItems,
        ),
      ),
    );
  }
}
