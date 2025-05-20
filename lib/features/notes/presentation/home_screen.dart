import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app_interview/features/category/domain/category.dart';
import 'package:notes_app_interview/features/notes/data/notes_database.dart';
import 'package:notes_app_interview/features/notes/domains/notes.dart';
import 'package:notes_app_interview/features/notes/presentation/calendar_strip.dart';
import 'package:notes_app_interview/features/notes/presentation/category_strip.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  Category? selectedCategory;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final yearMonth = "${selectedDate.year} ${_monthName(selectedDate.month)}";

    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          yearMonth,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            color: Colors.black87,
          ),
        ],
      ),
      body: notesAsync.when(
        data: (allNotes) {
          final filteredNotes =
              allNotes.where((note) {
                final matchDate = _isSameDay(note.createdAt, selectedDate);
                final matchCategory =
                    selectedCategory == null ||
                    note.categoryId == selectedCategory!.id;
                final matchSearch =
                    searchQuery.isEmpty ||
                    note.title.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    ) ||
                    note.content.toLowerCase().contains(
                      searchQuery.toLowerCase(),
                    );
                return matchDate && matchCategory && matchSearch;
              }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              CalendarStrip(
                selectedDate: selectedDate,
                onDateSelected: (date) => setState(() => selectedDate = date),
              ),
              const SizedBox(height: 12),
              CategoryStrip(
                selectedCategory: selectedCategory,
                onCategorySelected:
                    (category) => setState(() => selectedCategory = category),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child:
                      filteredNotes.isEmpty
                          ? const Center(child: Text('No notes found.'))
                          : GridView.builder(
                            itemCount: filteredNotes.length,
                            padding: const EdgeInsets.only(bottom: 100),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.9,
                                ),
                            itemBuilder: (context, index) {
                              final note = filteredNotes[index];
                              return _buildNoteCard(note, selectedCategory!);
                            },
                          ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading notes: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/editor', arguments: DateTime.now());
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search for notes",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() => searchQuery = value);
        },
      ),
    );
  }

  Widget _buildNoteCard(Note note, Category category) {
    final backgroundColor = category.color;

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

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
