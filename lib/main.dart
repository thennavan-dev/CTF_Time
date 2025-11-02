import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/card_controller.dart';
import 'models/ctf_event.dart';
import 'models/organizer.dart' as org;
import 'models/ctf_event_detail.dart';
import 'screens/dashboard_screen.dart';
import 'utils/theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await NotificationService().init();

  Hive.registerAdapter(CtfEventAdapter());
  Hive.registerAdapter(CtfEventDetailAdapter());
  Hive.registerAdapter(org.OrganizerAdapter());

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CardController())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CTF Events',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}
