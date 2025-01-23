import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ndialog/ndialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translation_app/pages/settings_page.dart';
import 'package:translation_app/providers/word_manager.dart';

class SavedPage extends ConsumerStatefulWidget {
  const SavedPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SavedPageState();
}

class _SavedPageState extends ConsumerState<SavedPage> {
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
                      key: Key(ref.watch(wordListProvider)[index].id),
                      onDismissed: (direction) {
                        ref.read(wordListProvider.notifier).removeFromPage(
                            ref.watch(wordListProvider)[index].id);
                      },
                      child: WordItems(index));
                },
                itemCount: ref.watch(wordListProvider).length),
        /* ),*/
      ),
    );
  }
}

class WordItems extends ConsumerWidget {
  const WordItems(this.index,{super.key});
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
          trailing: ShowTranslateIcon(index),
          title: Text(
            ref.watch(wordListProvider)[index].word,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
          ),
          children: [
            const Divider(
              thickness: 5.0,
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
                  ref.watch(wordListProvider)[index].wordLanguage,
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
                  ref.watch(wordListProvider)[index].targetLanguage,
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



class ShowTranslateIcon extends ConsumerWidget {
  const ShowTranslateIcon(this.index,{super.key});
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      child: const Icon(Icons.translate_rounded,
          size: 30, color: Color.fromARGB(255, 148, 158, 161)),
      onTap: () {
        translatedWordDialog(ref, index, context);
      },
    );
  }
}



void translatedWordDialog(
  WidgetRef ref,
  int index,
  context,
) {
  
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
              // Ana kelime

              Padding(
                padding: EdgeInsets.only(
                    bottom: 1.h, top: 1.h, left: 3.w, right: 3.w),
                child: Text(ref.watch(wordListProvider)[index].word,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontFamily: ref.watch(textFont),
                        fontSize: 25,
                        color: Color(ref.watch(colorSchemeText)))),
              ),

              Padding(
                padding: EdgeInsets.only(left: 1.5.w, right: 1.5.w),
                child: Text(ref.watch(wordListProvider)[index].wordExplanation,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontFamily: ref.watch(textFont),
                        fontSize: 19,
                        color: Color(ref.watch(colorSchemeText)))),
              ),
            ],
          ),
        ),
      ),
    ],
  ).show(context);
}
