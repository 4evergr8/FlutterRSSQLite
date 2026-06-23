import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:node_flutter/node_flutter.dart';
import 'theme/theme.dart';
import 'theme/util.dart';
import 'widget.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await Nodejs.start();
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);


  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;
    TextTheme textTheme = createTextTheme(context, "Noto Sans", "Noto Sans");
    MaterialTheme theme = MaterialTheme(textTheme);

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'RSSQlite',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BottomNavBar();
  }
}