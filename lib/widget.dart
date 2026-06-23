import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rssqlite/main.dart';
import 'package:rssqlite/view/add.dart';
import 'package:rssqlite/view/feed.dart';
import 'package:rssqlite/view/runner.dart';
import 'package:rssqlite/view/settings.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  // 3 个核心页面栏位（未读、所有、星标）
  // 统一复用同一个 RssFeedScreen 页面组件，通过 feedType 参数进行数据查询区分
  // feedType 对应关系: 0 = 未读, 1 = 所有, 2 = 星标
  static final List<Widget> _widgetOptions = <Widget>[
    const RssFeedScreen(feedType: 0), // 未读
    const RssFeedScreen(feedType: 1), // 所有
    const RssFeedScreen(feedType: 2), // 星标
    const ScriptRunnerScreen(), // 新增
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? '未读订阅'
              : _selectedIndex == 1
              ? '所有订阅'
              : '星标订阅',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddFeedScreen()));
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _widgetOptions,
        onPageChanged: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mark_as_unread_outlined),
            activeIcon: Icon(Icons.mark_as_unread),
            label: '未读',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.rss_feed_outlined), activeIcon: Icon(Icons.rss_feed), label: '所有'),
          BottomNavigationBarItem(icon: Icon(Icons.star_outline), activeIcon: Icon(Icons.star), label: '星标'),
          BottomNavigationBarItem(icon: Icon(Icons.code_outlined), activeIcon: Icon(Icons.code), label: '脚本'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.secondary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

VoidCallback showSnackBarGlobal(String type, String text) {
  final messenger = scaffoldMessengerKey.currentState;
  if (messenger == null) return () {};

  final context = messenger.context;

  if (type == "load") {
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(hours: 1),
        content: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  } else if (type == "success") {
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        content: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
          },
          child: Row(
            children: [
              Icon(Icons.check_circle, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 3),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  } else {
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: text));
          },
          child: Row(
            children: [
              Icon(Icons.error, size: 16, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      ),
    );
  }

  return () {
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
  };
}
