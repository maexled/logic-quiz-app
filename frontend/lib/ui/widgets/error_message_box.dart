import 'package:flutter/material.dart';

class ErrorMessageBox extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final TextStyle? textStyle;

  const ErrorMessageBox({
    super.key,
    required this.message,
    this.icon = Icons.error,
    this.backgroundColor = Colors.redAccent,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(left: 50, right: 50, top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 35,
            color: textStyle?.color,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
