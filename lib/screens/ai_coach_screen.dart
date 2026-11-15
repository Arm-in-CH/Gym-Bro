import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_tokens.dart';
import '../core/localization/persian_utils.dart';
import '../state/app_state.dart';
import '../models/chat_message.dart';
import 'ai_config_screen.dart';
import '../widgets/adaptive_container.dart';
import '../widgets/empty_state_widget.dart';

class AiCoachScreen extends StatefulWidget {
  final AppState state;

  const AiCoachScreen({super.key, required this.state});

  @override
  State<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends State<AiCoachScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickPrompts = const [
    'برنامه تمرینی امروز من چیه؟',
    'تحلیل پیشرفت و حجم وزنه‌های من',
    'وضعیت کالری و درشت‌مغذی‌های مصرفی امروز',
    'پیشنهاد حرکات جایگزین تمرین سینه در خانه',
    'راهکار بهبود ریکاوری و رشد عضلانی',
  ];

  @override
  void dispose() {
    _textController.dispose();
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

  Future<void> _handleSendMessage([String? overrideText]) async {
    final text = overrideText ?? _textController.text.trim();
    if (text.isEmpty || widget.state.isAiLoading) return;

    if (overrideText == null) {
      _textController.clear();
    }

    _scrollToBottom();
    await widget.state.sendAiMessage(text);
    _scrollToBottom();
  }

  void _showClearHistoryDialog() {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: tokens.cardBackground,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.baseRadius),
        title: Text(
          'پاکسازی تاریخچه گفتگو',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'آیا مایلید تمام پیام‌های قبلی پاک شوند؟ داده‌های ورزشی و بدنی شما در دیتابیس محفوظ خواهند ماند.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: tokens.textMuted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('انصراف', style: TextStyle(color: tokens.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.state.clearChatMessages();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('پاکسازی'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final hasApiKey = widget.state.geminiApiKey.isNotEmpty;
    final messages = widget.state.chatMessages;
    final isLoading = widget.state.isAiLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مربی هوشمند GymBro',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Semantics(
              label: 'وضعیت ارتباط مربی هوشمند',
              value: hasApiKey
                  ? 'متصل با مدل ${widget.state.geminiModel}'
                  : 'قطع ارتباط، نیازمند تنظیم کلید اختصاصی',
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasApiKey ? tokens.lime : tokens.orange,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    hasApiKey ? widget.state.geminiModel : 'نیازمند تنظیم کلید',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep_outlined, color: tokens.textMuted),
            tooltip: 'پاکسازی تاریخچه',
            constraints: const BoxConstraints(
              minWidth: AppSpacing.minTouchTarget,
              minHeight: AppSpacing.minTouchTarget,
            ),
            onPressed: messages.length <= 1 ? null : _showClearHistoryDialog,
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: tokens.lime),
            tooltip: 'تنظیمات هوش مصنوعی',
            constraints: const BoxConstraints(
              minWidth: AppSpacing.minTouchTarget,
              minHeight: AppSpacing.minTouchTarget,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiConfigScreen(state: widget.state),
                ),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: AdaptiveContainer(
          child: Column(
            children: [
              // API key warning banner
              if (!hasApiKey)
                Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: tokens.orange.withOpacity(0.12),
                    borderRadius: AppRadii.mdRadius,
                    border: Border.all(color: tokens.orange.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: tokens.orange, size: 22),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'کلید Google AI Studio وارد نشده است.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AiConfigScreen(state: widget.state),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        style:
                            TextButton.styleFrom(foregroundColor: tokens.lime),
                        child: const Text('تنظیم کلید',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),

              // Quick Prompts Bar
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  itemCount: _quickPrompts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final prompt = _quickPrompts[index];
                    return ActionChip(
                      label: Text(
                        prompt,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      backgroundColor: tokens.cardBackground,
                      side: BorderSide(color: tokens.borderColor),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadii.baseRadius),
                      onPressed:
                          isLoading ? null : () => _handleSendMessage(prompt),
                    );
                  },
                ),
              ),

              Divider(color: tokens.borderColor, height: 1),

