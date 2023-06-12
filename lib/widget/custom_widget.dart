
import 'package:flutter/material.dart';
import '../generated/l10n.dart';

///登录按钮
class LoginButton extends StatefulWidget {
  const LoginButton({Key? key, required this.onPressed}) : super(key: key);
  final Function() onPressed;

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: const Size(320, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25))),
        onPressed: widget.onPressed,
        child: Text(S.current.login, style: const TextStyle(fontSize: 20)));
  }
}
