import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 2)
class Reminder {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  Reminder(this.hour, this.minute);
}