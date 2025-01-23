import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translation_app/ai_clickable_text/ai_clickable_text.dart';
import 'package:translation_app/pages/settings_page.dart';
import 'package:translation_app/providers/text_manager.dart';

StateProvider<bool> absorbState = StateProvider<bool>((ref) {
  return false;
});

StateProvider<bool> readingPageBannerAd = StateProvider<bool>((ref) {
  return false;
});

class ReadingPage extends ConsumerStatefulWidget {
  const ReadingPage(this.index, {Key? key}) : super(key: key);
  final int index;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReadingPageState();
}

class _ReadingPageState extends ConsumerState<ReadingPage> {
  late BannerAd bannerAd;

  void createBannerAd() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: dotenv.env["BANNER_AD2"]!,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            ref.read(readingPageBannerAd.notifier).state = true;
            if (!mounted) {
              ad.dispose();
            }
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
          },
        ),
        request: const AdRequest());
    bannerAd.load();
  }

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    createBannerAd();
  }

  @override
  void dispose() {
    super.dispose();
    bannerAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PopScope(
        onPopInvoked: (didPop) {
          ref
              .read(textListProvider.notifier)
              .latestRead(ref.watch(textListProvider)[widget.index].id);

          ref.read(gestureLoad.notifier).state = false;
        },
        child: Scaffold(
          backgroundColor: Color(ref.watch(colorSchemeBackground)),
          persistentFooterButtons: [
            ref.watch(readingPageBannerAd)
                ? Center(
                    child: Container(
                      color: Color(ref.watch(colorSchemeBackground)),
                      width: bannerAd.size.width.toDouble(),
                      height: bannerAd.size.height.toDouble(),
                      child: AdWidget(ad: bannerAd),
                    ),
                  )
                : const SizedBox.shrink()
          ],
          body: AbsorbPointer(
            absorbing: ref.watch(absorbState),
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: Stack(children: [
                ClickableTextView(widget.index),
                Align(
                    alignment: Alignment.center,
                    child: ref.watch(loadingIndicator)
                        ? const CircularProgressIndicator()
                        : const SizedBox.shrink()),
                const ChangeModeButton()
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class ChangeModeButton extends ConsumerStatefulWidget {
  const ChangeModeButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ChangeModeButtonState();
}

class _ChangeModeButtonState extends ConsumerState<ChangeModeButton> {
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: const Alignment(0.85, 0.9),
        child: InkWell(
          splashColor: Colors.transparent,
          child: Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(ref.watch(colorSchemeText)),
                      blurRadius: 2.0,
                      spreadRadius: 0.0,
                      offset: const Offset(1.0, 1.0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(40.0),
                  color: Color(ref.watch(colorSchemeBackground))),
              child: ref.watch(gestureLoad)
                  ? Icon(Icons.translate,
                      size: 40,
                      color: Color(
                        ref.watch(colorSchemeText),
                      ))
                  : Icon(Icons.menu_book,
                      size: 40,
                      color: Color(
                        ref.watch(colorSchemeText),
                      ))),
          onTap: () => {
            if (ref.watch(gestureLoad))
              {ref.read(gestureLoad.notifier).state = false}
            else
              {ref.read(gestureLoad.notifier).state = true}
          },
        ));
  }
}
