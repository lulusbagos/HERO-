import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
    required this.title,
    this.route,
  });

  static const routeName = '/menu';
  final String title;
  final String? route;

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final TextEditingController _scheduleReasonController =
      TextEditingController();
  final TextEditingController _registrationNameController =
      TextEditingController();

  static const _notifications = <_NotificationItem>[
    _NotificationItem(
      title: 'Approval Reminder',
      htmlMessage: '<b>Action needed:</b> Please review leave request #310.',
      isUnread: true,
    ),
    _NotificationItem(
      title: 'Company News',
      htmlMessage:
          '<p>Portal update completed.<br/>New attendance insights are live.</p>',
    ),
  ];

  @override
  void dispose() {
    _scheduleReasonController.dispose();
    _registrationNameController.dispose();
    super.dispose();
  }

  void _showSubmittedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        child: SingleChildScrollView(
          key: ValueKey(widget.route ?? widget.title),
          padding: const EdgeInsets.all(16),
          child: content,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (widget.route) {
      case '/profile':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Employee Profile', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Employee ID'),
                subtitle: const Text('EMP-000123'),
                trailing: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: const Icon(Icons.qr_code_2_rounded, size: 42),
                ),
              ),
            ),
          ],
        );
      case '/work-schedule-revision':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Schedule Revision Request',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _scheduleReasonController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'Explain requested schedule changes',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () {
                    _showSubmittedMessage('Schedule revision request submitted');
                  },
                  icon: const Icon(Icons.send_rounded),
                  label: const Text('Submit Request'),
                ),
              ],
            ),
          ),
        );
      case '/her-registration':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HER Registration', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                TextField(
                  controller: _registrationNameController,
                  decoration: const InputDecoration(
                    labelText: 'Candidate Name',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    _showSubmittedMessage('HER registration saved');
                  },
                  child: const Text('Save Registration'),
                ),
              ],
            ),
          ),
        );
      case '/birthdays':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Birthdays", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            ...const [
              ListTile(
                leading: Icon(Icons.cake_outlined),
                title: Text('Rani Kusuma'),
                subtitle: Text('Mining Operation • 29 years old'),
              ),
              ListTile(
                leading: Icon(Icons.cake_outlined),
                title: Text('Dimas Prasetyo'),
                subtitle: Text('HRGA • 32 years old'),
              ),
            ],
          ],
        );
      case '/notifications':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Center',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ..._notifications.map((notification) {
              return Card(
                color: notification.isUnread
                    ? Theme.of(context).colorScheme.primaryContainer.withValues(
                        alpha: 0.5,
                      )
                    : null,
                child: ListTile(
                  key: notification.isUnread
                      ? const ValueKey('unread-notification')
                      : null,
                  title: Text(notification.title),
                  subtitle: _HtmlMessageText(html: notification.htmlMessage),
                ),
              );
            }),
          ],
        );
      default:
        return Center(
          child: Text(
            '${widget.title} module is ready for lazy-loaded feature implementation.',
            textAlign: TextAlign.center,
          ),
        );
    }
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.htmlMessage,
    this.isUnread = false,
  });

  final String title;
  final String htmlMessage;
  final bool isUnread;
}

class _HtmlMessageText extends StatelessWidget {
  const _HtmlMessageText({required this.html});

  final String html;

  @override
  Widget build(BuildContext context) {
    final clean = html
        .replaceAll('<br/>', '\n')
        .replaceAll('<br>', '\n')
        .replaceAll('<p>', '')
        .replaceAll('</p>', '\n');
    final spans = <TextSpan>[];

    final tagRegex = RegExp(r'<[^>]+>');
    var isBold = false;
    var isItalic = false;
    var cursor = 0;

    void appendText(String text) {
      if (text.isEmpty) return;
      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      );
    }

    for (final match in tagRegex.allMatches(clean)) {
      appendText(clean.substring(cursor, match.start));
      final tag = match.group(0)!.toLowerCase();
      switch (tag) {
        case '<b>':
        case '<strong>':
          isBold = true;
          break;
        case '</b>':
        case '</strong>':
          isBold = false;
          break;
        case '<i>':
        case '<em>':
          isItalic = true;
          break;
        case '</i>':
        case '</em>':
          isItalic = false;
          break;
      }
      cursor = match.end;
    }
    appendText(clean.substring(cursor));

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }
}
