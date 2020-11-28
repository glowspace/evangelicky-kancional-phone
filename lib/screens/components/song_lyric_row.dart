import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/songLyric.dart';
import 'package:zpevnik/providers/song_lyrics_provider.dart';
import 'package:zpevnik/screens/components/circular_checkbox.dart';
import 'package:zpevnik/screens/components/highlightable_row.dart';
import 'package:zpevnik/screens/song_lyric/components/song_lyric_container.dart';
import 'package:zpevnik/screens/song_lyric/song_lyric_screen.dart';
import 'package:zpevnik/screens/songbooks/componenets/songbook_provider.dart';
import 'package:zpevnik/theme.dart';

class SongLyricRowNew extends StatefulWidget {
  final SongLyric songLyric;
  final bool showStar;

  const SongLyricRowNew({Key key, @required this.songLyric, this.showStar = true}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SongLyricRowStateNew();
}

class _SongLyricRowStateNew extends State<SongLyricRowNew> {
  @override
  Widget build(BuildContext context) {
    return HighlightableRow(
      onPressed: () => _pushSongLyric(context),
      padding: EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding),
      highlightColor: AppThemeNew.of(context).highlightColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(widget.songLyric.name, style: AppThemeNew.of(context).bodyTextStyle)),
          if (widget.showStar && widget.songLyric.isFavorite)
            Transform.scale(scale: 0.75, child: Icon(Icons.star, color: AppThemeNew.of(context).iconColor)),
          _songLyricNumber(context, widget.songLyric.id.toString()),
        ],
      ),
    );
  }

  Widget _songLyricNumber(BuildContext context, String number) => SizedBox(
        width: 32,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(number, style: AppThemeNew.of(context).captionTextStyle),
        ),
      );

  void _pushSongLyric(BuildContext context) {
    FocusScope.of(context).unfocus();

    // if selecte songLyric is already in context pop back to it (used for translation screen)
    if (widget.songLyric == SongLyricContainer.of(context)?.songLyric)
      Navigator.of(context).pop();
    else
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SongLyricScreen(songLyric: widget.songLyric)));
  }
}

class SongLyricRow extends StatefulWidget {
  final SongLyric songLyric;
  final bool showStar;

  const SongLyricRow({Key key, @required this.songLyric, this.showStar = true}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SongLyricRowState();
}

class _SongLyricRowState extends State<SongLyricRow> {
  bool _highlighted;

  @override
  void initState() {
    super.initState();

    _highlighted = false;

    widget.songLyric.addListener(_update);
  }

  @override
  Widget build(BuildContext context) {
    final selectionProvider = Provider.of<SongLyricsProvider>(context, listen: false).selectionProvider;
    final songbookProvider = SongbookProvider.of(context);

    return GestureDetector(
      onLongPress: selectionProvider == null ? null : () => selectionProvider?.toggleSongLyric(widget.songLyric),
      onTap: () => (selectionProvider?.selectionEnabled ?? false)
          ? selectionProvider?.toggleSongLyric(widget.songLyric)
          : _pushSongLyric(context),
      onPanDown: (_) => setState(() => _highlighted = true),
      onPanCancel: () => setState(() => _highlighted = false),
      onPanEnd: (_) => setState(() => _highlighted = false),
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: (selectionProvider?.isSelected(widget.songLyric) ?? false)
            ? AppTheme.shared.selectedRowBackgroundColor(context)
            : (_highlighted ? AppTheme.shared.highlightColor(context) : null),
        padding: EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding),
        child: Row(
          children: [
            if (selectionProvider?.selectionEnabled ?? false)
              Container(
                padding: EdgeInsets.only(right: kDefaultPadding),
                child: CircularCheckbox(selected: selectionProvider?.isSelected(widget.songLyric) ?? false),
              )
            else if (songbookProvider != null)
              Container(
                padding: EdgeInsets.only(right: kDefaultPadding),
                child: _songLyricNumber(context, widget.songLyric.number(songbookProvider.songbook)),
              ),
            Expanded(child: Text(widget.songLyric.name, style: AppThemeNew.of(context).bodyTextStyle)),
            if (widget.showStar && widget.songLyric.isFavorite)
              Container(
                padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
                child: Transform.scale(
                  scale: 0.75,
                  child: Icon(
                    Icons.star,
                    color: (selectionProvider?.isSelected(widget.songLyric) ?? false)
                        ? AppTheme.shared.selectedRowColor(context)
                        : AppThemeNew.of(context).iconColor,
                  ),
                ),
              ),
            _songLyricNumber(context, widget.songLyric.id.toString()),
          ],
        ),
      ),
    );
  }

  Widget _songLyricNumber(BuildContext context, String number) => SizedBox(
        width: 32,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: Text(number, style: AppThemeNew.of(context).captionTextStyle),
        ),
      );

  void _pushSongLyric(BuildContext context) {
    FocusScope.of(context).unfocus();

    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SongLyricScreen(songLyric: widget.songLyric)));
  }

  void _update() => setState(() => {});

  @override
  void dispose() {
    widget.songLyric.removeListener(_update);

    super.dispose();
  }
}
