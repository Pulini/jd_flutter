import 'package:flutter/material.dart';

enum Combination { left, middle, right, intact }

///自定义按钮
class CombinationButton extends StatelessWidget {
  final Combination? combination;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool? isEnabled;
  final String text;
  final Widget? icon;
  final Function() click;

  const CombinationButton({
    super.key,
    required this.text,
    required this.click,
    this.icon,
    this.combination = Combination.intact,
    this.backgroundColor = Colors.blueAccent,
    this.foregroundColor = Colors.white,
    this.isEnabled = true,
  });

  EdgeInsets getPadding() {
    EdgeInsets padding;
    switch (combination) {
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
    switch (combination) {
      case Combination.left:
        borderRadius = const BorderRadius.only(
          topLeft: Radius.circular(25),
          bottomLeft: Radius.circular(25),
        );
        break;
      case Combination.middle:
        borderRadius = const BorderRadius.all(Radius.zero);
        break;
      case Combination.right:
        borderRadius = const BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        );
        break;
      default:
        borderRadius = const BorderRadius.all(Radius.circular(25));
        break;
    }
    return borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      color: isEnabled == true ? foregroundColor : Colors.grey[800],
    );
    return Padding(
      padding: getPadding(),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(left: 8, right: 8),
          backgroundColor: isEnabled == true ? backgroundColor : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: getRadius(),
          ),
        ),
        onPressed: () {
          if (isEnabled == true) {
            click.call();
          }
        },
        child: icon != null
            ? Text.rich(
          TextSpan(
            style: textStyle,
            children: [
              WidgetSpan(
                child: icon!,
                alignment: PlaceholderAlignment.middle,
              ),
              TextSpan(text: text),
            ],
          ),
        )
            : Text(text, style: textStyle),
      ),
    );
  }
}
