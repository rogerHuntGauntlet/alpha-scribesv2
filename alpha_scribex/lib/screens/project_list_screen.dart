import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/project_service.dart';
import '../models/writing_project.dart';
import '../theme/app_theme.dart';
import 'new_project_screen.dart';
import 'writing_editor_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({Key? key}) : super(key: key);

  void _showNewProjectScreen(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const NewProjectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Projects', style: AppTheme.headingMedium),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: () => _showNewProjectScreen(context),
        ),
      ),
      child: SafeArea(
        child: StreamBuilder<List<WritingProject>>(
          stream: Provider.of<ProjectService>(context).getUserProjects(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: AppTheme.bodyLarge.copyWith(
                    color: CupertinoColors.systemRed,
                  ),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            final projects = snapshot.data ?? [];

            if (projects.isEmpty) {
              return CustomScrollView(
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      // Refresh will happen automatically with StreamBuilder
                    },
                  ),
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.doc_text,
                            size: 64,
                            color: CupertinoColors.systemGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Projects Yet',
                            style: AppTheme.bodyLarge.copyWith(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          CupertinoButton(
                            child: const Text('Create New Project'),
                            onPressed: () => _showNewProjectScreen(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return CustomScrollView(
              slivers: [
                CupertinoSliverRefreshControl(
                  onRefresh: () async {
                    // Refresh will happen automatically with StreamBuilder
                  },
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final project = projects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
                          child: _ProjectCard(project: project),
                        );
                      },
                      childCount: projects.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final WritingProject project;

  const _ProjectCard({required this.project});

  Widget _buildProgressIndicator(WritingProject project) {
    if (project.lastAnalysis == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.doc_text,
            size: 16,
            color: CupertinoColors.systemGrey,
          ),
          SizedBox(width: 4),
          Text(
            'Not analyzed yet',
            style: TextStyle(
              fontSize: 13,
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      );
    }

    final currentLevel = project.lastAnalysis!['currentLevel'] as int? ?? 0;
    final progress = project.lastAnalysis!['progress'] as String? ?? '';
    final isPerfect = (project.lastAnalysis![
      currentLevel == 0 ? 'sentenceAnalysis' :
      currentLevel == 1 ? 'paragraphAnalysis' :
      'pageAnalysis'
    ] as List<dynamic>? ?? []).every((item) => item['isPerfect'] == true);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPerfect ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.arrow_right_circle_fill,
          size: 16,
          color: isPerfect ? CupertinoColors.activeGreen : CupertinoColors.activeBlue,
        ),
        const SizedBox(width: 4),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            progress,
            style: TextStyle(
              fontSize: 13,
              color: isPerfect ? CupertinoColors.activeGreen : CupertinoColors.activeBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => WritingEditorScreen(project: project),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          border: Border.all(
            color: CupertinoColors.systemGrey5,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  color: CupertinoColors.systemGrey2,
                ),
              ],
            ),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spacingS),
              Text(
                project.description,
                style: AppTheme.bodyMedium.copyWith(
                  color: CupertinoColors.systemGrey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: AppTheme.spacingM),
            Row(
              children: [
                const Icon(
                  CupertinoIcons.text_alignleft,
                  size: 16,
                  color: CupertinoColors.systemGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${project.wordCount} words',
                  style: AppTheme.bodyMedium.copyWith(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const Spacer(),
                _buildProgressIndicator(project),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 