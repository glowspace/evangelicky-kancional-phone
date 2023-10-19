import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/playlist/dialogs.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/playlist.dart';
import 'package:zpevnik/models/song_lyric.dart';
import 'package:zpevnik/providers/playlists.dart';
import 'package:zpevnik/utils/extensions.dart';

class PlaylistsSheet extends StatelessWidget {
  final SongLyric selectedSongLyric;

  const PlaylistsSheet({super.key, required this.selectedSongLyric});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(kDefaultPadding, kDefaultPadding, kDefaultPadding, kDefaultPadding / 2),
          child: Text('Playlisty', style: Theme.of(context).textTheme.titleLarge),
        ),
        SingleChildScrollView(
          child: Consumer(
            builder: (context, ref, __) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Highlightable(
                  onTap: () => showPlaylistDialog(context, selectedSongLyric: selectedSongLyric),
                  padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
                  icon: const Icon(Icons.add),
                  child: const Text('Nový playlist'),
                ),
                const Divider(height: kDefaultPadding / 2),
                ...[
                  for (final playlist in ref.watch(playlistsProvider))
                    Highlightable(
                      onTap: () => _addToPlaylist(context, playlist),
                      padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2),
                      icon: const Icon(Icons.playlist_play_rounded),
                      child: Text(playlist.name),
                    ),
                ],
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _addToPlaylist(BuildContext context, Playlist playlist) {
    context.providers.read(playlistsProvider.notifier).addToPlaylist(playlist, songLyric: selectedSongLyric);

    context.popAndPush('/playlist', arguments: playlist);
  }
}
