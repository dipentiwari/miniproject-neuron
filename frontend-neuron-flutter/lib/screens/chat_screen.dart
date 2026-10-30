import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../models/chat_model.dart';
import '../providers/chat_provider.dart';
import '../providers/documents_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_dialogs.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedPrompts = [
    'How is authentication implemented in BloodSync?',
    'Summarize my Machine Learning PDF notes',
    'What tasks are scheduled for today?',
    'Show me the Flutter state management guidelines',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitMessage(String text) {
    if (text.trim().isEmpty) return;
    final chat = context.read<ChatProvider>();
    final docs = context.read<DocumentsProvider>().allDocuments;
    final settings = context.read<SettingsProvider>();

    _inputController.clear();
    chat.sendMessage(
      text,
      responseStyle: settings.aiResponseStyle,
      localDocuments: docs,
    );
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final activeSession = chat.activeSession;
    final messages = activeSession.messages;
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        leading: !isDesktop
            ? Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu, size: 24),
                  tooltip: 'Open Menu',
                  onPressed: () => Scaffold.of(ctx).openDrawer(),
                ),
              )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activeSession.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'NEURON Assistant • Offline Ready',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: 22),
            tooltip: 'Conversation History',
            onPressed: () => _showHistorySheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined, size: 22),
            tooltip: 'New Conversation',
            onPressed: () {
              chat.startNewSession();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Started a new conversation'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Responsive.maxContentWidth),
          child: Column(
            children: [
              // Message list
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyChatView()
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: messages
                              .map((msg) => _buildMessageItem(context, msg))
                              .toList(),
                        ),
                      ),
              ),

              // Loading indicator
              if (chat.isLoading)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'NEURON is thinking...',
                        style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context)),
                      ),
                    ],
                  ),
                ),

              // Input Bar with Aligned Attachment, Mic, and Send
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: AppTheme.navSurface(context),
                  border: Border(top: BorderSide(color: AppTheme.border(context))),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, size: 22),
                        tooltip: 'Attach Note / Document',
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        constraints: const BoxConstraints(),
                        onPressed: () => AppDialogs.showDocumentSheet(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.card(context),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.border(context)),
                          ),
                          child: TextField(
                            controller: _inputController,
                            maxLines: 4,
                            minLines: 1,
                            textInputAction: TextInputAction.send,
                            onSubmitted: _submitMessage,
                            decoration: const InputDecoration(
                              hintText: 'Ask NEURON anything...',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.mic_none, size: 22),
                        tooltip: 'Voice Note (Simulated)',
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Listening... Voice input simulated.'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          tooltip: 'Send',
                          padding: EdgeInsets.zero,
                          onPressed: () => _submitMessage(_inputController.text),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyChatView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.psychology, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'What would you like to know?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'NEURON retrieves answers directly from your connected documents, code repositories, notes, and tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.secondaryText(context)),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Suggested questions:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 10),
            ..._suggestedPrompts.map((prompt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _submitMessage(prompt),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.card(context),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border(context)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 16, color: AppColors.primaryLight),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(prompt, style: const TextStyle(fontSize: 12)),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatMessage msg) {
    final timeStr = DateFormat('hh:mm a').format(msg.timestamp);

    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(4),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primaryLight.withValues(alpha: 0.3),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ),
      );
    }

    // Assistant message
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: AppColors.purpleGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.psychology, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.card(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(
                  color: msg.isError
                      ? AppColors.error.withValues(alpha: 0.4)
                      : AppTheme.border(context),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (msg.isSimulated)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline, size: 12, color: AppColors.warning),
                          SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Offline Demo Simulation • Connect FastAPI in Settings',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppTheme.primaryText(context),
                    ),
                  ),

                  // Sources citations
                  if (msg.sources.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Referenced Sources:',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: msg.sources.map((src) {
                        return InkWell(
                          onTap: () {
                            // Find matching document if exists
                            final docs = context.read<DocumentsProvider>().allDocuments;
                            final match = docs.where((d) => d.title.toLowerCase() == src.title.toLowerCase());
                            if (match.isNotEmpty) {
                              AppDialogs.showDocumentDetail(context, match.first);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Source: ${src.title} (${src.source})'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.link, size: 12, color: AppColors.primaryLight),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    src.title,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        timeStr,
                        style: TextStyle(fontSize: 10, color: AppTheme.secondaryText(context)),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.copy, size: 14),
                            tooltip: 'Copy Message',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: msg.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Message copied to clipboard'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 16),
                            tooltip: 'Retry Response',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final docs = context.read<DocumentsProvider>().allDocuments;
                              final settings = context.read<SettingsProvider>();
                              context.read<ChatProvider>().retryLastMessage(
                                    responseStyle: settings.aiResponseStyle,
                                    localDocuments: docs,
                                  );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showHistorySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final chat = ctx.watch<ChatProvider>();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.65,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Conversations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      chat.startNewSession();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('New Chat'),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: chat.sessions.length,
                  itemBuilder: (context, i) {
                    final session = chat.sessions[i];
                    final isCurrent = session.id == chat.activeSessionId;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isCurrent ? Icons.chat : Icons.chat_bubble_outline,
                        color: isCurrent ? AppColors.primaryLight : Colors.grey,
                        size: 20,
                      ),
                      title: Text(
                        session.title,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                          color: isCurrent ? AppColors.primaryLight : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        '${session.messages.length} messages • ${DateFormat('MMM d').format(session.createdAt)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: () {
                          AppDialogs.showConfirmDialog(
                            context,
                            title: 'Delete Conversation?',
                            message: 'Are you sure you want to delete "${session.title}"?',
                            confirmLabel: 'Delete',
                            isDestructive: true,
                            onConfirm: () => chat.deleteSession(session.id),
                          );
                        },
                      ),
                      onTap: () {
                        chat.selectSession(session.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
