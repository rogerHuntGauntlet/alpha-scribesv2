import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/project_service.dart';
import '../theme/app_theme.dart';

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({Key? key}) : super(key: key);

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    debugPrint('=================== START PROJECT CREATION ===================');
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final projectService = Provider.of<ProjectService>(context, listen: false);
      debugPrint('Creating project:');
      debugPrint('Title: ${_titleController.text}');
      debugPrint('Description: ${_descriptionController.text}');

      await projectService.createProject(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
      );
      debugPrint('Project created successfully');

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e, stack) {
      debugPrint('Error creating project: $e');
      debugPrint('Stack trace: $stack');
      
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text(e.toString()),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('=================== END PROJECT CREATION ===================');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('New Project'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CupertinoFormSection(
                header: const Text('Project Details'),
                children: [
                  CupertinoTextFormFieldRow(
                    controller: _titleController,
                    placeholder: 'Project Title',
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  CupertinoTextFormFieldRow(
                    controller: _descriptionController,
                    placeholder: 'Description',
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              if (_isLoading)
                const Center(child: CupertinoActivityIndicator())
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CupertinoButton.filled(
                    onPressed: _createProject,
                    child: const Text('Create Project'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 