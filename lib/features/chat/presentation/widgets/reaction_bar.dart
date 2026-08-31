import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  final ValueChanged<String> onSelectEmoji;

  const ReactionBar({super.key, required this.onSelectEmoji});

  static const List<String> emojis = ['❤️', '👍', '😂', '😍', '🎵'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: emojis.map((emoji) {
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onSelectEmoji(emoji),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
