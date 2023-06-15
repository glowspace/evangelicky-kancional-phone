import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zpevnik/utils/extensions.dart';

const double _navigationBarHeight = 64;

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness.isLight;

    return Hero(
      tag: 'bottomNavigationBar',
      transitionOnUserGestures: true,
      child: NavigationBar(
        backgroundColor: isLight ? const Color(0xfffffbfe) : const Color(0xff1e1e1e),
        surfaceTintColor: isLight ? const Color(0xfffffbfe) : const Color(0xff1e1e1e),
        selectedIndex: ModalRoute.of(context)?.settings.name == '/' ? 0 : 2,
        height: _navigationBarHeight,
        onDestinationSelected: (index) => _onDestinationSelected(context, index),
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

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == 1) {
      context.push('/search');
    } else if (index == 2) {
      // TODO: should pop if already inside of playlists subtree
      context.push('/playlists');
    } else {
      while (GoRouter.of(context).location != '/') {
        context.pop();
      }
    }
  }
}
