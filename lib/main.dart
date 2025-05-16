import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:notes_app_interview/features/notes/data/notes_database.dart';
import 'package:notes_app_interview/features/notes/presentation/home_screen.dart';
import 'package:notes_app_interview/features/notes/presentation/note_editor.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await NotesDatabase.getInstance();

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          title: 'Notes App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
            fontFamily: 'Avenir',
          ),
          home: const HomeScreen(),
          onGenerateRoute: (settings) {
            if (settings.name == '/editor') {
              final args = settings.arguments as DateTime;
              return MaterialPageRoute(
                builder: (_) => NoteEditorScreen(initialDate: args),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
