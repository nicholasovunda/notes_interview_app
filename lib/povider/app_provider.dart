import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app_interview/features/category/domain/category.dart';
import 'package:notes_app_interview/features/notes/data/notes_database.dart';
import 'package:notes_app_interview/features/notes/domains/notes.dart';
import 'package:notes_app_interview/utils/in_memory_store.dart';

class CategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final NotesDatabase _database;
  late InMemoryStore<List<Category>> _categoriesStore;

  CategoriesNotifier(this._database) : super(const AsyncValue.loading()) {
    _initCategories();
  }

  Future<void> _initCategories() async {
    try {
      final categories = await _database.getAllCategories();
      _categoriesStore = InMemoryStore<List<Category>>(categories);

      _categoriesStore.stream.listen((categories) {
        state = AsyncValue.data(categories);
      });

      state = AsyncValue.data(categories);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCategory(String name, int colorIndex) async {
    if (name.trim().toLowerCase() == 'all') return;

    final category = Category.create(name, colorIndex);
    await _database.saveCategory(category);

    final currentCategories = List<Category>.from(_categoriesStore.value);
    currentCategories.add(category);
    _categoriesStore.value = currentCategories;
  }

  Future<void> updateCategory(Category category) async {
    await _database.saveCategory(category);

    final currentCategories = List<Category>.from(_categoriesStore.value);
    final index = currentCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      currentCategories[index] = category;
      _categoriesStore.value = currentCategories;
    }
  }

  Future<List<Note>> getNotesByDate(DateTime date) async {
    try {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final allNotes = await _database.getAllNotes();
      return allNotes.where((note) {
        final created = note.createdAt.toLocal();
        final noteDate = DateTime(created.year, created.month, created.day);
        return noteDate == normalizedDate;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteCategory(
    String categoryId,
    String fallbackCategoryId,
  ) async {
    await _database.deleteCategory(categoryId, fallbackCategoryId);

    final currentCategories = List<Category>.from(_categoriesStore.value);
    currentCategories.removeWhere((c) => c.id == categoryId);
    _categoriesStore.value = currentCategories;
  }

  @override
  void dispose() {
    _categoriesStore.close();
    super.dispose();
  }
}

class NotesNotifier extends StateNotifier<AsyncValue<List<Note>>> {
  final NotesDatabase _database;
  final String? _selectedCategoryId;
  late InMemoryStore<List<Note>> _notesStore;

  NotesNotifier(this._database, this._selectedCategoryId)
    : super(const AsyncValue.loading()) {
    _initNotes();
  }

  Future<void> _initNotes() async {
    try {
      final notes =
          _selectedCategoryId == null || _selectedCategoryId == 'all'
              ? await _database.getAllNotes()
              : await _database.getNotesByCategory(_selectedCategoryId);

      _notesStore = InMemoryStore<List<Note>>(notes);

      _notesStore.stream.listen((notes) {
        state = AsyncValue.data(notes);
      });

      state = AsyncValue.data(notes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addNote(Note note) async {
    await _database.saveNote(note);

    if (_selectedCategoryId == null ||
        _selectedCategoryId == 'all' ||
        _selectedCategoryId == note.categoryId) {
      final currentNotes = List<Note>.from(_notesStore.value);
      currentNotes.add(note);
      _notesStore.value = currentNotes;
    }
  }

  Future<void> pinNotes(String noteId) async {
    await _database.pinNote(noteId);
    final currentNotes = List<Note>.from(_notesStore.value);
    final index = currentNotes.indexWhere((n) => n.id == noteId);
    if (index != -1) {
      final updatedNote = currentNotes[index].copyWith(pinned: true);
      currentNotes[index] = updatedNote;
      _notesStore.value = currentNotes;
    }
  }

  Future<void> updateNote(Note note) async {
    await _database.saveNote(note);

    if (_selectedCategoryId != null &&
        _selectedCategoryId != 'all' &&
        _selectedCategoryId != note.categoryId) {
      final currentNotes = List<Note>.from(_notesStore.value);
      currentNotes.removeWhere((n) => n.id == note.id);
      _notesStore.value = currentNotes;
    } else {
      final currentNotes = List<Note>.from(_notesStore.value);
      final index = currentNotes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        currentNotes[index] = note;
      } else {
        currentNotes.add(note);
      }
      _notesStore.value = currentNotes;
    }
  }

  Future<List<DateTime>> getUniqueDateTIme() async {
    final notes = await _database.getAllNotes();
    final uniquesDates =
        notes
            .map((note) {
              final created = note.createdAt.toLocal();
              return DateTime(2000, created.month, created.day);
            })
            .toSet()
            .toList();

    uniquesDates.sort((a, b) {
      final aValue = a.month * 31 + a.day;
      final bValue = b.month * 31 + b.day;
      return aValue.compareTo(bValue);
    });

    return uniquesDates;
  }

  Future<void> deleteNote(String noteId) async {
    await _database.deleteNote(noteId);

    final currentNotes = List<Note>.from(_notesStore.value);
    currentNotes.removeWhere((n) => n.id == noteId);
    _notesStore.value = currentNotes;
  }

  @override
  void dispose() {
    _notesStore.close();
    super.dispose();
  }
}
