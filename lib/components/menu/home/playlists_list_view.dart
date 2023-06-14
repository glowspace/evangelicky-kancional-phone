import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/playlist/dialogs.dart';
import 'package:zpevnik/components/playlist/playlist_row.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/providers/playlists.dart';

class PlaylistsListView extends ConsumerWidget {
  const PlaylistsListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataProvider = context.watch<DataProvider>();

    final playlists = ref.watch(playlistsProvider);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: kDefaultPadding / 2, bottom: 2 * kDefaultPadding),
        child: Column(children: [
          PlaylistRow(playlist: ref.read(favoritePlaylistProvider), visualDensity: VisualDensity.comfortable),
          Theme(
            data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              buildDefaultDragHandles: false,
              itemCount: playlists.length,
              itemBuilder: (_, index) => PlaylistRow(
                key: Key('${playlists[index].id}'),
                playlist: playlists[index],
                isReorderable: true,
                showDragIndicator: false,
                visualDensity: VisualDensity.comfortable,
              ),
              onReorder: dataProvider.reorderedPlaylists,
            ),
          ),
          HighlightableTextButton(
            onTap: () => showPlaylistDialog(context),
            padding: const EdgeInsets.all(kDefaultPadding),
            icon: const Icon(Icons.add, size: 20),
            child: const Text('Vytvořit nový seznam'),
          ),
        ]),
      ),
    );
  }
}
