import 'package:flutter/material.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/routing/router.dart';

class CustomCloseButton extends StatelessWidget {
  const CustomCloseButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Highlightable(
      padding: const EdgeInsets.all(kDefaultPadding).copyWith(left: 2 * kDefaultPadding),
      onTap: context.maybePop,
      icon: const Icon(Icons.close),
    );
  }
}
