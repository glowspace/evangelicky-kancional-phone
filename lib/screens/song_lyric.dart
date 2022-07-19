import 'dart:math';

import 'package:flutter/material.dart' hide PopupMenuEntry, PopupMenuItem;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/components/custom/back_button.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/song_lyric/externals_player_wrapper.dart';
import 'package:zpevnik/components/song_lyric/lyrics.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_files.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_menu_button.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_settings.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_tags.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/components/song_lyric/utils/lyrics_controller.dart';
import 'package:zpevnik/providers/navigation.dart';
import 'package:zpevnik/providers/settings.dart';
import 'package:zpevnik/utils/extensions.dart';

const double _externalsTitleHeight = 2 * kDefaultPadding + 21;
const double _externalsNameHeight = 2 * kDefaultPadding + 18;
const double _miniPlayerHeight = 64;

class SongLyricScreen extends StatefulWidget {
  final List<SongLyric> songLyrics;
  final int initialIndex;

  const SongLyricScreen({
    Key? key,
    required this.songLyrics,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<SongLyricScreen> createState() => _SongLyricScreenState();
}

class _SongLyricScreenState extends State<SongLyricScreen> {
  late final PageController _pageController;
  late final ValueNotifier<bool> _showingExternals;

  late final List<LyricsController> _lyricsControllers;

  late int _currentIndex;

  bool _fullscreen = false;

  SongLyric get _songLyric => widget.songLyrics[_currentIndex % widget.songLyrics.length];
  LyricsController get _lyricsController => _lyricsControllers[_currentIndex % _lyricsControllers.length];

  @override
  void initState() {
    super.initState();

    // make sure it is possible to swipe to previous song lyric
    _currentIndex = widget.initialIndex + (widget.songLyrics.length == 1 ? 0 : 10 * widget.songLyrics.length);
    _lyricsControllers = widget.songLyrics.map((songLyric) => LyricsController(songLyric, context)).toList();

    _pageController = PageController(initialPage: _currentIndex);
    _showingExternals = ValueNotifier(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    final settingsProvider = context.read<SettingsProvider>();

    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;

    AppBar? appBar;
    Widget? bottomBar;

    final backgroundColor = theme.brightness.isLight ? theme.colorScheme.surface : theme.scaffoldBackgroundColor;
    final borderColor = theme.brightness.isLight ? const Color(0xffd0d0d0) : const Color(0xff2f2f2f);

    if (!_fullscreen) {
      appBar = AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
        title: Text('${_songLyric.id}', style: theme.textTheme.titleMedium),
        centerTitle: false,
        leading: const CustomBackButton(),
        actions: [
          if (_songLyric.hasTranslations)
            Highlightable(
              onTap: () =>
                  NavigationProvider.of(context).popToOrPushNamed('/song_lyrics/translations', arguments: _songLyric),
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: const Icon(Icons.translate),
            ),
          StatefulBuilder(
            builder: (context, setState) => Highlightable(
              onTap: () => setState(() => _toggleFavorite(context)),
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Icon(_songLyric.isFavorite ? Icons.star : Icons.star_outline),
            ),
          ),
          SongLyricMenuButton(songLyric: _songLyric),
        ],
      );

      const bottomBarActionPadding = EdgeInsets.symmetric(vertical: kDefaultPadding, horizontal: 3 * kDefaultPadding);

      bottomBar = Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: borderColor, width: 1))),
        child: BottomAppBar(
          color: backgroundColor,
          elevation: 0,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mediaQuery.isTablet ? MainAxisAlignment.end : MainAxisAlignment.spaceAround,
            children: [
              Highlightable(
                padding: bottomBarActionPadding,
                onTap: () => _showingExternals.value = true,
                isDisabled: !_songLyric.hasRecordings,
                child: const Icon(FontAwesomeIcons.headphones),
              ),
              Highlightable(
                padding: bottomBarActionPadding,
                onTap: () => _showFiles(context),
                isDisabled: !_songLyric.hasFiles,
                child: const Icon(Icons.insert_drive_file),
              ),
              Highlightable(
                padding: bottomBarActionPadding,
                onTap: () => _showSettings(context),
                isDisabled: !_songLyric.hasChords,
                child: const Icon(Icons.tune),
              ),
              Highlightable(
                padding: bottomBarActionPadding,
                onTap: () => _showTags(context),
                isDisabled: !(_songLyric.tags.isNotEmpty || _songLyric.songbookRecords.isNotEmpty),
                child: const FaIcon(FontAwesomeIcons.tag),
              ),
              Highlightable(
                padding: bottomBarActionPadding,
                onTap: () => NavigationProvider.of(context).popToOrPushNamed('/search'),
                child: const Icon(Icons.search),
              ),
            ],
          ),
        ),
      );
    }

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        Scaffold(
          appBar: appBar,
          backgroundColor: backgroundColor,
          body: SafeArea(
            child: GestureDetector(
              onScaleStart: settingsProvider.fontScaleStarted,
              onScaleUpdate: settingsProvider.fontScaleUpdated,
              onTap: () => setState(() => _fullscreen = !_fullscreen),
              behavior: HitTestBehavior.translucent,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.songLyrics.length == 1 ? 1 : null,
                onPageChanged: (value) => setState(() {
                  _showingExternals.value = false;
                  _currentIndex = value;
                }),
                itemBuilder: (_, index) => LyricsWidget(
                  controller: _lyricsControllers[index % _lyricsControllers.length],
                ),
              ),
            ),
          ),
          bottomNavigationBar: bottomBar,
        ),
        ExternalsPlayerWrapper(
          key: Key('${_songLyric.id}'),
          songLyric: _songLyric,
          // TODO: move this computations to ExternalsPlayerWrapper
          maxHeight: min(
            2 / 3 * height,
            _externalsTitleHeight +
                bottomPadding +
                _songLyric.youtubes.length * (width / 16 * 9 + _externalsNameHeight) +
                kDefaultPadding,
          ),
          minHeight: _miniPlayerHeight + bottomPadding,
          isShowing: _showingExternals,
        ),
      ],
    );
  }

  void _showFiles(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius))),
      builder: (context) => SongLyricFilesWidget(songLyric: _songLyric),
      useRootNavigator: true,
    );
  }

  void _showSettings(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius))),
      builder: (context) => SongLyricSettingsWidget(controller: _lyricsController),
      useRootNavigator: true,
    );
  }

  void _showTags(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius))),
      builder: (context) => SongLyricTags(songLyric: _songLyric),
      useRootNavigator: true,
    );
  }

  void _toggleFavorite(BuildContext context) {
    context.read<DataProvider>().toggleFavorite(_songLyric);
  }
}
