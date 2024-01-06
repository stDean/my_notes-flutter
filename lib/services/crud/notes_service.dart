import 'package:flutter/foundation.dart';
import 'package:my_motes/services/crud/crud_constants.dart';
import 'package:my_motes/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class NoteService {
  Database? _db;

  Database _getDbOrThrow() {
    final db = _db;
    if (db == null) {
      throw DbIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DbAlreadyOpenException();
    }

    try {
      // connect to db
      final docsPath = await getApplicationCacheDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

      // create users table
      await db.execute(createUserTable);

      // create notes table
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DbIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

  // CRUD OPERATION FOR USERS
  Future<void> deleteUser({required String email}) async {
    final db = _getDbOrThrow();

    final deletedCount = await db.delete(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDbOrThrow();
    final results = await db.query(
      usersTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (results.isNotEmpty) throw UserAlreadyExistException();

    final userId = await db.insert(
      usersTable,
      {emailColumn: email.toLowerCase()},
    );

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDbOrThrow();
    final res = await db.query(
      usersTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (res.isEmpty) {
      throw CouldNotFindUserException();
    } else {
      return DatabaseUser.fromRow(res.first);
    }
  }

  // CRUD OPERATION FOR NOTES
  Future<DatabaseNote> createNote({
    required DatabaseUser owner,
    // required String text,
  }) async {
    final db = _getDbOrThrow();

    final dbUser = await getUser(email: owner.email);
    // make sure owner exists in db with correct id
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }

    const text = '';
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    return DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDbOrThrow();
    final delCount = await db.delete(
      notesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (delCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDbOrThrow();
    return await db.delete(notesTable);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDbOrThrow();
    final res = await db.query(
      notesTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (res.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      return DatabaseNote.fromRow(res.first);
    }
  }

  Future<Iterable<DatabaseNote>> getNotes() async {
    final db = _getDbOrThrow();
    final res = await db.query(notesTable);

    return res.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDbOrThrow();

    await getNote(id: note.id);

    final updateCount = await db.update(
      notesTable,
      {textColumn: text, isSyncedWithCloudColumn: 0},
    );
    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      return await getNote(id: note.id);
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
  String toString() => 'Person => ID: $id, EMAIL: $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Notes => ID: $id, USER_ID: $userId, IS_SYNCED_WITH_CLOUD: $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}
