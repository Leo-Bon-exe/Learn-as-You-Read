import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translation_app/bottom_navigation_bar.dart';
import 'package:translation_app/models/text_file_model.dart';
import 'package:translation_app/models/word_file_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
   unawaited(MobileAds.instance.initialize());
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  Hive.registerAdapter(TextFileAdapter());
  Hive.registerAdapter(WordFileAdapter());
  await Hive.openBox<String>('schemeName');
  await Hive.openBox<int>('backgroundScheme');
  await Hive.openBox<int>('textScheme');
  await Hive.openBox<String>('textFont');
  await Hive.openBox<double>('fontSize');
  await Hive.openBox<TextFile>('texts');
  await Hive.openBox<WordFile>('words');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, deviceType) {
        return const MaterialApp(
          title: 'Learn As You Read',
          debugShowCheckedModeBanner: false,
          
          home: NavigationBottomBar(),
        );
      },
    );
  }
}


