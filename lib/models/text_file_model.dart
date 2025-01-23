import 'package:hive_flutter/adapters.dart';
part 'text_file_model.g.dart';

@HiveType(typeId: 0)
class TextFile{

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String icerik;
  @HiveField(2)
  final DateTime timeCreated;
  @HiveField(3)
  final String targetLanguage;
  @HiveField(4)
  final String textLanguage;
  @HiveField(5)
  final String title;
  @HiveField(6)
  final double offset;


  TextFile(
    {
      required this.id,
      required this.icerik,
      required this.timeCreated,
      required this.targetLanguage,
      required this.textLanguage,
      required this.title,
      required this.offset
    }
  );

}