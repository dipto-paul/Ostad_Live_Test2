import 'package:flutter/material.dart';

import '../models/note_model.dart';
import '../services/note_storage.dart';
import 'add_edit_note_screen.dart';
import 'note_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<NoteModel> notes = [];
  List<NoteModel> filteredNotes = [];

  bool isLoading = true;

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    loadNotes();

    searchController.addListener(searchNotes);
  }

  Future<void> loadNotes() async {
    final data = await NoteStorage.getNotes();

    if (!mounted) return;

    setState(() {
      notes = data;
      filteredNotes = data;
      isLoading = false;
    });
  }

  void searchNotes() {
    final query = searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        filteredNotes = notes;
      } else {
        filteredNotes = notes.where((note) {
          return note.title.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> addNote() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditNoteScreen(),
      ),
    );

    await loadNotes();
  }

  Future<void> editNote(NoteModel note) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditNoteScreen(note: note),
      ),
    );

    await loadNotes();
  }

  Future<void> deleteNote(NoteModel note) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Note'),
          content: const Text(
            'Are you sure you want to delete this note?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await NoteStorage.deleteNote(note.id);

      await loadNotes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted successfully'),
        ),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: addNote,
        icon: const Icon(Icons.add),
        label: const Text('Add Note'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // Search
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : filteredNotes.isEmpty
                  ? buildEmptyState()
                  : ListView.builder(
                itemCount: filteredNotes.length,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];

                  return buildNoteCard(note);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    final bool isSearching =
        searchController.text.trim().isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching
                ? Icons.search_off
                : Icons.note_alt_outlined,
            size: 70,
            color: Colors.grey,
          ),

          const SizedBox(height: 16),

          Text(
            isSearching
                ? 'No notes found'
                : 'No notes yet',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            isSearching
                ? 'Try another title'
                : 'Create your first note',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoteCard(NoteModel note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        leading: CircleAvatar(
          child: const Icon(Icons.note),
        ),

        title: Text(
          note.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            note.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => NoteDetailsScreen(note: note),
            ),
          );
        },

        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              editNote(note);
            }

            if (value == 'delete') {
              deleteNote(note);
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 10),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 10),
                    Text('Delete'),
                  ],
                ),
              ),
            ];
          },
        ),
      ),
    );
  }
}