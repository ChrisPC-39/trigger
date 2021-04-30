import 'package:hive/hive.dart';

part 'question.g.dart';

@HiveType(typeId: 1)
class Question {
  @HiveField(0)
  final String question;

  @HiveField(1)
  final String answer;

  @HiveField(2)
  final int day;

  @HiveField(3)
  final int month;

  @HiveField(4)
  final int year;

  Question(this.question, this.answer, this.day, this.month, this.year);
}