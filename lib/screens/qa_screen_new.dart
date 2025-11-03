import 'package:flutter/material.dart';
import '../services/questions_service.dart';
import '../models/question_model.dart';
import 'question_editor_screen.dart';
import 'question_detail_screen.dart';

class QaScreenNew extends StatefulWidget {
  const QaScreenNew({super.key});

  @override
  State<QaScreenNew> createState() => _QaScreenNewState();
}

class _QaScreenNewState extends State<QaScreenNew> {
  final QuestionsService _questionsService = QuestionsService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedDifficulty = 'All';
  String _selectedStatus = 'All';
  String _selectedSubject = 'All';
  DateTime _lastRefresh = DateTime.now();
  String _sortBy = 'Newest';

  final List<String> _difficulties = ['All', 'Easy', 'Medium', 'Hard'];
  final List<String> _statuses = ['All', 'open', 'answered', 'closed'];
  final List<String> _subjects = [
    'All',
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openQuestionEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuestionEditorScreen(),
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      _lastRefresh = DateTime.now();
    });
    // StreamBuilder will automatically refresh
    await Future.delayed(const Duration(milliseconds: 500));
  }

  List<Question> _filterQuestions(List<Question> questions) {
    var filtered = questions;

    if (_selectedDifficulty != 'All') {
      filtered = filtered.where((q) => q.difficulty == _selectedDifficulty).toList();
    }

    if (_selectedStatus != 'All') {
      filtered = filtered.where((q) => q.status == _selectedStatus).toList();
    }

    if (_selectedSubject != 'All') {
      filtered = filtered.where((q) => q.subject == _selectedSubject).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((q) =>
              q.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              q.creatorName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'Newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Most Answers':
        filtered.sort((a, b) => b.answersCount.compareTo(a.answersCount));
        break;
      case 'Highest Points':
        filtered.sort((a, b) => b.points.compareTo(a.points));
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF4F46E5),
              child: StreamBuilder<List<Question>>(
                stream: _questionsService.getAllQuestions(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  final questions = snapshot.data ?? [];
                  final filteredQuestions = _filterQuestions(questions);

                  if (filteredQuestions.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _buildQuestionsList(filteredQuestions);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openQuestionEditor,
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.help_outline_rounded, color: Colors.white),
        label: const Text(
          'Ask Question',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        elevation: 2,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.question_answer_rounded,
              color: Color(0xFF4F46E5),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Q&A Forum',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                'Ask questions and help others',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              icon: const Icon(Icons.sort_rounded, color: Color(0xFF4F46E5)),
              underline: const SizedBox(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              items: ['Newest', 'Most Answers', 'Highest Points']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _sortBy = newValue;
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search questions...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterSection('Difficulty', _difficulties, _selectedDifficulty, (value) {
              setState(() => _selectedDifficulty = value);
            }),
            const SizedBox(width: 24),
            _buildFilterSection('Status', _statuses, _selectedStatus, (value) {
              setState(() => _selectedStatus = value);
            }),
            const SizedBox(width: 24),
            _buildFilterSection('Subject', _subjects, _selectedSubject, (value) {
              setState(() => _selectedSubject = value);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String label,
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 8),
        ...options.map((option) {
          final isSelected = selected == option;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onSelect(option),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF4F46E5),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildQuestionsList(List<Question> questions) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: questions.length,
      itemBuilder: (context, index) => _buildQuestionCard(questions[index]),
    );
  }

  Widget _buildQuestionCard(Question question) {
    final difficultyColor = _getDifficultyColor(question.difficulty);
    final statusColor = _getStatusColor(question.status);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionDetailScreen(question: question),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: difficultyColor.withOpacity(0.3)),
                ),
                child: Text(
                  question.difficulty,
                  style: TextStyle(
                    color: difficultyColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(_getStatusIcon(question.status), size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      question.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${question.points} pts',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  question.subject,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF4F46E5),
                child: Text(
                  question.creatorName.isNotEmpty ? question.creatorName[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                question.creatorName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Text(
                _formatDate(question.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Colors.grey[700]),
                    const SizedBox(width: 6),
                    Text(
                      '${question.answersCount} ${question.answersCount == 1 ? 'answer' : 'answers'}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.question_answer_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No questions found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty ||
                    _selectedDifficulty != 'All' ||
                    _selectedStatus != 'All' ||
                    _selectedSubject != 'All'
                ? 'Try adjusting your filters'
                : 'Be the first to ask a question!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty &&
              _selectedDifficulty == 'All' &&
              _selectedStatus == 'All' &&
              _selectedSubject == 'All')
            ElevatedButton.icon(
              onPressed: _openQuestionEditor,
              icon: const Icon(Icons.help_outline_rounded),
              label: const Text('Ask First Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
          ),
          SizedBox(height: 16),
          Text(
            'Loading questions...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF10B981);
      case 'medium':
        return const Color(0xFFF59E0B);
      case 'hard':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return const Color(0xFF3B82F6);
      case 'answered':
        return const Color(0xFF10B981);
      case 'closed':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Icons.radio_button_unchecked_rounded;
      case 'answered':
        return Icons.check_circle_rounded;
      case 'closed':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

class _CreateQuestionDialog extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController subjectController;
  final List<String> subjects;
  final List<String> difficulties;
  final Function(String) onDifficultyChanged;
  final Function(int) onPointsChanged;

  const _CreateQuestionDialog({
    required this.titleController,
    required this.subjectController,
    required this.subjects,
    required this.difficulties,
    required this.onDifficultyChanged,
    required this.onPointsChanged,
  });

  @override
  State<_CreateQuestionDialog> createState() => _CreateQuestionDialogState();
}

class _CreateQuestionDialogState extends State<_CreateQuestionDialog> {
  bool _isLoading = false;
  String _selectedDifficulty = 'Medium';
  int _selectedPoints = 15;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.help_outline_rounded, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ask a Question',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey[600],
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: widget.titleController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Question',
                hintText: 'What would you like to know?',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: widget.subjectController.text.isEmpty ? null : widget.subjectController.text,
              decoration: InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
              ),
              items: widget.subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.subjectController.text = value;
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
              ),
              items: widget.difficulties
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedDifficulty = value;
                    widget.onDifficultyChanged(value);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _selectedPoints,
              decoration: InputDecoration(
                labelText: 'Points',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                ),
              ),
              items: [5, 10, 15, 20, 25, 30, 50]
                  .map((p) => DropdownMenuItem(value: p, child: Text('$p points')))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPoints = value;
                    widget.onPointsChanged(value);
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _isLoading = true);
                          Navigator.pop(context, {
                            'difficulty': _selectedDifficulty,
                            'points': _selectedPoints,
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Post Question'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
