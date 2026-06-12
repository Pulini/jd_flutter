import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';

enum Combination { left, middle, right, intact }

//自定义按钮
class CombinationButton extends StatefulWidget {
  final Combination combination;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool isEnabled;
  final bool hasPadding;
  final String text;
  final Widget? icon;
  final Function() click;
  final int debounceDuration;

  const CombinationButton(
      {super.key,
      required this.text,
      required this.click,
      this.icon,
      this.combination = Combination.intact,
      this.backgroundColor = Colors.blue,
      this.foregroundColor = Colors.white,
      this.isEnabled = true,
      this.hasPadding = true,
      this.debounceDuration = 500});

  @override
  State<CombinationButton> createState() => _CombinationButtonState();
}

class _CombinationButtonState extends State<CombinationButton> {
  DateTime _lastClickTime = DateTime(2000);

  EdgeInsets getPadding() {
    EdgeInsets padding;
    switch (widget.combination) {
      case Combination.left:
        padding = const EdgeInsets.only(left: 4, top: 4, right: 1, bottom: 4);
        break;
      case Combination.middle:
        padding = const EdgeInsets.only(left: 1, top: 4, right: 1, bottom: 4);
        break;
      case Combination.right:
        padding = const EdgeInsets.only(left: 1, top: 4, right: 4, bottom: 4);
        break;
      default:
        padding = const EdgeInsets.all(4);
        break;
    }
    return padding;
  }

  BorderRadius getRadius() {
    BorderRadius borderRadius;
    switch (widget.combination) {
      case Combination.left:
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        );
        break;
      case Combination.middle:
        borderRadius = const BorderRadius.all(Radius.zero);
        break;
      case Combination.right:
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        );
        break;
      default:
        borderRadius = const BorderRadius.all(Radius.circular(20));
        break;
    }
    return borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: widget.isEnabled == true
          ? widget.foregroundColor
          : Colors.grey[800],
    );
    return Container(
      height: 40,
      padding: widget.hasPadding ? getPadding() : const EdgeInsets.all(0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          overlayColor: Colors.white,
          padding: const EdgeInsets.only(left: 8, right: 8),
          backgroundColor:
              widget.isEnabled == true ? widget.backgroundColor : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: getRadius(),
          ),
        ),
        onPressed: () {
          if (widget.isEnabled == true) {
            var now = DateTime.now();
            if (now.difference(_lastClickTime).inMilliseconds <
                widget.debounceDuration) {
              return;
            }
            _lastClickTime = now;
            widget.click.call();
          }
        },
        child: widget.icon != null
            ? Text.rich(
                TextSpan(
                  style: textStyle,
                  children: [
                    WidgetSpan(
                      child: widget.icon!,
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(text: widget.text),
                  ],
                ),
              )
            : AutoSizeText(
                widget.text,
                style: textStyle,
                maxLines: 1,
                minFontSize: 8,
                maxFontSize: 18,
              ),
      ),
    );
  }
}
