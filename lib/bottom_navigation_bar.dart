import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:translation_app/app_bar.dart';
import 'package:translation_app/pages/add_text_page.dart';
import 'package:translation_app/pages/home_page.dart';
import 'package:translation_app/pages/saved_page.dart';
import 'package:translation_app/pages/settings_page.dart';

StateProvider<int> widgetIndex = StateProvider<int>((ref) {
  return 1;
});

StateProvider<bool> navigationPageBannerAd = StateProvider<bool>((ref) {
  return false;
});


class NavigationBottomBar extends ConsumerStatefulWidget {
  const NavigationBottomBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NavigationBottomBarState();
}

class _NavigationBottomBarState extends ConsumerState<NavigationBottomBar> {
  void changeIndex(int index) {
    if (ref.watch(widgetIndex.notifier).state == 1 && index == 1) {
      ref.read(tempTitle.notifier).state = "";
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const AddPage()));
      addDialog(context, ref);
    }
    ref.read(widgetIndex.notifier).state = index;
  }


late BannerAd bannerAd;



  void createBannerAd() {
    bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: dotenv.env["BANNER_AD1"]!,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            ref.read(navigationPageBannerAd.notifier).state = true;
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
    const List<Widget> mainWidgets = <Widget>[
      SavedPage(),
      MyHomePage(),
      SettingsPage(),
    ];


    return SafeArea(
      
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 5, 30, 37),
        appBar: const AppBarWidgets(),
        persistentFooterButtons: [
          ref.watch(navigationPageBannerAd)
              ? Center(
                  child: Container(
                    color: const Color.fromARGB(255, 5, 30, 37),
                    width: bannerAd.size.width.toDouble(),
                    height: bannerAd.size.height.toDouble(),
                    child: AdWidget(ad: bannerAd),
                  ),
                )
              : const SizedBox.shrink()
        ],
        body: Center(
          child: mainWidgets.elementAt(ref.watch(widgetIndex)),
        ),
        bottomNavigationBar: SizedBox(
          height: 10.h,
          child: BottomNavigationBar(
            backgroundColor: const Color.fromARGB(255, 0, 92, 117),
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.bookmark,
                  color: Colors.white,
                ),
                label: 'Bookmarks',
              ),
              BottomNavigationBarItem(
                icon: ref.watch(widgetIndex) != 1
                    ? const Icon(
                        Icons.home,
                        color: Colors.white,
                      )
                    : const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                label: ref.watch(widgetIndex) != 1 ? "Home" : "New Text",
              ),
              const BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                label: 'Settings',
              ),
            ],
            currentIndex: ref.watch(widgetIndex),
            selectedItemColor:
                ref.watch(widgetIndex) != 1 ? Colors.white : Colors.white,
            onTap: changeIndex,
          ),
        ),
      ),
    );
  }
}

