import 'package:hive/hive.dart';

part 'setup.g.dart';

@HiveType(typeId: 0)
class Setup {
  @HiveField(0)
  final bool isFirstTime;

  @HiveField(1)
  final bool isSystemThemeSelected;

  Setup({this.isFirstTime, this.isSystemThemeSelected});
}