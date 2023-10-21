import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';

class BottomSheetSection extends StatelessWidget {
  final String title;
  final bool childrenPadding;
  final List<Widget> children;

  const BottomSheetSection({super.key, required this.title, this.childrenPadding = true, this.children = const []});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          childrenPadding ? 1.5 * kDefaultPadding : 0,
          kDefaultPadding,
          childrenPadding ? 1.5 * kDefaultPadding : 0,
          MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: childrenPadding ? 0 : 1.5 * kDefaultPadding),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
