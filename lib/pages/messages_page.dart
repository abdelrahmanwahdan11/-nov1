import 'package:flutter/material.dart';

import '../controllers/controllers_scope.dart';
import '../l10n/app_localizations.dart';
import '../models/message_thread.dart';
import '../theme/app_theme.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _composerController = TextEditingController();
  String? _selectedThreadId;

  @override
  void dispose() {
    _composerController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (_selectedThreadId == null && arg is String) {
      _selectedThreadId = arg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scope = ControllersScope.of(context);
    final messagesController = scope.messagesController;
    final localization = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = theme.extension<JewelThemeTokens>();

    return AnimatedBuilder(
      animation: messagesController,
      builder: (context, _) {
        final threads = messagesController.threads;
        if (threads.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text(localization.translate('messages'))),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  localization.translate('noMessages'),
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final currentThread = _resolveThread(threads);
        final reversedMessages = currentThread?.messages.reversed.toList() ?? const [];

        return Scaffold(
          appBar: AppBar(title: Text(localization.translate('messages'))),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: DropdownButtonFormField<String>(
                  value: currentThread?.itemId,
                  items: threads
                      .map(
                        (thread) => DropdownMenuItem(
                          value: thread.itemId,
                          child: Text(thread.itemName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedThreadId = value),
                  decoration: InputDecoration(
                    labelText: localization.translate('conversationWith'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  reverse: true,
                  itemCount: reversedMessages.length,
                  itemBuilder: (context, index) {
                    final message = reversedMessages[index];
                    final isBuyer = message.isBuyer;
                    final alignment = isBuyer ? Alignment.centerRight : Alignment.centerLeft;
                    final bubbleColor = isBuyer
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : theme.colorScheme.surface.withOpacity(0.85);
                    return Align(
                      alignment: alignment,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                        ),
                        child: Text(message.content, style: theme.textTheme.bodyMedium),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _composerController,
                          decoration: InputDecoration(
                            hintText: localization.translate('messagePlaceholder'),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(tokens?.pillRadius ?? 18),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: currentThread == null
                            ? null
                            : () {
                                final text = _composerController.text.trim();
                                if (text.isEmpty) return;
                                messagesController.sendMessage(currentThread.itemId, text);
                                _composerController.clear();
                              },
                        child: Text(localization.translate('send')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  MessageThread? _resolveThread(List<MessageThread> threads) {
    if (_selectedThreadId != null) {
      final match = threads.where((thread) => thread.itemId == _selectedThreadId).toList();
      if (match.isNotEmpty) {
        return match.first;
      }
    }
    _selectedThreadId = threads.first.itemId;
    return threads.first;
  }
}
