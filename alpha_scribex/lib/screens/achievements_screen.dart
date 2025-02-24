import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../theme/app_theme.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final achievementService = Provider.of<AchievementService>(context);
    final userId = Provider.of<String?>(context); // Make userId nullable

    if (userId == null) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Achievements', style: AppTheme.headingMedium),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.person_crop_circle,
                  size: 64,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please sign in to view achievements',
                  style: AppTheme.bodyLarge.copyWith(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Achievements', style: AppTheme.headingMedium),
      ),
      child: SafeArea(
        child: StreamBuilder<List<Achievement>>(
          stream: achievementService.getAchievements(),
          builder: (context, achievementsSnapshot) {
            if (achievementsSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.wifi_slash,
                      size: 64,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load achievements',
                      style: AppTheme.bodyLarge.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your internet connection',
                      style: AppTheme.bodyMedium.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CupertinoButton(
                      onPressed: () {
                        // This will trigger a rebuild and attempt to reconnect
                        achievementService.initializeDefaultAchievements();
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (!achievementsSnapshot.hasData) {
              return const Center(child: CupertinoActivityIndicator());
            }

            final achievements = achievementsSnapshot.data!;

            return StreamBuilder<List<UserAchievement>>(
              stream: achievementService.getUserAchievements(userId),
              builder: (context, userAchievementsSnapshot) {
                final userAchievements = userAchievementsSnapshot.data ?? [];

                return CustomScrollView(
                  slivers: [
                    CupertinoSliverRefreshControl(
                      onRefresh: () async {
                        // The streams will automatically refresh the data
                      },
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final achievement = achievements[index];
                            final userAchievement = userAchievements.firstWhere(
                              (ua) => ua.achievementId == achievement.id,
                              orElse: () => UserAchievement(
                                userId: userId,
                                achievementId: achievement.id,
                                earnedAt: DateTime.now(),
                                progress: 0,
                              ),
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _AchievementCard(
                                achievement: achievement,
                                userAchievement: userAchievement,
                              ),
                            );
                          },
                          childCount: achievements.length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final UserAchievement userAchievement;

  const _AchievementCard({
    required this.achievement,
    required this.userAchievement,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = userAchievement.isCompleted;
    final progress = userAchievement.progress;
    final target = achievement.requirements['target'] as int? ?? 100;
    final progressPercentage = (progress / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: CupertinoColors.systemGrey5,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? CupertinoColors.activeGreen.withOpacity(0.1)
                      : CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  CupertinoIcons.star_fill,
                  color: isCompleted
                      ? CupertinoColors.activeGreen
                      : CupertinoColors.systemGrey2,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.name,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: AppTheme.bodyMedium.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.activeGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${achievement.points} pts',
                    style: AppTheme.bodyMedium.copyWith(
                      color: CupertinoColors.activeGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          if (!isCompleted) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: AppTheme.bodyMedium.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    Text(
                      '$progress / $target',
                      style: AppTheme.bodyMedium.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemGrey6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: progressPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.activeBlue,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
} 