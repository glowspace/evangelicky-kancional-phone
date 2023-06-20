import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wakelock/wakelock.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/models/songbook.dart';
import 'package:zpevnik/routes/arguments/song_lyric.dart';
import 'package:zpevnik/screens/about.dart';
import 'package:zpevnik/screens/home.dart';
import 'package:zpevnik/screens/initial.dart';
import 'package:zpevnik/screens/playlist.dart';
import 'package:zpevnik/screens/playlists.dart';
import 'package:zpevnik/screens/search.dart';
import 'package:zpevnik/screens/song_lyric.dart';
import 'package:zpevnik/screens/songbook.dart';
import 'package:zpevnik/screens/songbooks.dart';
import 'package:zpevnik/screens/updated_song_lyrics.dart';
import 'package:zpevnik/screens/user.dart';

part 'router.g.dart';

extension AppNavigatorHelper on BuildContext {
  void popUntil(String routeName) {
    while (GoRouter.of(this).location != routeName) {
      pop();
    }
  }
}

@Riverpod(keepAlive: true)
AppNavigator appNavigator(AppNavigatorRef ref) => AppNavigator();

class AppNavigator extends NavigatorObserver {
  late final appRouter = GoRouter(
    initialLocation: '/initial',
    observers: [this],
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/about', builder: (_, __) => const AboutScreen()),
      GoRoute(path: '/initial', builder: (_, __) => const InitialScreen()),
      GoRoute(path: '/playlist', builder: (_, state) => PlaylistScreen(playlist: state.extra as Playlist)),
      GoRoute(path: '/playlists', builder: (_, __) => const PlaylistsScreen()),
      GoRoute(
        path: '/search',
        pageBuilder: (_, __) => const MaterialPage(name: '/search', fullscreenDialog: true, child: SearchScreen()),
      ),
      GoRoute(path: '/songbook', builder: (_, state) => SongbookScreen(songbook: state.extra as Songbook)),
      GoRoute(path: '/songbooks', builder: (_, __) => const SongbooksScreen()),
      GoRoute(
        path: '/song_lyric',
        builder: (_, state) {
          final arguments = state.extra as SongLyricScreenArguments;

          return SongLyricScreen(songLyrics: arguments.songLyrics, initialIndex: arguments.index);
        },
      ),
      GoRoute(path: '/user', builder: (_, __) => const UserScreen()),
      GoRoute(
        path: '/updated_song_lyrics',
        builder: (_, state) => UpdatedSongLyricsScreen(songLyrics: state.extra as List<SongLyric>),
      ),
    ],
  );

  bool _isSearchRouteInStack = false;

  bool get isSearchRouteInStack => _isSearchRouteInStack;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    log('[APP_NAVIGATOR] pushed: $route from: $previousRoute');

    final name = route.settings.name;

    if (name == '/search') _isSearchRouteInStack = true;

    _handleWakeLock(name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    final name = route.settings.name;

    if (name == '/search') _isSearchRouteInStack = false;

    _handleWakeLock(previousRoute?.settings.name);

    log('[APP_NAVIGATOR] popped: $route to: $previousRoute');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    log('[APP_NAVIGATOR] replaced: $oldRoute to: $newRoute');
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    super.didRemove(route, previousRoute);

    log('[APP_NAVIGATOR] removed: $route to: $previousRoute');
  }

  // enable wakelock for `SongLyricScreen` disable for other screens
  void _handleWakeLock(String? routeName) {
    if (routeName == '/song_lyric') {
      Wakelock.enable();
    } else {
      Wakelock.disable();
    }
  }
}
