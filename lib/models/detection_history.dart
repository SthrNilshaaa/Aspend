import 'package:hive/hive.dart';

part 'detection_history.g.dart';

@HiveType(typeId: 5)
class DetectionHistory extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final String status; // 'detected', 'skipped', 'failed'

  @HiveField(3)
  final String? reason;

  @HiveField(4)
  final String? packageName;

  DetectionHistory({
    required this.text,
    required this.timestamp,
    required this.status,
    this.reason,
    this.packageName,
  });
}
