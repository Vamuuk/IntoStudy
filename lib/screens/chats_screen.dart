import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  int? _selectedChatIndex;
  final TextEditingController _messageController = TextEditingController();
  
  final List<Map<String, dynamic>> _chats = [
    {
      'id': 1,
      'name': 'Web Development Study Group',
      'avatar': 'W',
      'color': const Color(0xFF4F46E5),
      'lastMessage': 'Anyone know good React tutorials?',
      'time': '2m ago',
      'unread': 3,
      'messages': [
        {'sender': 'Alex', 'text': 'Hey everyone!', 'time': '10:30', 'isMe': false},
        {'sender': 'You', 'text': 'Hi Alex! How\'s it going?', 'time': '10:32', 'isMe': true},
        {'sender': 'Sarah', 'text': 'Working on my portfolio site', 'time': '10:35', 'isMe': false},
        {'sender': 'Alex', 'text': 'Anyone know good React tutorials?', 'time': '10:40', 'isMe': false},
      ],
    },
    {
      'id': 2,
      'name': 'Data Science & AI',
      'avatar': 'D',
      'color': const Color(0xFF10B981),
      'lastMessage': 'Check out this ML model I built',
      'time': '1h ago',
      'unread': 0,
      'messages': [
        {'sender': 'Mike', 'text': 'Who\'s taking ML course?', 'time': '09:15', 'isMe': false},
        {'sender': 'You', 'text': 'I am! It\'s challenging but fun', 'time': '09:20', 'isMe': true},
        {'sender': 'Emma', 'text': 'Check out this ML model I built', 'time': '09:45', 'isMe': false},
      ],
    },
    {
      'id': 3,
      'name': 'Backend Engineering',
      'avatar': 'B',
      'color': const Color(0xFFF59E0B),
      'lastMessage': 'Docker container is running!',
      'time': '3h ago',
      'unread': 1,
      'messages': [
        {'sender': 'John', 'text': 'Need help with Node.js', 'time': '08:00', 'isMe': false},
        {'sender': 'You', 'text': 'What\'s the issue?', 'time': '08:05', 'isMe': true},
        {'sender': 'John', 'text': 'Docker container is running!', 'time': '08:30', 'isMe': false},
      ],
    },
  ];

  void _createNewChat() {
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create New Chat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Chat Name',
                  hintText: 'e.g., Mobile Development',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isNotEmpty) {
                        setState(() {
                          _chats.add({
                            'id': _chats.length + 1,
                            'name': nameController.text,
                            'avatar': nameController.text[0].toUpperCase(),
                            'color': const Color(0xFFEC4899),
                            'lastMessage': 'Chat created',
                            'time': 'now',
                            'unread': 0,
                            'messages': [],
                          });
                        });
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty && _selectedChatIndex != null) {
      setState(() {
        final messages = _chats[_selectedChatIndex!]['messages'] as List;
        messages.add({
          'sender': 'You',
          'text': _messageController.text,
          'time': TimeOfDay.now().format(context),
          'isMe': true,
        });
        _chats[_selectedChatIndex!]['lastMessage'] = _messageController.text;
        _chats[_selectedChatIndex!]['time'] = 'now';
        _messageController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // Chats List
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                right: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      IconButton(
                        onPressed: _createNewChat,
                        icon: const Icon(Icons.add_circle, color: Color(0xFF4F46E5)),
                        iconSize: 28,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search chats...',
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      final isSelected = _selectedChatIndex == index;
                      
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedChatIndex = index;
                              _chats[index]['unread'] = 0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? const Color(0xFF4F46E5).withOpacity(0.05)
                                  : Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: isSelected 
                                      ? const Color(0xFF4F46E5)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: chat['color'],
                                  child: Text(
                                    chat['avatar'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              chat['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15,
                                                color: Color(0xFF1E293B),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            chat['time'],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              chat['lastMessage'],
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (chat['unread'] > 0)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF4F46E5),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                '${chat['unread']}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Chat Messages
          Expanded(
            child: _selectedChatIndex == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Select a chat to start messaging',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Chat Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: _chats[_selectedChatIndex!]['color'],
                              child: Text(
                                _chats[_selectedChatIndex!]['avatar'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _chats[_selectedChatIndex!]['name'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  Text(
                                    '${(_chats[_selectedChatIndex!]['messages'] as List).length} members',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.info_outline, color: Colors.grey[400]),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      
                      // Messages
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: (_chats[_selectedChatIndex!]['messages'] as List).length,
                          itemBuilder: (context, index) {
                            final message = (_chats[_selectedChatIndex!]['messages'] as List)[index];
                            final isMe = message['isMe'] as bool;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                mainAxisAlignment: isMe 
                                    ? MainAxisAlignment.end 
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe) ...[
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(0xFF4F46E5).withOpacity(0.1),
                                      child: Text(
                                        message['sender'][0],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: isMe 
                                          ? CrossAxisAlignment.end 
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if (!isMe)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              message['sender'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isMe 
                                                ? const Color(0xFF4F46E5)
                                                : Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: isMe 
                                                ? null 
                                                : Border.all(color: Colors.grey[200]!),
                                          ),
                                          child: Text(
                                            message['text'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isMe ? Colors.white : const Color(0xFF1E293B),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          message['time'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[400],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Message Input
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: TextField(
                                  controller: _messageController,
                                  decoration: const InputDecoration(
                                    hintText: 'Type a message...',
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF4F46E5),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.send_rounded, color: Colors.white),
                                onPressed: _sendMessage,
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
}