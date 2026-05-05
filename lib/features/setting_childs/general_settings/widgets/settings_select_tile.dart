import 'package:flutter/material.dart';

class SettingsSelectTile extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const SettingsSelectTile({
    super.key,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(value),
                  const SizedBox(width: 6),
                  const Icon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
