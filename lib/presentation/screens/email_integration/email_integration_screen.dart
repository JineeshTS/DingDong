import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/email_integration.dart';
import '../../providers/email_integration/email_integration.dart';

/// Email Integration Screen
///
/// Displays connected email integrations (Gmail, Outlook) and provides
/// functionality to:
/// - Connect/disconnect email accounts
/// - View and manage emails
/// - Create tasks from emails
/// - Configure sync settings
class EmailIntegrationScreen extends ConsumerStatefulWidget {
  const EmailIntegrationScreen({super.key});

  @override
  ConsumerState<EmailIntegrationScreen> createState() =>
      _EmailIntegrationScreenState();
}

class _EmailIntegrationScreenState
    extends ConsumerState<EmailIntegrationScreen> {
  @override
  Widget build(BuildContext context) {
    final emailState = ref.watch(emailIntegrationNotifierProvider);
    final emailNotifier =
        ref.read(emailIntegrationNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Integrations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: emailState.isSyncing
                ? null
                : () => emailNotifier.syncEmails(),
            tooltip: 'Sync Emails',
          ),
        ],
      ),
      body: emailState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Error banner
                if (emailState.error != null)
                  MaterialBanner(
                    content: Text(emailState.error!),
                    backgroundColor: Colors.red.shade100,
                    actions: [
                      TextButton(
                        onPressed: () => emailNotifier.clearError(),
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),

                // Connected integrations section
                _buildIntegrationsSection(emailState, emailNotifier),

                const Divider(),

                // Emails section
                if (emailState.activeIntegration != null)
                  Expanded(
                    child: _buildEmailsSection(emailState, emailNotifier),
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Connect an email account to get started',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showConnectDialog(context, emailNotifier),
        icon: const Icon(Icons.add),
        label: const Text('Connect Email'),
      ),
    );
  }

  // ============================================================================
  // UI Sections
  // ============================================================================

  Widget _buildIntegrationsSection(
    EmailIntegrationState state,
    EmailIntegrationNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connected Accounts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (state.integrations.isEmpty)
            const Text(
              'No email accounts connected',
              style: TextStyle(color: Colors.grey),
            )
          else
            ...state.integrations.map((integration) =>
                _buildIntegrationCard(integration, state, notifier)),
        ],
      ),
    );
  }

  Widget _buildIntegrationCard(
    EmailIntegration integration,
    EmailIntegrationState state,
    EmailIntegrationNotifier notifier,
  ) {
    final isActive = state.activeIntegration?.id == integration.id;
    final icon = integration.provider == EmailProvider.gmail
        ? Icons.email
        : Icons.mail_outline;
    final providerName = integration.provider.name.toUpperCase();

    return Card(
      color: isActive ? Colors.blue.shade50 : null,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.blue : Colors.grey),
        title: Text(integration.emailAddress),
        subtitle: Text(providerName),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (integration.isConnected)
              Chip(
                label: const Text('Connected', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.green.shade100,
              ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () =>
                  _showIntegrationSettings(integration, notifier),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _confirmDisconnect(integration, notifier),
            ),
          ],
        ),
        onTap: () => notifier.setActiveIntegration(integration),
      ),
    );
  }

  Widget _buildEmailsSection(
    EmailIntegrationState state,
    EmailIntegrationNotifier notifier,
  ) {
    return Column(
      children: [
        // Sync status
        _buildSyncStatus(state, notifier),

        const Divider(),

        // Email list
        Expanded(
          child: state.isFetchingEmails
              ? const Center(child: CircularProgressIndicator())
              : state.emails.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No emails found'),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => notifier.fetchEmails(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Fetch Emails'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.emails.length,
                      itemBuilder: (context, index) {
                        final email = state.emails[index];
                        return _buildEmailCard(email, notifier);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildSyncStatus(
    EmailIntegrationState state,
    EmailIntegrationNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Emails',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (state.isSyncing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (state.lastSyncedAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Last synced: ${_formatDateTime(state.lastSyncedAt!)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          if (state.lastSyncResult != null) ...[
            const SizedBox(height: 4),
            Text(
              '${state.lastSyncResult!.emailsProcessed} emails processed, '
              '${state.lastSyncResult!.tasksCreated} tasks created',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmailCard(Email email, EmailIntegrationNotifier notifier) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(email.from[0].toUpperCase()),
        ),
        title: Text(
          email.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              email.from,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (email.timestamp != null)
              Text(
                _formatDateTime(email.timestamp!),
                style: const TextStyle(fontSize: 11),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (email.isStarred)
              const Icon(Icons.star, color: Colors.amber, size: 16),
            if (email.attachments.isNotEmpty)
              const Icon(Icons.attach_file, size: 16),
            IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: () => _createTaskFromEmail(email, notifier),
              tooltip: 'Create Task',
            ),
          ],
        ),
        onTap: () => _showEmailDetail(email),
      ),
    );
  }

  // ============================================================================
  // Dialog Methods
  // ============================================================================

  void _showConnectDialog(
    BuildContext context,
    EmailIntegrationNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Email Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Gmail'),
              onTap: () {
                Navigator.pop(context);
                notifier.connectIntegration(EmailProvider.gmail);
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Outlook'),
              onTap: () {
                Navigator.pop(context);
                notifier.connectIntegration(EmailProvider.outlook);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showIntegrationSettings(
    EmailIntegration integration,
    EmailIntegrationNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Integration Settings'),
        content: const Text(
          'Integration settings would be configured here.\n\n'
          'Options include:\n'
          '• Email forwarding rules\n'
          '• Auto-create tasks settings\n'
          '• Label/folder filtering\n'
          '• Sync frequency',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmDisconnect(
    EmailIntegration integration,
    EmailIntegrationNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect Email Account'),
        content: Text(
          'Are you sure you want to disconnect ${integration.emailAddress}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.disconnectIntegration(integration.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  void _showEmailDetail(Email email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(email.subject),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('From: ${email.from}'),
              const SizedBox(height: 8),
              if (email.to.isNotEmpty)
                Text('To: ${email.to.join(', ')}'),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(email.bodyPlainText ?? email.body ?? 'No content'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _createTaskFromEmail(
    Email email,
    EmailIntegrationNotifier notifier,
  ) {
    // Show confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Task'),
        content: Text('Create a task from email:\n\n"${email.subject}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.createTaskFromEmail(emailId: email.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task created from email')),
              );
            },
            child: const Text('Create Task'),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
