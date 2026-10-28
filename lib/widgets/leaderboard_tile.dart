import 'package:flutter/material.dart';
import '../utils/theme.dart';

class LeaderboardTile extends StatelessWidget {
  final int rank;
  final String name;
  final int streak;
  final String? avatarUrl;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.rank,
    required this.name,
    required this.streak,
    this.avatarUrl,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isTopThree = rank <= 3;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isCurrentUser ? ShrexTheme.primaryGradient : null,
        color: isCurrentUser ? null : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? null
            : Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: isTopThree ? ShrexTheme.accentGradient : null,
              color: isTopThree ? null : theme.colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  color: isTopThree ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: theme.colorScheme.surfaceVariant,
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          // Name and streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isCurrentUser ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$streak day${streak == 1 ? '' : 's'} streak',
                  style: TextStyle(
                    color: isCurrentUser 
                        ? Colors.white.withOpacity(0.8)
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Streak badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentUser 
                  ? Colors.white.withOpacity(0.2)
                  : ShrexTheme.accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$streak',
              style: TextStyle(
                color: isCurrentUser ? Colors.white : ShrexTheme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
