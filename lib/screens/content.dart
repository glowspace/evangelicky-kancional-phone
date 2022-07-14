import 'package:flutter/material.dart';
import 'package:zpevnik/screens/home.dart';

const double _navigationBarHeight = 64;

class ContentScreen extends StatefulWidget {
  const ContentScreen({Key? key}) : super(key: key);

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(child: HomeScreen()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
        height: _navigationBarHeight,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Nástěnka',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Hledání',
          ),
          NavigationDestination(
            icon: Icon(Icons.playlist_play_rounded),
            label: 'Seznamy',
          ),
        ],
      ),
    );
  }

  void _onDestinationSelected(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed('/search');
    } else if (index == 2) {
      Navigator.of(context).pushNamed('/playlists');
    } else {
      setState(() => _currentIndex = index);
    }
  }
}
