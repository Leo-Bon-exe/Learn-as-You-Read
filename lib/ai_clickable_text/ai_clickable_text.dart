import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:ndialog/ndialog.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translation_app/models/word_file_model.dart';

import 'package:translation_app/pages/settings_page.dart';
import 'package:translation_app/providers/text_manager.dart';
import 'package:translation_app/providers/word_manager.dart';

final client = OpenAIClient(
    apiKey: dotenv.env["API_KEY"],
    organization: dotenv.env["ORG_NAME"]);

StateProvider<String> translatedWord = StateProvider<String>((ref) {
  return "";
});

StateProvider<bool> loadingIndicator = StateProvider<bool>((ref) {
  return false;
});

StateProvider<bool> gestureLoad = StateProvider<bool>((ref) {
  return false;
});

StateProvider<bool> wordAvailable = StateProvider<bool>((ref) {
  return false;
});

StateProvider<ScrollController> scrollController =
    StateProvider<ScrollController>((ref) {
  return ScrollController(
    initialScrollOffset: ref.watch(scrollOffset),
  );
});

StateProvider<double> scrollOffset = StateProvider<double>((ref) {
  return 0.0;
});

StateProvider<List<InlineSpan>> simpleWordList =
    StateProvider<List<InlineSpan>>((ref) {
  return [];
});

StateProvider<List<InlineSpan>> navigationWordList =
    StateProvider<List<InlineSpan>>((ref) {
  return [];
});

class ClickableTextView extends ConsumerStatefulWidget {
  const ClickableTextView(this.index, {super.key});
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ClickableTextViewState();
}

class _ClickableTextViewState extends ConsumerState<ClickableTextView> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification) {
          ref.read(textListProvider.notifier).setOffset(
              ref.watch(textListProvider)[widget.index].id,
              ref.watch(scrollController).offset.toDouble());
        }

        return true;
      },
      child: SingleChildScrollView(
        controller: ref.watch(scrollController),
        physics: ref.watch(gestureLoad)
            ? const NeverScrollableScrollPhysics()
            : const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: 3.h, bottom: 3.h, left: 4.w, right: 4.w),
        child: RichText(
          text: TextSpan(
              style: TextStyle(
                  fontFamily: ref.watch(textFont),
                  fontSize: ref.watch(fontSize),
                  color: Color(ref.watch(colorSchemeText))),
              children: ref.watch(gestureLoad)
                  ? ref.watch(navigationWordList)
                  : ref.watch(simpleWordList)),
        ),
      ),
    );
  }
}

void wordDialog(WidgetRef ref, String word, int index, context,
    [WordFile? existedWord]) {
  NDialog(
    dialogStyle: DialogStyle(
        elevation: 0, backgroundColor: Color(ref.watch(colorSchemeBackground))),
    actions: [
      SizedBox(
        height: 55.h,
        width: 100.w,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnaKelime(index, word),
              Padding(
                padding: EdgeInsets.only(left: 1.5.w, right: 1.5.w),
                child: Text(
                  ref.watch(wordAvailable)
                      ? existedWord!.wordExplanation
                      : ref.watch(translatedWord),
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: ref.watch(textFont),
                      fontSize: 19,
                      color: Color(ref.watch(colorSchemeText))),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  ).show(context);
  ref.read(gestureLoad.notifier).state = true;
}

class AnaKelime extends ConsumerWidget {
  const AnaKelime(this.index, this.word, {super.key});
  final int index;
  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h, top: 1.h, left: 3.w, right: 3.w),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(right: 1.w),
                scrollDirection: Axis.horizontal,
                child: Text(word,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: ref.watch(textFont),
                        fontSize: 25,
                        color: Color(ref.watch(colorSchemeText)))),
              ),
            ),
          ),
          IconButton(
              onPressed: () {
                if (!ref.watch(wordAvailable)) {
                  ref.read(wordListProvider.notifier).addToWords(
                        word,
                        ref.watch(translatedWord),
                        ref.watch(textListProvider)[index].textLanguage,
                        ref.watch(textListProvider)[index].targetLanguage,
                      );
                  checkWordAvailable(ref, word, index);
                } else {
                  ref.read(wordListProvider.notifier).remove(
                      word,
                      ref.watch(textListProvider)[index].textLanguage,
                      ref.watch(textListProvider)[index].targetLanguage);
                  checkWordAvailable(ref, word, index);
                }
              },
              icon: const BookmarkIcon())
        ],
      ),
    );
  }
}

class BookmarkIcon extends ConsumerStatefulWidget {
  const BookmarkIcon({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BookmarkIconState();
}

class _BookmarkIconState extends ConsumerState<BookmarkIcon> {
  @override
  Widget build(BuildContext context) {
    return Icon(
      ref.watch(wordAvailable) ? Icons.bookmark_added : Icons.bookmark_add,
      color: ref.watch(wordAvailable) ? Colors.green : Colors.grey,
    );
  }
}

void checkWordAvailable(WidgetRef ref, String clickedWord, int index) {
  for (WordFile item in ref.watch(wordListProvider)) {
    if (item.word.toLowerCase() == clickedWord.toLowerCase() &&
        item.targetLanguage ==
            ref.watch(textListProvider)[index].targetLanguage &&
        item.wordLanguage == ref.watch(textListProvider)[index].textLanguage) {
      ref.read(wordAvailable.notifier).state = true;
      return;
    }
  }
  ref.read(wordAvailable.notifier).state = false;
}

Future<String> translateWords(
    String word, String textLanguage, String targetLanguage) async {
  final res = await client.createChatCompletion(
    request: CreateChatCompletionRequest(
      model: const ChatCompletionModel.modelId('gpt-4o'),
      maxTokens: 350,
      messages: [
        ChatCompletionMessage.system(
          content:
              'IMPORTANT: disregard the English language I use on user prompt, use the $targetLanguage language when explaining the translation',
        ),
        ChatCompletionMessage.user(
          content: ChatCompletionUserMessageContent.string(
              "Translate this \" $word \" from $textLanguage to $targetLanguage and explain the translation(if word is polysemous, give other meanings too, if its not polysemous then do not). Give different examples in $textLanguage and in parenthesis its translation to $targetLanguage."),
        ),
      ],
      temperature: 0,
    ),
  );
  return res.choices.first.message.content.toString();
}

Future<bool> checkConnection() async {
  final connection = InternetConnection.createInstance(
    customCheckOptions: [
      InternetCheckOption(uri: Uri.parse('https://api.openai.com/v1')),
    ],
  );

  return connection.hasInternetAccess;
}
