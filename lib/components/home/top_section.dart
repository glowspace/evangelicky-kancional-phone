import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/components/logo.dart';
import 'package:zpevnik/constants.dart';

const double _avatarRadius = 19;

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2 / 3 * kDefaultPadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Logo(showFullName: false),
          const Spacer(),
          HighlightableIconButton(
            onTap: () => context.push('/user'),
            padding: const EdgeInsets.all(kDefaultPadding / 2),
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              radius: _avatarRadius,
              child: const Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }
}
