import 'package:flutter/foundation.dart';
import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart";
import "package:path/path.dart" show join;

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    final db = _getDatabaseOrThrow();

    //call this function to confirm the note exists
    await getNote(id: note.id);

    //returns the number of updates
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updatesCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(notes.first);
    }
  }

  //will return the number of
  Future<int> deleteAllNotews() async {
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: "id = ?",
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = "";
    const title = "";
    //No need for the note id
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      titleColumn: title,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      title: title,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    //Buscamos si existe el usuario, si la lista devuelta no es vacia, es verdad
    final results = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) {
      //es error porque no tiene sentido volverlo a crear
      throw UserAlreadyExists();
    }
    //solo pone email porque en la configuración el user tiene un id
    //que es AI (immediatamente aumentado) asi que no nos preocupamos del id
    final userId = db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    //insert returns the id
    return DatabaseUser(
      id: userId as int,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      //siginifica que buscara donde email sea igual a algo
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldnotDeleteUser();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      //si no hay una base de datos entonces se creará una
      //pero necesitamos crear las tablas
      final db = await openDatabase(dbPath);
      _db = db;

      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID = " + id.toString() + ", email = " + email;

  //covariant hace que el operador solo compare objetos de la misma clase
  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String title;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.title,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        title = map[titleColumn] as String,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Note, Id = $id, UserId = $userId, Title = $title, Text = $text, IsSyncedWithCloud = $isSyncedWithCloud";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";

const noteTable = "note";
const userTable = "user";

const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const textColumn = "text";
const titleColumn = "title";
const isSyncedWithCloudColumn = "is_synced_with_cloud";

const createUserTable = """
          CREATE TABLE IF NOT EXISTS"user" (
            "id"	INTEGER NOT NULL,
            "email"	TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id" AUTOINCREMENT)
          );
          """;

const createNoteTable = """
        CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
        "title"	TEXT NOT NULL,
        PRIMARY KEY("id" AUTOINCREMENT),
        FOREIGN KEY("user_id") REFERENCES "user"("id")
        );
      """;
