import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/platform/components/scaffold.dart';
import 'package:zpevnik/platform/utils/bottom_sheet.dart';
import 'package:zpevnik/platform/utils/route_builder.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/providers/fullscreen.dart';
import 'package:zpevnik/providers/scroll.dart';
import 'package:zpevnik/providers/settings.dart';
import 'package:zpevnik/providers/song_lyrics.dart';
import 'package:zpevnik/screens/components/highlightable.dart';
import 'package:zpevnik/screens/song_lyric/components/bottom_menu.dart';
import 'package:zpevnik/screens/song_lyric/components/externals.dart';
import 'package:zpevnik/screens/song_lyric/components/song_lyric_menu.dart';
import 'package:zpevnik/screens/song_lyric/components/song_lyric_settings.dart';
import 'package:zpevnik/screens/song_lyric/lyrics.dart';
import 'package:zpevnik/screens/song_lyric/translations.dart';
import 'package:zpevnik/screens/song_lyric/utils/lyrics_controller.dart';
import 'package:zpevnik/screens/utils/updateable.dart';

enum SwipeDirection { left, right }

class SongLyricScreen extends StatefulWidget {
  final SongLyric songLyric;
  final bool fromTranslations;

  const SongLyricScreen({Key? key, required this.songLyric, this.fromTranslations = false}) : super(key: key);

  @override
  _SongLyricScreenState createState() => _SongLyricScreenState();
}

class _SongLyricScreenState extends State<SongLyricScreen> with Updateable {
  // needed so that lyrics widget does not rebuild after toggling full screen mode
  final lyricsGlobalKey = GlobalKey();

  late LyricsController _lyricsController;
  late ScrollProvider _scrollProvider;

  late ValueNotifier<bool> _menuCollapsed;

  // scaling and swiping cannot be captured simultaneosly by `GestureDetector`
  // custom functions are implemented to handle it
  Offset? _swipeStartLocation;
  DateTime? _swipeStartTime;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    _lyricsController = LyricsController(widget.songLyric, context.read<SettingsProvider>());
    _scrollProvider = ScrollProvider(ScrollController());

    _menuCollapsed = ValueNotifier(true);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final fullScreenProvider = context.watch<FullScreenProvider>();

    return WillPopScope(
      onWillPop: fullScreenProvider.isFullScreen ? () async => !Navigator.of(context).userGestureInProgress : null,
      child: PlatformScaffold(
        title: _lyricsController.songLyric.id.toString(),
        trailing: _actions(context),
        body: GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onTap: _onTap,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LyricsWidget(
                key: lyricsGlobalKey,
                controller: _lyricsController,
                scrollController: _scrollProvider.controller,
              ),
              Positioned(
                right: 0,
                child: SongLyricMenu(lyricsController: _lyricsController, collapsed: _menuCollapsed),
              ),
              if (settingsProvider.showBottomOptions && !_lyricsController.isProjectionEnabled)
                Positioned(
                  right: 0,
                  bottom: kDefaultPadding,
                  child: BottomMenu(
                    showSettings: _showSettings,
                    showExternals: _showExternals,
                    scrollProvider: _scrollProvider,
                    hasExternals: _lyricsController.songLyric.hasExternals,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final padding = EdgeInsets.symmetric(horizontal: kDefaultPadding / 2);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasTranslations)
          Highlightable(
            child: Icon(Icons.translate),
            onPressed: _pushTranslations,
            padding: padding,
          ),
        Highlightable(
          child: Icon(_lyricsController.songLyric.isFavorite ? Icons.star : Icons.star_border),
          onPressed: () => setState(() => _lyricsController.songLyric.toggleFavorite()),
          padding: padding,
        ),
        Highlightable(
          child: Icon(Icons.more_vert),
          onPressed: () => _menuCollapsed.value = !_menuCollapsed.value,
          padding: padding,
        ),
      ],
    );
  }

  void _showSettings() {
    showPlatformBottomSheet(
      context: context,
      builder: (_) => SongLyricSettingsWidget(songLyricController: _lyricsController),
      height: 0.5 * MediaQuery.of(context).size.height,
    );
  }

  void _showExternals() {
    showPlatformBottomSheet(
      context: context,
      builder: (_) => ExternalsWidget(externals: _lyricsController.songLyric.youtubes),
      height: 0.67 * MediaQuery.of(context).size.height,
    );
  }

  void _pushTranslations() {
    if (widget.fromTranslations)
      Navigator.of(context).pop();
    else
      Navigator.of(context)
          .push(platformRouteBuilder(
            context,
            TranslationsScreen(songLyric: _lyricsController.songLyric),
            types: [ProviderType.data, ProviderType.fullScreen, ProviderType.playlist, ProviderType.songLyric],
          ))
          .then((value) => context.read<SongLyricsProvider>().currentSongLyric = widget.songLyric);
  }

  void _onScaleStart(ScaleStartDetails details) {
    // if there is only one pointer at the start it might be swipe
    if (details.pointerCount == 1) {
      _swipeStartLocation = details.focalPoint;
      _swipeStartTime = DateTime.now();
    }

    context.read<SettingsProvider>().fontScaleStarted();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    // if another pointer is added during swipe change it to scale
    if (details.pointerCount > 1) {
      _swipeStartLocation = null;
      _swipeStartTime = null;
      _swipeDirection = null;
    } else if (_swipeStartLocation != null) {
      if (_swipeStartLocation!.dx < details.focalPoint.dx)
        _swipeDirection = SwipeDirection.right;
      else
        _swipeDirection = SwipeDirection.left;
    }

    context.read<SettingsProvider>().fontScaleUpdated(details);
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // when person lifts up fingers the `GestureDetector` will detect is as new scale event and custom logic will detect is as swipe
    // normal swipe will take at least 10μs, so if it is lower just ignore it
    if (_swipeStartTime != null && DateTime.now().difference(_swipeStartTime!).inMicroseconds > 10000) {
      if (_swipeDirection == SwipeDirection.right) {
        if (_lyricsController.isProjectionEnabled)
          _lyricsController.previousVerse();
        else {
          final newSongLyric = context.read<SongLyricsProvider>().previousSongLyric;
          if (newSongLyric != null)
            setState(() => _lyricsController = LyricsController(newSongLyric, context.read<SettingsProvider>()));
        }
      } else if (_swipeDirection == SwipeDirection.left) {
        if (_lyricsController.isProjectionEnabled)
          _lyricsController.nextVerse();
        else {
          final newSongLyric = context.read<SongLyricsProvider>().nextSongLyric;
          if (newSongLyric != null)
            setState(() => _lyricsController = LyricsController(newSongLyric, context.read<SettingsProvider>()));
        }
      }
    }

    _swipeStartLocation = null;
    _swipeStartTime = null;
    _swipeDirection = null;
  }

  void _onTap() {
    _menuCollapsed.value = true;

    if (_lyricsController.isProjectionEnabled)
      _lyricsController.nextVerse();
    else
      context.read<FullScreenProvider>().toggleFullScreen();
  }

  bool get _hasTranslations {
    return (context.read<DataProvider>().songsSongLyrics(widget.songLyric.songId ?? -1)?.length ?? 0) > 1;
  }

  @override
  List<Listenable> get listenables => [_lyricsController];
}
