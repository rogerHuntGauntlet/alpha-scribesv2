import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/writing_project.dart';
import '../services/writing_project_service.dart';
import '../services/achievement_service.dart';
import '../theme/app_theme.dart';
import '../services/ai_analysis_service.dart';
import '../config/api_config.dart';

class WritingEditorScreen extends StatefulWidget {
  final WritingProject project;

  const WritingEditorScreen({
    Key? key,
    required this.project,
  }) : super(key: key);

  @override
  State<WritingEditorScreen> createState() => _WritingEditorScreenState();
}

class _WritingEditorScreenState extends State<WritingEditorScreen> {
  final WritingProjectService _projectService = WritingProjectService();
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = true;
  bool _isAnalyzing = false;
  Timer? _autoSaveTimer;
  String _achievementLevel = '';
  final AIAnalysisService _aiService = AIAnalysisService(APIConfig.openAIKey);
  final Map<String, bool> _expandedItems = {};
  List<Map<String, dynamic>> _analysisData = [];
  String _progressText = '';
  String _nextSteps = '';

  @override
  void initState() {
    super.initState();
    _loadContent();
    _loadAchievementLevel();
    _loadLastAnalysis();
    // Set up auto-save timer
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (_) => _saveContent());
  }

  @override
  void dispose() {
    _textController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadContent() async {
    try {
      final content = await _projectService.getProjectContent(widget.project.id);
      if (content != null) {
        _textController.text = content.toString();
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to load content: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _saveContent() async {
    try {
      await _projectService.saveProjectContent(
        widget.project.id,
        _textController.text,
      );
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save content: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _loadAchievementLevel() async {
    try {
      final achievementService = Provider.of<AchievementService>(context, listen: false);
      final userId = Provider.of<String?>(context, listen: false);
      if (userId != null) {
        final level = await achievementService.getUserLevel(userId);
        if (mounted) {
          setState(() {
            _achievementLevel = level;
          });
        }
      }
    } catch (e) {
      print('Error loading achievement level: $e');
      if (mounted) {
        setState(() {
          _achievementLevel = 'Level 0: Beginner';
        });
      }
    }
  }

  Future<void> _loadLastAnalysis() async {
    try {
      final results = await _projectService.getAnalysisResults(widget.project.id);
      if (results != null && mounted) {
        setState(() {
          _progressText = results['progress'] ?? '';
          _nextSteps = results['nextSteps'] ?? '';
          
          final analysisKey = results['currentLevel'] == 0 ? 'sentenceAnalysis' :
                             results['currentLevel'] == 1 ? 'paragraphAnalysis' :
                             'pageAnalysis';
          
          _analysisData = (results[analysisKey] as List<dynamic>? ?? [])
              .map((item) => item as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      print('Error loading last analysis: $e');
    }
  }

  Future<void> _analyzeAndShowResults() async {
    if (_textController.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: const Text('Please write some text before submitting.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisData = [];
      _progressText = '';
      _nextSteps = '';
    });

    try {
      // Get current level
      int currentLevel = 0;
      try {
        currentLevel = int.parse(_achievementLevel.split(':')[0].replaceAll('Level ', '').trim());
      } catch (e) {
        print('Error parsing level: $e');
        currentLevel = 0;
      }

      // Analyze text
      final analysis = await _aiService.analyzeText(_textController.text, currentLevel);
      
      if (mounted) {
        // Save content first
        await _saveContent();
        
        if (analysis.containsKey('error')) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Analysis Error'),
              content: Text(analysis['error'] ?? 'Unknown error occurred'),
              actions: [
                CupertinoDialogAction(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
          return;
        }
        
        // Add current level to analysis results
        final resultsToSave = {
          ...analysis,
          'currentLevel': currentLevel,
        };
        
        // Save analysis results
        await _projectService.saveAnalysisResults(widget.project.id, resultsToSave);
        
        // Update the analysis results
        setState(() {
          _progressText = analysis['progress'] ?? 'No progress data';
          _nextSteps = analysis['nextSteps'] ?? 'Continue improving your writing';
          
          switch (currentLevel) {
            case 0:
              _analysisData = (analysis['sentenceAnalysis'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
              break;
            case 1:
              _analysisData = (analysis['paragraphAnalysis'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
              break;
            case 2:
              _analysisData = (analysis['pageAnalysis'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();
              break;
          }
        });
      }
    } catch (e) {
      print('Analysis error: $e');
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to analyze text: ${e.toString()}'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Widget _buildAnalysisItem(String text, int score, bool isPerfect, String feedback, String suggestions) {
    final isExpanded = _expandedItems[text] ?? false;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedItems[text] = !isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey6,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPerfect ? CupertinoColors.activeGreen : CupertinoColors.systemGrey4,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getScoreColor(score),
                  ),
                  child: Center(
                    child: Text(
                      score.toString(),
                      style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text.length > 50 ? '${text.substring(0, 50)}...' : text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isPerfect ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.info_circle_fill,
                            color: isPerfect ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPerfect ? 'Perfect!' : 'Needs improvement',
                            style: TextStyle(
                              fontSize: 13,
                              color: isPerfect ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 200),
                  turns: isExpanded ? 0.5 : 0,
                  child: const Icon(
                    CupertinoIcons.chevron_down,
                    color: CupertinoColors.systemGrey,
                    size: 20,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: CupertinoColors.separator,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Feedback',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedback,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (suggestions.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Suggestions',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      suggestions,
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 9) return CupertinoColors.activeGreen;
    if (score >= 7) return CupertinoColors.activeBlue;
    if (score >= 5) return CupertinoColors.systemOrange;
    return CupertinoColors.systemRed;
  }

  String _getNextLevelRequirement() {
    try {
      final level = int.parse(_achievementLevel.split(':')[0].replaceAll('Level ', '').trim());
      switch (level) {
        case 0:
          return 'Perfect 5 sentences to reach Level 1: Paragraph Analysis';
        case 1:
          return 'Perfect 3 paragraphs to reach Level 2: Page Analysis';
        case 2:
          return 'You\'ve reached the highest level!';
        default:
          return 'Keep writing to improve!';
      }
    } catch (e) {
      return 'Perfect 5 sentences to reach Level 1';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Loading...'),
        ),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.project.title),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Achievement Level
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: CupertinoColors.systemGrey6,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.pencil_circle_fill,
                        color: _achievementLevel.startsWith('Level 0') 
                            ? CupertinoColors.systemGrey
                            : CupertinoColors.activeBlue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _achievementLevel,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _achievementLevel.startsWith('Level 0') 
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.activeBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getNextLevelRequirement(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Text Input
            CupertinoTextField(
              controller: _textController,
              placeholder: 'Start writing your story...',
              minLines: 5,
              maxLines: 10,
              padding: const EdgeInsets.all(12),
            ),
            
            const SizedBox(height: 16),
            
            // Submit Button
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isAnalyzing) ...[
                    const CupertinoActivityIndicator(color: CupertinoColors.white),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    _isAnalyzing ? 'Analyzing...' : 'Submit',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              onPressed: _isAnalyzing ? null : _analyzeAndShowResults,
            ),

            if (_analysisData.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _progressText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.activeBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Next Steps: $_nextSteps',
                style: const TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 16),
              ..._analysisData.map((item) => _buildAnalysisItem(
                item['sentence']?.toString() ?? item['paragraph']?.toString() ?? item['page']?.toString() ?? '',
                (item['score'] as num?)?.toInt() ?? 0,
                item['isPerfect'] as bool? ?? false,
                item['feedback']?.toString() ?? '',
                item['suggestions']?.toString() ?? '',
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }
} 