import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme.dart';
import 'providers/task_provider.dart';
import 'services/notification_service.dart';
import 'screens/video_splash_screen.dart';
import 'screens/error_fallback_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Global Error Handlers (Prevents Grey Screen of Death)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError caught: ${details.exception}');
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PlatformDispatcher error caught: $error');
    return true; // Prevent app crash
  };

  await dotenv.load(fileName: ".env");

  // 2. Fault-Tolerant Supabase Initialization
  bool isOfflineMode = false;
  try {
    // If Supabase takes longer than 5 seconds or throws (e.g. no internet), we catch it
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Failed to connect to Supabase. Booting in Offline Mode. Error: $e');
    isOfflineMode = true;
  }

  // Initialize notification service (requests permissions on Android/iOS)
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MyApp(isOfflineMode: isOfflineMode),
    ),
  );
}

// Global key to allow providers to show SnackBars for network errors
final GlobalKey<ScaffoldMessengerState> globalScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  final bool isOfflineMode;
  
  const MyApp({super.key, required this.isOfflineMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nova Task Manager',
      scaffoldMessengerKey: globalScaffoldMessengerKey,
      theme: NovaTheme.themeData,
      debugShowCheckedModeBanner: false,
      builder: (context, widget) {
        // Global error widget override
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
          return ErrorFallbackScreen(errorDetails: errorDetails);
        };
        return widget!;
      },
      // If offline mode is triggered immediately on launch, show fallback screen instead of splash
      home: isOfflineMode 
          ? const ErrorFallbackScreen() 
          : const VideoSplashScreen(),
    );
  }
}
