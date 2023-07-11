import '../barrel/export.dart';

class MobileScreenLayout extends StatefulWidget {
  const MobileScreenLayout({super.key});

  @override
  State<MobileScreenLayout> createState() => _MobileScreenLayoutState();
}

class _MobileScreenLayoutState extends State<MobileScreenLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: mobileBackgroundColor,
        onDestinationSelected: navigationTapped,
        selectedIndex: _page,
        indicatorColor: mobileBackgroundColor,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home,
              color: (_page == 0) ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.search,
              color: (_page == 1) ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.add_circle,
              color: (_page == 2) ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.favorite,
              color: (_page == 3) ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.person,
              color: (_page == 4) ? primaryColor : secondaryColor,
            ),
            label: '',
          ),
        ],
      ),
    );
  }
}
