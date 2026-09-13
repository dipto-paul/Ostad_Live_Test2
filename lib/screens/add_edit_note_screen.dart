import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/note_storage.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({
    super.key,
    this.note,
  });

  @override
  State<AddEditNoteScreen> createState() =>
      _AddEditNoteScreenState();
}

class _AddEditNoteScreenState
    extends State<AddEditNoteScreen> {

  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController descriptionController =
  TextEditingController();

  bool isSaving = false;

  bool get isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      descriptionController.text =
          widget.note!.description;
    }
  }

  Future<void> saveNote() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    final title = titleController.text.trim();
    final description =
    descriptionController.text.trim();

    if (isEditing) {
      final updatedNote = widget.note!.copyWith(
        title: title,
        description: description,
      );

      await NoteStorage.updateNote(updatedNote);
    } else {
      final newNote = NoteModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        title: title,
        description: description,
      );

      await NoteStorage.addNote(newNote);
    }

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isEditing
              ? 'Note updated successfully'
              : 'Note added successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Note' : 'Add Note',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                const Text(
                  'Note Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: titleController,
                  textInputAction:
                  TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Enter note title',
                    prefixIcon:
                    const Icon(Icons.title),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a title';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller:
                  descriptionController,
                  minLines: 6,
                  maxLines: 10,
                  decoration: InputDecoration(
                    hintText:
                    'Write your note here...',
                    alignLabelWithHint: true,
                    prefixIcon:
                    const Padding(
                      padding:
                      EdgeInsets.only(bottom: 90),
                      child: Icon(
                        Icons.description,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter a description';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed:
                    isSaving ? null : saveNote,
                    child: isSaving
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      isEditing
                          ? 'Update Note'
                          : 'Save Note',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}