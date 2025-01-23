import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translation_app/models/word_file_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

var wordBox = Hive.box<WordFile>('words');

final wordListProvider =
    StateNotifierProvider<WordFileManager, List<WordFile>>((ref) {
  return WordFileManager([
    if (wordBox.isEmpty == false)
      for (int i = 0; i < wordBox.length; i++) wordBox.getAt(i) as WordFile
  ]);
});

class WordFileManager extends StateNotifier<List<WordFile>> {
  WordFileManager([List<WordFile>? initialNotes]) : super(initialNotes ?? []);

  void addToWords(
    String word,
    String wordExplanation,
    String wordLanguage,
    String targetLanguage,
  ) {
    state = [
      WordFile(
        id: UniqueKey().toString(),
        targetLanguage: targetLanguage,
        wordLanguage: wordLanguage,
        word: word,
        wordExplanation: wordExplanation,
        timeCreated: DateTime.now(),
      ),
      ...state
    ];
    wordBox.clear();
    wordBox.addAll(state);
  }

  void search(String text) {
    state = [
      for (var wordFile in state)
        if (wordFile.word.toLowerCase().contains(text)) wordFile,
      for (var wordFile in state)
        if (wordFile.word.toLowerCase().contains(text) == false) wordFile
    ];
  }

  void filterByLanguage([String? wordLanguage, String? targetLanguage]) {
    Iterable<WordFile> bothLanguageItems = state.where((wordFile) =>
        wordFile.targetLanguage == targetLanguage &&
        wordFile.wordLanguage == wordLanguage);
    Iterable<WordFile> textLanguageItems = state.where((wordFile) =>
        wordFile.wordLanguage == wordLanguage &&
         targetLanguage != wordFile.targetLanguage);
    Iterable<WordFile> targetLanguageItems = state.where((wordFile) =>
        wordFile.targetLanguage == targetLanguage &&
         wordLanguage != wordFile.wordLanguage);
    Iterable<WordFile> notMatchingItems = state.where((wordFile) =>
        wordFile.targetLanguage != targetLanguage &&
        wordFile.wordLanguage != wordLanguage);
    state = [
      for (var wordFile in bothLanguageItems) wordFile,
      for (var wordFile in textLanguageItems) wordFile,
      for (var wordFile in targetLanguageItems) wordFile,
      for (var wordFile in notMatchingItems) wordFile,
    ];
  }


  void latest() {
    state = state.sorted((a, b) => b.timeCreated.compareTo(a.timeCreated));
  }

  void oldest() {
    state = state.sorted((a, b) => a.timeCreated.compareTo(b.timeCreated));
  }

  void remove(String word, String textLanguage, String targetLanguage) {
    state = state
        .where((element) =>
            !(element.word.toLowerCase() == word.toLowerCase() &&
                element.wordLanguage == textLanguage &&
                element.targetLanguage == targetLanguage))
        .toList();
    wordBox.clear();
    wordBox.addAll(state);
  }

  void removeFromPage(String id) {
    state = state.where((element) => element.id != id).toList();
    wordBox.clear();
    wordBox.addAll(state);
  }
}
