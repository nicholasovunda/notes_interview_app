import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app_interview/features/category/domain/category.dart';
import 'package:notes_app_interview/features/notes/domains/notes.dart';
import 'package:notes_app_interview/povider/app_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class NotesDatabase {
  NotesDatabase._();
  static NotesDatabase? _instance;

  late Database _database;
  late StoreRef<String, Map<String, dynamic>> _notesStore;
  late StoreRef<String, Map<String, dynamic>> _categoriesStore;

  bool _isInitialized = false;

  static Future<NotesDatabase> getInstance() async {
    if (_instance == null) {
      _instance = NotesDatabase._();
      await _instance!._initialize();
    }
    return _instance!;
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;

    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocDir.path, 'notes_app.db');

    _database = await databaseFactoryIo.openDatabase(dbPath);
    _notesStore = stringMapStoreFactory.store('notes');
    _categoriesStore = stringMapStoreFactory.store('categories');

    final categoriesCount = await _categoriesStore.count(_database);
    if (categoriesCount == 0) {
      final defaultCategory = Category.create("All", 0);
      await _categoriesStore
          .record(defaultCategory.id)
          .put(_database, defaultCategory.toMap());
    }

    _isInitialized = true;
  }

  // Notes CRUD

  Future<List<Note>> getAllNotes() async {
    final finder = Finder(
      sortOrders: [SortOrder('pinned', false), SortOrder('updatedAt', false)],
    );
    final snapshots = await _notesStore.find(_database, finder: finder);
    return snapshots.map((e) => Note.fromMap(e.value)).toList();
  }

  Future<List<Note>> getNotesByCategory(String categoryId) async {
    final finder = Finder(
      filter: Filter.equals('categoryId', categoryId),
      sortOrders: [SortOrder('pinned', false), SortOrder('updatedAt', false)],
    );
    final snapshots = await _notesStore.find(_database, finder: finder);
    return snapshots.map((e) => Note.fromMap(e.value)).toList();
  }

  Future<List<Note>> getByDate(DateTime date) async {
    final allNotes = await getAllNotes();
    return allNotes.where((note) {
      final d = note.createdAt;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  Future<void> saveNote(Note note) async {
    await _notesStore.record(note.id).put(_database, note.toMap());
  }

  Future<void> deleteNote(String noteId) async {
    await _notesStore.record(noteId).delete(_database);
  }

  Future<void> pinNote(String noteId) async {
    final finder = Finder(filter: Filter.equals('id', noteId));
    final snapshots = await _notesStore.find(_database, finder: finder);
    if (snapshots.isNotEmpty) {
      final note = Note.fromMap(snapshots.first.value);
      final updated = note.copyWith(pinned: true);
      await _notesStore.record(note.id).put(_database, updated.toMap());
    }
  }

  // Category CRUD

  Future<List<Category>> getAllCategories() async {
    final snapshots = await _categoriesStore.find(_database);
    return snapshots.map((e) => Category.fromMap(e.value)).toList();
  }

  Future<void> saveCategory(Category category) async {
    await _categoriesStore.record(category.id).put(_database, category.toMap());
  }

  Future<void> deleteCategory(
    String categoryId,
    String fallbackCategoryId,
  ) async {
    final finder = Finder(filter: Filter.equals('categoryId', categoryId));
    final notesToUpdate = await _notesStore.find(_database, finder: finder);

    for (final snap in notesToUpdate) {
      final note = Note.fromMap(snap.value);
      final updated = note.copyWith(categoryId: fallbackCategoryId);
      await _notesStore.record(note.id).put(_database, updated.toMap());
    }

    await _categoriesStore.record(categoryId).delete(_database);
  }

  Future<void> close() async {
    await _database.close();
  }
}

// Database provider
final databaseProvider = Provider<NotesDatabase>((ref) {
  final database = ref.watch(databaseInitializerProvider).valueOrNull;
  if (database == null) {
    throw UnimplementedError('Database must be initialized before use');
  }
  return database;
});

// Initialization provider
final databaseInitializerProvider = FutureProvider<NotesDatabase>((ref) async {
  return await NotesDatabase.getInstance();
});

// Categories providers
final categoriesProvider =
    StateNotifierProvider<CategoriesNotifier, AsyncValue<List<Category>>>((
      ref,
    ) {
      final database = ref.watch(databaseProvider);
      return CategoriesNotifier(database);
    });

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Notes providers
final notesProvider =
    StateNotifierProvider<NotesNotifier, AsyncValue<List<Note>>>((ref) {
      final database = ref.watch(databaseProvider);
      final selectedCategoryId = ref.watch(selectedCategoryProvider);
      return NotesNotifier(database, selectedCategoryId);
    });
