import 'package:flutter/material.dart';
class ProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const ProgressBar({super.key, required this.current, required this.total});


  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: i <= current ? Colors.pink : Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}


