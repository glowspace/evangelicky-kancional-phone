import 'package:flutter/material.dart';
import 'package:zpevnik/theme.dart';
import 'package:zpevnik/utils/platform.dart';

class HighlightableButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final Color highlightColor;
  final EdgeInsets padding;
  final Function() onPressed;

  const HighlightableButton({
    Key key,
    this.icon,
    this.color,
    this.highlightColor,
    this.padding,
    this.onPressed,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HighlightableButtonState();
}

class _HighlightableButtonState extends State<HighlightableButton> {
  bool _isHighlighted;

  @override
  void initState() {
    super.initState();

    _isHighlighted = false;
  }

  Color get _color => widget.color == null ? AppThemeNew.of(context).iconColor : widget.color;

  Color get _iconColor =>
      _isHighlighted ? (widget.highlightColor == null ? _color.withAlpha(0x80) : widget.highlightColor) : _color;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onPanDown: (_) => setState(() => _isHighlighted = true),
        onPanCancel: () => setState(() => _isHighlighted = false),
        onPanEnd: (_) => setState(() => _isHighlighted = false),
        onTap: widget.onPressed,
        behavior: HitTestBehavior.translucent,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            padding: widget.padding,
            child: Icon(
              widget.icon,
              color: widget.onPressed == null ? AppThemeNew.of(context).disabledColor : _iconColor,
            ),
          ),
        ),
      );
}
