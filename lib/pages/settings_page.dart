import 'dart:convert';

import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

var fontStyleBox = Hive.box<String>('textFont');
var fontSizeBox = Hive.box<double>('fontSize');
var colorSchemeNameBox = Hive.box<String>('schemeName');
var colorSchemeBackgroundBox = Hive.box<int>('backgroundScheme');
var colorSchemeTextBox = Hive.box<int>('textScheme');

StateProvider<String> colorSchemeName = StateProvider<String>((ref) {
  if (colorSchemeNameBox.isEmpty) {
    colorSchemeNameBox.add('Sepia');
  }
  String value = (colorSchemeNameBox.getAt(0)) as String;
  return value;
});
const List<String> schemeNames = <String>[
  'Day',
  'Night',
  'Night Contrast',
  'Sepia',
  'Sepia Contrast',
  'Twilight',
  'Console',
];

StateProvider<int> colorSchemeBackground = StateProvider<int>((ref) {
  if (colorSchemeBackgroundBox.isEmpty) {
    colorSchemeBackgroundBox
        .add(const Color.fromARGB(255, 240, 222, 198).value);
  }
  int value = (colorSchemeBackgroundBox.getAt(0)) as int;
  return value;
});
List<int> backgroundScheme = <int>[
  const Color.fromARGB(255, 255, 255, 255).value,
  const Color.fromARGB(255, 0, 0, 0).value,
  const Color.fromARGB(255, 0, 0, 0).value,
  const Color.fromARGB(255, 240, 222, 198).value,
  const Color.fromARGB(255, 240, 222, 198).value,
  const Color.fromARGB(255, 43, 43, 43).value,
  const Color.fromARGB(255, 0, 0, 0).value
];

StateProvider<int> colorSchemeText = StateProvider<int>((ref) {
  if (colorSchemeTextBox.isEmpty) {
    colorSchemeTextBox.add(const Color.fromARGB(255, 128, 108, 83).value);
  }
  int value = (colorSchemeTextBox.getAt(0)) as int;
  return value;
});
List<int> textScheme = <int>[
  const Color.fromARGB(255, 58, 58, 58).value,
  const Color.fromARGB(255, 129, 129, 129).value,
  const Color.fromARGB(255, 203, 203, 203).value,
  const Color.fromARGB(255, 128, 108, 83).value,
  const Color.fromARGB(255, 113, 105, 101).value,
  const Color.fromARGB(255, 165, 173, 182).value,
  const Color.fromARGB(255, 7, 105, 8).value
];

StateProvider<double> fontSize = StateProvider<double>((ref) {
  if (fontSizeBox.isEmpty) {
    fontSizeBox.add(17);
  }
  double value = (fontSizeBox.getAt(0)) as double;
  return value;
});

StateProvider<String> textFont = StateProvider<String>((ref) {
  if (fontStyleBox.isEmpty) {
    fontStyleBox.add("Roboto");
  }
  String value = (fontStyleBox.getAt(0)) as String;
  return value;
});

List<String> fontList = [];
List<Widget> textWidgets = [];

void initTextFonts() async {
  final String response =
      await rootBundle.loadString('assets/fonts/google_fonts.json');
  Map<String, dynamic> data = json.decode(response);
  List<dynamic> familyMetadataList = data['familyMetadataList'];

  for (var item in familyMetadataList) {
    fontList.add(item['family']);
  }

  for (var element in fontList) {
    textWidgets.add(Container(
      margin: EdgeInsets.only(top: 1.h),
      child: Text(
        element,
        style: const TextStyle(fontSize: 15, color: Colors.white),
      ),
    ));
  }
}


class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    initTextFonts();
    super.initState();
  }

  @override
  void dispose() {
    fontList.clear();
    textWidgets.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 30, 37),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 1.h, right: 3.w, left: 3.w),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Font",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                FontPicker(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 1.h, right: 3.w, left: 3.w),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Font Size",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                FontSizePicker(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 1.h, right: 3.w, left: 3.w),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Color Scheme",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                ColorSchemePicker()
              ],
            ),
          ),
          Align(
            child: ElevatedButton.icon(
              style: const ButtonStyle(
                backgroundColor: WidgetStatePropertyAll<Color>(
                    Color.fromARGB(255, 0, 92, 117)),
              ),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationIcon: const Image(
                    image: AssetImage("assets/images/ic_launcher.png"),
                    width: 70,
                    color: null,
                  ),
                  applicationVersion: '1.1.4',
                );
              },
              icon: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
              ),
              label: const Text(
                'Info',
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    ));
  }
}

