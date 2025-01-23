import 'package:hive_flutter/adapters.dart';

part 'word_file_model.g.dart';

@HiveType(typeId: 1)
class WordFile{

  @HiveField(0)
  final String id;
  @HiveField(1)
  final String word;
  @HiveField(2)
  final String wordExplanation;
  @HiveField(3)
  final DateTime timeCreated;
  @HiveField(4)
  final String targetLanguage;
  @HiveField(5)
  final String wordLanguage;

  WordFile(
    {
      required this.id,
      required this.word,
      required this.wordExplanation,
      required this.timeCreated,
      required this.targetLanguage,
      required this.wordLanguage
    }
  );

}