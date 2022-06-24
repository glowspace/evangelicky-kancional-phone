import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/models/external.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/providers/song_lyrics.dart';
import 'package:zpevnik/screens/content.dart';
import 'package:zpevnik/screens/initial.dart';
import 'package:zpevnik/screens/pdf.dart';
import 'package:zpevnik/screens/playlist.dart';
import 'package:zpevnik/screens/search.dart';
import 'package:zpevnik/screens/song_lyric.dart';
import 'package:zpevnik/screens/song_lyric/translations.dart';

import 'models/song_lyric.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return CustomPageRoute(builder: (_) => const InitialScreen());
      case '/home':
        return CustomPageRoute(builder: (_) => const ContentScreen());
      case '/pdf':
        final pdf = settings.arguments as External;

        return CustomPageRoute(builder: (_) => PdfScreen(pdf: pdf));
      case '/playlist':
        final playlist = settings.arguments as Playlist;

        return CustomPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => PlaylistSongLyricsProvider(context.read<DataProvider>(), playlist),
            builder: (_, __) => const PlaylistScreen(),
          ),
        );
      case '/search':
        return CustomPageRoute(
          builder: (_) => ChangeNotifierProvider(
            create: (context) => AllSongLyricsProvider(context.read<DataProvider>()),
            builder: (_, __) => const SearchScreen(),
          ),
          fullscreenDialog: true,
        );
      case '/song_lyric':
        final songLyric = settings.arguments as SongLyric;

        return CustomPageRoute(builder: (_) => SongLyricScreen(songLyric: songLyric));
      case '/song_lyric/translations':
        final songLyric = settings.arguments as SongLyric;

        return CustomPageRoute(builder: (_) => TranslationsScreen(songLyric: songLyric));
      default:
        throw 'Unknown route: ${settings.name}';
    }
  }
}

class CustomPageRoute extends MaterialPageRoute {
  // @override
  // Duration get transitionDuration => const Duration(milliseconds: 5000);

  CustomPageRoute({required WidgetBuilder builder, bool fullscreenDialog = false})
      : super(builder: builder, fullscreenDialog: fullscreenDialog);
}
