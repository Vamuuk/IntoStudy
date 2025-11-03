import 'package:flutter/material.dart';
import '../services/questions_service.dart';
import '../services/auth_service.dart';

class QuestionEditorScreen extends StatefulWidget {
  const QuestionEditorScreen({super.key});

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final QuestionsService _questionsService = QuestionsService();
  final AuthService _authService = AuthService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedSubject = 'Software Engineering';
  String _selectedDifficulty = 'Medium';
  bool _isSaving = false;

  final List<String> _subjects = [
    'Software Engineering',
    'Computer Science',
    'Information Systems',
    'Data Science',
    'Artificial Intelligence',
    'Cybersecurity',
    'Business Administration',
    'Digital Marketing',
    'Game Design',
    'Web Development',
  ];

  final Map<String, Map<String, dynamic>> _difficultyConfig = {
    'Easy': {
      'points': 10,
      'color': const Color(0xFF10B981),
      'icon': Icons.check_circle_outline,
    },
    'Medium': {
      'points': 20,
      'color': const Color(0xFFF59E0B),
      'icon': Icons.help_outline_rounded,
    },
    'Hard': {
      'points': 50,
      'color': const Color(0xFFEF4444),
      'icon': Icons.local_fire_department_rounded,
    },
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  int get _points => _difficultyConfig[_selectedDifficulty]!['points'] as int;

  Future<void> _postQuestion() async {
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      _showSnackBar('Please fill in all fields', isError: true);
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      _showSnackBar('Please sign in', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final userProfile = await _authService.getUserProfile(user.uid);
      final userName = userProfile?['name'] ?? 'Anonymous';

      await _questionsService.createQuestion(
        title: _titleController.text.trim(),
        subject: _selectedSubject,
        difficulty: _selectedDifficulty,
        points: _points,
        creatorUid: user.uid,
        creatorName: userName,
        description: _descriptionController.text.trim(),
      );

      if (mounted) {
        _showSnackBar('Question posted successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[400] : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
        ),
        title: const Text(
          'Ask a Question',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: ElevatedButton.icon(
                onPressed: _postQuestion,
                icon: const Icon(Icons.send_rounded, size: 20),
                label: const Text('Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question Title
                _buildSectionHeader('Question Title', Icons.help_outline_rounded),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: 'What would you like to know?',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(20),
                  ),
                ),

                const SizedBox(height: 32),

                // Subject Selection
                _buildSectionHeader('Subject', Icons.school_rounded),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSubject,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E293B),
                      ),
                      items: _subjects.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedSubject = value);
                        }
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Difficulty Selection
                _buildSectionHeader('Difficulty Level', Icons.trending_up_rounded),
                const SizedBox(height: 12),
                Row(
                  children: _difficultyConfig.entries.map((entry) {
                    final difficulty = entry.key;
                    final config = entry.value;
                    final isSelected = _selectedDifficulty == difficulty;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: InkWell(
                          onTap: () => setState(() => _selectedDifficulty = difficulty),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: isSelected ? config['color'] as Color : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? config['color'] as Color
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (config['color'] as Color)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  config['icon'] as IconData,
                                  color: isSelected
                                      ? Colors.white
                                      : config['color'] as Color,
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  difficulty,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF1E293B),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${config['points']} pts',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Question Description
                _buildSectionHeader('Detailed Description', Icons.article_outlined),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 12,
                    style: const TextStyle(fontSize: 15, height: 1.6),
                    decoration: InputDecoration(
                      hintText: 'Provide more details about your question...\n\nYou can include:\n• Context and background\n• What you\'ve tried so far\n• Specific areas where you need help',
                      hintStyle: TextStyle(color: Colors.grey[400], height: 1.6),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(20),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Reward Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        (_difficultyConfig[_selectedDifficulty]!['color'] as Color)
                            .withValues(alpha: 0.1),
                        (_difficultyConfig[_selectedDifficulty]!['color'] as Color)
                            .withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: (_difficultyConfig[_selectedDifficulty]!['color'] as Color)
                          .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _difficultyConfig[_selectedDifficulty]!['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.stars_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question Reward',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Helper earns $_points points for best answer',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
