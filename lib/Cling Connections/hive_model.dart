import 'package:hive/hive.dart';

part 'hive_model.g.dart';
 // 🔁 Code generator will create this

@HiveType(typeId: 0)
class MinuteData extends HiveObject {
  @HiveField(0)
  final Map<String, dynamic> data;

  MinuteData({required this.data});
}
