import 'package:flutter/material.dart';
import 'package:viam_sdk/protos/app/app.dart';

import '../../../utils.dart';
import 'robot_status_chip.dart';

class RobotListItem extends StatelessWidget {
  RobotListItem({
    super.key,
    required this.machineSummary,
    this.organization,
    required this.locationName,
    required this.onTap,
  }) : // Grabbing the first part summary, there isn't currently a way to tell which is the main part
       mainPartSummary = machineSummary.partSummaries.first,
       state = calculateRobotStatus(machineSummary.partSummaries.first);

  final MachineSummary machineSummary;
  final PartSummary mainPartSummary;
  final RobotStatus state;
  final String locationName;
  final Organization? organization;
  final VoidCallback onTap;

  /// Calculates the robot status based on the last online time of the part summary
  static RobotStatus calculateRobotStatus(PartSummary partSummary) {
    final seconds = partSummary.lastOnline.seconds.toInt();
    final actual =
        DateTime.now().microsecondsSinceEpoch / Duration.microsecondsPerSecond;

    if ((actual - seconds) < 10) {
      return RobotStatus.online;
    }

    if (!partSummary.lastOnline.hasNanos() &&
        !partSummary.lastOnline.hasSeconds()) {
      return RobotStatus.awaitingSetup;
    }

    if ((actual - seconds) > 10) return RobotStatus.offline;

    return RobotStatus.loading;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      height: 100,
      child: Card.outlined(
        child: ListTile(
          onTap:
              (state == RobotStatus.offline ||
                      state == RobotStatus.awaitingSetup)
                  ? onTap
                  : null,
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$locationName - ${machineSummary.machineName}',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                // softwrap and overlfow set to handle long location & machiname names
                softWrap: false,
                overflow: TextOverflow.fade,
              ),
              SizedBox(height: 4),
              Row(
                spacing: 8.0,
                children: [
                  RobotStateChip(state: state),
                  if (state == RobotStatus.offline)
                    Text(
                      'Active ${dateTimeToDate(lastAccessToDateTime(mainPartSummary.lastOnline))} ago',
                      style: textTheme.bodyMedium,
                    ),
                ],
              ),
            ],
          ),
          contentPadding: EdgeInsets.fromLTRB(16, 10, 8, 14),
        ),
      ),
    );
  }
}
