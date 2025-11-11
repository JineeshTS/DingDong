/// Workspace Providers Barrel File
///
/// This file exports all workspace-related providers, notifiers, and states
/// for convenient importing throughout the application.
///
/// The workspace module provides comprehensive team workspace management including:
/// - Workspace creation and management (10 use cases integrated)
/// - Member management with role-based access control
/// - Invitation system with acceptance flow
/// - Ownership transfer capabilities
/// - Workspace statistics and metrics
/// - Multiple derived providers for common queries
///
/// Usage:
/// ```dart
/// import 'package:dingdong/presentation/providers/workspace/workspace.dart';
///
/// // Now you can use:
/// // - workspaceNotifierProvider
/// // - activeWorkspacesProvider
/// // - teamWorkspacesProvider
/// // - personalWorkspacesProvider
/// // - workspaceMembersProvider
/// // - pendingMembersProvider
/// // - workspaceByIdProvider
/// // - etc.
/// ```

export 'workspace_notifier.dart';
export 'workspace_providers.dart';
export 'workspace_state.dart';
