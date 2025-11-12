import 'package:flutter/material.dart';
import '../../../../domain/entities/focus_session_entity.dart';

/// Session Type Selector Widget
///
/// Allows users to select the type of focus session to start
class SessionTypeSelector extends StatelessWidget {
  final FocusSessionType? currentType;
  final Function(FocusSessionType) onTypeSelected;
  final bool enabled;

  const SessionTypeSelector({
    super.key,
    this.currentType,
    required this.onTypeSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTypeChip(
            context,
            type: FocusSessionType.pomodoro,
            label: 'Pomodoro',
            subtitle: '25 min',
            icon: Icons.timer_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeChip(
            context,
            type: FocusSessionType.shortBreak,
            label: 'Short Break',
            subtitle: '5 min',
            icon: Icons.coffee_rounded,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildTypeChip(
            context,
            type: FocusSessionType.longBreak,
            label: 'Long Break',
            subtitle: '15 min',
            icon: Icons.spa_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required FocusSessionType type,
    required String label,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = currentType == type;
    final theme = Theme.of(context);

    return Material(
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? () => onTypeSelected(type) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 28,
                color: isSelected
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Session Type Quick Start Button
///
/// A simple button for quickly starting a specific session type
class SessionTypeButton extends StatelessWidget {
  final String label;
  final String duration;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const SessionTypeButton({
    super.key,
    required this.label,
    required this.duration,
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: buttonColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      duration,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
