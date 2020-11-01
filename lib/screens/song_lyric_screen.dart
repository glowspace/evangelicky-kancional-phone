import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/songLyric.dart';
import 'package:zpevnik/providers/scroll_provider.dart';
import 'package:zpevnik/providers/settings_provider.dart';
import 'package:zpevnik/screens/components/lyrics_widget.dart';
import 'package:zpevnik/screens/components/song_lyric_menu.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/platform.dart';

import 'components/sliding_widget.dart';
import 'components/song_lyric_settings.dart';

class SongLyricScreen extends StatefulWidget {
  final SongLyric songLyric;

  const SongLyricScreen({Key key, this.songLyric}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SongLyricScreen();
}

class _SongLyricScreen extends State<SongLyricScreen> with PlatformStateMixin {
  ScrollController _scrollController;
  ScrollProvider _scrollProvider;

  bool _fullScreen;
  ValueNotifier<bool> _showingMenu;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollProvider = ScrollProvider(_scrollController);

    _fullScreen = false;
    _showingMenu = ValueNotifier(false);

    widget.songLyric.addListener(_update);
  }

  @override
  void dispose() {
    widget.songLyric.removeListener(_update);
    super.dispose();
  }

  @override
  Widget iOSWidget(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(widget.songLyric.id.toString()),
        ),
        child: _body(context),
      );

  @override
  Widget androidWidget(BuildContext context) => Scaffold(
        appBar: _fullScreen
            ? null
            : AppBar(
                title: Text(widget.songLyric.id.toString()),
                shadowColor: AppTheme.shared.appBarDividerColor(context),
                actions: _actions(context),
              ),
        body: _body(context),
      );

  Widget _body(BuildContext context) => SafeArea(
        child: GestureDetector(
          onTap: () => setState(() {
            _showingMenu.value = false;
            _fullScreen = !_fullScreen;
          }),
          child: Stack(
            children: [
              NotificationListener(
                onNotification: (notif) {
                  if (notif is ScrollEndNotification) setState(() => _scrollProvider.scrollEnded());

                  return true;
                },
                child: Container(
                  height: double.infinity,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: kDefaultPadding, horizontal: kDefaultPadding / 2),
                      child: ChangeNotifierProvider.value(
                        value: SettingsProvider.shared,
                        child: LyricsWidget(songLyric: widget.songLyric),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: SongLyricMenu(
                  songLyric: widget.songLyric,
                  showing: _showingMenu,
                ),
              ),
              Positioned(
                right: 0,
                bottom: kDefaultPadding,
                child: ChangeNotifierProvider.value(
                  value: _scrollProvider,
                  child: SlidingWidget(
                    showSettings: _showSettings,
                    showExternals: _showExternals,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  List<Widget> _actions(BuildContext context) => [
        IconButton(
          onPressed: null,
          icon: Icon(Icons.translate),
        ),
        IconButton(
          onPressed: widget.songLyric.toggleFavorite,
          icon: Icon(widget.songLyric.isFavorite ? Icons.star : Icons.star_outline),
        ),
        IconButton(
          onPressed: () => _showingMenu.value = !_showingMenu.value,
          icon: Icon(Icons.more_vert),
        ),
      ];

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) => SizedBox(
        height: 0.67 * MediaQuery.of(context).size.height,
        child: ChangeNotifierProvider.value(
          value: widget.songLyric,
          child: ChangeNotifierProvider.value(value: SettingsProvider.shared, child: SongLyricSettings()),
        ),
      ),
    );
  }

  void _showExternals() => showCupertinoModalBottomSheet(
        context: context,
        builder: (context, scrollController) => SizedBox(
          height: 0.67 * MediaQuery.of(context).size.height,
          child: Container(),
        ),
        useRootNavigator: true,
      );

  void _update() => setState(() => {});
}
