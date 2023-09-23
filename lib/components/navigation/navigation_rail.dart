import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/navigation/utils.dart';
import 'package:zpevnik/routing/router.dart';

class CustomNavigationRail extends StatelessWidget {
  const CustomNavigationRail({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Hero(
      tag: 'navigationRail',
      transitionOnUserGestures: true,
      // can't set `surfaceTintColor` for `NavigationRail`, so it is wrapped to match the app bar color
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            if (context.isHome)
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.2),
                spreadRadius: 0,
                blurRadius: 6,
                offset: const Offset(2, 0),
              ),
          ],
        ),
        child: Material(
          color: context.isHome ? theme.canvasColor : theme.colorScheme.surface,
          elevation: 1,
          surfaceTintColor: context.isHome ? null : theme.colorScheme.surfaceTint,
          child: SafeArea(
            child: NavigationRail(
              backgroundColor: Colors.transparent,
              labelType: NavigationRailLabelType.all,
              groupAlignment: context.isHome ? 0 : -0.155,
              selectedIndex: context.isHome ? 0 : (context.isSearching ? 1 : 2),
              onDestinationSelected: (index) => onDestinationSelected(context, index),
              leading: context.isHome
                  ? null
                  : Column(
                      children: [
                        Image.asset('assets/images/logos/logo.png'),
                        // StatefulBuilder(
                        //   builder: () => Highlightable(
                        //     onTap: ref.read(menuCollapsedProvider.notifier).toggle,
                        //     icon: Icon(ref.watch(menuCollapsedProvider) ? Icons.menu : Icons.menu_open),
                        //   ),
                        // ),
                      ],
                    ),
              destinations: const [
                NavigationRailDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: Text('Nástěnka'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Hledání'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.playlist_play_rounded),
                  label: Text('Seznamy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
