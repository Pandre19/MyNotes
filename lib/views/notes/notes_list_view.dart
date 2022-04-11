import 'package:flutter/material.dart';

import '../../services/crud/notes_service.dart';
import '../../utilities/dialogs/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;

  const NotesListView({
    Key? key,
    required this.notes,
    required this.onDeleteNote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: ListView.separated(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(
                color: Colors.black,
              ),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(10),
              title: Text(
                note.title.isEmpty ? "-NO TITLE-" : note.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: note.title.isEmpty
                      ? Color.fromARGB(255, 111, 128, 143)
                      : Color.fromARGB(255, 59, 149, 185),
                ),
              ),
              subtitle: Text(
                note.text,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 2,
              ),
              trailing: IconButton(
                onPressed: () async {
                  final shouldDelete = await showDeleteDialog(context);
                  if (shouldDelete) {
                    onDeleteNote(note);
                  }
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 15);
        },
      ),
    );
  }
}
