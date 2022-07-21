import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/songbook.dart';
import 'package:zpevnik/providers/data.dart';
import 'package:zpevnik/providers/navigation.dart';
import 'package:zpevnik/components/highlightable.dart';

const _logosPath = '$imagesPath/songbooks';
const _existingLogos = [
  '1ch',
  '2ch',
  '3ch',
  '4ch',
  '5ch',
  '6ch',
  '7ch',
  '8ch',
  '9ch',
  'c',
  'csach',
  'csatr',
  'csmom',
  'csmta',
  'csmzd',
  'dbl',
  'k',
  'kan',
  'sdmkr',
  'h1',
  'h2'
];

class SongbookTile extends StatelessWidget {
  final Songbook songbook;

  const SongbookTile({Key? key, required this.songbook}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shortcut = songbook.shortcut.toLowerCase();
    final imagePath = _existingLogos.contains(shortcut) ? '$_logosPath/$shortcut.png' : '$_logosPath/default.png';

    final pinHighlightablKey = GlobalKey();

    return Highlightable(
      onTap: () => _pushSongbook(context),
      padding: const EdgeInsets.all(kDefaultPadding),
      highlightBackground: true,
      highlightableChildKeys: [pinHighlightablKey],
      child: IntrinsicWidth(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: FittedBox(child: Image.asset(imagePath)),
              ),
            ),
            const SizedBox(height: kDefaultPadding / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(songbook.name, maxLines: 2)),
                Highlightable(
                  key: pinHighlightablKey,
                  child: Icon(songbook.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
                  onTap: () => context.read<DataProvider>().togglePin(songbook),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pushSongbook(BuildContext context) {
    FocusScope.of(context).unfocus();

    NavigationProvider.of(context).pushNamed('/songbook', arguments: songbook);
  }
}