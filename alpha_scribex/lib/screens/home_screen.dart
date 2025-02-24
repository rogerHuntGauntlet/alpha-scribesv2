import 'package:flutter/cupertino.dart';
import '../theme/app_theme.dart';
import '../screens/new_project_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onSwitchTab;

  const HomeScreen({
    Key? key,
    required this.onSwitchTab,
  }) : super(key: key);

  void _showNewProjectScreen(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const NewProjectScreen(),
      ),
    ).then((created) {
      if (created == true) {
        onSwitchTab(1); // Switch to projects tab after creation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Writer';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Welcome', style: AppTheme.headingMedium),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                // TODO: Implement refresh logic
              },
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Hello, $displayName!',
                      style: AppTheme.headingLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What would you like to do today?',
                      style: AppTheme.bodyLarge.copyWith(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _QuickActionButton(
                      icon: CupertinoIcons.add_circled,
                      label: 'New Project',
                      onPressed: () => _showNewProjectScreen(context),
                    ),
                    const SizedBox(height: 16),
                    _QuickActionButton(
                      icon: CupertinoIcons.book,
                      label: 'Continue Writing',
                      onPressed: () {
                        // Switch to projects tab
                        onSwitchTab(1);
                        // TODO: Navigate to most recent project
                      },
                    ),
                    const SizedBox(height: 16),
                    _QuickActionButton(
                      icon: CupertinoIcons.star,
                      label: 'View Achievements',
                      onPressed: () {
                        // Switch to achievements tab
                        onSwitchTab(2);
                      },
                    ),
                    const Spacer(),
                    Center(
                      child: Column(
                        children: [
                          const Icon(
                            CupertinoIcons.lightbulb,
                            size: 48,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Writing Tip',
                            style: AppTheme.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Try to write a little bit every day\nto build a consistent habit.',
                            style: AppTheme.bodyMedium.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: CupertinoTheme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTheme.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Icon(
              CupertinoIcons.chevron_right,
              size: 20,
              color: CupertinoColors.systemGrey2,
            ),
          ],
        ),
      ),
    );
  }
} 