import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zpevnik/components/playlist/playlist_row.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/providers/playlists.dart';

class PlaylistsListView extends ConsumerWidget {
  const PlaylistsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlists = ref.watch(playlistsProvider);

    return SingleChildScrollView(
      child: Column(children: [
        const SizedBox(height: kDefaultPadding / 2),
        PlaylistRow(playlist: ref.read(favoritePlaylistProvider)),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 2 * kDefaultPadding),
          itemCount: playlists.length,
          itemBuilder: (_, index) {
            final playlist = playlists[index];

            return PlaylistRow(key: Key('${playlist.id}'), playlist: playlist, isReorderable: true);
          },
          onReorder: ref.read(playlistsProvider.notifier).reorderPlaylists,
        ),
      ]),
    );
  }
}
