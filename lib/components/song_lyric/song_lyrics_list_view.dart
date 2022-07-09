import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/components/song_lyric/song_lyric_row.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/song_lyrics.dart';
import 'package:zpevnik/routes/arguments/song_lyric.dart';

const _noSongLyricsText =
    'V tomto seznamu nemáte žádné písně. Klikněte na${unbreakableSpace}tlačítko níže pro přidání nové písně.';

typedef ListItemBuilder = Widget Function(BuildContext);

class SongLyricsListView<T extends SongLyricsProvider> extends StatelessWidget {
  const SongLyricsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final songLyricsProvider = context.watch<T>();

    Key? listViewKey;
    final List<ListItemBuilder> listItems = [];

    if (songLyricsProvider is AllSongLyricsProvider) {
      listViewKey = Key('${songLyricsProvider.searchText}_${songLyricsProvider.selectedTags.length}');

      if (songLyricsProvider.recentSongLyrics.isNotEmpty) {
        listItems.add((_) => const SizedBox(height: kDefaultPadding / 2));
        listItems.add((context) => _buildHeader(context, "POSLEDNÍ PÍSNĚ"));

        listItems.addAll(_songLyricRowBuilders(songLyricsProvider.recentSongLyrics));

        listItems.add((_) => const SizedBox(height: 2 * kDefaultPadding));
      }

      if (songLyricsProvider.matchedById != null) {
        listItems.add((_) => SongLyricRow(songLyric: songLyricsProvider.matchedById!));
        listItems.add((_) => const SizedBox(height: 2 * kDefaultPadding));
      }

      if (songLyricsProvider.songLyricsMatchedBySongbookNumber.isNotEmpty) {
        if (listItems.isEmpty) listItems.add((_) => const SizedBox(height: kDefaultPadding / 2));
        listItems.add((context) => _buildHeader(context, "ČÍSLO ${songLyricsProvider.searchText} VE ZPĚVNÍCÍCH"));

        listItems.addAll(_songLyricRowBuilders(songLyricsProvider.songLyricsMatchedBySongbookNumber));

        listItems.add((_) => const SizedBox(height: 2 * kDefaultPadding));
      }

      if (listItems.isNotEmpty && songLyricsProvider.songLyrics.isNotEmpty) {
        if (listItems.isEmpty) listItems.add((_) => const SizedBox(height: kDefaultPadding / 2));
        if (songLyricsProvider.searchText.isEmpty) {
          listItems.add((context) => _buildHeader(context, "VŠECHNY PÍSNĚ"));
        } else {
          listItems.add((context) => _buildHeader(context, "OSTATNÍ VÝSLEDKY"));
        }
      }
    }

    if (songLyricsProvider is PlaylistSongLyricsProvider) {
      listViewKey = Key(songLyricsProvider.searchText);
    }

    listItems.addAll(_songLyricRowBuilders(songLyricsProvider.songLyrics,
        isReorderable: songLyricsProvider is PlaylistSongLyricsProvider));

    if (listItems.isEmpty) {
      String text = '';

      if (songLyricsProvider is AllSongLyricsProvider) {
        if (songLyricsProvider.selectedTags.isEmpty) {
          text = 'Nebyly nalezeny žádné písně pro hledaný výraz: "${songLyricsProvider.searchText}".';
        } else {
          text = 'Nebyly nalezeny žádné písně pro zvolenou kombinaci filtrů.';
        }
      } else if (songLyricsProvider is PlaylistSongLyricsProvider) {
        if (songLyricsProvider.searchText.isEmpty) {
          text = _noSongLyricsText;
        } else {
          text = 'Nebyly nalezeny žádné písně pro hledaný výraz: "${songLyricsProvider.searchText}".';
        }
      }

      return Container(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Center(child: Text(text, textAlign: TextAlign.center)),
      );
    }

    if (songLyricsProvider is PlaylistSongLyricsProvider) {
      return Theme(
        data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
        child: ReorderableListView.builder(
          key: listViewKey,
          primary: false,
          padding: const EdgeInsets.only(top: kDefaultPadding / 2, bottom: 2 * kDefaultPadding),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: listItems.length,
          itemBuilder: (context, index) => listItems[index](context),
          onReorder: (newIndex, oldIndex) => songLyricsProvider.onReorder(context, newIndex, oldIndex),
        ),
      );
    }

    return ListView.builder(
      key: listViewKey,
      primary: false,
      padding: const EdgeInsets.only(top: kDefaultPadding / 2, bottom: 2 * kDefaultPadding),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: listItems.length,
      itemBuilder: (context, index) => listItems[index](context),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
      child: Text(title, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
    );
  }

  List<ListItemBuilder> _songLyricRowBuilders(List<SongLyric> songLyrics, {bool isReorderable = false}) {
    final List<ListItemBuilder> listItems = [];

    for (var i = 0; i < songLyrics.length; i++) {
      listItems.add(
        (_) => SongLyricRow(
          key: Key('${songLyrics[i].id}'),
          songLyric: songLyrics[i],
          isReorderable: isReorderable,
          songLyricScreenArguments: SongLyricScreenArguments(songLyrics, i),
        ),
      );
    }

    return listItems;
  }
}