class FontPicker extends ConsumerStatefulWidget {
  const FontPicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FontPickerState();
}

class _FontPickerState extends ConsumerState<FontPicker> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: const Color.fromARGB(0, 0, 0, 0),
      child: Container(
        margin: EdgeInsets.all(1.w),
        padding: EdgeInsets.all(1.w),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color.fromARGB(255, 197, 194, 194),
        ),
        height: 5.h,
        width: 35.w,
        child: Center(
            child: Text(ref.watch(textFont),
                style: TextStyle(fontFamily: ref.watch(textFont)))),
      ),
      onTap: () {
        BottomPicker(
                backgroundColor: const Color.fromARGB(255, 0, 92, 117),
                dismissable: true,
                selectedItemIndex: fontList.indexOf(ref.watch(textFont)),
                items: textWidgets,
                onSubmit: (index) {
                  ref.read(textFont.notifier).state = fontList[index];
                  fontStyleBox.put(0, fontList[index]);
                },
                pickerTitle: const Text("Font",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)))
            .show(context);
      },
    );
  }
}

class FontSizePicker extends ConsumerStatefulWidget {
  const FontSizePicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FontSizePickerState();
}

class _FontSizePickerState extends ConsumerState<FontSizePicker> {
  @override
  Widget build(BuildContext context) {
    List<Widget> textWidgets = [];
    for (double i = 12; i < 120; i++) {
      textWidgets.add(Container(
          margin: EdgeInsets.only(top: 1.h),
          child: Text("$i",
              style: const TextStyle(fontSize: 15, color: Colors.white))));
    }
    return InkWell(
      splashColor: const Color.fromARGB(0, 0, 0, 0),
      child: Container(
        margin: EdgeInsets.all(1.w),
        padding: EdgeInsets.all(1.w),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color.fromARGB(255, 197, 194, 194),
        ),
        height: 5.h,
        width: 35.w,
        child: Center(
          child: Text(
            "${ref.watch(fontSize)}",
          ),
        ),
      ),
      onTap: () {
        BottomPicker(
                backgroundColor: const Color.fromARGB(255, 0, 92, 117),
                dismissable: true,
                selectedItemIndex: (ref.watch(fontSize) - 12).toInt(),
                items: textWidgets,
                onSubmit: (index) {
                  ref.read(fontSize.notifier).state = index + 12.toDouble();
                  fontSizeBox.put(0, index + 12.toDouble());
                },
                pickerTitle: const Text("Font Size",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)))
            .show(context);
      },
    );
  }
}

class ColorSchemePicker extends ConsumerStatefulWidget {
  const ColorSchemePicker({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ColorSchemePickerState();
}

class _ColorSchemePickerState extends ConsumerState<ColorSchemePicker> {
  @override
  Widget build(BuildContext context) {
    List<Widget> textWidgets = [];
    for (var element in schemeNames) {
      textWidgets.add(Container(
          margin: EdgeInsets.only(top: 1.h),
          child: Text(element,
              style: const TextStyle(fontSize: 15, color: Colors.white))));
    }
    return InkWell(
      splashColor: const Color.fromARGB(0, 0, 0, 0),
      child: Container(
        margin: EdgeInsets.all(1.w),
        padding: EdgeInsets.all(1.w),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color.fromARGB(255, 197, 194, 194),
        ),
        height: 5.h,
        width: 35.w,
        child: Center(
          child: Text(
            ref.watch(colorSchemeName),
          ),
        ),
      ),
      onTap: () {
        BottomPicker(
                backgroundColor: const Color.fromARGB(255, 0, 92, 117),
                dismissable: true,
                items: textWidgets,
                selectedItemIndex:
                    schemeNames.indexOf(ref.watch(colorSchemeName)),
                onSubmit: (index) {
                  ref.read(colorSchemeName.notifier).state = schemeNames[index];
                  colorSchemeNameBox.put(0, schemeNames[index]);
                  ref.read(colorSchemeBackground.notifier).state =
                      backgroundScheme[index];
                  colorSchemeBackgroundBox.put(0, backgroundScheme[index]);
                  ref.read(colorSchemeText.notifier).state = textScheme[index];
                  colorSchemeTextBox.put(0, textScheme[index]);
                },
                pickerTitle: const Text("Color Scheme",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)))
            .show(context);
      },
    );
  }
}
