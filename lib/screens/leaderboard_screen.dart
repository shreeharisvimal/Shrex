import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../services/firebase_service.dart';
import '../widgets/leaderboard_tile.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class LeaderboardScreen extends HookConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = useState<List<dynamic>>([]);
    final isLoading = useState(true);
    final isFirebaseEnabled = useState(false);

    useEffect(() {
      Future<void> _loadLeaderboard() async {
        try {
          final enabled = await FirebaseService.isFirebaseEnabled();
          isFirebaseEnabled.value = enabled;
          
          if (enabled) {
            final data = await FirebaseService.getLeaderboard();
            leaderboard.value = data;
          }
          isLoading.value = false;
        } catch (e) {
          debugPrint('Error loading leaderboard: $e');
          isLoading.value = false;
        }
      }
      _loadLeaderboard();
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final enabled = await FirebaseService.isFirebaseEnabled();
                isFirebaseEnabled.value = enabled;
                
                if (enabled) {
                  final data = await FirebaseService.getLeaderboard();
                  leaderboard.value = data;
                }
              } catch (e) {
                debugPrint('Error loading leaderboard: $e');
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: ShrexTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.padding),
            child: Column(
              children: [
                // Firebase Status
                if (!isFirebaseEnabled.value) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ShrexTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: ShrexTheme.warningColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_off,
                          color: ShrexTheme.warningColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cloud Sync Disabled',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: ShrexTheme.warningColor,
                                ),
                              ),
                              Text(
                                'Enable Firebase sync in Settings to see leaderboard',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Leaderboard Content
                Expanded(
                  child: isLoading.value
                      ? const Center(child: CircularProgressIndicator())
                      : leaderboard.value.isEmpty
                          ? _buildEmptyState(context)
                          : _buildLeaderboard(context, leaderboard.value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No Leaderboard Data',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete focus sessions and sync with Firebase to appear on the leaderboard',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            icon: const Icon(Icons.settings),
            label: const Text('Go to Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, List<dynamic> leaderboard) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: ShrexTheme.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Leaderboard',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Top ${leaderboard.length} Focus Masters',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Leaderboard List
        Expanded(
          child: ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final user = leaderboard[index];
              final rank = index + 1;
              final isCurrentUser = user.uid == FirebaseService.currentUser?.uid;

              return LeaderboardTile(
                rank: rank,
                name: user.displayName ?? user.email ?? 'Anonymous',
                streak: user.currentStreak,
                avatarUrl: user.photoURL,
                isCurrentUser: isCurrentUser,
              );
            },
          ),
        ),

        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Leaderboard updates every hour. Keep building your streak!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
