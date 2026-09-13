import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';

class NoteStorage {
  static String _notesKey = 'notes';

  static Future<List<NoteModel>> getNotes() async {
    final prefs = await SharedPreferences.getInstance();

    final String? notesString = prefs.getString(_notesKey);

    if (notesString == null || notesString.isEmpty) {
      return [];
    }

    final List<dynamic> notesJson = jsonDecode(notesString);

    return notesJson
        .map((note) => NoteModel.fromJson(note))
        .toList();
  }

  static Future<void> saveNotes(List<NoteModel> notes) async {
    final prefs = await SharedPreferences.getInstance();

    final List<Map<String, dynamic>> notesJson =
    notes.map((note) => note.toJson()).toList();

    await prefs.setString(
      _notesKey,
      jsonEncode(notesJson),
    );
  }

  static Future<void> addNote(NoteModel note) async {
    final notes = await getNotes();

    notes.add(note);

    await saveNotes(notes);
  }

  static Future<void> updateNote(NoteModel updatedNote) async {
    final notes = await getNotes();

    final index = notes.indexWhere(
          (note) => note.id == updatedNote.id,
    );

    if (index != -1) {
      notes[index] = updatedNote;
    }

    await saveNotes(notes);
  }

  static Future<void> deleteNote(String id) async {
    final notes = await getNotes();

    notes.removeWhere(
          (note) => note.id == id,
    );

    await saveNotes(notes);
  }
}