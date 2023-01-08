import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';

class Section extends StatelessWidget {
  final Widget? title;

  final Widget child;
  final Widget? action;

  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const Section({
    Key? key,
    this.title,
    required this.child,
    this.action,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final section = Container(
      padding: padding,
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(kDefaultRadius)),
      clipBehavior: Clip.antiAlias,
      child: Material(child: child), // needs another wrapping in material widget, so inkwell highlight is visible
    );

    if (title != null) {
      return Container(
        margin: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(child: title!),
              if (action != null) action!,
            ]),
            const SizedBox(height: kDefaultPadding / 2),
            section,
          ],
        ),
      );
    }

    return Container(margin: margin, child: section);
  }
}
