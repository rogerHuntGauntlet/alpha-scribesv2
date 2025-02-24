import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show LinearProgressIndicator, AlwaysStoppedAnimation;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/auth/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return CupertinoPageScaffold(
      backgroundColor: AppTheme.backgroundLight,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: AppTheme.surfaceLight,
        border: null,
        middle: Text(
          'BrainLift',
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.primaryBlue,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.profile_circled,
            color: AppTheme.primaryBlue,
          ),
          onPressed: () {
            // TODO: Implement profile navigation
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          children: [
            // Welcome Section
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.shadowMedium,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTheme.bodyLarge,
                            ),
                            const SizedBox(height: AppTheme.spacingXS),
                            Text(
                              user?.email?.split('@')[0] ?? 'Student',
                              style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingS),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLavender,
                          borderRadius: BorderRadius.circular(AppTheme.radiusM),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Level',
                              style: AppTheme.bodyMedium,
                            ),
                            Text(
                              '1',
                              style: AppTheme.headingLarge.copyWith(
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingL),
                  LinearProgressIndicator(
                    value: 0.3,
                    backgroundColor: AppTheme.backgroundLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Text(
                    '30% progress to Level 2',
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Quick Actions
            Text(
              'Quick Actions',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: CupertinoIcons.pencil_circle_fill,
                    label: 'New Writing',
                    color: AppTheme.primaryTeal,
                    onTap: () {
                      // TODO: Implement new writing
                    },
                  ),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    icon: CupertinoIcons.book_circle_fill,
                    label: 'My Projects',
                    color: AppTheme.primaryLavender,
                    onTap: () {
                      // TODO: Implement projects view
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Current Projects
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Projects',
                  style: AppTheme.headingMedium,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  child: Text(
                    'See All',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  onPressed: () {
                    // TODO: Implement see all projects
                  },
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildProjectCard(
              context,
              title: 'My First Essay',
              progress: 0.7,
              dueDate: 'Due Tomorrow',
              type: 'Essay',
            ),
            const SizedBox(height: AppTheme.spacingM),
            _buildProjectCard(
              context,
              title: 'Creative Writing Exercise',
              progress: 0.3,
              dueDate: 'Due in 3 days',
              type: 'Creative',
            ),

            const SizedBox(height: AppTheme.spacingL),

            // Writing Exercises
            Text(
              'Writing Exercises',
              style: AppTheme.headingMedium,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusL),
                boxShadow: AppTheme.shadowSmall,
              ),
              child: Column(
                children: [
                  _buildExerciseItem(
                    context,
                    title: 'Sentence Structure',
                    description: 'Master the basics of sentence construction',
                    progress: 0.8,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildExerciseItem(
                    context,
                    title: 'Paragraph Writing',
                    description: 'Learn to write cohesive paragraphs',
                    progress: 0.4,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  _buildExerciseItem(
                    context,
                    title: 'Essay Planning',
                    description: 'Plan and structure your essays effectively',
                    progress: 0.1,
                    isLocked: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          boxShadow: AppTheme.shadowSmall,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: color,
            ),
            const SizedBox(height: AppTheme.spacingS),
            Text(
              label,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectCard(
    BuildContext context, {
    required String title,
    required double progress,
    required String dueDate,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingS,
                  vertical: AppTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLavender,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Text(
                  type,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.backgroundLight,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                    ),
                    const SizedBox(height: AppTheme.spacingXS),
                    Text(
                      '${(progress * 100).toInt()}% Complete',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                dueDate,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.accentCoral,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(
    BuildContext context, {
    required String title,
    required String description,
    required double progress,
    bool isLocked = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      decoration: BoxDecoration(
        color: isLocked ? AppTheme.backgroundLight : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLocked ? AppTheme.textSecondary : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: isLocked ? AppTheme.textSecondary : null,
                  ),
                ),
                if (!isLocked) ...[
                  const SizedBox(height: AppTheme.spacingS),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.backgroundLight,
                    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Icon(
            isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.chevron_right,
            color: isLocked ? AppTheme.textSecondary : AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }
} 