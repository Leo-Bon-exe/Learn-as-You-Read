import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ndialog/ndialog.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translation_app/pages/settings_page.dart';
import 'package:translation_app/providers/text_manager.dart';

TextEditingController textController = TextEditingController();
TextEditingController textController2 = TextEditingController();

StateProvider<String> tempTitle = StateProvider<String>((ref) {
  return "";
});
StateProvider<String> tempTextLanguage = StateProvider<String>((ref) {
  return "";
});
StateProvider<String> tempTargetLanguage = StateProvider<String>((ref) {
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

class AddPage extends ConsumerWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Scaffold(
        appBar: const AddPageAppBar(),
        backgroundColor: const Color.fromARGB(255, 32, 32, 41),
        body: SizedBox(
          width: 100.w,
          height: 100.h,
          child: TextField(
              style: TextStyle(
                  fontFamily: ref.watch(textFont),
                  color: Color(ref.watch(colorSchemeText))),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(3.w),
                filled: true,
                fillColor: Color(ref.watch(colorSchemeBackground)),
                hintText: 'Write/Paste your text HERE (300 lines max)',
              ),
              controller: textController,
              //autofocus: true,
              maxLength: 14130,
              maxLines: 999,
              textInputAction: TextInputAction.newline,
              keyboardType: TextInputType.multiline),
        ),
      ),
    );
  }
}

class AddPageAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const AddPageAppBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddPageAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AddPageAppBarState extends ConsumerState<AddPageAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 0, 92, 117),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
          ref.read(tempTitle.notifier).state = "";
        },
        icon: const Icon(Icons.arrow_back),
      ),
      actions: <Widget>[
        if (ref.watch(tempTargetLanguage) != "" &&
            ref.watch(tempTextLanguage) != "" &&
            ref.watch(tempTitle) != "")
          IconButton(
            icon: const Icon(
              Icons.check,
              color: Colors.green,
            ),
            onPressed: () {
              ref.read(textListProvider.notifier).createReadingText(
                  textController.text,
                  ref.watch(tempTextLanguage),
                  ref.watch(tempTargetLanguage),
                  ref.watch(tempTitle));
              ref.read(tempTitle.notifier).state = "";
              textController.clear();
              Navigator.of(context).pop();
            },
          )
        else
          const Row(children: [
            Icon(Icons.error_outline),
            Text(" No title or language entry\t")
          ])
      ],
    );
  }
}

void addDialog(BuildContext context, WidgetRef ref) {
  NDialog(
    dialogStyle:
        DialogStyle(backgroundColor: const Color.fromARGB(255, 0, 92, 117)),
    actions: <Widget>[
      Container(
        height: 30.h,
        width: 100.w,
        alignment: Alignment.topCenter,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ListTile(
              title: TextFormField(
                  decoration: const InputDecoration(
                    filled: true,
                    hintText: 'Enter your title',
                    fillColor: Color.fromARGB(255, 197, 194, 194),
                  ),
                  controller: textController2,
                  //autofocus: true,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  keyboardType: TextInputType.multiline),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomTextLanguagePicker(),
                Icon(Icons.arrow_forward),
                BottomTargetLanguagePicker()
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.blueGrey)),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel",
                      style: TextStyle(color: Colors.black)),
                ),
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(Colors.blueGrey)),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    ref.read(tempTitle.notifier).state = textController2.text;
                    textController2.clear();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Confirm",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  ).show(context, dismissable: false);
}

class BottomTextLanguagePicker extends ConsumerStatefulWidget {
  const BottomTextLanguagePicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomTextLanguagePickerState();
}

class _BottomTextLanguagePickerState
    extends ConsumerState<BottomTextLanguagePicker> {
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
      child: Container(
        margin: EdgeInsets.only(right: 1.w),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: const Color.fromARGB(255, 197, 194, 194),
        ),
        height: 5.h,
        width: 35.w,
        child: Center(
            child: Text(ref.watch(tempTextLanguage) == ""
                ? "Text Language"
                : ref.watch(tempTextLanguage))),
      ),
      onTap: () {
        BottomPicker(
                backgroundColor: const Color.fromARGB(255, 0, 92, 117),
                dismissable: true,
                items: textWidgets,
                onSubmit: (index) {
                  ref.read(tempTextLanguage.notifier).state = languages[index];
                },
                pickerTitle: const Text("Text Language",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)))
            .show(context);
      },
    );
  }
}

class BottomTargetLanguagePicker extends ConsumerStatefulWidget {
  const BottomTargetLanguagePicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BottomTargetLanguagePickerState();
}

class _BottomTargetLanguagePickerState
    extends ConsumerState<BottomTargetLanguagePicker> {
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
      child: Container(
        margin: EdgeInsets.only(left: 1.w),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 7,
            ),
          ],
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: const Color.fromARGB(255, 197, 194, 194),
        ),
        height: 5.h,
        width: 35.w,
        child: Center(
            child: Text(ref.watch(tempTargetLanguage) == ""
                ? "Your Language"
                : ref.watch(tempTargetLanguage))),
      ),
      onTap: () {
        BottomPicker(
                backgroundColor: const Color.fromARGB(255, 0, 92, 117),
                dismissable: true,
                items: textWidgets,
                onSubmit: (index) {
                  ref.read(tempTargetLanguage.notifier).state =
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
