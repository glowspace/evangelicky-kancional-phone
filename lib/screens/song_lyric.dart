import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/components/custom/back_button.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/song_lyric/externals_player_wrapper.dart';
import 'package:zpevnik/components/song_lyric/lyrics.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_files.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_settings.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/screens/song_lyric/utils/lyrics_controller.dart';

const double _navigationBarHeight = 48;

const double _miniPlayerHeight = 64;

class SongLyricScreen extends StatefulWidget {
  final SongLyric songLyric;
  const SongLyricScreen({Key? key, required this.songLyric}) : super(key: key);

  @override
  State<SongLyricScreen> createState() => _SongLyricScreenState();
}

class _SongLyricScreenState extends State<SongLyricScreen> {
  late final LyricsController _lyricsController;

  late final ValueNotifier<bool> _showingExternals;

  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();

    _lyricsController = LyricsController(widget.songLyric, context);

    _showingExternals = ValueNotifier(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final height = MediaQuery.of(context).size.height;

    AppBar? appBar;
    NavigationBar? navigationBar;

    if (!_fullscreen) {
      appBar = AppBar(
        title: Text('${widget.songLyric.id}', style: theme.textTheme.titleMedium),
        centerTitle: false,
        leading: const CustomBackButton(),
        actions: [
          if (widget.songLyric.hasTranslations)
            Highlightable(
              onTap: () => _pushTranslations(context),
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: const Icon(Icons.translate),
            ),
          StatefulBuilder(
            builder: (context, setState) => Highlightable(
              onTap: () => setState(() => _toggleFavorite(context)),
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Icon(widget.songLyric.isFavorite ? Icons.star : Icons.star_outline),
            ),
          ),
          Highlightable(
            onTap: _showMenu,
            padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
            child: const Icon(Icons.more_vert),
          ),
        ],
      );

      navigationBar = NavigationBar(
        height: _navigationBarHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        onDestinationSelected: (destination) => _destinationSelected(context, destination),
        destinations: [
          _buildDestination(context, FontAwesomeIcons.headphones),
          _buildDestination(context, Icons.insert_drive_file),
          _buildDestination(context, Icons.tune),
          _buildDestination(context, Icons.search),
        ],
      );
    }

    return Theme(
      data: theme.copyWith(
        navigationBarTheme: theme.navigationBarTheme.copyWith(indicatorColor: Colors.transparent),
      ),
      child: Stack(
        children: [
          Scaffold(
            appBar: appBar,
            body: SafeArea(child: _buildLyrics(context)),
            bottomNavigationBar: navigationBar,
          ),
          ExternalsPlayerWrapper(
            songLyric: widget.songLyric,
            maxHeight: 2 / 3 * height,
            minHeight: _miniPlayerHeight,
            isShowing: _showingExternals,
          ),
        ],
      ),
    );
  }

  Widget _buildLyrics(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _fullscreen = !_fullscreen),
      child: LyricsWidget(controller: _lyricsController),
    );
  }

  Widget _buildDestination(BuildContext context, IconData icon) {
    return Highlightable(
      child: NavigationDestination(
        label: '',
        icon: Icon(icon),
      ),
    );
  }

  void _destinationSelected(BuildContext context, int destination) {
    switch (destination) {
      case 0:
        _showingExternals.value = true;
        break;
      case 1:
        _showFiles(context);
        break;
      case 2:
        _showSettings(context);
        break;
      case 3:
        // TODO: check if it is from search screen
        Navigator.of(context).pop();
        break;
    }
  }

  void _showFiles(BuildContext context) {
    showMaterialModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultRadius))),
      builder: (context) => SongLyricFilesWidget(songLyric: widget.songLyric),
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

  void _pushTranslations(BuildContext context) {
    Navigator.of(context).pushNamed('/song_lyric/translations', arguments: widget.songLyric);
  }

  void _toggleFavorite(BuildContext context) {
    context.read<DataProvider>().toggleFavorite(widget.songLyric);
  }

  void _showMenu() {}
}
