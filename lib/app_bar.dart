import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ndialog/ndialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:searchbar_animation/searchbar_animation.dart';
import 'package:translation_app/bottom_navigation_bar.dart';
import 'package:translation_app/providers/text_manager.dart';
import 'package:translation_app/providers/word_manager.dart';

TextEditingController controller = TextEditingController();

StateProvider<String> filterFirstLanguage = StateProvider<String>((ref) {
  return "";
});
StateProvider<String> filterSecondLanguage = StateProvider<String>((ref) {
  return "";
});

const List<String> languages = <String>[
  'English',
  'Korean',
  'Spanish',
  'French',
  'German',
  'Italian',
  'Portuguese',
  'Russian',
  'Turkish',
  'Indonesian',
  'Vietnamese',
  'Polish',
  'Filipino',
  'Swahili',
  'Bengali',
  'Urdu',
  'Marathi',
  'Pashto',
  'Bhojpuri',
  'Javanese',
  'Yoruba',
];

class AppBarWidgets extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const AppBarWidgets({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AppBarWidgetsState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWidgetsState extends ConsumerState<AppBarWidgets> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          title: const Center(
              child: Text(
            "Settings",
            style: TextStyle(fontSize: 17, color: Colors.white),
          )),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 0, 92, 117),
          toolbarHeight: kToolbarHeight,
        ),
        AppBar(
          toolbarHeight: ref.watch(widgetIndex) != 2 ? kToolbarHeight : 0.0,
          backgroundColor: ref.watch(widgetIndex) != 2
              ? const Color.fromARGB(255, 0, 92, 117)
              : const Color.fromARGB(0, 0, 0, 0),
          leading: const Filters(),
          actions: const <Widget>[
            Row(children: [SearchButton()]),
          ],
        ),
      ],
    );
  }
}

class SearchButton extends ConsumerStatefulWidget {
  const SearchButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchButtonState();
}

class _SearchButtonState extends ConsumerState<SearchButton> {
  @override
  Widget build(BuildContext context) {
    return SearchBarAnimation(
      textEditingController: controller,
      hintText: (''),
      isOriginalAnimation: false,
      

      enableKeyboardFocus: true,
      buttonColour: const Color.fromARGB(255, 0, 92, 117),
      searchBoxWidth: 99.w,
      durationInMilliSeconds: 200,
      

      onChanged: (String value) {
        if (ref.watch(widgetIndex) == 0) {
          ref.read(wordListProvider.notifier).search(value);
        }
        if (ref.watch(widgetIndex) == 1) {
          ref.read(textListProvider.notifier).search(value);
        }
        if (value == "") {
          ref.read(wordListProvider.notifier).latest();
          ref.read(textListProvider.notifier).latest();
        }
      },
      searchBoxColour: const Color.fromARGB(255, 225, 222, 222),
      buttonWidget: const Icon(
        Icons.search,
        color: Colors.black,
      ),

      onCollapseComplete: () {
        ref.read(wordListProvider.notifier).latest();
        ref.read(textListProvider.notifier).latest();
        controller.clear();
        FocusScope.of(context).unfocus();
      },
      
      trailingWidget: const InkWell(child: Icon(null)),
      secondaryButtonWidget: const Icon(Icons.search_off),
    );
  }
}

class Filters extends ConsumerWidget {
  const Filters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      child: const Icon(Icons.filter_list_rounded),
      onTap: () {
        filterDialog(context, ref);
      },
    );
  }
}


void filterDialog(BuildContext context, WidgetRef ref) {
  NDialog(
    dialogStyle:
        DialogStyle(backgroundColor: const Color.fromARGB(255, 0, 92, 117)),
    
    actions: <Widget>[
      Container(
        height: 25.h,
        width: 60.w,
        alignment: Alignment.topCenter,
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
             const Text("Filters",style: TextStyle(fontSize: 16),),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FirstLanguagePicker(),
                Icon(Icons.arrow_downward),
                SecondLanguagePicker()
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                    child: const Icon(Icons.restore, color: Colors.red),
                    onPressed: () {
                      if (ref.watch(widgetIndex) == 0) {
                        ref.read(wordListProvider.notifier).latest();
                      } else {
                        ref.read(textListProvider.notifier).latest();
                      }
                      ref.read(filterFirstLanguage.notifier).state = "";
                      ref.read(filterSecondLanguage.notifier).state = "";
                      FocusScope.of(context).unfocus();
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: const Icon(Icons.check_outlined, color: Colors.green),
                  onPressed: () {
                    if (ref.watch(widgetIndex) == 0) {
                      ref.read(wordListProvider.notifier).filterByLanguage(
                          ref.watch(filterFirstLanguage),
                          ref.watch(filterSecondLanguage));
                    } else {
                      ref.read(textListProvider.notifier).filterByLanguage(
                          ref.watch(filterFirstLanguage),
                          ref.watch(filterSecondLanguage));
                    }
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ).show(context);
}

class FirstLanguagePicker extends ConsumerStatefulWidget {
  const FirstLanguagePicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FirstLanguagePickerState();
}

class _FirstLanguagePickerState extends ConsumerState<FirstLanguagePicker> {
  @override
  Widget build(BuildContext context) {
    List<Widget> textWidgets = [];
    for (var element in languages) {
      textWidgets.add(Container(
          margin: EdgeInsets.only(top: 1.h),
          child: Text(element,
              style: const TextStyle(fontSize: 15, color: Colors.white))));
    }
    return InkWell(
      splashColor: const Color.fromARGB(255, 46, 46, 58),
      child: Container(
        margin: EdgeInsets.only(right: 1.w, bottom: 1.h),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color.fromARGB(255, 197, 194, 194),
        ),
        height: 5.h,
        width: 35.w,
        child: Center(
            child: Text(ref.watch(filterFirstLanguage) == ""
                ? "Text Language"
                : ref.watch(filterFirstLanguage))),
      ),
      onTap: () {
        BottomPicker(
          backgroundColor: const Color.fromARGB(255, 0, 92, 117),
          dismissable: true,
          items: textWidgets,
          onSubmit: (index) {
            ref.read(filterFirstLanguage.notifier).state = languages[index];
          },
          pickerTitle: const Text("Text Language",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white)),
        ).show(context);
      },
    );
  }
}

class SecondLanguagePicker extends ConsumerStatefulWidget {
  const SecondLanguagePicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SecondLanguagePickerState();
}

class _SecondLanguagePickerState extends ConsumerState<SecondLanguagePicker> {
  @override
  Widget build(BuildContext context) {
    List<Widget> textWidgets = [];
    for (var element in languages) {
      textWidgets.add(Container(
          margin: EdgeInsets.only(top: 1.h),
          child: Text(element,
              style: const TextStyle(fontSize: 15, color: Colors.white))));
    }
    return InkWell(
      splashColor: const Color.fromARGB(255, 46, 46, 58),
      child: Container(
        margin: EdgeInsets.only(left: 1.w, top: 1.h),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color.fromARGB(255, 197, 194, 194),
        ),
        height: 5.h,
        width: 35.w,
        child: Center(
            child: Text(ref.watch(filterSecondLanguage) == ""
                ? "Your Language"
                : ref.watch(filterSecondLanguage))),
      ),
      onTap: () {
        BottomPicker(
                backgroundColor: const Color.fromARGB(255, 0, 92, 117),
                dismissable: true,
                items: textWidgets,
                onSubmit: (index) {
                  ref.read(filterSecondLanguage.notifier).state =
                      languages[index];
                },
                pickerTitle: const Text("Your Language",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)))
            .show(context);
      },
    );
  }
}
