import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/songbook.dart';
import 'package:zpevnik/providers/navigation.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/providers/songbooks.dart';

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
  'csmhk',
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

    return InkWell(
      onTap: () => _pushSongbook(context),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
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
                  Consumer(
                    builder: (_, ref, __) => HighlightableIconButton(
                      onTap: () => ref.read(pinnedSongbookIdsProvider.notifier).togglePin(songbook),
                      icon: Icon(ref.watch(pinnedSongbookIdsProvider).contains(songbook.id)
                          ? Icons.push_pin
                          : Icons.push_pin_outlined),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pushSongbook(BuildContext context) {
    FocusScope.of(context).unfocus();

    context.push('/songbook', extra: songbook);
  }
}
