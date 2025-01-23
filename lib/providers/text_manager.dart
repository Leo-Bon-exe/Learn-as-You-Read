import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:translation_app/models/text_file_model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

var textBox = Hive.box<TextFile>('texts');

final textListProvider =
    StateNotifierProvider<TextFileManager, List<TextFile>>((ref) {
  return TextFileManager([
    if (textBox.isEmpty == false)
      for (int i = 0; i < textBox.length; i++) textBox.getAt(i) as TextFile
  ]);
});

class TextFileManager extends StateNotifier<List<TextFile>> {
  TextFileManager([List<TextFile>? initialNotes]) : super(initialNotes ?? []);

  void createReadingText(
      String icerik, String textLanguage, String targetLanguage, String title) {
    state = [
      TextFile(
          id: UniqueKey().toString(),
          targetLanguage: targetLanguage,
          icerik: icerik,
          textLanguage: textLanguage,
          timeCreated: DateTime.now(),
          title: title,
          offset: 0.0),
      ...state
    ];
    textBox.clear();
    textBox.addAll(state);
  }

  void setOffset(String id, double offset) {
    state = [
      for (var textFile in state)
        if (textFile.id == id)
          TextFile(
              id: textFile.id,
              targetLanguage: textFile.targetLanguage,
              icerik: textFile.icerik,
              textLanguage: textFile.textLanguage,
              timeCreated: textFile.timeCreated,
              title: textFile.title,
              offset: offset)
        else
          textFile
    ];
    textBox.clear();
    textBox.addAll(state);
  }

  void search(String text) {
    state = [
      for (var textFile in state)
        if (textFile.title.toLowerCase().contains(text)) textFile,
      for (var textFile in state)
        if (!textFile.title.toLowerCase().contains(text)) textFile
    ];
  }

  void filterByLanguage([String? textLanguage, String? targetLanguage]) {
    Iterable<TextFile> bothLanguageItems = state.where((textFile) =>
        textFile.targetLanguage == targetLanguage &&
        textFile.textLanguage == textLanguage);
    Iterable<TextFile> wordLanguageItems = state.where((textFile) =>
        textFile.textLanguage == textLanguage &&
        targetLanguage != textFile.targetLanguage);
    Iterable<TextFile> targetLanguageItems = state.where((textFile) =>
        textFile.targetLanguage == targetLanguage &&
        textLanguage != textFile.textLanguage);
    Iterable<TextFile> notMatchingItems = state.where((textFile) =>
        textFile.targetLanguage != targetLanguage &&
        textFile.textLanguage != textLanguage);
    state = [
      for (var textFile in bothLanguageItems) textFile,
      for (var textFile in wordLanguageItems) textFile,
      for (var textFile in targetLanguageItems) textFile,
      for (var textFile in notMatchingItems) textFile,
    ];
  }


  void latest() {
    state = state.sorted((a, b) => b.timeCreated.compareTo(a.timeCreated));
  }

  void oldest() {
    state = state.sorted((a, b) => a.timeCreated.compareTo(b.timeCreated));
  }

  void latestRead(String id) {
    state = [
      for (var textFile in state)
        if (textFile.id == id)
          TextFile(
              id: textFile.id,
              targetLanguage: textFile.targetLanguage,
              icerik: textFile.icerik,
              textLanguage: textFile.textLanguage,
              timeCreated: DateTime.now(),
              title: textFile.title,
              offset: textFile.offset)
        else
          textFile
    ];
    latest();
    textBox.clear();
    textBox.addAll(state);
  }

  void remove(String id) {
    state = state.where((element) => element.id != id).toList();
    textBox.clear();
    textBox.addAll(state);
  }
}
