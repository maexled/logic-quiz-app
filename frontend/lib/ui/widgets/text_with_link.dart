import 'package:flutter/material.dart';

class TextWithLink extends StatelessWidget {
  const TextWithLink(
      {super.key,
      required this.onTap,
      required this.text,
      required this.tapText});

  final Function()? onTap;
  final String text;
  final String tapText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$text ",
        ),
        InkWell(
          onTap: onTap,
          child: Text(
            tapText,
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }
}
