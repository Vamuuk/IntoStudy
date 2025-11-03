import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/default_chats_service.dart';

class OnboardingScreen extends StatefulWidget {
  final String email;
  final String uid;

  const OnboardingScreen({
    super.key,
    required this.email,
    required this.uid,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _slideController;
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  
  // Selections
  String _selectedAvatar = 'A';
  Color _selectedColor = const Color(0xFF4F46E5);
  String? _selectedUniversity;
  final List<String> _selectedInterests = [];
  
  final List<String> _avatarOptions = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
  
  final List<Color> _colorOptions = [
    const Color(0xFF4F46E5),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFFEC4899),
    const Color(0xFF8B5CF6),
    const Color(0xFF06B6D4),
  ];
  
final Map<String, List<String>> _universities = {
    'Seoul': [
      'Seoul National University',
      'Yonsei University',
      'Korea University',
      'Sungkyunkwan University',
      'Sogang University',
      'Kyung Hee University',
      'Hanyang University',
      'Ewha Womans University',
      'Hongik University',
      'Chung-Ang University',
      'Korea Military Academy',
    ],
    'Busan': [
      'Pusan National University',
      'Pukyong National University',
      'Busan University of Foreign Studies',
    ],
    'Daejeon': [
      'KAIST',
      'Chungnam National University',
      'Solbridge International School of Business Woosong University',
    ],
    'Incheon': [
      'Incheon National University',
      'Yonsei University (Songdo Campus)',
    ],
    'Gwangju': [
      'Chonnam National University',
      'Gwangju Institute of Science and Technology (GIST)',
    ],
    'Pohang': [
      'Pohang University of Science and Technology (POSTECH)',
    ],
    'Ulsan': [
      'Ulsan National Institute of Science and Technology (UNIST)',
    ],
    'Jeonju': [
      'Chonbuk National University',
    ],
    'Namyangju': [
      'Kyungbok University',
    ],
    'Other': [
      'Other',
    ]
  };
  
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Programming', 'icon': Icons.code_rounded},
    {'name': 'Web Development', 'icon': Icons.web_rounded},
    {'name': 'Data Science', 'icon': Icons.analytics_rounded},
    {'name': 'Mobile Development', 'icon': Icons.phone_android_rounded},
    {'name': 'DevOps & Cloud', 'icon': Icons.cloud_rounded},
    {'name': 'Cybersecurity', 'icon': Icons.security_rounded},
    {'name': 'Machine Learning', 'icon': Icons.psychology_rounded},
    {'name': 'Database Systems', 'icon': Icons.storage_rounded},
    {'name': 'UI/UX Design', 'icon': Icons.design_services_rounded},
    {'name': 'Game Development', 'icon': Icons.games_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_canProceed()) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
        _slideController.reset();
        _slideController.forward();
      } else {
        _finish();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _slideController.reset();
      _slideController.forward();
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty;
      case 1:
        return _selectedUniversity != null;
      case 2:
        return true; // Avatar is optional
      case 3:
        return _selectedInterests.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _finish() async {
    setState(() => _isLoading = true);

    try {
      // Convert color to hex string for storage
      final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2)}';

      await _authService.createUserProfile(
        uid: widget.uid,
        email: widget.email,
        name: _nameController.text.trim(),
        university: _selectedUniversity ?? 'Not specified',
        bio: _bioController.text.trim(),
        avatarLetter: _selectedAvatar,
        avatarColor: colorHex,
        interests: _selectedInterests,
      );

      // Create default chats for new user
      final defaultChatsService = DefaultChatsService();
      await defaultChatsService.createDefaultChatsIfNeeded(widget.uid);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save profile: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Left Side - Progress
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.auto_stories,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to\nIntoStudy',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Let\'s set up your profile',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Steps
                  _buildStepItem(0, 'Basic Info', 'Tell us about yourself'),
                  _buildStepItem(1, 'University', 'Select your institution'),
                  _buildStepItem(2, 'Avatar', 'Choose your style'),
                  _buildStepItem(3, 'Interests', 'Pick your topics'),
                  
                  const Spacer(),
                  
                  LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Step ${_currentStep + 1} of 4',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Right Side - Content
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(60),
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: FadeTransition(
                          opacity: _slideController,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.1, 0),
                              end: Offset.zero,
                            ).animate(_slideController),
                            child: _buildStepContent(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        TextButton.icon(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back_rounded),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                          ),
                        )
                      else
                        const SizedBox(),
                      ElevatedButton.icon(
                        onPressed: (_canProceed() && !_isLoading) ? _nextStep : null,
                        icon: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                _currentStep == 3 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                              ),
                        label: Text(_currentStep == 3 ? 'Get Started' : 'Continue'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, String subtitle) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? const Color(0xFF4F46E5)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF1E293B) : Colors.grey[600],
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildUniversityStep();
      case 2:
        return _buildAvatarStep();
      case 3:
        return _buildInterestsStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tell us about yourself',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This information will be visible on your profile',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
        
        TextField(
          controller: _nameController,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            labelText: 'Display Name',
            hintText: 'How should we call you?',
            prefixIcon: const Icon(Icons.person_rounded),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        
        TextField(
          controller: _bioController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Bio (Optional)',
            hintText: 'Tell others about your interests...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 70),
              child: Icon(Icons.description_rounded),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your university',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Connect with students from your institution',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
        
        ...(_universities.entries.expand((entry) {
          final city = entry.key;
          final universities = entry.value;
          return [
            Padding(
              padding: const EdgeInsets.only(bottom: 16, top: 16),
              child: Text(
                city,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            ...universities.map((uni) {
              final isSelected = _selectedUniversity == uni;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedUniversity = uni;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF4F46E5) 
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.school_rounded,
                            color: isSelected 
                                ? const Color(0xFF4F46E5) 
                                : Colors.grey[400],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              uni,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected 
                                    ? const Color(0xFF1E293B) 
                                    : Colors.grey[700],
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF4F46E5),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
          ];
        })),
      ],
    );
  }

  Widget _buildAvatarStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your avatar',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pick a letter and color that represents you',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
        
        // Preview
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundColor: _selectedColor,
            child: Text(
              _selectedAvatar,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        
        const Text(
          'Choose Letter',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _avatarOptions.map((letter) {
            final isSelected = _selectedAvatar == letter;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = letter;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? _selectedColor : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? _selectedColor : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 32),
        
        const Text(
          'Choose Color',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _colorOptions.map((color) {
            final isSelected = _selectedColor == color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 32)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What are you interested in?',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select at least one topic to personalize your feed',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 40),
        
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest['name']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest['name']);
                  } else {
                    _selectedInterests.add(interest['name'] as String);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF4F46E5) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      interest['icon'] as IconData,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      interest['name'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        
        if (_selectedInterests.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4F46E5).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF4F46E5),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Great! We\'ll show you content related to ${_selectedInterests.join(", ")}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
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