import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notes_app_interview/features/category/domain/category.dart';
import 'package:notes_app_interview/features/category/presentation/add_category.dart';
import 'package:notes_app_interview/features/notes/data/notes_database.dart';
import 'package:notes_app_interview/features/notes/domains/notes.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final DateTime initialDate;

  const NoteEditorScreen({super.key, required this.initialDate});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _quillController;
  bool isPinned = false;
  Category? selectedCategory;
  bool _showToolbar = false;

  @override
  void initState() {
    super.initState();
    _quillController = quill.QuillController.basic();

    _quillController.addListener(() {
      final selection = _quillController.selection;
      final show = selection.baseOffset != selection.extentOffset;
      if (_showToolbar != show) {
        setState(() {
          _showToolbar = show;
        });
      }
    });
  }

  void _togglePin() {
    setState(() => isPinned = !isPinned);
  }

  Future<void> _pickCategory() async {
    final result = await showModalBottomSheet<Category>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const CustomBottomSheet(),
    );

    if (result != null) {
      setState(() => selectedCategory = result);
    }
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _quillController.document.toPlainText().trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty note.')),
      );
      return;
    }
    if (selectedCategory == null) {
      await _pickCategory();
      if (selectedCategory == null) return;
    }

    final newNote = Note.create(
      title: title,
      content: content,
      pinned: isPinned,
      categoryId: selectedCategory!.id,
    );

    ref.read(notesProvider.notifier).addNote(newNote);
    Navigator.pop(context);
  }

  void _exportToPdf() {
    // TODO: Implement export feature
  }

  Widget _buildFloatingToolbar() {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        opacity: _showToolbar ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Visibility(
          visible: _showToolbar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_bold, color: Colors.white),
                  tooltip: 'Bold',
                  onPressed:
                      () => _quillController.formatSelection(
                        quill.Attribute.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.format_italic, color: Colors.white),
                  tooltip: 'Italic',
                  onPressed:
                      () => _quillController.formatSelection(
                        quill.Attribute.italic,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.format_underline, color: Colors.white),
                  tooltip: 'Underline',
                  onPressed:
                      () => _quillController.formatSelection(
                        quill.Attribute.underline,
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.format_align_left,
                    color: Colors.white,
                  ),
                  tooltip: 'Align Left',
                  onPressed:
                      () => _quillController.formatSelection(
                        quill.Attribute.leftAlignment,
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.format_align_center,
                    color: Colors.white,
                  ),
                  tooltip: 'Align Center',
                  onPressed:
                      () => _quillController.formatSelection(
                        quill.Attribute.centerAlignment,
                      ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.format_align_right,
                    color: Colors.white,
                  ),
                  tooltip: 'Align Right',
                  onPressed:
                      () => _quillController.formatSelection(
                        quill.Attribute.rightAlignment,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Note"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: _saveNote,
            color: Theme.of(context).primaryColor,
          ),
          IconButton(
            icon: Icon(isPinned ? Icons.push_pin : Icons.push_pin_outlined),
            onPressed: _togglePin,
          ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: _exportToPdf,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 8),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Text(
                //       selectedCategory?.name ?? "Select Category",
                //       style: TextStyle(
                //         color:
                //             selectedCategory != null
                //                 ? Colors.black
                //                 : Colors.grey,
                //         fontWeight: FontWeight.w500,
                //       ),
                //     ),
                //     IconButton(
                //       icon: const Icon(Icons.category_outlined),
                //       onPressed: _pickCategory,
                //     ),
                //   ],
                // ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: quill.QuillEditor.basic(
                      controller: _quillController,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildFloatingToolbar(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quillController.dispose();
    super.dispose();
  }
}