              // Messages List
              Expanded(
                child: messages.isEmpty && !isLoading
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.base),
                          child: EmptyStateWidget(
                            icon: Icons.chat_bubble_outline,
                            title: 'گفتگو با مربی هوشمند ورزشی',
                            subtitle:
                                'سؤالات تمرینی، آنالیز غذایی یا تنظیمات برنامه بدنسازی خود را بپرسید یا یکی از گزینه‌های سریع بالا را انتخاب کنید.',
                            actionLabel: 'برنامه تمرینی امروز من چیه؟',
                            onAction: () => _handleSendMessage(
                                'برنامه تمرینی امروز من چیه؟'),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length && isLoading) {
                            return _buildLoadingBubble(context);
                          }
                          final msg = messages[index];
                          return _buildMessageItem(context, msg);
                        },
                      ),
              ),

              // Bottom Input Bar
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: tokens.borderColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: tokens.cardBackground,
                          borderRadius: AppRadii.xlRadius,
                          border: Border.all(color: tokens.borderColor),
                        ),
                        child: Semantics(
                          label: 'متن پیام برای گفتگو با مربی هوشمند جیم‌برو',
                          child: TextField(
                            controller: _textController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _handleSendMessage(),
                            maxLines: 4,
                            minLines: 1,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'از مربی جیم‌برو بپرسید...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: tokens.textMuted,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.base,
                                  vertical: AppSpacing.md),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      decoration: BoxDecoration(
                        color: tokens.lime,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon:
                            Icon(Icons.send_rounded, color: tokens.textOnLime),
                        constraints: const BoxConstraints(
                          minWidth: AppSpacing.minTouchTarget,
                          minHeight: AppSpacing.minTouchTarget,
                        ),
                        onPressed:
                            isLoading ? null : () => _handleSendMessage(),
                        tooltip: 'ارسال',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, ChatMessage msg) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);
    final timeStr = PersianUtils.toPersianDigits(DateFormat('HH:mm').format(msg.timestamp));

    if (msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: tokens.lime.withOpacity(0.18),
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(AppRadii.base),
                    topEnd: Radius.circular(AppRadii.xs),
                    bottomStart: Radius.circular(AppRadii.base),
                    bottomEnd: Radius.circular(AppRadii.base),
                  ),
                  border: Border.all(color: tokens.lime.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      msg.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      timeStr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: tokens.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tokens.cardElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: tokens.lime, size: 18),
            ),
          ],
        ),
      );
    } else {
      // AI or Error Message
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: msg.isError
                    ? tokens.red.withOpacity(0.2)
                    : tokens.lime.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      msg.isError ? tokens.red : tokens.lime.withOpacity(0.4),
                ),
              ),
              child: Icon(
                msg.isError ? Icons.error_outline : Icons.smart_toy,
                color: msg.isError ? tokens.red : tokens.lime,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: msg.isError
                      ? tokens.red.withOpacity(0.1)
                      : tokens.cardBackground,
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(AppRadii.xs),
                    topEnd: Radius.circular(AppRadii.base),
                    bottomStart: Radius.circular(AppRadii.base),
                    bottomEnd: Radius.circular(AppRadii.base),
                  ),
                  border: Border.all(
                    color: msg.isError
                        ? tokens.red.withOpacity(0.5)
                        : tokens.borderColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            msg.isError
                                ? 'خطا در ارتباط'
                                : 'مربی هوشمند جیم‌برو',
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: msg.isError ? tokens.red : tokens.lime,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          timeStr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: tokens.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectableText(
                      msg.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        height: 1.55,
                      ),
                    ),
                    if (msg.isError) ...[
                      const SizedBox(height: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: widget.state.isAiLoading
                            ? null
                            : () {
                                final messages = widget.state.chatMessages;
                                final msgIndex = messages.indexOf(msg);
                                String? retryText;
                                if (msgIndex > 0) {
                                  for (int i = msgIndex - 1; i >= 0; i--) {
                                    if (messages[i].isUser) {
                                      retryText = messages[i].text;
                                      break;
                                    }
                                  }
                                }
                                if (retryText != null && retryText.isNotEmpty) {
                                  _handleSendMessage(retryText);
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: tokens.red,
                          side: BorderSide(color: tokens.red.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('تلاش مجدد'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildLoadingBubble(BuildContext context) {
    final tokens = context.appTokens;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: tokens.lime.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy, color: tokens.lime, size: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: tokens.cardBackground,
              borderRadius: AppRadii.baseRadius,
              border: Border.all(color: tokens.borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  label: 'در حال نگارش پاسخ توسط مربی هوشمند',
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: tokens.lime,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'جیم‌برو در حال بررسی داده‌های بدنی و نگارش پاسخ است...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: tokens.textMuted,
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
