import 'package:flutter/material.dart';

class FaradayAction extends StatelessWidget {
  final Color? color;
  final Widget icon;
  final VoidCallback? onTap;
  final String description;

  const FaradayAction(
      {Key? key,
      this.color,
      required this.icon,
      this.onTap,
      required this.description})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: onTap,
        child: Stack(
          children: [
            Positioned(
              top: 8.0,
              left: 8.0,
              child: icon,
            ),
            Positioned(
              left: 8.0,
              bottom: 8.0,
              child: Text(
                description,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
