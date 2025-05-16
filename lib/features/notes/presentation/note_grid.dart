import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app_interview/features/category/domain/category.dart';
import 'package:notes_app_interview/features/notes/data/notes_database.dart';
import 'package:notes_app_interview/features/notes/domains/notes.dart';

class NotesGrid extends ConsumerWidget {
  final DateTime selectedDate;
  final Category? selectedCategory;

  const NotesGrid({
    super.key,
    required this.selectedDate,
    required this.selectedCategory,
  });

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return notesAsync.when(
      data: (allNotes) {
        final filteredNotes =
            allNotes.where((note) {
              final matchDate = isSameDay(note.createdAt, selectedDate);
              final matchCategory =
                  selectedCategory == null ||
                  note.categoryId == selectedCategory!.id;
              return matchDate && matchCategory;
            }).toList();

        if (filteredNotes.isEmpty) {
          return const Expanded(child: Center(child: Text("No notes found.")));
        }

        return categoriesAsync.when(
          data: (allCategories) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.builder(
                  itemCount: filteredNotes.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final category = allCategories.firstWhere(
                      (cat) => cat.id == note.categoryId,
                      orElse: () => Category.create('All', 0),
                    );
                    return _buildNoteCard(note, category.color);
                  },
                ),
              ),
            );
          },
          loading:
              () => const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
          error:
              (error, _) => Expanded(
                child: Center(child: Text("Error loading categories: $error")),
              ),
        );
      },
      loading:
          () =>
              const Expanded(child: Center(child: CircularProgressIndicator())),
      error:
          (error, _) => Expanded(
            child: Center(child: Text("Error loading notes: $error")),
          ),
    );
  }

  Widget _buildNoteCard(Note note, Color backgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              note.content,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
