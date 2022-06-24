import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/models/tag.dart';
import 'package:zpevnik/providers/song_lyrics.dart';

class FilterTag extends StatelessWidget {
  final Tag tag;
  final bool isToggable;
  final bool isRemovable;

  const FilterTag({
    Key? key,
    required this.tag,
    this.isToggable = false,
    this.isRemovable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final padding = isRemovable
        ? const EdgeInsets.only(left: kDefaultPadding)
        : const EdgeInsets.symmetric(horizontal: kDefaultPadding, vertical: kDefaultPadding / 2);

    final songLyricsProvider = context.watch<AllSongLyricsProvider>();

    final child = Container(
      margin: const EdgeInsets.symmetric(horizontal: kDefaultPadding / 4),
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: isToggable ? Border.all(color: theme.hintColor, width: 0.5) : null,
        color: (isRemovable || songLyricsProvider.isSelected(tag)) ? theme.colorScheme.primary.withAlpha(0x20) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag.name),
          if (isRemovable) const SizedBox(width: kDefaultPadding / 2),
          if (isRemovable)
            Highlightable(
              onTap: () => songLyricsProvider.toggleSelectedTag(tag),
              child: Container(
                padding: const EdgeInsets.all(kDefaultPadding / 2).copyWith(left: kDefaultPadding / 4),
                color: theme.colorScheme.primary.withAlpha(0x30),
                child: const Icon(Icons.close, size: 14),
              ),
            ),
        ],
      ),
    );

    if (isToggable) {
      return Highlightable(onTap: () => songLyricsProvider.toggleSelectedTag(tag), child: child);
    }

    return child;
  }
}
