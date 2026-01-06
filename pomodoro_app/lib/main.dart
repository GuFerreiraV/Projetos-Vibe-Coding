import 'package:flutter/material.dart';
import 'package:pomodoro_app/services/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:pomodoro_app/models/study_sequence.dart';
import 'package:pomodoro_app/models/study_session.dart';
import 'package:pomodoro_app/models/study_wave.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/timer_provider.dart';
import 'providers/sequence_provider.dart';
import 'providers/history_provider.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o Hive
  await Hive.initFlutter();

  // Registra os adaptadores do Hive
  Hive.registerAdapter(StudySequenceAdapter());
  Hive.registerAdapter(StudySessionAdapter());
  Hive.registerAdapter(StudyWaveAdapter());

  // Abre a caixa do Hive
  await Hive.openBox<StudySequence>('sequences');
  await Hive.openBox<StudySession>('sessions');

  await StorageService().initialize();

  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => SequenceProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: MaterialApp(
        title: 'Pomodoro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScreen(),
      ),
    );
  }
}
