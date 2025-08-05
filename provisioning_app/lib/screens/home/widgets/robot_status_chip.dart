import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

enum RobotStatus {
  online,
  awaitingSetup,
  offline,
  attemptingConnection,
  errorConnecting,
  loading,
}

class RobotStateChip extends StatelessWidget {
  const RobotStateChip({super.key, required this.state});

  final RobotStatus state;

  RobotStateChip.online() : state = RobotStatus.online;
  RobotStateChip.awaitingSetup() : state = RobotStatus.awaitingSetup;
  RobotStateChip.offline() : state = RobotStatus.offline;
  RobotStateChip.attemptingConnection()
    : state = RobotStatus.attemptingConnection;
  RobotStateChip.errorConnecting() : state = RobotStatus.errorConnecting;
  RobotStateChip.loading() : state = RobotStatus.loading;

  @override
  Widget build(BuildContext context) {
    final (color, textColor, label) = switch (state) {
      RobotStatus.online => (
        AppColors.successlight,
        AppColors.successdark,
        'Live',
      ),
      RobotStatus.offline => (AppColors.errorlight, AppColors.error, 'Offline'),
      RobotStatus.attemptingConnection => (
        AppColors.successlight,
        AppColors.successdark,
        'Connecting...',
      ),
      RobotStatus.awaitingSetup || RobotStatus.loading => (
        AppColors.infolight,
        AppColors.infodark,
        'Awaiting setup',
      ),
      RobotStatus.errorConnecting => (
        AppColors.errorlight,
        AppColors.error,
        'Error connecting',
      ),
    };

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
