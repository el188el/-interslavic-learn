import 'package:flutter/material.dart';

import '../../models/user_progress.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.progress});

  final UserProgress progress;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  progress.displayName.isNotEmpty
                      ? progress.displayName[0].toUpperCase()
                      : 'У',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              if (progress.isPremium)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star,
                        color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            progress.displayName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}
