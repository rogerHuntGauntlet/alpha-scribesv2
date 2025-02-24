import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../services/achievement_service.dart';
import '../services/initialization_service.dart';
import 'project_list_screen.dart';
import 'achievements_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late InitializationService _initializationService;
  final _tabController = CupertinoTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    _initializationService = InitializationService(
      Provider.of<AchievementService>(context, listen: false),
    );
    _initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _initializationService.initializeIfNeeded();
  }

  void switchToTab(int index) {
    setState(() {
      _tabController.index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      controller: _tabController,
      tabBar: CupertinoTabBar(
        activeColor: CupertinoTheme.of(context).primaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            activeIcon: Icon(CupertinoIcons.doc_text_fill),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.star),
            activeIcon: Icon(CupertinoIcons.star_fill),
            label: 'Achievements',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return HomeScreen(
                  key: const PageStorageKey('home'),
                  onSwitchTab: switchToTab,
                );
              case 1:
                return const ProjectListScreen(
                  key: PageStorageKey('projects'),
                );
              case 2:
                return const AchievementsScreen(
                  key: PageStorageKey('achievements'),
                );
              default:
                return HomeScreen(
                  key: const PageStorageKey('home'),
                  onSwitchTab: switchToTab,
                );
            }
          },
          defaultTitle: index == 0 
              ? 'Home' 
              : index == 1 
                  ? 'Projects' 
                  : 'Achievements',
        );
      },
    );
  }
}