import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/services/services.dart';

class AiChatScreen extends StatefulWidget {
  AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  void _sendMessage(MedicateProvider provider) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      provider.sendPatientMessage(text);
      _textController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MedicateProvider>(context);
    final messages = provider.chatMessages;

    // Trigger scroll to bottom on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Chat Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                border: Border(bottom: BorderSide(color: AppTheme.borderCard, width: 1.2)),
              ),
              child: Row(
                children: [
                  // AI Avatar with green dot
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryTeal.withOpacity(0.15),
                          border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
                        ),
                        child: Icon(
                          Icons.insights_rounded,
                          color: AppTheme.primaryCyan,
                          size: 24,
                        ),
                      ),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.cardColor, width: 2),
                        ),
                      )
                    ],
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicate Health Assistant',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Active AI Agent',
                          style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Messages View
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(20.0),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return _buildMessageBubble(msg);
                },
              ),
            ),

            // Input Bar
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      radius: 20,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      borderColor: AppTheme.borderCard,
                      fillColor: Colors.black.withOpacity(0.3),
                      child: TextField(
                        controller: _textController,
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                        onSubmitted: (_) => _sendMessage(provider),
                        decoration: InputDecoration(
                          hintText: 'Describe symptoms (e.g. dry cough, fever)...',
                          hintStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendMessage(provider),
                    child: Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.tealCyanGradient,
                      ),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final bubbleColor = msg.isUser ? AppTheme.primaryTeal.withOpacity(0.2) : AppTheme.cardColor;
    final borderColor = msg.isUser ? AppTheme.primaryTeal.withOpacity(0.4) : AppTheme.borderCard;
    final rList = msg.isUser
        ? const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
          )
        : const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          );

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: FadeInSlide(
        duration: Duration(milliseconds: 400),
        slideOffset: 15,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          margin: EdgeInsets.only(bottom: 16.0),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: rList,
            border: Border.all(color: borderColor, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                msg.text,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14.5, height: 1.4),
              ),
              SizedBox(height: 6),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  _formatTime(msg.timestamp),
                  style: TextStyle(fontSize: 9, color: AppTheme.textSecondary.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final min = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }
}
