import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:zpevnik/components/custom/back_button.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/navigation/scaffold.dart';
import 'package:zpevnik/components/playlist/playlist_button.dart';
import 'package:zpevnik/components/playlist/playlist_records_list_view.dart';
import 'package:zpevnik/components/playlist/selected_playlist.dart';
import 'package:zpevnik/components/split_view.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/bible_verse.dart';
import 'package:zpevnik/models/custom_text.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/playlists.dart';
import 'package:zpevnik/providers/tags.dart';
import 'package:zpevnik/routing/arguments.dart';
import 'package:zpevnik/screens/playlists.dart';
import 'package:zpevnik/utils/extensions.dart';

class PlaylistScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).isTablet && context.isPlaylist) return _PlaylistScreenTablet(playlist: playlist);

    return _PlaylistScaffold(playlist: playlist);
  }
}

class _PlaylistScreenTablet extends StatefulWidget {
  final Playlist playlist;

  const _PlaylistScreenTablet({required this.playlist});

  @override
  State<_PlaylistScreenTablet> createState() => _PlaylistScreenTabletState();
}

class _PlaylistScreenTabletState extends State<_PlaylistScreenTablet> {
  late final _selectedPlaylistNotifier = ValueNotifier(widget.playlist);

  @override
  Widget build(BuildContext context) {
    return SplitView(
      childFlex: 3,
      subChildFlex: 7,
      subChild: ValueListenableBuilder(
        valueListenable: _selectedPlaylistNotifier,
        builder: (_, playlist, __) => _PlaylistScaffold(playlist: playlist, hideNavigationRail: true),
      ),
      child: SelectedPlaylist(
        playlistNotifier: _selectedPlaylistNotifier,
        child: const PlaylistsScreen(),
      ),
    );
  }
}

class _PlaylistScaffold extends StatelessWidget {
  final Playlist playlist;
  final bool hideNavigationRail;

  const _PlaylistScaffold({required this.playlist, this.hideNavigationRail = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Widget floatingActionButton;

    if (playlist.isFavorites) {
      floatingActionButton = FloatingActionButton(
        heroTag: 'playlist',
        backgroundColor: theme.colorScheme.surface,
        child: const Icon(Icons.playlist_add),
        onPressed: () => _addSongLyric(context),
      );
    } else {
      floatingActionButton = SpeedDial(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kDefaultRadius)),
        backgroundColor: theme.colorScheme.surface,
        overlayColor: Colors.black,
        overlayOpacity: 0.1,
        spacing: kDefaultPadding / 2,
        icon: Icons.add,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            label: 'vlastní text',
            onTap: () => _addText(context),
            child: const Icon(Icons.edit_note),
          ),
          SpeedDialChild(
            label: 'biblický úryvek',
            onTap: () => _addBibleVerse(context),
            child: const Icon(Icons.book_outlined),
          ),
          SpeedDialChild(
            label: 'píseň',
            onTap: () => _addSongLyric(context),
            child: const Icon(Icons.music_note),
          ),
        ],
      );
    }

    return CustomScaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: context.isPlaylist ? const CustomBackButton() : null,
        titleSpacing: context.isPlaylist ? null : 2 * kDefaultPadding,
        title: Text(playlist.name),
        actions: [
          Highlightable(
            onTap: playlist.records.isEmpty ? null : () => _pushSearch(context),
            padding: EdgeInsets.symmetric(horizontal: (playlist.isFavorites ? 1.5 : 1) * kDefaultPadding),
            icon: const Icon(Icons.filter_alt),
          ),
          if (!playlist.isFavorites) PlaylistButton(playlist: playlist, isInAppBar: true),
        ],
      ),
      floatingActionButton: floatingActionButton,
      hideNavigationRail: hideNavigationRail,
      body: SafeArea(child: PlaylistRecordsListView(key: Key('${playlist.id}'), playlist: playlist)),
    );
  }

  void _pushSearch(BuildContext context) {
    context.providers.read(selectedTagsProvider.notifier).push(initialTag: playlist.tag);

    context.push('/search');
  }

  void _addText(BuildContext context) async {
    final customText = await context.push('/playlist/custom_text') as CustomText?;

    if (context.mounted && customText != null) {
      context.providers.read(playlistsProvider.notifier).addToPlaylist(playlist, customText: customText);
    }
  }

  void _addBibleVerse(BuildContext context) async {
    final bibleVerse = (await context.push('/playlist/bible_verse/select_verse')) as BibleVerse?;

    if (context.mounted && bibleVerse != null) {
      context.providers.read(playlistsProvider.notifier).addToPlaylist(playlist, bibleVerse: bibleVerse);
    }
  }

  void _addSongLyric(BuildContext context) async {
    final songLyric = (await context.push('/search', arguments: SearchScreenArguments.returnSongLyric())) as SongLyric?;

    if (context.mounted && songLyric != null) {
      context.providers.read(playlistsProvider.notifier).addToPlaylist(playlist, songLyric: songLyric);
    }
  }
}
