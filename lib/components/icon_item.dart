import 'package:flutter/material.dart';
import 'package:zpevnik/constants.dart';
import 'package:zpevnik/components/highlightable.dart';
import 'package:zpevnik/theme.dart';

class IconItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final IconData? trailingIcon;
  final Function()? onTap;

  const IconItem({
    Key? key,
    required this.title,
    this.icon,
    this.trailingIcon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final iconColor = appTheme.iconColor;

    return Highlightable(
      onTap: onTap,
      child: Row(children: [
        if (icon != null)
          Container(padding: const EdgeInsets.only(right: kDefaultPadding), child: Icon(icon, color: iconColor)),
        Expanded(child: Text(title, style: appTheme.bodyTextStyle)),
        if (trailingIcon != null)
          Container(padding: const EdgeInsets.only(left: kDefaultPadding), child: Icon(trailingIcon, color: iconColor)),
      ]),
    );
  }
}
