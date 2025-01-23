import 'package:collection/collection.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translation_app/ai_clickable_text/ai_clickable_text.dart';
import 'package:translation_app/models/word_file_model.dart';
import 'package:translation_app/pages/reading_page.dart';

import 'package:translation_app/providers/text_manager.dart';
import 'package:translation_app/providers/word_manager.dart';

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromARGB(255, 5, 30, 37),
        body:
            /*Expanded(
      child:*/
            ListView.builder(
                itemBuilder: (context, index) {
                  return Dismissible(
                      direction: DismissDirection.startToEnd,
                      background: const Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            Icon(Icons.arrow_right_alt_sharp)
                          ],
                        ),
                      ),
                      key: Key(ref.watch(textListProvider)[index].id),
                      onDismissed: (direction) {
                        ref
                            .read(textListProvider.notifier)
                            .remove(ref.watch(textListProvider)[index].id);
                      },
                      child: TextPreviewItems(index));
                },
                itemCount: ref.watch(textListProvider).length),
        /* ),*/
      ),
    );
  }
}

class TextPreviewItems extends ConsumerWidget {
  const TextPreviewItems(this.index, {super.key});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(top: 1.h, bottom: 0.1.h, right: 1.w, left: 1.w),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 0.6.w),
        child: ExpansionTileCard(
          initialElevation: 1,
          baseColor: const Color.fromARGB(255, 27, 50, 56),
          expandedColor: const Color.fromARGB(255, 27, 50, 56),
          elevation: 0,
          trailing: ReadTextIcon(index),
          title: Text(
            ref.watch(textListProvider)[index].title,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
          ),
          children: [
            const Divider(
              thickness: 5.0,
              color: Colors.blueGrey,
              height: 1.0,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.h, vertical: 1.w)),
            ),
            Row(
              children: [
                SizedBox(
                  width: 3.w,
                ),
                Text(
                  ref.watch(textListProvider)[index].textLanguage,
                  style: const TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 3.w,
                ),
                const Icon(Icons.translate),
                SizedBox(
                  width: 3.w,
                ),
                Text(
                  ref.watch(textListProvider)[index].targetLanguage,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class ReadTextIcon extends ConsumerWidget {
  const ReadTextIcon(this.index, {super.key});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      child: const Icon(Icons.menu_book_rounded,
          size: 30, color: Color.fromARGB(255, 148, 158, 161)),
      onTap: () {
        ref.read(simpleWordList.notifier).state = [];
        ref.read(navigationWordList.notifier).state = [];
        ref.read(loadingIndicator.notifier).state = false;
        ref.read(absorbState.notifier).state = false;
        ref.read(scrollOffset.notifier).state =
            ref.watch(textListProvider)[index].offset;
        Navigator.of(context).push(animatedRoute(index));
        String initialText = ref.watch(textListProvider)[index].icerik;
        String text = initialText
            .split('\n')
            .map((e) => "$e \u000A")
            .toList()
            .reduce((value, element) => "$value$element");
        ref.read(simpleWordList.notifier).state = text
            .split(' ')
            .map((word) => TextSpan(
                  text: '$word ',
                ))
            .toList();

        ref.read(navigationWordList.notifier).state = text
            .split(' ')
            .map((word) => TextSpan(
                  text: '$word ',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      word = word
                          .replaceAll(
                            RegExp(r"[^a-zA-Z'\p{L}’`]", unicode: true),
                            ' ',
                          )
                          .trim();
                      checkWordAvailable(ref, word, index);

                      WordFile? existedWord;
                      if (ref.watch(wordAvailable)) {
                        existedWord = ref
                            .watch(wordListProvider)
                            .firstWhereOrNull((element) =>
                                element.word.toLowerCase() ==
                                    word.toLowerCase() &&
                                element.targetLanguage ==
                                    ref
                                        .watch(textListProvider)[index]
                                        .targetLanguage &&
                                element.wordLanguage ==
                                    ref
                                        .watch(textListProvider)[index]
                                        .textLanguage);
                        wordDialog(ref, word, index, context, existedWord);
                      } else {
                        if (await checkConnection()) {
                          if (word.isNotEmpty && word.length < 81) {
                            ref.read(absorbState.notifier).state = true;
                            ref.read(loadingIndicator.notifier).state = true;
                            ref.read(translatedWord.notifier).state =
                                await translateWords(
                                    word,
                                    ref
                                        .watch(textListProvider)[index]
                                        .textLanguage,
                                    ref
                                        .watch(textListProvider)[index]
                                        .targetLanguage);

                            if (context.mounted) {
                              ref.read(loadingIndicator.notifier).state = false;
                              ref.read(absorbState.notifier).state = false;
                              wordDialog(
                                  ref, word, index, context, existedWord);
                            }
                          }
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Connection Issue"),
                                    duration: Duration(seconds: 1)));
                          }
                        }
                      }
                    },
                ))
            .toList();
      },
    );
  }
}

Route animatedRoute(index) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ReadingPage(index),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
