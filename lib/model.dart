import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class Data extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String director;

  @HiveField(2)
  String image;

  @HiveField(3)
  final bool isdone = true;

  Data({this.name, this.director, this.image});
}
